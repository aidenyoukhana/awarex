import Foundation
import SwiftUI
import SwiftData
import CoreLocation

@Observable
final class IncidentViewModel {
    var incidents: [Incident] = []
    var selectedIncident: Incident?
    var isLoading: Bool = false
    var errorMessage: String?
    var searchText: String = ""
    var selectedCategory: IncidentCategory?
    var selectedSeverity: IncidentSeverity?
    
    // Report incident form
    var reportTitle: String = ""
    var reportDescription: String = ""
    var reportCategory: IncidentCategory = .other
    var reportSeverity: IncidentSeverity = .medium
    var reportLocation: CLLocationCoordinate2D?
    var reportAddress: String = ""
    
    var filteredIncidents: [Incident] {
        incidents.filter { incident in
            let matchesSearch = searchText.isEmpty ||
                incident.title.localizedCaseInsensitiveContains(searchText) ||
                incident.incidentDescription.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory = selectedCategory == nil || incident.category == selectedCategory
            let matchesSeverity = selectedSeverity == nil || incident.severity == selectedSeverity
            
            return matchesSearch && matchesCategory && matchesSeverity && incident.isActive
        }
    }
    
    var activeIncidentsCount: Int {
        incidents.filter { $0.isActive }.count
    }
    
    var isReportValid: Bool {
        !reportTitle.isEmpty && !reportDescription.isEmpty && reportLocation != nil
    }
    
    func fetchIncidents(modelContext: ModelContext) {
        isLoading = true
        
        let descriptor = FetchDescriptor<Incident>(
            sortBy: [SortDescriptor(\.reportedAt, order: .reverse)]
        )
        
        do {
            incidents = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Failed to fetch incidents: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func reportIncident(modelContext: ModelContext, reporterID: UUID?) async {
        guard let location = reportLocation else { return }
        
        isLoading = true
        
        // Simulate AI processing
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let aiSummary = generateAISummary()
        let aiRisk = generateAIRiskAssessment()
        
        let incident = Incident(
            title: reportTitle,
            incidentDescription: reportDescription,
            category: reportCategory,
            severity: reportSeverity,
            latitude: location.latitude,
            longitude: location.longitude,
            address: reportAddress.isEmpty ? nil : reportAddress,
            reporterID: reporterID,
            aiSummary: aiSummary,
            aiRiskAssessment: aiRisk
        )
        
        modelContext.insert(incident)
        incidents.insert(incident, at: 0)
        
        clearReportForm()
        isLoading = false
    }
    
    func verifyIncident(_ incident: Incident) {
        incident.verificationCount += 1
        incident.updatedAt = Date()
    }
    
    func resolveIncident(_ incident: Incident) {
        incident.isActive = false
        incident.updatedAt = Date()
    }
    
    func addUpdate(to incident: Incident, content: String, modelContext: ModelContext) {
        let update = IncidentUpdate(
            content: content,
            incident: incident
        )
        modelContext.insert(update)
        incident.updatedAt = Date()
    }
    
    func generateAISummary() -> String {
        // Simulated AI summary generation
        let summaries = [
            "Based on the report details, this incident appears to be contained to the immediate area.",
            "AI analysis suggests this is an isolated event with no immediate spread risk.",
            "Pattern recognition indicates similar incidents have been resolved within 30 minutes.",
            "Automated assessment: Standard response protocols recommended."
        ]
        return summaries.randomElement() ?? ""
    }
    
    func generateAIRiskAssessment() -> String {
        // Simulated AI risk assessment
        switch reportSeverity {
        case .low:
            return "Low risk - Minimal impact expected. Stay aware but no immediate action required."
        case .medium:
            return "Moderate risk - Consider avoiding the area. Monitor for updates."
        case .high:
            return "High risk - Avoid the area if possible. Follow official guidance."
        case .critical:
            return "Critical risk - Immediate danger. Evacuate or shelter in place as appropriate."
        }
    }
    
    func clearReportForm() {
        reportTitle = ""
        reportDescription = ""
        reportCategory = .other
        reportSeverity = .medium
        reportLocation = nil
        reportAddress = ""
    }
    
    func clearFilters() {
        searchText = ""
        selectedCategory = nil
        selectedSeverity = nil
    }
}
