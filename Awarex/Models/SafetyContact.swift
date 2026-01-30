import Foundation
import SwiftData

@Model
final class SafetyContact {
    @Attribute(.unique) var id: UUID
    var name: String
    var phoneNumber: String
    var email: String?
    var relationship: String
    var isPrimary: Bool
    var notifyOnEmergency: Bool
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        phoneNumber: String,
        email: String? = nil,
        relationship: String,
        isPrimary: Bool = false,
        notifyOnEmergency: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.relationship = relationship
        self.isPrimary = isPrimary
        self.notifyOnEmergency = notifyOnEmergency
        self.createdAt = createdAt
    }
}
