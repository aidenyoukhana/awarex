import Foundation
import SwiftUI
import SwiftData

@Observable
final class AlertViewModel {
    var alerts: [Alert] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var filterType: AlertType?
    var showUnreadOnly: Bool = false
    
    var filteredAlerts: [Alert] {
        alerts.filter { alert in
            let matchesType = filterType == nil || alert.alertType == filterType
            let matchesUnread = !showUnreadOnly || !alert.isRead
            let notExpired = alert.expiresAt == nil || alert.expiresAt! > Date()
            return matchesType && matchesUnread && notExpired
        }
    }
    
    var unreadCount: Int {
        alerts.filter { !$0.isRead }.count
    }
    
    var emergencyAlertsCount: Int {
        alerts.filter { $0.alertType == .emergency && !$0.isRead }.count
    }
    
    func fetchAlerts(modelContext: ModelContext) {
        isLoading = true
        
        let descriptor = FetchDescriptor<Alert>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            alerts = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Failed to fetch alerts: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func markAsRead(_ alert: Alert) {
        alert.isRead = true
    }
    
    func markAllAsRead() {
        for alert in alerts {
            alert.isRead = true
        }
    }
    
    func deleteAlert(_ alert: Alert, modelContext: ModelContext) {
        modelContext.delete(alert)
        alerts.removeAll { $0.id == alert.id }
    }
    
    func createAlert(
        title: String,
        message: String,
        type: AlertType,
        incidentID: UUID? = nil,
        modelContext: ModelContext
    ) {
        let alert = Alert(
            title: title,
            message: message,
            alertType: type,
            incidentID: incidentID
        )
        
        modelContext.insert(alert)
        alerts.insert(alert, at: 0)
    }
    
    func generateAIInsight(for incidents: [Incident], modelContext: ModelContext) {
        guard !incidents.isEmpty else { return }
        
        // Simulated AI insight generation
        let insights = [
            "AI detected increased activity in your area. Stay vigilant.",
            "Pattern analysis shows this is an unusual time for incidents in your area.",
            "Based on historical data, similar situations typically resolve within 1 hour.",
            "AI recommends avoiding the northeast sector for the next 30 minutes."
        ]
        
        if let insight = insights.randomElement() {
            createAlert(
                title: "AI Safety Insight",
                message: insight,
                type: .aiInsight,
                modelContext: modelContext
            )
        }
    }
    
    func clearFilters() {
        filterType = nil
        showUnreadOnly = false
    }
}
