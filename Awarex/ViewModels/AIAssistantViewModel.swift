import Foundation
import SwiftUI

@Observable
final class AIAssistantViewModel {
    var messages: [AIMessage] = []
    var inputText: String = ""
    var isProcessing: Bool = false
    var isExpanded: Bool = false
    var nearbyIncidents: [Incident] = []
    
    enum MessageType {
        case text
        case incidentsList
        case safetyStatus
        case safetyTips
        case summary
        case trends
        case safeRoute
        case emergency
    }
    
    struct AIMessage: Identifiable {
        let id = UUID()
        let content: String
        let isUser: Bool
        let timestamp: Date
        var messageType: MessageType = .text
        var incidents: [Incident] = []
        var safetyScore: Int = 0
    }
    
    init() {
        // Welcome message
        messages.append(AIMessage(
            content: "Hello! I'm your AI safety assistant. I can help you with:\n• Understanding nearby incidents\n• Safety recommendations\n• Emergency guidance\n• Area risk assessments\n\nHow can I help you stay safe today?",
            isUser: false,
            timestamp: Date()
        ))
    }
    
    func sendMessage(incidents: [Incident] = []) async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = inputText
        messages.append(AIMessage(content: userMessage, isUser: true, timestamp: Date()))
        inputText = ""
        isProcessing = true
        
        // Simulate AI processing
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        let response = generateResponse(for: userMessage, incidents: incidents)
        messages.append(response)
        
        isProcessing = false
    }
    
    private func generateResponse(for query: String, incidents: [Incident]) -> AIMessage {
        let lowercased = query.lowercased()
        let activeIncidents = incidents.filter { $0.isActive }
        let safetyScore = calculateSafetyScore(incidents: activeIncidents)
        
        // Check for safety tips FIRST (before "safe" check)
        if lowercased.contains("tip") || lowercased.contains("advice") {
            return AIMessage(
                content: "Here are some safety recommendations for your area:",
                isUser: false,
                timestamp: Date(),
                messageType: .safetyTips
            )
        }
        
        // Check for nearby incidents query
        if lowercased.contains("near") || (lowercased.contains("incident") && !lowercased.contains("report")) {
            if activeIncidents.isEmpty {
                return AIMessage(
                    content: "Great news! There are no active incidents reported near you right now.",
                    isUser: false,
                    timestamp: Date(),
                    messageType: .safetyStatus,
                    safetyScore: 95
                )
            } else {
                return AIMessage(
                    content: "I found \(activeIncidents.count) active incident\(activeIncidents.count == 1 ? "" : "s") in your area:",
                    isUser: false,
                    timestamp: Date(),
                    messageType: .incidentsList,
                    incidents: Array(activeIncidents.prefix(5))
                )
            }
        }
        
        // Safety check
        if lowercased.contains("safe") || lowercased.contains("danger") {
            return AIMessage(
                content: safetyScore >= 70 ? "Your area appears to be safe" : "Exercise caution in your area",
                isUser: false,
                timestamp: Date(),
                messageType: .safetyStatus,
                incidents: Array(activeIncidents.prefix(3)),
                safetyScore: safetyScore
            )
        }
        
        // Summarize today's incidents
        if lowercased.contains("summar") {
            let categories = Dictionary(grouping: activeIncidents, by: { $0.category })
            return AIMessage(
                content: "Summary",
                isUser: false,
                timestamp: Date(),
                messageType: .summary,
                incidents: activeIncidents
            )
        }
        
        // Trends
        if lowercased.contains("trend") || lowercased.contains("pattern") {
            return AIMessage(
                content: "Trends",
                isUser: false,
                timestamp: Date(),
                messageType: .trends,
                incidents: activeIncidents
            )
        }
        
        // Safe route
        if lowercased.contains("route") || lowercased.contains("navigate") || lowercased.contains("path") {
            return AIMessage(
                content: "Safe Route",
                isUser: false,
                timestamp: Date(),
                messageType: .safeRoute,
                incidents: activeIncidents
            )
        }
        
        // Emergency contacts
        if lowercased.contains("emergency") || lowercased.contains("contact") || lowercased.contains("911") {
            return AIMessage(
                content: "Emergency",
                isUser: false,
                timestamp: Date(),
                messageType: .emergency
            )
        }
        
        if lowercased.contains("report") || (lowercased.contains("how") && lowercased.contains("report")) {
            return AIMessage(
                content: "To report an incident:\n\n1. Tap the '+' button on the map\n2. Select the incident type\n3. Provide details and location\n4. Submit the report\n\nYour report helps keep the community safe!",
                isUser: false,
                timestamp: Date()
            )
        }
        
        // Try to find a specific incident the user is asking about
        if let matchedIncident = findMatchingIncident(query: lowercased, incidents: incidents) {
            return AIMessage(
                content: "Here's what I know about that incident:",
                isUser: false,
                timestamp: Date(),
                messageType: .incidentsList,
                incidents: [matchedIncident]
            )
        }
        
        return AIMessage(
            content: "I understand you're asking about \"\(query)\". Based on my analysis of local conditions and incident data, I recommend staying aware of your surroundings. Is there something specific about safety in your area I can help you with?",
            isUser: false,
            timestamp: Date()
        )
    }
    
    private func findMatchingIncident(query: String, incidents: [Incident]) -> Incident? {
        // Try to match incident by keywords in the query
        let queryWords = query.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 }
        
        for incident in incidents where incident.isActive {
            let titleWords = incident.title.lowercased()
            let descWords = incident.incidentDescription.lowercased()
            
            // Check if multiple keywords match
            var matchCount = 0
            for word in queryWords {
                if titleWords.contains(word) || descWords.contains(word) {
                    matchCount += 1
                }
            }
            
            // If at least 2 keywords match, consider it a match
            if matchCount >= 2 {
                return incident
            }
            
            // Also check for category matches
            if queryWords.contains(incident.category.rawValue.lowercased()) {
                return incident
            }
        }
        
        return nil
    }
    
    func clearChat() {
        messages.removeAll()
        messages.append(AIMessage(
            content: "Chat cleared. How can I help you stay safe?",
            isUser: false,
            timestamp: Date()
        ))
    }
    
    private func calculateSafetyScore(incidents: [Incident]) -> Int {
        var score = 100
        
        for incident in incidents {
            switch incident.severity {
            case .critical: score -= 15
            case .high: score -= 10
            case .medium: score -= 5
            case .low: score -= 2
            }
        }
        
        return max(0, min(100, score))
    }
    
    func getSafetyScore(for incidents: [Incident], userLocation: (Double, Double)?) -> Int {
        guard let location = userLocation else { return 75 }
        
        var score = 100
        
        for incident in incidents where incident.isActive {
            let distance = calculateDistance(
                from: location,
                to: (incident.latitude, incident.longitude)
            )
            
            if distance < 500 {
                score -= incident.severity == .critical ? 30 : 20
            } else if distance < 1000 {
                score -= incident.severity == .critical ? 20 : 10
            } else if distance < 2000 {
                score -= 5
            }
        }
        
        return max(0, min(100, score))
    }
    
    private func calculateDistance(from: (Double, Double), to: (Double, Double)) -> Double {
        let lat1 = from.0 * .pi / 180
        let lat2 = to.0 * .pi / 180
        let dLat = (to.0 - from.0) * .pi / 180
        let dLon = (to.1 - from.1) * .pi / 180
        
        let a = sin(dLat/2) * sin(dLat/2) +
                cos(lat1) * cos(lat2) *
                sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        return 6371000 * c // Earth radius in meters
    }
}
