import SwiftUI
import MapKit
import SwiftData

struct MapTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var incidentViewModel: IncidentViewModel
    @Bindable var mapViewModel: MapViewModel
    
    @State private var showReportSheet = false
    @State private var showIncidentDetail = false
    @State private var showMapSettings = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Map
                Map(position: $mapViewModel.cameraPosition, selection: $mapViewModel.selectedMapIncident) {
                    // User Location
                    if mapViewModel.showUserLocation {
                        UserAnnotation()
                    }
                    
                    // Incident Markers
                    ForEach(incidentViewModel.filteredIncidents) { incident in
                        Annotation(
                            incident.title,
                            coordinate: incident.coordinate,
                            anchor: .bottom
                        ) {
                            IncidentMarkerView(incident: incident)
                        }
                        .tag(incident)
                    }
                }
                .mapStyle(mapStyle)
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }
                
                // Overlay Controls
                VStack {
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 12) {
                            // Map style button
                            Button {
                                showMapSettings = true
                            } label: {
                                Image(systemName: "map")
                                    .font(.title2)
                                    .padding(12)
                                    .background(.regularMaterial)
                                    .clipShape(Circle())
                            }
                            
                            // Center on user
                            Button {
                                mapViewModel.centerOnUserLocation()
                            } label: {
                                Image(systemName: "location.fill")
                                    .font(.title2)
                                    .padding(12)
                                    .background(.regularMaterial)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        incidentViewModel.fetchIncidents(modelContext: modelContext)
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if let location = mapViewModel.userLocation {
                            incidentViewModel.reportLocation = location
                        }
                        showReportSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showReportSheet) {
                ReportIncidentView(
                    incidentViewModel: incidentViewModel,
                    mapViewModel: mapViewModel
                )
            }
            .sheet(isPresented: $showMapSettings) {
                MapSettingsView(mapViewModel: mapViewModel)
                    .presentationDetents([.medium])
            }
            .onChange(of: mapViewModel.selectedMapIncident) { _, incident in
                if incident != nil {
                    showIncidentDetail = true
                }
            }
            .sheet(isPresented: $showIncidentDetail) {
                if let incident = mapViewModel.selectedMapIncident {
                    IncidentDetailView(
                        incident: incident,
                        incidentViewModel: incidentViewModel,
                        mapViewModel: mapViewModel
                    )
                    .presentationDetents([.medium, .large])
                }
            }
        }
    }
    
    private var mapStyle: MapStyle {
        switch mapViewModel.mapStyle {
        case .standard:
            return .standard
        case .satellite:
            return .imagery
        case .hybrid:
            return .hybrid
        }
    }
}

struct IncidentMarkerView: View {
    let incident: Incident
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(severityColor)
                    .frame(width: 36, height: 36)
                
                Image(systemName: incident.category.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
            }
            
            Image(systemName: "triangle.fill")
                .font(.system(size: 10))
                .foregroundStyle(severityColor)
                .rotationEffect(.degrees(180))
                .offset(y: -3)
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

#Preview {
    MapTabView(
        incidentViewModel: IncidentViewModel(),
        mapViewModel: MapViewModel()
    )
    .modelContainer(for: Incident.self, inMemory: true)
}
