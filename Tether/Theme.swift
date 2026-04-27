import SwiftUI
import UIKit

enum Theme {
    static let pink     = Color(red: 0.961, green: 0.412, blue: 0.604)
    static let pinkDeep = Color(red: 0.851, green: 0.255, blue: 0.471)
    static let pinkSoft = Color(red: 1.000, green: 0.910, blue: 0.945)
    static let pinkTint = Color(red: 0.996, green: 0.949, blue: 0.969)
    static let textOnPink = Color.white

    static let cardCorner: CGFloat = 18
    static let buttonCorner: CGFloat = 14

    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 1.0,   green: 0.949, blue: 0.969),
            Color(red: 1.0,   green: 0.875, blue: 0.918),
            Color(red: 0.996, green: 0.808, blue: 0.882)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let buttonGradient = LinearGradient(
        colors: [pink, pinkDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// Reusable avatar bubble showing the first letter of an email.
// Each email gets a stable, solid pastel color (no gradient).
struct AvatarView: View {
    let email: String
    var size: CGFloat = 36

    // Curated set of solid colors used for default profile avatars.
    private static let palette: [Color] = [
        Color(red: 0.96, green: 0.41, blue: 0.60), // pink
        Color(red: 0.55, green: 0.36, blue: 0.96), // purple
        Color(red: 0.27, green: 0.61, blue: 0.96), // blue
        Color(red: 0.18, green: 0.78, blue: 0.65), // teal
        Color(red: 0.96, green: 0.62, blue: 0.27), // orange
        Color(red: 0.95, green: 0.78, blue: 0.20), // amber
        Color(red: 0.40, green: 0.78, blue: 0.39), // green
        Color(red: 0.93, green: 0.36, blue: 0.40), // red
        Color(red: 0.40, green: 0.49, blue: 0.59), // slate
        Color(red: 0.78, green: 0.42, blue: 0.85)  // magenta
    ]

    private var initial: String {
        String(email.prefix(1)).uppercased()
    }

    private var solidColor: Color {
        let sum = email.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return Self.palette[sum % Self.palette.count]
    }

    var body: some View {
        ZStack {
            solidColor
            Text(initial)
                .font(.system(size: size * 0.45, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 1))
        .shadow(color: .black.opacity(0.10), radius: 3, y: 1)
    }
}

// Standard pink "primary" button look used across the app.
struct PrimaryPinkButtonStyle: ButtonStyle {
    var loading: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Theme.buttonGradient, in: RoundedRectangle(cornerRadius: Theme.buttonCorner))
            .foregroundStyle(.white)
            .font(.body.weight(.semibold))
            .shadow(color: Theme.pink.opacity(0.35), radius: 8, y: 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// Soft glassy card container used for post rows etc.
struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.cardCorner))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCorner)
                    .stroke(Theme.pink.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: Theme.pink.opacity(0.10), radius: 10, y: 4)
    }
}

extension View {
    func tetherCard() -> some View { modifier(CardBackground()) }
}

// Pink-themed text-field background.
struct PinkFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(Color.white.opacity(0.85), in: RoundedRectangle(cornerRadius: Theme.buttonCorner))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.buttonCorner)
                    .stroke(Theme.pink.opacity(0.25), lineWidth: 1)
            )
    }
}

extension View {
    func pinkField() -> some View { modifier(PinkFieldStyle()) }
}

// Keyboard dismissal helpers.
extension View {
    /// Tap anywhere on this view to dismiss the keyboard.
    func dismissKeyboardOnTap() -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        )
    }
}

func hideKeyboard() {
    UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil, from: nil, for: nil
    )
}
