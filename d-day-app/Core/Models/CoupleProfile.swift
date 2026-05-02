import Foundation
import SwiftData

@Model
final class CoupleProfile {
    var firstName: String
    var partnerName: String
    var startedAt: Date
    var memo: String
    var createdAt: Date
    var updatedAt: Date

    init(
        firstName: String = "",
        partnerName: String = "",
        startedAt: Date = .now,
        memo: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.firstName = firstName
        self.partnerName = partnerName
        self.startedAt = startedAt
        self.memo = memo
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
