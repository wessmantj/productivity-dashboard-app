import SwiftUI

enum StackTheme {

    // BACKGROUNDS — near-black, Whoop-style depth
    enum Background {
        static let base     = Color(hex: "#0a0a0d")  // root app background
        static let surface  = Color(hex: "#151519")  // cards, rows
        static let elevated = Color(hex: "#1e1e24")  // sheets, overlays, ring tracks
        static let input    = Color(hex: "#26262c")  // text fields, pickers
    }

    // BORDERS — hairline strokes on cards and inputs
    enum Border {
        static let subtle = Color(hex: "#232329")
        static let input  = Color(hex: "#3a3a41")
    }

    // TEXT
    enum Text {
        static let primary   = Color.white
        static let secondary = Color(hex: "#9b9ba3")
        static let tertiary  = Color(hex: "#52525b")
    }

    // ACCENTS — indigo brand (logo) + metric state colors
    enum Accent {
        static let primary  = Color(hex: "#6366f1")  // indigo — brand, interactive elements
        static let soft     = Color(hex: "#6366f1").opacity(0.15)
        static let positive = Color(hex: "#32e575")  // state: good / complete
        static let warning  = Color(hex: "#ffd60a")  // state: mid
        static let negative = Color(hex: "#ff5147")  // state: poor / overdue
    }

    /// Whoop-style state color for a 0–1 completion ratio.
    static func stateColor(for ratio: Double) -> Color {
        if ratio >= 0.8 { return Accent.positive }
        if ratio >= 0.4 { return Accent.warning }
        if ratio > 0    { return Accent.negative }
        return Accent.primary
    }

    // TYPOGRAPHY — condensed technical numerals, uppercase micro-labels
    enum Typography {
        /// Giant gauge numerals (hero ring center)
        static let hero        = Font.system(size: 64, weight: .heavy).width(.compressed)
        /// Large stat numerals (stat cards, health heroes)
        static let stat        = Font.system(size: 38, weight: .heavy).width(.condensed)
        /// Mid-size metric numerals / card leads
        static let metric      = Font.system(size: 22, weight: .bold).width(.condensed)
        static let title       = Font.system(.title2, weight: .bold)
        static let headline    = Font.system(.headline)
        static let body        = Font.system(.body)
        static let callout     = Font.system(.callout)
        static let subheadline = Font.system(.subheadline)
        static let caption     = Font.system(.caption)
        /// Uppercase micro-label — always pair with Tracking.label
        static let label       = Font.system(size: 11, weight: .semibold)
        /// Schedule / timestamp text
        static let time        = Font.system(.caption, design: .monospaced, weight: .medium)
    }

    // LETTER-SPACING — apply via .tracking() alongside Typography.label
    enum Tracking {
        static let label: CGFloat = 1.4
        static let wide:  CGFloat = 2.2
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
