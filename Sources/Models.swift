import SwiftUI

// MARK: - Βασικοί τύποι

enum EngineType: String, CaseIterable, Identifiable {
    case naPetrol, turboPetrol, turboDiesel
    var id: String { rawValue }

    var title: String {
        switch self {
        case .naPetrol: "Ατμοσφαιρικός"
        case .turboPetrol: "Turbo βενζίνη"
        case .turboDiesel: "Turbo diesel"
        }
    }
    var icon: String {
        switch self {
        case .naPetrol: "wind"
        case .turboPetrol: "tornado"
        case .turboDiesel: "fuelpump.fill"
        }
    }
    /// Όριο συνολικής αύξησης ισχύος πριν χρειαστούν ενισχυμένα εσωτερικά κινητήρα
    var internalsLimit: Double {
        switch self {
        case .naPetrol: 0.45
        case .turboPetrol: 0.70
        case .turboDiesel: 0.50
        }
    }
}

enum Risk: Int, Comparable {
    case low, medium, high
    static func < (a: Risk, b: Risk) -> Bool { a.rawValue < b.rawValue }

    var title: String {
        switch self {
        case .low: "Χαμηλό ρίσκο"
        case .medium: "Μέτριο ρίσκο"
        case .high: "Υψηλό ρίσκο"
        }
    }
    var color: Color {
        switch self {
        case .low: .green
        case .medium: .yellow
        case .high: .red
        }
    }
}

struct Shop: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let url: String
}

enum Shops {
    static let apr = Shop(name: "APR", url: "https://www.goapr.com")
    static let cobb = Shop(name: "COBB", url: "https://www.cobbtuning.com")
    static let unitronic = Shop(name: "Unitronic", url: "https://www.getunitronic.com")
    static let burger = Shop(name: "Burger Motorsports", url: "https://burgertuning.com")
    static let forge = Shop(name: "Forge Motorsport", url: "https://www.forgemotorsport.com")
    static let eventuri = Shop(name: "Eventuri", url: "https://www.eventuri.com")
    static let bmc = Shop(name: "BMC", url: "https://www.bmcairfilters.com")
    static let milltek = Shop(name: "Milltek Sport", url: "https://www.millteksport.com")
    static let akrapovic = Shop(name: "Akrapovič", url: "https://www.akrapovic.com")
    static let remus = Shop(name: "Remus", url: "https://www.remus.eu")
    static let wagner = Shop(name: "Wagner Tuning", url: "https://www.wagnertuning.com")
    static let mishimoto = Shop(name: "Mishimoto", url: "https://www.mishimoto.com")
    static let pureTurbos = Shop(name: "Pure Turbos", url: "https://www.pureturbos.com")
    static let garrett = Shop(name: "Garrett", url: "https://www.garrettmotion.com")
    static let injDynamics = Shop(name: "Injector Dynamics", url: "https://www.injectordynamics.com")
    static let kelford = Shop(name: "Kelford Cams", url: "https://www.kelfordcams.com")
    static let rotrex = Shop(name: "Rotrex", url: "https://www.rotrex.com")
    static let edelbrock = Shop(name: "Edelbrock", url: "https://www.edelbrock.com")
    static let sachs = Shop(name: "Sachs Performance", url: "https://www.sachsperformance.com")
    static let exedy = Shop(name: "Exedy", url: "https://www.exedy.com")
    static let brembo = Shop(name: "Brembo", url: "https://www.brembo.com")
    static let ebc = Shop(name: "EBC Brakes", url: "https://www.ebcbrakes.com")
    static let cpCarrillo = Shop(name: "CP-Carrillo", url: "https://www.cp-carrillo.com")
    static let manley = Shop(name: "Manley", url: "https://www.manleyperformance.com")
    static let autodoc = Shop(name: "Autodoc.gr", url: "https://www.autodoc.gr")
    static let ecs = Shop(name: "ECS Tuning", url: "https://www.ecstuning.com")
}

struct Upgrade: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let detail: String
    let gain: Double              // κέρδος ως ποσοστό της αρχικής ισχύος (0.18 = +18%)
    let minCost: Int
    let maxCost: Int
    let risk: Risk
    let riskNote: String
    let engines: Set<EngineType>
    let shops: [Shop]
    var emissions = false         // επηρεάζει ΚΤΕΟ / εκπομπές
    var isRemap = false           // επηρεάζει εγγύηση

    var efficiency: Double { gain / Double(minCost + maxCost) * 2 }
}

// MARK: - Κατάλογος αναβαθμίσεων (ενδεικτικές τιμές σε €)

enum Catalog {
    static let upgrades: [Upgrade] = [
        // ---- TURBO ΒΕΝΖΙΝΗ ----
        Upgrade(name: "ECU Remap (Stage 1)", icon: "cpu",
                detail: "Αναπρογραμματισμός εγκεφάλου: πίεση turbo, ποσότητα καυσίμου, avance.",
                gain: 0.18, minCost: 350, maxCost: 800, risk: .medium,
                riskNote: "Ακυρώνει εγγύηση κατασκευαστή. Κακό tune μπορεί να προκαλέσει knock και ζημιά σε έμβολα/μπιέλες.",
                engines: [.turboPetrol], shops: [Shops.apr, Shops.cobb, Shops.unitronic, Shops.burger], isRemap: true),
        Upgrade(name: "Intake υψηλής ροής", icon: "wind",
                detail: "Φίλτρο/κιτ εισαγωγής αέρα με μικρότερη αντίσταση ροής.",
                gain: 0.03, minCost: 150, maxCost: 500, risk: .low,
                riskNote: "Ελάχιστο ρίσκο. Φθηνά φίλτρα μπορεί να μην φιλτράρουν σωστά και να βλάψουν τον MAF.",
                engines: [.turboPetrol, .turboDiesel, .naPetrol], shops: [Shops.forge, Shops.eventuri, Shops.bmc, Shops.autodoc]),
        Upgrade(name: "Cat-back εξάτμιση", icon: "speaker.wave.3.fill",
                detail: "Σπορ εξάτμιση από τον καταλύτη και πίσω, λιγότερη αντίθλιψη.",
                gain: 0.02, minCost: 400, maxCost: 1400, risk: .low,
                riskNote: "Αυξημένος θόρυβος· έλεγξε τα όρια decibel για το ΚΤΕΟ.",
                engines: [.turboPetrol, .naPetrol, .turboDiesel], shops: [Shops.milltek, Shops.akrapovic, Shops.remus]),
        Upgrade(name: "Downpipe (αθλητικός καταλύτης)", icon: "arrow.down.right.circle",
                detail: "Αντικατάσταση του downpipe για ταχύτερο spool και περισσότερη ροή.",
                gain: 0.08, minCost: 450, maxCost: 1200, risk: .high,
                riskNote: "Έκδοση χωρίς καταλύτη είναι παράνομη για δρόμο και απορρίπτεται στο ΚΤΕΟ. Επιλέγε μόνο homologated / sport-cat.",
                engines: [.turboPetrol, .turboDiesel], shops: [Shops.milltek, Shops.wagner, Shops.ecs], emissions: true),
        Upgrade(name: "Intercooler μεγαλύτερος", icon: "snowflake",
                detail: "Χαμηλότερες θερμοκρασίες αέρα εισαγωγής = σταθερή ισχύς.",
                gain: 0.06, minCost: 500, maxCost: 1500, risk: .low,
                riskNote: "Πιθανά θέματα τοποθέτησης/προφυλακτήρα. Κόστος εργασίας εξαρτάται από το μοντέλο.",
                engines: [.turboPetrol, .turboDiesel], shops: [Shops.wagner, Shops.forge, Shops.mishimoto]),
        Upgrade(name: "Injectors + αντλία καυσίμου", icon: "drop.fill",
                detail: "Περισσότερη παροχή καυσίμου για υψηλά boost.",
                gain: 0.10, minCost: 800, maxCost: 2800, risk: .medium,
                riskNote: "Λάθος μέγεθος injectors οδηγεί σε φτωχό μείγμα και λιωμένα έμβολα. Απαιτεί dyno tune.",
                engines: [.turboPetrol, .turboDiesel], shops: [Shops.injDynamics, Shops.ecs, Shops.burger]),
        Upgrade(name: "Αναβαθμισμένο / hybrid turbo", icon: "tornado",
                detail: "Μεγαλύτερος στροβιλοσυμπιεστής για ισχύ Stage 3.",
                gain: 0.22, minCost: 1800, maxCost: 5000, risk: .high,
                riskNote: "Κινδύνος για στάνταρ εσωτερικά, σπάσιμο συμπλέκτη/κιβωτίου, πολύ υψηλές θερμοκρασίες καυσαερίων.",
                engines: [.turboPetrol, .turboDiesel], shops: [Shops.pureTurbos, Shops.garrett, Shops.ecs]),

        // ---- DIESEL ----
        Upgrade(name: "ECU Remap diesel", icon: "cpu",
                detail: "Αύξηση πίεσης turbo και διάρκειας έγχυσης.",
                gain: 0.20, minCost: 300, maxCost: 650, risk: .medium,
                riskNote: "Εγγύηση, καταπόνηση DPF/EGR και σφονδύλου διπλής μάζας· μην αφαιρείς DPF (παράνομο).",
                engines: [.turboDiesel], shops: [Shops.unitronic, Shops.apr, Shops.autodoc], isRemap: true),

        // ---- ΑΤΜΟΣΦΑΙΡΙΚΟΣ ----
        Upgrade(name: "ECU dyno tune (NA)", icon: "cpu",
                detail: "Βελτιστοποίηση avance και μείγματος μετά από τις μηχανικές αλλαγές.",
                gain: 0.05, minCost: 400, maxCost: 900, risk: .low,
                riskNote: "Μικρό ρίσκο αν γίνει σε πραγματικό δυναμόμετρο από έμπειρο tuner.",
                engines: [.naPetrol], shops: [Shops.cobb, Shops.burger], isRemap: true),
        Upgrade(name: "Headers / εξαγωγή", icon: "arrow.triangle.merge",
                detail: "Συλλέκτης εξαγωγής με ελεύθερη ροή.",
                gain: 0.05, minCost: 600, maxCost: 1800, risk: .medium,
                riskNote: "Συχνά χωρίς έγκριση τύπου → πρόβλημα στο ΚΤΕΟ και αυξημένο θόρυβο.",
                engines: [.naPetrol], shops: [Shops.akrapovic, Shops.milltek, Shops.ecs], emissions: true),
        Upgrade(name: "Σπορ εκκεντροφόροι", icon: "gearshape.2.fill",
                detail: "Πιο επιθετικό προφίλ βαλβίδων για ισχύ στα υψηλά.",
                gain: 0.08, minCost: 1200, maxCost: 3200, risk: .high,
                riskNote: "Ανοίγεις κινητήρα· λάθος ρύθμιση = επαφή βαλβίδων με έμβολα. Χειρότερο ρελαντί και χαμηλά.",
                engines: [.naPetrol], shops: [Shops.kelford, Shops.ecs]),
        Upgrade(name: "Σπορ throttle bodies (ITB)", icon: "circle.grid.3x3.fill",
                detail: "Ανεξάρτητα πεταλούδες ανά κύλινδρο για άμεση ανταπόκριση.",
                gain: 0.05, minCost: 2000, maxCost: 5500, risk: .medium,
                riskNote: "Δύσκολη ρύθμιση, σκληρή οδήγηση στην πόλη, απαιτεί standalone ECU.",
                engines: [.naPetrol], shops: [Shops.ecs]),
        Upgrade(name: "Κιτ compressor (supercharger)", icon: "bolt.circle.fill",
                detail: "Η μεγαλύτερη αύξηση για ατμοσφαιρικό χωρίς ριζικό άνοιγμα κινητήρα.",
                gain: 0.40, minCost: 5000, maxCost: 9500, risk: .high,
                riskNote: "Αυξάνει σημαντικά θερμικό φορτίο και καταπόνηση. Συχνά χρειάζονται εσωτερικά, καύσιμο 98+, ψύξη.",
                engines: [.naPetrol], shops: [Shops.rotrex, Shops.edelbrock]),
        Upgrade(name: "Κιτ turbo για NA", icon: "tornado",
                detail: "Μετατροπή σε turbo για μεγάλες αυξήσεις ισχύος.",
                gain: 0.60, minCost: 6500, maxCost: 13000, risk: .high,
                riskNote: "Πολύ υψηλό κόστος και πολυπλοκότητα. Πρέπει σχεδόν πάντα να χαμηλώσει η συμπίεση / να ενισχυθούν εσωτερικά.",
                engines: [.naPetrol], shops: [Shops.garrett, Shops.pureTurbos, Shops.ecs]),
    ]

    // Υποστηρικτικά (δεν δίνουν ίππους, αλλά είναι απαραίτητα)
    static let dyno = Upgrade(name: "Δυναμόμετρο / επαγγελματικό tune", icon: "gauge.with.dots.needle.67percent",
        detail: "Ρύθμιση σε δυναμόμετρο ώστε να είναι ασφαλές το μείγμα και το avance.",
        gain: 0, minCost: 300, maxCost: 800, risk: .low,
        riskNote: "Μην το παραλείψεις. Είναι η πιο φτηνή ασφάλεια για τον κινητήρα.",
        engines: [], shops: [])

    static let clutch = Upgrade(name: "Ενισχυμένος συμπλέκτης", icon: "circle.dashed",
        detail: "Ο στάνταρ συμπλέκτης συχνά γλιστράει πάνω από ~25% επιπλέον ροπή.",
        gain: 0, minCost: 700, maxCost: 2000, risk: .low,
        riskNote: "Πιο σκληρό πεντάλ. Στα diesel έλεγξε και τον σφόνδυλο διπλής μάζας.",
        engines: [], shops: [Shops.sachs, Shops.exedy, Shops.autodoc])

    static let brakes = Upgrade(name: "Φρένα (δίσκοι / τακάκια)", icon: "circle.hexagongrid.circle",
        detail: "Περισσότερη ισχύς σημαίνει πιο γρήγορες ταχύτητες και μεγαλύτερη ανάγκη φρεναρίσματος.",
        gain: 0, minCost: 400, maxCost: 2500, risk: .low,
        riskNote: "Πρακτικά ζήτημα ασφάλειας, όχι προαιρετικό σε μεγάλες αυξήσεις.",
        engines: [], shops: [Shops.brembo, Shops.ebc, Shops.autodoc])

    static let cooling = Upgrade(name: "Ψύξη (νερό / λάδι)", icon: "thermometer.snowflake",
        detail: "Ψυγείο και ψύκτρα λαδιού για σταθερές θερμοκρασίες σε πίστα ή υψηλό φορτίο.",
        gain: 0, minCost: 300, maxCost: 1200, risk: .low,
        riskNote: "Η υπερθέρμανση είναι η συχνότερη αιτία βλάβης σε tuned κινητήρες.",
        engines: [], shops: [Shops.mishimoto, Shops.wagner])

    static let internals = Upgrade(name: "Ενισχυμένα εσωτερικά κινητήρα", icon: "wrench.and.screwdriver.fill",
        detail: "Σφυρήλατα έμβολα και μπιέλες για αντοχή σε μεγάλες αυξήσεις.",
        gain: 0, minCost: 3000, maxCost: 7500, risk: .high,
        riskNote: "Πλήρες άνοιγμα κινητήρα. Χωρίς αυτά, ο κίνδυνος καταστροφικής βλάβης είναι υψηλός.",
        engines: [], shops: [Shops.cpCarrillo, Shops.manley])
}

// MARK: - Πλάνο

struct Plan {
    let currentHP: Double
    let targetHP: Double
    let engine: EngineType
    let upgrades: [Upgrade]
    let support: [Upgrade]
    let predictedHP: Double
    let reachable: Bool
    let warnings: [String]
    let overallRisk: Risk

    var all: [Upgrade] { upgrades + support }
    var totalMin: Int { all.reduce(0) { $0 + $1.minCost } }
    var totalMax: Int { all.reduce(0) { $0 + $1.maxCost } }
    func hpGain(_ u: Upgrade) -> Int { Int((currentHP * u.gain).rounded()) }
}

enum Planner {
    static func make(current: Double, target: Double, engine: EngineType) -> Plan {
        let needed = max(0, (target - current) / current)

        // Επιλογή αναβαθμίσεων με τη βέλτιστη σχέση κέρδους/κόστους μέχρι να φτάσουμε τον στόχο
        let pool = Catalog.upgrades
            .filter { $0.engines.contains(engine) }
            .sorted { $0.efficiency > $1.efficiency }

        var chosen: [Upgrade] = []
        var total = 0.0
        for u in pool {
            if total >= needed { break }
            chosen.append(u)
            total += u.gain
        }
        let reachable = total >= needed - 0.001

        // Υποστηρικτικά
        var support: [Upgrade] = []
        if !chosen.isEmpty { support.append(Catalog.dyno) }
        if total > 0.25 { support.append(Catalog.clutch) }
        if total > 0.20 { support.append(Catalog.brakes) }
        if total > 0.30 { support.append(Catalog.cooling) }
        if total > engine.internalsLimit { support.append(Catalog.internals) }

        // Προειδοποιήσεις
        var warnings: [String] = []
        if needed == 0 { warnings.append("Ο στόχος είναι ίσος ή μικρότερος από την τωρινή ισχύ. Δεν χρειάζεται αναβάθμιση.") }
        if chosen.contains(where: { $0.isRemap }) { warnings.append("Το remap ακυρώνει συνήθως την εγγύηση και μπορεί να επηρεάσει ασφάλιση/μεταπώληση.") }
        if chosen.contains(where: { $0.emissions }) { warnings.append("Κάποιες αλλαγές επηρεάζουν εκπομπές/θόρυβο και μπορεί να μην περάσουν ΚΤΕΟ ή έλεγχο καυσαερίων.") }
        if total > 0.30 { warnings.append("Σε μεγάλες αυξήσεις χρησιμοποίησε καύσιμο 98+ οκτανίων και κάνε πιο συχνό service (λάδι, μπουζί, φίλτρα).") }
        if total > engine.internalsLimit { warnings.append("Ο στόχος ξεπερνά το συνηθισμένο όριο των στάνταρ εσωτερικών· υπάρχει υψηλός κίνδυνος καταστροφικής βλάβης.") }
        if !reachable && needed > 0 { warnings.append("Ο στόχος δεν φτάνει με τον κατάλογο αναβαθμίσεων για αυτόν τον κινητήρα. Θα χρειαστεί ριζική μετατροπή ή αλλαγή κινητήρα.") }

        // Συνολικό ρίσκο
        let risk: Risk
        if total > 0.50 || (total > 0.35 && chosen.contains { $0.risk == .high }) { risk = .high }
        else if total > 0.20 || chosen.contains(where: { $0.risk == .high }) { risk = .medium }
        else { risk = .low }

        return Plan(currentHP: current, targetHP: target, engine: engine,
                    upgrades: chosen, support: support,
                    predictedHP: current * (1 + total),
                    reachable: reachable, warnings: warnings, overallRisk: risk)
    }
}

func eur(_ v: Int) -> String {
    v.formatted(.currency(code: "EUR").precision(.fractionLength(0)))
}
