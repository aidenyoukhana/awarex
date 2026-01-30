import SwiftUI
import MapKit
import SwiftData

struct ReportIncidentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var incidentViewModel: IncidentViewModel
    @Bindable var mapViewModel: MapViewModel
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        NavigationStack {
            Form {
                Section("What happened?") {
                    TextField("Title", text: $incidentViewModel.reportTitle)
                    
                    Picker("Category", selection: $incidentViewModel.reportCategory) {
                        ForEach(IncidentCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    
                    Picker("Severity", selection: $incidentViewModel.reportSeverity) {
                        ForEach(IncidentSeverity.allCases, id: \.self) { severity in
                            Text(severity.rawValue).tag(severity)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Description") {
                    TextEditor(text: $incidentViewModel.reportDescription)
                        .frame(minHeight: 100)
                }
                
                Section("Location") {
                    if let location = incidentViewModel.reportLocation {
                        Map(initialPosition: .region(MKCoordinateRegion(
                            center: location,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        ))) {
                            Marker("Incident Location", coordinate: location)
                        }
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        TextField("Address (optional)", text: $incidentViewModel.reportAddress)
                    } else {
                        Button {
                            if let userLoc = mapViewModel.userLocation {
                                incidentViewModel.reportLocation = userLoc
                            }
                        } label: {
                            Label("Use Current Location", systemImage: "location.fill")
                        }
                    }
                }
                
                Section {
                    // AI Preview
                    VStack(alignment: .leading, spacing: 8) {
                        Label("AI Analysis Preview", systemImage: "brain.head.profile")
                            .font(.subheadline)
                            .foregroundStyle(.purple)
                        
                        Text("Once submitted, our AI will analyze this incident and provide:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Risk assessment", systemImage: "checkmark")
                            Label("Similar incident patterns", systemImage: "checkmark")
                            Label("Safety recommendations", systemImage: "checkmark")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Report Incident")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        incidentViewModel.clearReportForm()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Submit") {
                        Task {
                            await incidentViewModel.reportIncident(
                                modelContext: modelContext,
                                reporterID: nil // Would come from auth
                            )
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(!incidentViewModel.isReportValid || incidentViewModel.isLoading)
                }
            }
            .overlay {
                if incidentViewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("AI analyzing incident...")
                                .font(.subheadline)
                        }
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }
}

#Preview {
    ReportIncidentView(
        incidentViewModel: IncidentViewModel(),
        mapViewModel: MapViewModel()
    )
    .modelContainer(for: Incident.self, inMemory: true)
}
