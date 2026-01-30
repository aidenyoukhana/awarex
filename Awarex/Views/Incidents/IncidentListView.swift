import SwiftUI
import SwiftData

struct IncidentListView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var incidentViewModel: IncidentViewModel
    @Bindable var mapViewModel: MapViewModel
    
    @State private var showFilters = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Tags
                if incidentViewModel.selectedCategory != nil || incidentViewModel.selectedSeverity != nil {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            if let category = incidentViewModel.selectedCategory {
                                FilterTag(title: category.rawValue) {
                                    incidentViewModel.selectedCategory = nil
                                }
                            }
                            
                            if let severity = incidentViewModel.selectedSeverity {
                                FilterTag(title: severity.rawValue) {
                                    incidentViewModel.selectedSeverity = nil
                                }
                            }
                            
                            Button("Clear All") {
                                incidentViewModel.clearFilters()
                            }
                            .font(.caption)
                            .foregroundStyle(.blue)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    .background(.bar)
                }
                
                // Incident List
                if incidentViewModel.isLoading {
                    Spacer()
                    ProgressView("Loading incidents...")
                    Spacer()
                } else if incidentViewModel.filteredIncidents.isEmpty {
                    Spacer()
                    ContentUnavailableView(
                        "No Incidents",
                        systemImage: "checkmark.shield",
                        description: Text("No incidents match your filters. Your area appears safe!")
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(incidentViewModel.filteredIncidents) { incident in
                            NavigationLink {
                                IncidentDetailView(
                                    incident: incident,
                                    incidentViewModel: incidentViewModel,
                                    mapViewModel: mapViewModel
                                )
                            } label: {
                                IncidentRowView(
                                    incident: incident,
                                    distance: mapViewModel.distanceToIncident(incident)
                                )
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        incidentViewModel.fetchIncidents(modelContext: modelContext)
                    }
                }
            }
            .navigationTitle("Incidents")
            .searchable(text: $incidentViewModel.searchText, prompt: "Search incidents")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                IncidentFiltersView(incidentViewModel: incidentViewModel)
                    .presentationDetents([.medium])
            }
        }
    }
}

struct IncidentRowView: View {
    let incident: Incident
    let distance: String?
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(severityColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: incident.category.icon)
                    .font(.title3)
                    .foregroundStyle(severityColor)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(incident.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(incident.incidentDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Label(incident.category.rawValue, systemImage: incident.category.icon)
                    
                    if let distance = distance {
                        Text("•")
                        Text(distance)
                    }
                    
                    Text("•")
                    Text(incident.reportedAt.formatted(.relative(presentation: .named)))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Severity Badge
            Text(incident.severity.rawValue)
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(severityColor.opacity(0.15))
                .foregroundStyle(severityColor)
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
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

struct FilterTag: View {
    let title: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.blue.opacity(0.1))
        .foregroundStyle(.blue)
        .clipShape(Capsule())
    }
}

#Preview {
    IncidentListView(
        incidentViewModel: IncidentViewModel(),
        mapViewModel: MapViewModel()
    )
    .modelContainer(for: Incident.self, inMemory: true)
}
