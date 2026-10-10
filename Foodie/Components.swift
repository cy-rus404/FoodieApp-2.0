import SwiftUI

struct StaggerIn: ViewModifier {
    let index: Int
    let show: Bool

    func body(content: Content) -> some View {
        content
            .opacity(show ? 1 : 0)
            .offset(y: show ? 0 : 26)
            .animation(.easeOut(duration: 0.7).delay(Double(index) * 0.1), value: show)
    }
}

extension View {
    func staggerIn(_ index: Int, show: Bool) -> some View {
        modifier(StaggerIn(index: index, show: show))
    }
}

struct PressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct AppField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure = false
    var keyboard: UIKeyboardType = .default
    var highlighted = false
    @State private var reveal = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(highlighted ? .coral : .muted)
                .frame(width: 22)

            Group {
                if isSecure && !reveal {
                    SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(.muted))
                } else {
                    TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.muted))
                }
            }
            .foregroundColor(.textMain)
            .keyboardType(keyboard)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)

            if isSecure {
                Button {
                    reveal.toggle()
                } label: {
                    Image(systemName: reveal ? "eye.slash" : "eye")
                        .foregroundColor(.muted)
                }
                .accessibilityLabel(reveal ? "Hide password" : "Show password")
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Color.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(highlighted ? Color.coral : Color.stroke, lineWidth: highlighted ? 2 : 1)
        )
        .animation(.easeOut(duration: 0.2), value: highlighted)
    }
}

struct SocialButton: View {
    let title: String
    let symbol: String?

    var body: some View {
        Button {} label: {
            HStack(spacing: 8) {
                if let symbol {
                    Image(systemName: symbol)
                } else {
                    Text("G").fontWeight(.bold)
                }
                Text(title).fontWeight(.medium)
            }
            .font(.subheadline)
            .foregroundColor(.textMain)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.stroke, lineWidth: 1)
            )
        }
        .buttonStyle(PressStyle())
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 8
    var shakes: CGFloat

    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX: amount * sin(shakes * .pi * 2), y: 0)
        )
    }
}
