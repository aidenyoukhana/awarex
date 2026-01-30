import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var email: String
    var displayName: String
    var phoneNumber: String?
    var profileImageURL: String?
    var isVerified: Bool
    var createdAt: Date
    var lastLoginAt: Date?
    var notificationsEnabled: Bool
    var locationSharingEnabled: Bool
    var safetyCircleRadius: Double // in meters
    
    init(
        id: UUID = UUID(),
        email: String,
        displayName: String,
        phoneNumber: String? = nil,
        profileImageURL: String? = nil,
        isVerified: Bool = false,
        createdAt: Date = Date(),
        lastLoginAt: Date? = nil,
        notificationsEnabled: Bool = true,
        locationSharingEnabled: Bool = true,
        safetyCircleRadius: Double = 5000
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.phoneNumber = phoneNumber
        self.profileImageURL = profileImageURL
        self.isVerified = isVerified
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
        self.notificationsEnabled = notificationsEnabled
        self.locationSharingEnabled = locationSharingEnabled
        self.safetyCircleRadius = safetyCircleRadius
    }
}
