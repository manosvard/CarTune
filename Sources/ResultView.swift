import SwiftUI

struct ResultView: View {
    let plan: Plan
    let carName: String

    var body: some View {
        ZStack {
            AuroraBackground()
            ScrollView {
                VStack(spacing: 16) {
                    summary
                    NavigationLink {
                        AIView(carName: carName, plan: plan)
                    } label: {
                        Label("Live AI ανάλυση με internet", systemImage: "sparkles")
                            .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 8)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.purple)
                    if !plan.warnings.isEmpty { warnings }
                    if !plan.upgrades.isEmpty {
                        sectionTitle("Αναβαθμίσεις ισχύος", "bolt.fill")
                        ForEach(plan.upgrades) { UpgradeCard(plan: plan, upgrade: $0) }
                    }
                    if !plan.support.isEmpty {
                        sectionTitle("Απαραίτητα υποστηρικτικά", "shield.lefthalf.filled")
                        ForEach(plan.support) { UpgradeCard(plan: plan, upgrade: $0) }
                    }
                    disclaimer
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(carName.isEmpty ? "Το πλάνο σου" : carName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summary: some View {
        VStack(spacing: 18) {
            HStack(spacing: 20) {
                Gauge(value: min(plan.predictedHP, max(plan.targetHP, plan.currentHP + 1)),
                      in: plan.currentHP...max(plan.targetHP, plan.currentHP + 1)) {
                    Text("HP")
                } currentValueLabel: {
                    Text("\(Int(plan.predictedHP))")
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(.orange)
                .scaleEffect(1.7)
                .frame(width: 100, height: 100)

                VStack(alignment: .leading, spacing: 6) {
                    Text("\(Int(plan.currentHP)) → \(Int(plan.predictedHP)) HP")
                        .font(.title2.weight(.bold).monospacedDigit())
                    Text("Στόχος: \(Int(plan.targetHP)) HP")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Text(plan.engine.title)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .glassEffect(.regular, in: .capsule)
                }
                Spacer(minLength: 0)
            }

            Divider().opacity(0.3)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Συνολικό κόστος").font(.caption).foregroundStyle(.secondary)
                    Text("\(eur(plan.totalMin)) – \(eur(plan.totalMax))")
                        .font(.title3.weight(.bold).monospacedDigit())
                }
                Spacer()
                riskBadge(plan.overallRisk)
            }
        }
        .padding(20)
        .glassCard()
    }

    private var warnings: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Προσοχή", systemImage: "exclamationmark.triangle.fill")
                .font(.headline).foregroundStyle(.yellow)
            ForEach(plan.warnings, id: \.self) { w in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                    Text(w).font(.subheadline)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .glassEffect(.regular.tint(.yellow.opacity(0.18)), in: .rect(cornerRadius: 26))
    }

    private func sectionTitle(_ text: String, _ icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(.title3.weight(.bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }

    private var disclaimer: some View {
        Text("Οι τιμές και τα κέρδη ισχύος είναι ενδεικτικές εκτιμήσεις (τιμές αγοράς + εργασία) και δεν προέρχονται από ζωντανές τιμές καταστημάτων. Έλεγξε τη συμβατότητα με το ακριβές μοντέλο/κινητήρα σου, ζήτησε προσφορά από εξειδικευμένο συνεργείο και επιβεβαίωσε τη νομιμότητα στην Ελλάδα (ΚΤΕΟ, ΚΟΚ, εκπομπές).")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.top, 8)
    }
}

func riskBadge(_ risk: Risk) -> some View {
    HStack(spacing: 6) {
        Circle().fill(risk.color).frame(width: 9, height: 9)
        Text(risk.title).font(.caption.weight(.semibold))
    }
    .padding(.horizontal, 12).padding(.vertical, 7)
    .glassEffect(.regular.tint(risk.color.opacity(0.25)), in: .capsule)
}

struct UpgradeCard: View {
    let plan: Plan
    let upgrade: Upgrade
    @State private var expanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button {
                withAnimation(.snappy) { expanded.toggle() }
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: upgrade.icon)
                        .font(.title3).foregroundStyle(.orange)
                        .frame(width: 40, height: 40)
                        .glassEffect(.regular, in: .circle)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(upgrade.name).font(.headline).multilineTextAlignment(.leading)
                        Text("\(eur(upgrade.minCost)) – \(eur(upgrade.maxCost))")
                            .font(.subheadline.monospacedDigit()).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if upgrade.gain > 0 {
                        Text("+\(plan.hpGain(upgrade)) HP")
                            .font(.subheadline.weight(.bold).monospacedDigit())
                            .foregroundStyle(.green)
                    }
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold)).foregroundStyle(.secondary)
                        .rotationEffect(.degrees(expanded ? 180 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expanded {
                Text(upgrade.detail).font(.subheadline).foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    riskBadge(upgrade.risk)
                    Text(upgrade.riskNote).font(.footnote)
                }

                if upgrade.shops.isEmpty {
                    Label("Βρες εξειδικευμένο συνεργείο chiptuning/δυναμόμετρου κοντά σου", systemImage: "mappin.and.ellipse")
                        .font(.footnote).foregroundStyle(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Πού να το αγοράσεις").font(.caption).foregroundStyle(.secondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            GlassEffectContainer(spacing: 8) {
                                HStack(spacing: 8) {
                                    ForEach(upgrade.shops) { shop in
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
            }
        }
        .padding(18)
        .glassCard()
    }
}
