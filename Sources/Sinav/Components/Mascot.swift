import SwiftUI

/// Şirin ZoB mascot — küçük gülen yüzlü turuncu kare.
/// Açılışta hafif zıplar, dokunduğunda neşelenir.
struct ZobMascot: View {
    var size: CGFloat = 96
    var animate: Bool = true

    @State private var bounce = false
    @State private var blink = false
    @State private var sparkles = false

    var body: some View {
        ZStack {
            // Squircle face
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.78, blue: 0.60),
                            Color(red: 1.0, green: 0.55, blue: 0.26),
                            Color(red: 0.92, green: 0.42, blue: 0.13)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    // Inner shine
                    RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(0.45), .white.opacity(0)],
                                center: UnitPoint(x: 0.25, y: 0.2),
                                startRadius: 0, endRadius: size * 0.7
                            )
                        )
                )
                .shadow(color: Color(red: 1.0, green: 0.55, blue: 0.26).opacity(0.45), radius: 18, x: 0, y: 8)

            // Eyes
            HStack(spacing: size * 0.18) {
                eye()
                eye()
            }
            .offset(y: -size * 0.06)

            // Blush cheeks
            HStack(spacing: size * 0.46) {
                Circle().fill(Color(red: 1.0, green: 0.42, blue: 0.42).opacity(0.55))
                    .frame(width: size * 0.18, height: size * 0.10)
                    .blur(radius: 2)
                Circle().fill(Color(red: 1.0, green: 0.42, blue: 0.42).opacity(0.55))
                    .frame(width: size * 0.18, height: size * 0.10)
                    .blur(radius: 2)
            }
            .offset(y: size * 0.10)

            // Smile
            Path { p in
                p.move(to: CGPoint(x: -size * 0.14, y: 0))
                p.addQuadCurve(to: CGPoint(x: size * 0.14, y: 0),
                               control: CGPoint(x: 0, y: size * 0.14))
            }
            .stroke(Color.white, style: StrokeStyle(lineWidth: size * 0.05, lineCap: .round))
            .frame(width: size * 0.28, height: size * 0.14)
            .offset(y: size * 0.18)

            // Sparkles around (subtle, dance)
            if sparkles {
                ForEach(0..<4, id: \.self) { i in
                    Image(systemName: "sparkle")
                        .font(.system(size: size * 0.10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .offset(sparkleOffset(i))
                        .scaleEffect(sparkles ? 1.0 : 0.5)
                        .opacity(sparkles ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6)
                                    .delay(Double(i) * 0.12), value: sparkles)
                }
            }
        }
        .frame(width: size, height: size)
        .scaleEffect(bounce ? 1.04 : 1.0)
        .rotationEffect(.degrees(bounce ? -1.5 : 1.5))
        .onAppear {
            guard animate else { return }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.55).repeatForever(autoreverses: true)) {
                bounce = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                sparkles = true
            }
            // Blink every few seconds
            Timer.scheduledTimer(withTimeInterval: 3.8, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.16)) { blink = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                    withAnimation(.easeInOut(duration: 0.16)) { blink = false }
                }
            }
        }
    }

    private func eye() -> some View {
        Capsule()
            .fill(Color.white)
            .frame(width: size * 0.10, height: blink ? size * 0.02 : size * 0.14)
            .animation(.easeInOut(duration: 0.16), value: blink)
    }

    private func sparkleOffset(_ i: Int) -> CGSize {
        let positions: [CGSize] = [
            CGSize(width: -size * 0.55, height: -size * 0.45),
            CGSize(width:  size * 0.55, height: -size * 0.40),
            CGSize(width: -size * 0.50, height:  size * 0.50),
            CGSize(width:  size * 0.58, height:  size * 0.46)
        ]
        return positions[i]
    }
}

/// Hafif şirin sparkle dekorasyon — başlıkların yanına serpiştirmek için.
struct SparkleDecoration: View {
    var tint: Color = Theme.brand
    var size: CGFloat = 12
    @State private var spin = false
    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: size, weight: .bold))
            .foregroundStyle(tint)
            .symbolEffect(.pulse, options: .repeating, value: spin)
            .onAppear { spin = true }
    }
}

/// Mini konfeti — bir state değişiminde patlar.
struct Confetti: View {
    let trigger: Int
    @State private var pieces: [Piece] = []

    struct Piece: Identifiable {
        let id = UUID()
        let color: Color
        let x: CGFloat
        let delay: Double
        let xEnd: CGFloat
        let yEnd: CGFloat
        let rotation: Double
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(pieces) { p in
                    Rectangle()
                        .fill(p.color)
                        .frame(width: 8, height: 12)
                        .position(x: proxy.size.width / 2 + p.x, y: proxy.size.height / 2)
                        .modifier(FallEffect(end: CGSize(width: p.xEnd, height: p.yEnd),
                                             rotation: p.rotation,
                                             delay: p.delay))
                }
            }
            .onChange(of: trigger) { _, _ in pop(in: proxy.size) }
        }
        .allowsHitTesting(false)
    }

    private func pop(in size: CGSize) {
        let colors: [Color] = [Theme.brand, Theme.brandSecondary, Theme.brandAccent,
                               Theme.green, Theme.amber, .pink, .purple]
        pieces = (0..<26).map { i in
            Piece(
                color: colors.randomElement()!,
                x: CGFloat.random(in: -30...30),
                delay: Double(i) * 0.012,
                xEnd: CGFloat.random(in: -240...240),
                yEnd: CGFloat.random(in: size.height/2...size.height),
                rotation: Double.random(in: -540...540)
            )
        }
    }

    private struct FallEffect: ViewModifier {
        let end: CGSize
        let rotation: Double
        let delay: Double
        @State private var go = false
        func body(content: Content) -> some View {
            content
                .offset(go ? end : .zero)
                .rotationEffect(.degrees(go ? rotation : 0))
                .opacity(go ? 0 : 1)
                .onAppear {
                    withAnimation(.easeOut(duration: 1.4).delay(delay)) {
                        go = true
                    }
                }
        }
    }
}
