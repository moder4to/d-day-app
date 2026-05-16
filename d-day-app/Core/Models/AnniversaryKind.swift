import Foundation

enum AnniversaryKind: String, CaseIterable, Codable, Identifiable {
    case firstDay
    case anniversary
    case birthday
    case travel
    case custom

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .firstDay:
            return "시작일"
        case .anniversary:
            return "기념일"
        case .birthday:
            return "생일"
        case .travel:
            return "여행"
        case .custom:
            return "직접 입력"
        }
    }

    var symbolName: String {
        switch self {
        case .firstDay:
            return "flag.fill"
        case .anniversary:
            return "calendar.badge.clock"
        case .birthday:
            return "gift.fill"
        case .travel:
            return "airplane"
        case .custom:
            return "calendar"
        }
    }
}
