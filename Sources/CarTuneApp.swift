import SwiftUI

@main
struct CarTuneApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Κοινά στοιχεία UI

struct AuroraBackground: View {
    var body: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [[0, 0], [0.5, 0], [1, 0],
                     [0, 0.5], [0.6, 0.4], [1, 0.5],
                     [0, 1], [0.5, 1], [1, 1]],
            colors: [Color.black, Color.indigo.opacity(0.7), Color.black,
                     Color.purple.opacity(0.5), Color.blue.opacity(0.6), Color.black,
                     Color.black, Color.orange.opacity(0.5), Color.black]
        )
        .ignoresSafeArea()
    }
}

extension View {
    func glassCard(_ radius: CGFloat = 26) -> some View {
        glassEffect(.regular, in: .rect(cornerRadius: radius))
    }
}

struct HPSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(title).font(.subheadline).foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(value))")
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .foregroundStyle(tint)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: value)
                Text("HP").font(.headline).foregroundStyle(.secondary)
            }
            Slider(value: $value, in: range, step: 5).tint(tint)
        }
        .padding(20)
        .glassCard()
    }
}

// MARK: - Κεντρική οθόνη

struct ContentView: View {
    @State private var make = ""
    @State private var model = ""
    @State private var engine: EngineType = .turboPetrol
    @State private var currentHP: Double = 150
    @State private var targetHP: Double = 220
    @State private var plan: Plan?
    @State private var showResult = false

    var body: some View {
        NavigationStack {
            ZStack {
                AuroraBackground()
                ScrollView {
                    VStack(spacing: 18) {
                        header
                        carCard
                        engineCard
                        HPSlider(title: "Τωρινή ισχύς", value: $currentHP, range: 40...800, tint: .cyan)
                        HPSlider(title: "Στόχος", value: $targetHP, range: 50...1500, tint: .orange)
                        calculateButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                .scrollIndicators(.hidden)
            }
            .navigationDestination(isPresented: $showResult) {
                if let plan {
                    ResultView(plan: plan, carName: [make, model].filter { !$0.isEmpty }.joined(separator: " "))
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("CarTune")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
            Text("Πόσο θα κοστίσει να φτάσεις τους ίππους που θέλεις;")
                .font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 10)
    }

    private var carCard: some View {
        VStack(spacing: 12) {
            field("Μάρκα", text: $make, icon: "car.fill")
            Divider().opacity(0.3)
            field("Μοντέλο", text: $model, icon: "number")
        }
        .padding(20)
        .glassCard()
    }

    private func field(_ title: String, text: Binding<String>, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(.orange).frame(width: 24)
            TextField(title, text: text)
        }
    }

    private var engineCard: some View {
        GlassEffectContainer(spacing: 10) {
            HStack(spacing: 10) {
                ForEach(EngineType.allCases) { type in
                    let selected = engine == type
                    Button {
                        withAnimation(.snappy) { engine = type }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: type.icon).font(.title2)
                            Text(type.title).font(.caption.weight(.semibold)).multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, minHeight: 78)
                        .foregroundStyle(selected ? Color.white : Color.secondary)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(selected ? .regular.tint(.orange.opacity(0.55)).interactive() : .regular.interactive(),
                                 in: .rect(cornerRadius: 22))
                }
            }
        }
    }

    private var calculateButton: some View {
        Button {
            plan = Planner.make(current: currentHP, target: targetHP, engine: engine)
            showResult = true
        } label: {
            Label("Υπολόγισε το πλάνο", systemImage: "bolt.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(.glassProminent)
        .tint(.orange)
        .controlSize(.large)
        .padding(.top, 6)
    }
}

#Preview { ContentView() }
