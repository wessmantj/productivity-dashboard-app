import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable {
    case dashboard = 0
    case proto     = 1
    case fitness   = 2
    case tasks     = 3
    case learn     = 4
    case progress  = 5
    case vision    = 6
    case health    = 7

    var id: Int { rawValue }

    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2.fill"
        case .proto:     return "checklist"
        case .fitness:   return "dumbbell.fill"
        case .health:    return "heart.fill"
        case .learn:     return "brain.head.profile"
        case .vision:    return "star.fill"
        case .tasks:     return "checkmark.circle.fill"
        case .progress:  return "chart.bar.fill"
        }
    }

    var label: String {
        switch self {
        case .dashboard: return "Home"
        case .proto:     return "Protocol"
        case .fitness:   return "Fitness"
        case .health:    return "Health"
        case .learn:     return "Learn"
        case .vision:    return "Vision"
        case .tasks:     return "Tasks"
        case .progress:  return "Progress"
        }
    }

    var accent: Color {
        StackTheme.Accent.primary
    }
}
