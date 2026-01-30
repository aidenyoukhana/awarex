import Foundation
import SwiftData

@Model
final class IncidentUpdate {
    @Attribute(.unique) var id: UUID
    var content: String
    var timestamp: Date
    var source: UpdateSource
    var isAIGenerated: Bool
    
    @Relationship(inverse: \Incident.updates) var incident: Incident?
    
    init(
        id: UUID = UUID(),
        content: String,
        timestamp: Date = Date(),
        source: UpdateSource = .user,
        isAIGenerated: Bool = false,
        incident: Incident? = nil
    ) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
        self.source = source
        self.isAIGenerated = isAIGenerated
        self.incident = incident
    }
}

enum UpdateSource: String, Codable {
    case user = "User"
    case official = "Official"
    case ai = "AI"
    case system = "System"
}
