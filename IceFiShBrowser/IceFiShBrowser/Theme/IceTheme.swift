import SwiftUI

enum IcePalette {
    static let mist = Color(red: 0.945, green: 0.973, blue: 0.992)
    static let glacier = Color(red: 0.86, green: 0.94, blue: 0.98)
    static let pack = Color(red: 0.72, green: 0.89, blue: 0.96)
    static let lagoon = Color(red: 0.37, green: 0.68, blue: 0.82)
    static let deep = Color(red: 0.14, green: 0.33, blue: 0.45)
    static let ink = Color(red: 0.10, green: 0.22, blue: 0.30)
    static let glassFill = Color.white.opacity(0.46)
    static let glassStroke = Color.white.opacity(0.78)
    static let frostStroke = Color(red: 0.55, green: 0.78, blue: 0.90).opacity(0.55)

    static var skyGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.93, green: 0.98, blue: 1.0),
                Color(red: 0.78, green: 0.92, blue: 0.98),
                Color(red: 0.67, green: 0.86, blue: 0.95)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var wordmarkGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.20, green: 0.48, blue: 0.64),
                Color(red: 0.32, green: 0.66, blue: 0.82)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

struct IceGlass: ViewModifier {
    var cornerRadius: CGFloat = 28
    var shadow: Bool = true

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(IcePalette.glassFill)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(IcePalette.glassStroke, lineWidth: 1)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(IcePalette.frostStroke, lineWidth: 0.6)
            }
            .shadow(
                color: shadow ? IcePalette.deep.opacity(0.12) : .clear,
                radius: shadow ? 22 : 0,
                y: shadow ? 10 : 0
            )
    }
}

struct IceCapsuleGlass: ViewModifier {
    var shadow: Bool = true

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    Capsule(style: .continuous)
                        .fill(.ultraThinMaterial)
                    Capsule(style: .continuous)
                        .fill(IcePalette.glassFill)
                }
            }
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(IcePalette.glassStroke, lineWidth: 1)
            }
            .shadow(
                color: shadow ? IcePalette.deep.opacity(0.14) : .clear,
                radius: shadow ? 20 : 0,
                y: shadow ? 8 : 0
            )
    }
}

extension View {
    func iceGlass(cornerRadius: CGFloat = 28, shadow: Bool = true) -> some View {
        modifier(IceGlass(cornerRadius: cornerRadius, shadow: shadow))
    }

    func iceCapsule(shadow: Bool = true) -> some View {
        modifier(IceCapsuleGlass(shadow: shadow))
    }
}
