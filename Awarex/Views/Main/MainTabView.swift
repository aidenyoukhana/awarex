import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var authViewModel: AuthViewModel
    @State private var incidentViewModel = IncidentViewModel()
    @State private var mapViewModel = MapViewModel()
    @State private var aiViewModel = AIAssistantViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MapTabView(
                incidentViewModel: incidentViewModel,
                mapViewModel: mapViewModel
            )
            .tabItem {
                Label("Map", systemImage: "map")
            }
            .tag(0)
            
            IncidentListView(
                incidentViewModel: incidentViewModel,
                mapViewModel: mapViewModel
            )
            .tabItem {
                Label("Incidents", systemImage: "exclamationmark.triangle")
            }
            .tag(1)
            
            AIAssistantView(
                aiViewModel: aiViewModel,
                incidentViewModel: incidentViewModel,
                mapViewModel: mapViewModel
            )
            .tabItem {
                Label("AI Assistant", systemImage: "brain.head.profile")
            }
            .tag(2)
            
            ProfileView(
                authViewModel: authViewModel,
                user: authViewModel.currentUser
            )
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(3)
        }
        .onAppear {
            incidentViewModel.fetchIncidents(modelContext: modelContext)
            mapViewModel.requestLocationPermission()
        }
    }
}

#Preview {
    MainTabView(authViewModel: AuthViewModel())
        .modelContainer(for: [User.self, Incident.self, Alert.self], inMemory: true)
}
