import SwiftUI
import MapKit
import SwiftData

struct IncidentDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let incident: Incident
    @Bindable var incidentViewModel: IncidentViewModel
    @Bindable var mapViewModel: MapViewModel
    
    @State private var showAddUpdate = false
    @State private var updateText = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: incident.category.icon)
                                .font(.title2)
                            
                            Text(incident.category.rawValue)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            SeverityBadge(severity: incident.severity)
                        }
                        
                        Text(incident.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let address = incident.address {
                            Label(address, systemImage: "mappin")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Label(incident.reportedAt.formatted(.relative(presentation: .named)), systemImage: "clock")
                            
                            Spacer()
                            
                            Label("\(incident.verificationCount) verified", systemImage: "checkmark.seal")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Map Preview
                    Map(initialPosition: .region(MKCoordinateRegion(
                        center: incident.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ))) {
                        Marker(incident.title, coordinate: incident.coordinate)
                            .tint(severityColor)
                    }
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(true)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        
                        Text(incident.incidentDescription)
                            .font(.body)
                    }
                    
                    // AI Analysis
                    if incident.aiSummary != nil || incident.aiRiskAssessment != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("AI Analysis", systemImage: "brain.head.profile")
                                .font(.headline)
                            
                            if let summary = incident.aiSummary {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Summary")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(summary)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            if let risk = incident.aiRiskAssessment {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Risk Assessment")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(risk)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(.purple.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Updates
                    if let updates = incident.updates, !updates.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Updates")
                                .font(.headline)
                            
                            ForEach(updates.sorted { $0.timestamp > $1.timestamp }) { update in
                                UpdateRowView(update: update)
                            }
                        }
                    }
                    
                    // Actions
                    VStack(spacing: 10) {
                        Button {
                            incidentViewModel.verifyIncident(incident)
                        } label: {
                            Label("Verify Incident", systemImage: "checkmark.seal")
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }
                        .foregroundStyle(Color.accentColor)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Button {
                            showAddUpdate = true
                        } label: {
                            Label("Add Update", systemImage: "plus.bubble")
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }
                        .foregroundStyle(Color.accentColor)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Button {
                            mapViewModel.centerOnIncident(incident)
                            dismiss()
                        } label: {
                            Label("View on Map", systemImage: "map")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Incident Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            // Share functionality
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        
                        if incident.isActive {
                            Button(role: .destructive) {
                                incidentViewModel.resolveIncident(incident)
                                dismiss()
                            } label: {
                                Label("Mark as Resolved", systemImage: "checkmark.circle")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Add Update", isPresented: $showAddUpdate) {
                TextField("What's happening?", text: $updateText)
                Button("Cancel", role: .cancel) {
                    updateText = ""
                }
                Button("Submit") {
                    if !updateText.isEmpty {
                        incidentViewModel.addUpdate(to: incident, content: updateText, modelContext: modelContext)
                        updateText = ""
                    }
                }
            }
        }
    }
    
    private var severityColor: Color {
        switch incident.severity {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

struct SeverityBadge: View {
    let severity: IncidentSeverity
    
    var body: some View {
        Text(severity.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(severityColor.opacity(0.15))
            .foregroundStyle(severityColor)
            .clipShape(Capsule())
    }
    
    private var severityColor: Color {
        switch severity {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

struct UpdateRowView: View {
    let update: IncidentUpdate
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(.blue)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(update.source.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    if update.isAIGenerated {
                        Image(systemName: "brain.head.profile")
                            .font(.caption2)
                            .foregroundStyle(.purple)
                    }
                    
                    Spacer()
                    
                    Text(update.timestamp.formatted(.relative(presentation: .named)))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Text(update.content)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    IncidentDetailView(
        incident: Incident(
            title: "Test Incident",
            incidentDescription: "This is a test incident description.",
            category: .accident,
            severity: .medium,
            latitude: 37.7749,
            longitude: -122.4194
        ),
        incidentViewModel: IncidentViewModel(),
        mapViewModel: MapViewModel()
    )
    .modelContainer(for: Incident.self, inMemory: true)
}
