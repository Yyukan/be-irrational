import SwiftUI

/// The 2011 look, kept: a wooden desk with a spiral notepad on it.
enum Theme {
    static let ink = Color(red: 0.16, green: 0.12, blue: 0.09)
    static let brown = Color(red: 0.56, green: 0.30, blue: 0.13)
    static let paper = Color(red: 1.0, green: 0.995, blue: 0.975)
    static let dotOff = Color(red: 0.80, green: 0.78, blue: 0.80)
}

/// The wood tile from the 2011 app, repeated rather than stretched.
struct WoodBackground: View {
    var body: some View {
        Image("Wood")
            .resizable(resizingMode: .tile)
            .ignoresSafeArea()
    }
}

/// A sheet of paper with the spiral binding along its top edge.
struct Notepad<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            Image("Spiral")
                .resizable(resizingMode: .tile)
                .frame(height: 15)
                .accessibilityHidden(true)
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.paper)
        }
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 14, bottomTrailingRadius: 14))
        .shadow(color: .black.opacity(0.25), radius: 6, y: 2)
        .padding(.horizontal, 10)
    }
}

/// A screen of the app: wood behind, the notepad in front, a clear navigation bar.
struct DeskPage<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            WoodBackground()
            Notepad { content }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

/// The ring of twelve dots the 2011 app drew for progress, with a small figure in the middle.
struct DotsRing: View {
    /// 0...1
    let fraction: Double
    let label: String
    var size: CGFloat = 42

    var body: some View {
        let lit = Int((min(max(fraction, 0), 1) * 12).rounded())
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                Circle()
                    .fill(index < lit ? Theme.ink : Theme.dotOff)
                    .frame(width: size * 0.17, height: size * 0.17)
                    .offset(y: -size * 0.415)
                    .rotationEffect(.degrees(Double(index) * 30))
            }
            Text(label)
                .font(.system(size: size * 0.25, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(width: size * 0.64)
                .foregroundStyle(Theme.ink)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

#Preview {
    HStack {
        DotsRing(fraction: 0, label: "0%")
        DotsRing(fraction: 0.4, label: "40%")
        DotsRing(fraction: 1, label: "100%")
        DotsRing(fraction: 0.7, label: "7")
    }
    .padding()
}
