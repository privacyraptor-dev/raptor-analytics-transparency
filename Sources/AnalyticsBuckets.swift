import Foundation

func analyticsRatioBucket(_ value: Double) -> String {
    switch value {
    case ..<0.25:
        return "0-24"
    case ..<0.50:
        return "25-49"
    case ..<0.75:
        return "50-74"
    case ..<1.00:
        return "75-99"
    case ..<1.25:
        return "100-124"
    case ..<1.50:
        return "125-149"
    default:
        return "150_plus"
    }
}

func analyticsCountBucket(_ count: Int) -> String {
    switch count {
    case 0:
        return "0"
    case 1...5:
        return "1-5"
    case 6...15:
        return "6-15"
    case 16...30:
        return "16-30"
    case 31...50:
        return "31-50"
    default:
        return "51_plus"
    }
}

func analyticsPaydayWindow(_ days: Int) -> String {
    switch days {
    case 0:
        return "today"
    case 1...3:
        return "1-3"
    case 4...7:
        return "4-7"
    case 8...14:
        return "8-14"
    default:
        return "15_plus"
    }
}
