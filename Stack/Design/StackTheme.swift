import SwiftUI

enum StackTheme {

    // BACKGROUNDS — charcoal base, no color tint
    enum Background {
        static let base     = Color(hex: "#111114")  // root app background
        static let surface  = Color(hex: "#1c1c1f")  // cards, rows
        static let elevated = Color(hex: "#242428")  // sheets, overlays
        static let input    = Color(hex: "#2a2a2e")  // text fields, pickers

        // Legacy aliases
        static let primary   = base
        static let secondary = surface
        static let card      = surface
    }

    // BORDERS — used only on inputs and dividers, never on cards
    enum Border {
        static let subtle = Color(hex: "#2c2c30")
        static let input  = Color(hex: "#38383d")

        // Legacy aliases
        static let `default` = subtle
        static let strong    = input
    }

    // TEXT
    enum Text {
        static let primary   = Color.white
        static let secondary = Color(hex: "#8e8e93")  // Apple gray
        static let tertiary  = Color(hex: "#48484a")  // very muted
    }

    // SINGLE ACCENT — indigo throughout
    enum Accent {
        static let primary  = Color(hex: "#6366f1")  // indigo — all interactive elements
        static let soft     = Color(hex: "#6366f1").opacity(0.15)  // backgrounds behind accent elements
        static let positive = Color(hex: "#30d158")  // Apple green — completion, success only
        static let warning  = Color(hex: "#ffd60a")  // Apple yellow — warnings only
        static let negative = Color(hex: "#ff453a")  // Apple red — errors, overdue only

        // Legacy aliases
        static let indigo  = primary
        static let purple  = primary
        static let blue    = primary
        static let green   = positive
        static let gold    = warning
        static let red     = negative
        static let orange  = warning
    }

    // TYPOGRAPHY — Apple system font, Whoop-style hierarchy
    enum Typography {
        static let hero        = Font.system(size: 52, weight: .bold, design: .rounded)
        static let stat        = Font.system(size: 34, weight: .bold, design: .rounded)
        static let metric      = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let title       = Font.system(.title2, design: .default, weight: .bold)
        static let headline    = Font.system(.headline)
        static let body        = Font.system(.body)
        static let callout     = Font.system(.callout)
        static let subheadline = Font.system(.subheadline)
        static let caption     = Font.system(.caption)
        static let label       = Font.system(size: 11, weight: .medium)
        static let quote       = Font.system(.body, design: .serif)

        // Legacy aliases
        static let largeTitle    = stat
        static let heroNumber    = hero
        static let statNumber    = stat
        static let metricSmall   = metric
        static let sectionHeader = label
        static let caption2      = label
    }

    // SPACING
    enum Spacing {
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // RADIUS
    enum Radius {
        static let sm:   CGFloat = 10
        static let md:   CGFloat = 14
        static let lg:   CGFloat = 18
        static let xl:   CGFloat = 22
        static let pill: CGFloat = 999
    }
}
