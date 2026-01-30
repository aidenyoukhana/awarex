import Foundation
import SwiftData
import CoreLocation

@Model
final class Incident {
    @Attribute(.unique) var id: UUID
    var title: String
    var incidentDescription: String
    var category: IncidentCategory
    var severity: IncidentSeverity
    var latitude: Double
    var longitude: Double
    var address: String?
    var reportedAt: Date
    var updatedAt: Date
    var isActive: Bool
    var reporterID: UUID?
    var verificationCount: Int
    var aiSummary: String?
    var aiRiskAssessment: String?
    
    @Relationship(deleteRule: .cascade) var updates: [IncidentUpdate]?
    
    init(
        id: UUID = UUID(),
        title: String,
        incidentDescription: String,
        category: IncidentCategory,
        severity: IncidentSeverity,
        latitude: Double,
        longitude: Double,
        address: String? = nil,
        reportedAt: Date = Date(),
        updatedAt: Date = Date(),
        isActive: Bool = true,
        reporterID: UUID? = nil,
        verificationCount: Int = 0,
        aiSummary: String? = nil,
        aiRiskAssessment: String? = nil,
        updates: [IncidentUpdate]? = nil
    ) {
        self.id = id
        self.title = title
        self.incidentDescription = incidentDescription
        self.category = category
        self.severity = severity
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.reportedAt = reportedAt
        self.updatedAt = updatedAt
        self.isActive = isActive
        self.reporterID = reporterID
        self.verificationCount = verificationCount
        self.aiSummary = aiSummary
        self.aiRiskAssessment = aiRiskAssessment
        self.updates = updates
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum IncidentCategory: String, Codable, CaseIterable {
    case crime = "Crime"
    case fire = "Fire"
    case accident = "Accident"
    case medical = "Medical"
    case hazard = "Hazard"
    case suspicious = "Suspicious Activity"
    case weather = "Weather"
    case traffic = "Traffic"
    case publicSafety = "Public Safety"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .crime: return "exclamationmark.shield"
        case .fire: return "flame"
        case .accident: return "car.side.front.open"
        case .medical: return "cross.case"
        case .hazard: return "exclamationmark.triangle"
        case .suspicious: return "eye"
        case .weather: return "cloud.bolt"
        case .traffic: return "car.2"
        case .publicSafety: return "person.3"
        case .other: return "questionmark.circle"
        }
    }
}

enum IncidentSeverity: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
}
