import SwiftUI

struct LoginView: View {
    var onLogin: () -> Void = {}

    enum Field { case email, password }

    @State private var email = ""
    @State private var password = ""
    @State private var appeared = false
    @State private var loading = false
    @FocusState private var focus: Field?

    private var canSubmit: Bool {
        email.contains("@") && password.count >= 6
    }

    var body: some View {
        ZStack {
            Color.paper
                .ignoresSafeArea()
                .onTapGesture { focus = nil }

            RadialGradient(
                colors: [Color.coral.opacity(0.28), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 380
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    LogoView(size: 56)
                        .padding(.bottom, 8)
                        .staggerIn(0, show: appeared)

                   VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome back")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.textMain)
                        Text("Sign in to order your favourites")
                            .font(.subheadline)
                            .foregroundColor(.muted)
                    }
                    .staggerIn(1, show: appeared)

                    VStack(spacing: 12) {
                        AppField(
                            icon: "envelope",
                            placeholder: "Email address",
                            text: $email,
                            keyboard: .emailAddress,
                            highlighted: focus == .email
                        )
                        .focused($focus, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focus = .password }

                        AppField(
                            icon: "lock",
                            placeholder: "Password",
                            text: $password,
                            isSecure: true,
                            highlighted: focus == .password
                        )
                        .focused($focus, equals: .password)
                        .submitLabel(.go)
                        .onSubmit { if canSubmit { signIn() } }
                    }
                    .padding(.top, 12)
                    .staggerIn(2, show: appeared)

                    HStack {
                        Spacer()
                        Button("Forgot password?") {}
                            .font(.footnote)
                            .foregroundColor(Color(hex: 0xFF8A6E))
                    }
                    .staggerIn(3, show: appeared)

                    Button(action: signIn) {
                        ZStack {
                            if loading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Sign in")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.coral)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(PressStyle())
                    .opacity(canSubmit ? 1 : 0.5)
                    .disabled(!canSubmit || loading)
                    .staggerIn(4, show: appeared)

                    HStack(spacing: 12) {
                        Rectangle().fill(Color.stroke).frame(height: 1)
                        Text("or continue with")
                            .font(.footnote)
                            .foregroundColor(.muted)
                            .fixedSize()
                        Rectangle().fill(Color.stroke).frame(height: 1)
                    }
                    .padding(.vertical, 4)
                    .staggerIn(5, show: appeared)

                    HStack(spacing: 12) {
                        SocialButton(title: "Apple", symbol: "applelogo")
                        SocialButton(title: "Google", symbol: nil)
                    }
                    .staggerIn(6, show: appeared)

                    HStack(spacing: 6) {
                        Text("New here?").foregroundColor(.muted)
                        Button("Create account") {}
                            .fontWeight(.semibold)
                            .foregroundColor(.coral)
                    }
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                    .staggerIn(7, show: appeared)
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .padding(.bottom, 24)
            }
        }
        .onAppear { appeared = true }
    }

    private func signIn() {
        focus = nil
        loading = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            loading = false
            onLogin()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewDevice("iPhone 14")
    }
}
