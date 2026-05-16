import Foundation
import SwiftData

enum RepeatRule: String, CaseIterable, Codable, Identifiable {
    case none
    case yearly

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .none:
            return "반복 없음"
        case .yearly:
            return "매년 반복"
        }
    }
}

@Model
final class DayEvent {
    var stableID: String
    var title: String
    var targetDate: Date
    var kindRawValue: String
    var repeatRuleRawValue: String = "none"
    var note: String
    var colorHex: String
    var isPinned: Bool
    var createdAt: Date
    var updatedAt: Date

    var kind: AnniversaryKind {
        get {
            AnniversaryKind(rawValue: kindRawValue) ?? .custom
        }
        set {
            kindRawValue = newValue.rawValue
        }
    }

    var repeatRule: RepeatRule {
        get {
            RepeatRule(rawValue: repeatRuleRawValue) ?? .none
        }
        set {
            repeatRuleRawValue = newValue.rawValue
        }
    }

    init(
        stableID: String = UUID().uuidString,
        title: String,
        targetDate: Date,
        kind: AnniversaryKind = .custom,
        repeatRule: RepeatRule = .none,
        note: String = "",
        colorHex: String = "FF6B8A",
        isPinned: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.stableID = stableID
        self.title = title
        self.targetDate = targetDate
        self.kindRawValue = kind.rawValue
        self.repeatRuleRawValue = repeatRule.rawValue
        self.note = note
        self.colorHex = colorHex
        self.isPinned = isPinned
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
