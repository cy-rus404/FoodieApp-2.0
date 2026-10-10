import SwiftUI

struct CutleryShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = rect.width / 100
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * s, y: rect.minY + y * s)
        }
        var p = Path()

        for x in [28.0, 36.0, 44.0] {
            p.move(to: pt(x, 26))
            p.addLine(to: pt(x, 42))
        }
        p.move(to: pt(28, 42))
        p.addQuadCurve(to: pt(44, 42), control: pt(36, 52))

        p.move(to: pt(36, 48))
        p.addLine(to: pt(36, 74))

        p.move(to: pt(64, 44))
        p.addLine(to: pt(64, 74))

        return p
    }
}

struct LogoView: View {
    var size: CGFloat = 120

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.23, style: .continuous)
                .fill(Color.coral)

            Circle()
                .fill(.white)
                .frame(width: size * 0.58, height: size * 0.58)

            Circle()
                .fill(Color.blush)
                .frame(width: size * 0.4, height: size * 0.4)

            CutleryShape()
                .stroke(Color.coral, style: StrokeStyle(lineWidth: size * 0.02, lineCap: .round))
                .frame(width: size * 0.5, height: size * 0.5)

            Ellipse()
                .fill(Color.coral)
                .frame(width: size * 0.08, height: size * 0.11)
                .offset(x: size * 0.07, y: -size * 0.08)

            Circle()
                .fill(Color.lime)
                .frame(width: size * 0.07, height: size * 0.07)
                .offset(x: size * 0.25, y: -size * 0.24)
        }
        .frame(width: size, height: size)
        .shadow(color: .black.opacity(0.35), radius: size * 0.12, y: size * 0.1)
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView(size: 200)
            .padding(40).background(Color.ink).previewLayout(.sizeThatFits)
    }
}
