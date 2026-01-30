//
//  AwarexApp.swift
//  Awarex
//

import SwiftUI
import SwiftData

@main
struct AwarexApp: App {
    @State private var authViewModel = AuthViewModel()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Incident.self,
            IncidentUpdate.self,
            Alert.self,
            SafetyContact.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    MainTabView(authViewModel: authViewModel)
                } else {
                    LoginView(authViewModel: authViewModel)
                }
            }
            .onAppear {
                seedSampleDataIfNeeded()
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func seedSampleDataIfNeeded() {
        let context = sharedModelContainer.mainContext
        
        // Check if we already have incidents
        let descriptor = FetchDescriptor<Incident>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        
        guard existingCount == 0 else { return }
        
        // Sample incidents around San Francisco (varied and light-hearted)
        let sampleIncidents: [(String, String, IncidentCategory, IncidentSeverity, Double, Double, String)] = [
            // Traffic & Road
            ("Road Work on Market St", "Construction crew working on road repairs. Expect minor delays.", .traffic, .low, 37.7849, -122.4094, "Market Street, SF"),
            ("Double Parked Delivery Truck", "Large delivery truck blocking bike lane near cafe.", .traffic, .low, 37.7879, -122.4074, "Mission St, SF"),
            ("Traffic Light Out", "Traffic signal not working at intersection. Drivers treating as 4-way stop.", .traffic, .medium, 37.7749, -122.4194, "Van Ness & Grove"),
            
            // Weather & Environment  
            ("Foggy Conditions", "Heavy fog rolling in from the bay. Reduced visibility on bridges.", .weather, .low, 37.8199, -122.4783, "Golden Gate Bridge"),
            ("Wet Sidewalks", "Sprinkler malfunction causing slippery sidewalks near park entrance.", .hazard, .low, 37.7694, -122.4862, "Golden Gate Park"),
            
            // Community & Public
            ("Street Fair Setup", "Vendors setting up for weekend farmers market. Some parking spots blocked.", .publicSafety, .low, 37.7599, -122.4148, "Valencia St"),
            ("Lost Dog Spotted", "Friendly golden retriever without collar seen near the park. Appears well-fed.", .other, .low, 37.7685, -122.4536, "Panhandle Park"),
            ("Loud Music Event", "Outdoor concert at the plaza. Sound levels high but permitted event.", .other, .low, 37.7786, -122.4159, "UN Plaza"),
            
            // Minor Issues
            ("Broken Parking Meter", "Parking meter #247 not accepting coins or cards.", .other, .low, 37.7922, -122.4058, "Embarcadero"),
            ("Overflowing Trash Bin", "Public trash can needs attention near bus stop.", .hazard, .low, 37.7846, -122.4097, "Powell Station"),
            
            // Medium Priority
            ("Minor Fender Bender", "Two cars involved in minor collision. No injuries, exchanging info.", .accident, .medium, 37.7614, -122.4350, "Haight & Ashbury"),
            ("Water Main Work", "City crew repairing water main. Water may be temporarily off for some buildings.", .hazard, .medium, 37.7955, -122.3937, "South Beach"),
            ("Large Crowd Gathering", "Popular food truck drawing big lunch crowd. Sidewalk congested.", .publicSafety, .low, 37.7879, -122.3965, "Oracle Park Area"),
            
            // Medical (minor)
            ("First Aid Station Active", "Medical tent set up for marathon runners. Non-emergency.", .medical, .low, 37.8029, -122.4484, "Crissy Field"),
            
            // Misc observations
            ("Filming in Progress", "Movie crew filming on location. Some street closures.", .other, .low, 37.7990, -122.4050, "North Beach"),
            ("Street Performer Crowd", "Popular street performer drawing large audience on pier.", .publicSafety, .low, 37.8087, -122.4098, "Pier 39")
        ]
        
        for (title, description, category, severity, lat, lon, address) in sampleIncidents {
            let incident = Incident(
                title: title,
                incidentDescription: description,
                category: category,
                severity: severity,
                latitude: lat,
                longitude: lon,
                address: address,
                reportedAt: Date().addingTimeInterval(-Double.random(in: 0...7200)), // Random time within last 2 hours
                verificationCount: Int.random(in: 0...15),
                aiSummary: "Community report - situation is being monitored."
            )
            context.insert(incident)
        }
        
        try? context.save()
    }
}
