import Foundation
import SwiftData

@Model
final class Alert {
    @Attribute(.unique) var id: UUID
    var title: String
    var message: String
    var alertType: AlertType
    var isRead: Bool
    var createdAt: Date
    var expiresAt: Date?
    var incidentID: UUID?
    var actionURL: String?
    
    init(
        id: UUID = UUID(),
        title: String,
        message: String,
        alertType: AlertType,
        isRead: Bool = false,
        createdAt: Date = Date(),
        expiresAt: Date? = nil,
        incidentID: UUID? = nil,
        actionURL: String? = nil
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.alertType = alertType
        self.isRead = isRead
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.incidentID = incidentID
        self.actionURL = actionURL
    }
}

enum AlertType: String, Codable, CaseIterable {
    case emergency = "Emergency"
    case warning = "Warning"
    case info = "Info"
    case aiInsight = "AI Insight"
    
    var icon: String {
        switch self {
        case .emergency: return "exclamationmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        case .aiInsight: return "brain.head.profile"
        }
    }
    
    var colorName: String {
        switch self {
        case .emergency: return "red"
        case .warning: return "orange"
        case .info: return "blue"
        case .aiInsight: return "purple"
        }
    }
}
