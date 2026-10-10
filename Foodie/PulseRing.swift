import SwiftUI

struct PulseRing: View {
    var delay: Double
    @State private var animate = false

    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .stroke(Color.lime, lineWidth: 2)
            .scaleEffect(animate ? 1.9 : 0.9)
            .opacity(animate ? 0 : 0.7)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 2.2)
                        .repeatForever(autoreverses: false)
                        .delay(delay)
                ) {
                    animate = true
                }
            }
    }
}
