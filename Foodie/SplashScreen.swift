import SwiftUI

struct SplashView: View {
    @State private var floating = false
    @State private var showText = false
    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            Color.ink.ignoresSafeArea()

            RadialGradient(
                colors: [.coral, Color(hex: 0x8A2A1A), .clear],
                center: UnitPoint(x: 0.5, y: 0.42),
                startRadius: 0,
                endRadius: 330
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    PulseRing(delay: 0)
                    PulseRing(delay: 0.9)
                    LogoView(size: 120)
                        .offset(y: floating ? -10 : 0)
                        .rotationEffect(.degrees(floating ? 2 : -2))
                }
                .frame(width: 120, height: 120)

                Text("Foodie App(2.0)")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .opacity(showText ? 1 : 0)
                    .offset(y: showText ? 0 : 26)

                Text("Hot food. Right on time.")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: 0xFFD9CF))
                    .opacity(showText ? 1 : 0)
                    .offset(y: showText ? 0 : 26)
                    .animation(.easeOut(duration: 0.7).delay(0.2), value: showText)
            }

            VStack {
                Spacer()
                GeometryReader { geo in
                    Capsule()
                        .fill(.white.opacity(0.15))
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(Color.lime)
                                .frame(width: geo.size.width * progress)
                        }
                }
                .frame(height: 5)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                floating = true
            }
            withAnimation(.easeOut(duration: 0.7).delay(0.3)) {
                showText = true
            }
            withAnimation(.easeOut(duration: 5)) {
                progress = 1
            }
        }
    }
}
                struct SplashView_Previews: PreviewProvider {
                    static var previews:  some View{
                        SplashView()
                            .previewDevice("iphone 14pro")
                    }
                }
