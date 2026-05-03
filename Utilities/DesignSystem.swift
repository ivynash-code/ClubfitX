import SwiftUI

// MARK: - Color Extensions
extension Color {
    static let bg           = Color("BG")
    static let bgCard       = Color("BGCard")
    static let bgCard2      = Color("BGCard2")
    static let accentPurple = Color("AccentPurple")
    static let accentGreen  = Color("AccentGreen")
    static let accentOrange = Color("AccentOrange")
    static let accentRed    = Color("AccentRed")
    static let accentTeal   = Color("AccentTeal")
    static let brand        = Color("AccentPurple")   // The 99 Percent Club brand color
    static let textPrimary  = Color.white
    static let textSecondary = Color(white: 0.62)
    static let textTertiary  = Color(white: 0.40)
}

// MARK: - Card
struct CardView<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.07), lineWidth: 0.5))
    }
}

// MARK: - Progress Ring
struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let color: Color
    let size: CGFloat
    var body: some View {
        ZStack {
            Circle().stroke(color.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6), value: progress)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let label: String
    let value: String
    let unit: String
    let color: Color
    var progress: Double? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold)).foregroundColor(.textTertiary).kerning(0.5)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .heavy, design: .rounded)).foregroundColor(color)
                Text(unit).font(.system(size: 10, weight: .semibold)).foregroundColor(.textSecondary)
            }
            if let p = progress {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.1)).frame(height: 4)
                        Capsule().fill(color).frame(width: geo.size.width * min(p, 1.0), height: 4)
                    }
                }.frame(height: 4)
            }
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(Color.white.opacity(0.07), lineWidth: 0.5))
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    var trailing: String? = nil
    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold)).foregroundColor(.textTertiary).kerning(0.8)
            Spacer()
            if let t = trailing {
                Text(t).font(.system(size: 12, weight: .semibold)).foregroundColor(.accentPurple)
            }
        }
        .padding(.horizontal, 4).padding(.top, 8)
    }
}

// MARK: - Macro Bar
struct MacroBar: View {
    let label: String; let current: Double; let goal: Double; let color: Color
    var progress: Double { goal > 0 ? min(current / goal, 1.0) : 0 }
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text(label).font(.system(size: 13, weight: .semibold)).foregroundColor(.textSecondary)
                Spacer()
                Text("\(Int(current))g").font(.system(size: 13, weight: .bold)).foregroundColor(color)
                Text("/ \(Int(goal))g").font(.system(size: 11)).foregroundColor(.textTertiary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08)).frame(height: 6)
                    Capsule().fill(color).frame(width: geo.size.width * progress, height: 6)
                        .animation(.spring(response: 0.5), value: progress)
                }
            }.frame(height: 6)
        }
    }
}

// MARK: - Gradient Button
struct GradientButton: View {
    let title: String
    let action: () -> Void
    var icon: String? = nil
    var color1: Color = .accentPurple
    var color2: Color = Color(red:0.55, green:0.12, blue:0.85)
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon).font(.system(size: 16, weight: .semibold)) }
                Text(title).font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 15)
            .background(LinearGradient(colors: [color1, color2], startPoint: .leading, endPoint: .trailing))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

// MARK: - Input Field
struct InputField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label.uppercased()).font(.system(size: 10, weight: .bold))
                .foregroundColor(.textTertiary).kerning(0.5)
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType).font(.system(size: 15)).foregroundColor(.white)
                .padding(12).background(Color.bgCard2)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let icon: String; let message: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 48)).foregroundColor(.textTertiary)
            Text(message).font(.system(size: 15)).foregroundColor(.textSecondary).multilineTextAlignment(.center)
        }.padding(.vertical, 40)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

// MARK: - Workout Types
struct WorkoutType: Identifiable {
    let id = UUID()
    let name: String; let emoji: String; let caloriesPerMinute: Double

    static let all: [WorkoutType] = [
        WorkoutType(name: "Running",           emoji: "🏃", caloriesPerMinute: 10.0),
        WorkoutType(name: "Strength Training", emoji: "🏋️", caloriesPerMinute: 8.0),
        WorkoutType(name: "Cycling",           emoji: "🚴", caloriesPerMinute: 9.0),
        WorkoutType(name: "Yoga",              emoji: "🧘", caloriesPerMinute: 4.0),
        WorkoutType(name: "Swimming",          emoji: "🏊", caloriesPerMinute: 9.5),
        WorkoutType(name: "Walking",           emoji: "🚶", caloriesPerMinute: 4.5),
        WorkoutType(name: "HIIT",              emoji: "⚡", caloriesPerMinute: 12.0),
        WorkoutType(name: "Cricket",           emoji: "🏏", caloriesPerMinute: 6.5),
        WorkoutType(name: "Badminton",         emoji: "🏸", caloriesPerMinute: 8.0),
        WorkoutType(name: "Football",          emoji: "⚽", caloriesPerMinute: 9.0),
        WorkoutType(name: "Dance",             emoji: "💃", caloriesPerMinute: 7.5),
        WorkoutType(name: "Boxing",            emoji: "🥊", caloriesPerMinute: 11.0),
        WorkoutType(name: "Kabaddi",           emoji: "🤼", caloriesPerMinute: 8.5),
        WorkoutType(name: "Jump Rope",         emoji: "🪢", caloriesPerMinute: 12.5),
        WorkoutType(name: "Stretching",        emoji: "🤸", caloriesPerMinute: 3.0),
        WorkoutType(name: "Elliptical",        emoji: "🏃", caloriesPerMinute: 8.5),
    ]
}

// MARK: - BMI Scale Bar
struct BMIScaleBarView: View {
    let bmi: Double
    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    LinearGradient(colors: [Color("AccentTeal"), Color("AccentGreen"),
                                            Color("AccentOrange"), Color("AccentRed")],
                                   startPoint: .leading, endPoint: .trailing)
                        .frame(height: 8).clipShape(Capsule())
                    let pct = max(0, min((bmi - 15) / 25, 1))
                    Circle().fill(Color.white).frame(width: 14, height: 14)
                        .shadow(color: .black.opacity(0.3), radius: 3)
                        .offset(x: geo.size.width * pct - 7)
                        .animation(.spring(response: 0.5), value: bmi)
                }
            }.frame(height: 14)
            HStack {
                Text("15 Underweight").font(.system(size: 8)).foregroundColor(.textTertiary)
                Spacer()
                Text("25").font(.system(size: 8)).foregroundColor(.textTertiary)
                Spacer()
                Text("40 Obese").font(.system(size: 8)).foregroundColor(.textTertiary)
            }
        }
    }
}

// MARK: - Date Helpers
func formatDate(_ date: Date, style: DateFormatter.Style = .short) -> String {
    let f = DateFormatter(); f.dateStyle = style; f.timeStyle = .none
    return f.string(from: date)
}
func shortDay(_ date: Date) -> String {
    let f = DateFormatter(); f.dateFormat = "EEE"; return f.string(from: date)
}
func shortDate(_ date: Date) -> String {
    let f = DateFormatter(); f.dateFormat = "d MMM"; return f.string(from: date)
}
func timeString(_ date: Date) -> String {
    let f = DateFormatter(); f.timeStyle = .short; f.dateStyle = .none
    return f.string(from: date)
}
