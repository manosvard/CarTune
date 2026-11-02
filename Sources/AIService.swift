import SwiftUI

// MARK: - Μοντέλα απάντησης AI

struct AIShop: Codable, Identifiable {
    var id = UUID()
    var name: String
    var url: String
    enum CodingKeys: String, CodingKey { case name, url }
}

struct AIUpgrade: Codable, Identifiable {
    var id = UUID()
    var name: String
    var gainHP: Double?
    var minCost: Double?
    var maxCost: Double?
    var risk: String?
    var riskNote: String?
    var details: String?
    var shops: [AIShop]?
    enum CodingKeys: String, CodingKey { case name, gainHP, minCost, maxCost, risk, riskNote, details, shops }

    var riskLevel: Risk {
        switch (risk ?? "").lowercased() {
        case "high", "υψηλό", "υψηλο": .high
        case "medium", "μέτριο", "μετριο": .medium
        default: .low
        }
    }
}

struct AIPlan: Codable {
    var summary: String
    var feasibility: String?
    var upgrades: [AIUpgrade]
    var warnings: [String]?
    var totalMin: Double?
    var totalMax: Double?
    var sources: [AIShop]?
}

enum AIError: LocalizedError {
    case noKey
    case http(Int, String)
    case empty
    case parse

    var errorDescription: String? {
        switch self {
        case .noKey: "Δεν έχεις βάλει API key. Πάτα το ⚙︎ στην αρχική οθόνη."
        case .http(let code, let msg): "Σφάλμα OpenAI (\(code)): \(msg)"
        case .empty: "Η απάντηση ήρθε κενή."
        case .parse: "Δεν κατάφερα να διαβάσω την απάντηση. Δοκίμασε ξανά."
        }
    }
}

// MARK: - Κλήση στο OpenAI (Responses API + web search)

enum AIService {
    static func advise(apiKey: String, model: String, car: String,
                       engine: EngineType, current: Int, target: Int) async throws -> AIPlan {
        guard !apiKey.trimmingCharacters(in: .whitespaces).isEmpty else { throw AIError.noKey }

        let instructions = """
        Είσαι έμπειρος μηχανικός tuning αυτοκινήτων. Χρησιμοποίησε αναζήτηση στο διαδίκτυο για να βρεις ΤΩΡΙΝΕΣ \
        πληροφορίες και τιμές (προτίμηση σε αγορά Ελλάδας/Ευρώπης, σε EUR) ειδικά για το συγκεκριμένο αυτοκίνητο και κινητήρα. \
        Βάλε μόνο προϊόντα που υπάρχουν πραγματικά και συμβατά με το μοντέλο, και μόνο URL που βρήκες πραγματικά στην αναζήτηση. \
        Αν κάτι δεν το βρήκες, πες το ρητά αντί να το επινοήσεις. Να είσαι ρεαλιστικός για ρίσκα (αντοχή κινητήρα/κιβωτίου, εγγύηση, ΚΤΕΟ).
        Απάντησε ΜΟΝΟ με ένα έγκυρο JSON αντικείμενο, χωρίς markdown και χωρίς άλλο κείμενο, στα ελληνικά, με αυτή τη μορφή:
        {"summary": string, "feasibility": string, "upgrades": [{"name": string, "gainHP": number, "minCost": number, "maxCost": number, "risk": "low"|"medium"|"high", "riskNote": string, "details": string, "shops": [{"name": string, "url": string}]}], "warnings": [string], "totalMin": number, "totalMax": number, "sources": [{"name": string, "url": string}]}
        """

        let input = """
        Αυτοκίνητο: \(car.isEmpty ? "(δεν δόθηκε, γενικός \(engine.title) κινητήρας)" : car)
        Τύπος κινητήρα: \(engine.title)
        Τωρινή ισχύς: \(current) HP
        Στόχος: \(target) HP
        Δώσε αναλυτικό πλάνο αναβαθμίσεων με κόστος, ρίσκα και καταστήματα αγοράς.
        """

        var req = URLRequest(url: URL(string: "https://api.openai.com/v1/responses")!)
        req.httpMethod = "POST"
        req.timeoutInterval = 300
        req.setValue("Bearer \(apiKey.trimmingCharacters(in: .whitespacesAndNewlines))", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "model": model,
            "instructions": instructions,
            "input": input,
            "tools": [["type": "web_search"]]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        let status = (resp as? HTTPURLResponse)?.statusCode ?? 0
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw AIError.parse }

        if status != 200 {
            let msg = ((json["error"] as? [String: Any])?["message"] as? String) ?? "άγνωστο σφάλμα"
            throw AIError.http(status, msg)
        }

        // Συλλογή του κειμένου από τα output items
        var text = ""
        for item in (json["output"] as? [[String: Any]]) ?? [] where item["type"] as? String == "message" {
            for c in (item["content"] as? [[String: Any]]) ?? [] where c["type"] as? String == "output_text" {
                text += (c["text"] as? String) ?? ""
            }
        }
        guard !text.isEmpty else { throw AIError.empty }

        guard let start = text.firstIndex(of: "{"), let end = text.lastIndex(of: "}"), start < end,
              let jsonData = String(text[start...end]).data(using: .utf8),
              let plan = try? JSONDecoder().decode(AIPlan.self, from: jsonData)
        else { throw AIError.parse }
        return plan
    }
}

// MARK: - Ρυθμίσεις

struct SettingsView: View {
    @AppStorage("openai_key") private var apiKey = ""
    @AppStorage("openai_model") private var model = "gpt-5"
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("OpenAI API key") {
                    SecureField("sk-...", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Link("Φτιάξε key στο platform.openai.com", destination: URL(string: "https://platform.openai.com/api-keys")!)
                }
                Section {
                    TextField("Μοντέλο", text: $model)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("Μοντέλο")
                } footer: {
                    Text("Βάλε οποιοδήποτε μοντέλο OpenAI που υποστηρίζει web search. Το key αποθηκεύεται μόνο στο κινητό σου.")
                }
            }
            .navigationTitle("Ρυθμίσεις")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Έτοιμο") { dismiss() } } }
        }
    }
}

// MARK: - Οθόνη AI ανάλυσης

struct AIView: View {
    let carName: String
    let plan: Plan

    @AppStorage("openai_key") private var apiKey = ""
    @AppStorage("openai_model") private var model = "gpt-5"
    @State private var result: AIPlan?
    @State private var error: String?
    @State private var loading = false

    var body: some View {
        ZStack {
            AuroraBackground()
            ScrollView {
                VStack(spacing: 16) {
                    if loading { loadingCard }
                    if let error { errorCard(error) }
                    if let r = result { content(r) }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Live AI ανάλυση")
        .navigationBarTitleDisplayMode(.inline)
        .task { if result == nil { await run() } }
    }

    private func run() async {
        loading = true; error = nil
        do {
            result = try await AIService.advise(apiKey: apiKey, model: model, car: carName,
                                                engine: plan.engine, current: Int(plan.currentHP), target: Int(plan.targetHP))
        } catch {
            self.error = error.localizedDescription
        }
        loading = false
    }

    private var loadingCard: some View {
        VStack(spacing: 14) {
            ProgressView().controlSize(.large)
            Text("Ψάχνω στο internet για το αυτοκίνητό σου…").font(.headline).multilineTextAlignment(.center)
            Text("Μπορεί να πάρει έως και 1–2 λεπτά.").font(.footnote).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity).padding(28).glassCard()
    }

    private func errorCard(_ msg: String) -> some View {
        VStack(spacing: 12) {
            Label("Κάτι πήγε στραβά", systemImage: "exclamationmark.triangle.fill").font(.headline).foregroundStyle(.yellow)
            Text(msg).font(.subheadline)
            Button("Δοκίμασε ξανά") { Task { await run() } }.buttonStyle(.glass)
        }
        .frame(maxWidth: .infinity).padding(20)
        .glassEffect(.regular.tint(.red.opacity(0.2)), in: .rect(cornerRadius: 26))
    }

    @ViewBuilder
    private func content(_ r: AIPlan) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Σύνοψη").font(.headline)
            Text(r.summary).font(.subheadline)
            if let f = r.feasibility { Text(f).font(.subheadline).foregroundStyle(.secondary) }
            if let lo = r.totalMin, let hi = r.totalMax {
                Divider().opacity(0.3)
                Text("Συνολικό κόστος: \(eur(Int(lo))) – \(eur(Int(hi)))")
                    .font(.title3.weight(.bold).monospacedDigit())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(20).glassCard()

        if let w = r.warnings, !w.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Label("Προσοχή", systemImage: "exclamationmark.triangle.fill").font(.headline).foregroundStyle(.yellow)
                ForEach(w, id: \.self) { Text("• \($0)").font(.subheadline) }
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(20)
            .glassEffect(.regular.tint(.yellow.opacity(0.18)), in: .rect(cornerRadius: 26))
        }

        ForEach(r.upgrades) { AIUpgradeCard(u: $0) }

        if let s = r.sources, !s.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Πηγές").font(.headline)
                ForEach(s) { src in
                    if let url = URL(string: src.url) {
                        Link(destination: url) { Label(src.name, systemImage: "link").font(.footnote) }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(20).glassCard()
        }

        Text("Η απάντηση παράγεται από AI με αναζήτηση στο web. Επιβεβαίωσε τιμές, συμβατότητα και νομιμότητα πριν αγοράσεις.")
            .font(.footnote).foregroundStyle(.secondary)
    }
}

struct AIUpgradeCard: View {
    let u: AIUpgrade

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(u.name).font(.headline)
                Spacer()
                if let g = u.gainHP, g > 0 {
                    Text("+\(Int(g)) HP").font(.subheadline.weight(.bold).monospacedDigit()).foregroundStyle(.green)
                }
            }
            if let lo = u.minCost, let hi = u.maxCost {
                Text("\(eur(Int(lo))) – \(eur(Int(hi)))").font(.subheadline.monospacedDigit()).foregroundStyle(.secondary)
            }
            if let d = u.details { Text(d).font(.subheadline).foregroundStyle(.secondary) }
            riskBadge(u.riskLevel)
            if let n = u.riskNote { Text(n).font(.footnote) }
            if let shops = u.shops, !shops.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    GlassEffectContainer(spacing: 8) {
                        HStack(spacing: 8) {
                            ForEach(shops) { shop in
                                if let url = URL(string: shop.url) {
                                    Link(destination: url) {
                                        Label(shop.name, systemImage: "arrow.up.right")
                                            .font(.footnote.weight(.semibold))
                                            .padding(.horizontal, 14).padding(.vertical, 9)
                                    }
                                    .glassEffect(.regular.interactive(), in: .capsule)
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .glassCard()
    }
}
