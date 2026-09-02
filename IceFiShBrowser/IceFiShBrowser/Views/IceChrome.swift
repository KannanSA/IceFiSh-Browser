import SwiftUI

struct IceBackground: View {
    var body: some View {
        ZStack {
            IcePalette.skyGradient
                .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.55))
                .frame(width: 340, height: 340)
                .blur(radius: 50)
                .offset(x: -130, y: -280)

            Circle()
                .fill(IcePalette.pack.opacity(0.55))
                .frame(width: 420, height: 420)
                .blur(radius: 70)
                .offset(x: 160, y: 80)

            Circle()
                .fill(Color.white.opacity(0.4))
                .frame(width: 260, height: 260)
                .blur(radius: 40)
                .offset(x: 40, y: 340)

            LinearGradient(
                colors: [.white.opacity(0.35), .clear, IcePalette.lagoon.opacity(0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .allowsHitTesting(false)
    }
}

struct IceFishMark: View {
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            IcePalette.pack.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.9), lineWidth: 1)
                }
                .shadow(color: IcePalette.lagoon.opacity(0.25), radius: 8, y: 3)

            Image(systemName: "snowflake")
                .font(.system(size: size * 0.28, weight: .semibold))
                .foregroundStyle(IcePalette.lagoon.opacity(0.9))
                .offset(x: -size * 0.16, y: -size * 0.16)

            Image(systemName: "fish.fill")
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(IcePalette.deep)
                .rotationEffect(.degrees(-18))
                .offset(x: size * 0.04, y: size * 0.06)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct IceWordmark: View {
    var body: some View {
        HStack(spacing: 12) {
            IceFishMark(size: 46)
            Text("IceFiSh")
                .font(.system(size: 40, weight: .semibold, design: .rounded))
                .foregroundStyle(IcePalette.wordmarkGradient)
                .shadow(color: Color.white.opacity(0.8), radius: 0, y: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("IceFiSh")
    }
}
