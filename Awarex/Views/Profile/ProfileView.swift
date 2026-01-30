import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var authViewModel: AuthViewModel
    let user: User?
    
    @State private var showSettings = false
    @State private var showSafetyContacts = false
    @State private var showEditProfile = false
    
    var body: some View {
        NavigationStack {
            List {
                // Profile Header
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(.blue.opacity(0.15))
                                .frame(width: 70, height: 70)
                            
                            Text(user?.displayName.prefix(1).uppercased() ?? "?")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user?.displayName ?? "User")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text(user?.email ?? "")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            if user?.isVerified == true {
                                Label("Verified", systemImage: "checkmark.seal.fill")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // Safety Features
                Section("Safety Features") {
                    NavigationLink {
                        SafetyContactsView()
                    } label: {
                        Label("Safety Contacts", systemImage: "person.2.fill")
                    }
                    
                    NavigationLink {
                        SafetyCircleView(user: user)
                    } label: {
                        Label("Safety Circle", systemImage: "circle.hexagongrid.fill")
                    }
                    
                    NavigationLink {
                        EmergencyInfoView()
                    } label: {
                        Label("Emergency Info", systemImage: "cross.case.fill")
                    }
                }
                
                // Account
                Section("Account") {
                    Button {
                        showEditProfile = true
                    } label: {
                        Label("Edit Profile", systemImage: "pencil")
                    }
                    
                    NavigationLink {
                        NotificationSettingsView(user: user)
                    } label: {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    
                    NavigationLink {
                        PrivacySettingsView(user: user)
                    } label: {
                        Label("Privacy", systemImage: "lock.fill")
                    }
                }
                
                // About
                Section("About") {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About Awarex", systemImage: "info.circle")
                    }
                    
                    Link(destination: URL(string: "https://example.com/help")!) {
                        Label("Help Center", systemImage: "questionmark.circle")
                    }
                    
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "doc.text")
                    }
                }
                
                // Logout
                Section {
                    Button(role: .destructive) {
                        authViewModel.logout()
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(user: user)
            }
        }
    }
}

struct SafetyContactsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var contacts: [SafetyContact]
    @State private var showAddContact = false
    
    var body: some View {
        List {
            if contacts.isEmpty {
                ContentUnavailableView(
                    "No Safety Contacts",
                    systemImage: "person.2.slash",
                    description: Text("Add contacts who will be notified in emergencies")
                )
            } else {
                ForEach(contacts) { contact in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(contact.name)
                                .fontWeight(.medium)
                            Text(contact.relationship)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if contact.isPrimary {
                            Text("Primary")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blue.opacity(0.1))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(contacts[index])
                    }
                }
            }
        }
        .navigationTitle("Safety Contacts")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddContact = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddContact) {
            AddSafetyContactView()
        }
    }
}

struct AddSafetyContactView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var relationship = ""
    @State private var isPrimary = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    TextField("Email (optional)", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Relationship", text: $relationship)
                }
                
                Section {
                    Toggle("Primary Contact", isOn: $isPrimary)
                }
            }
            .navigationTitle("Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let contact = SafetyContact(
                            name: name,
                            phoneNumber: phoneNumber,
                            email: email.isEmpty ? nil : email,
                            relationship: relationship,
                            isPrimary: isPrimary
                        )
                        modelContext.insert(contact)
                        dismiss()
                    }
                    .disabled(name.isEmpty || phoneNumber.isEmpty || relationship.isEmpty)
                }
            }
        }
    }
}

struct SafetyCircleView: View {
    let user: User?
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Safety Circle Radius")
                        .font(.headline)
                    
                    Text("\(Int(user?.safetyCircleRadius ?? 5000))m")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("You'll receive alerts for incidents within this radius")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            Section("Adjust Radius") {
                Button("1 km") {}
                Button("2 km") {}
                Button("5 km") {}
                Button("10 km") {}
            }
        }
        .navigationTitle("Safety Circle")
    }
}

struct EmergencyInfoView: View {
    var body: some View {
        List {
            Section("Emergency Numbers") {
                HStack {
                    Text("Emergency")
                    Spacer()
                    Link("911", destination: URL(string: "tel://911")!)
                }
                
                HStack {
                    Text("Police (Non-Emergency)")
                    Spacer()
                    Link("311", destination: URL(string: "tel://311")!)
                }
            }
            
            Section("Medical Information") {
                Text("Add your medical information for first responders")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Emergency Info")
    }
}

struct NotificationSettingsView: View {
    let user: User?
    @State private var pushEnabled = true
    @State private var criticalAlerts = true
    @State private var nearbyIncidents = true
    @State private var aiInsights = true
    
    var body: some View {
        List {
            Section {
                Toggle("Push Notifications", isOn: $pushEnabled)
            }
            
            Section("Alert Types") {
                Toggle("Critical Alerts", isOn: $criticalAlerts)
                Toggle("Nearby Incidents", isOn: $nearbyIncidents)
                Toggle("AI Safety Insights", isOn: $aiInsights)
            }
        }
        .navigationTitle("Notifications")
    }
}

struct PrivacySettingsView: View {
    let user: User?
    @State private var locationSharing = true
    @State private var anonymousReporting = false
    
    var body: some View {
        List {
            Section {
                Toggle("Location Sharing", isOn: $locationSharing)
                Toggle("Anonymous Reporting", isOn: $anonymousReporting)
            }
            
            Section {
                Button("Download My Data") {}
                Button("Delete Account", role: .destructive) {}
            }
        }
        .navigationTitle("Privacy")
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    let user: User?
    
    @State private var displayName: String = ""
    @State private var phoneNumber: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Display Name", text: $displayName)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section {
                    Text(user?.email ?? "")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        user?.displayName = displayName
                        user?.phoneNumber = phoneNumber.isEmpty ? nil : phoneNumber
                        dismiss()
                    }
                }
            }
            .onAppear {
                displayName = user?.displayName ?? ""
                phoneNumber = user?.phoneNumber ?? ""
            }
        }
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("Awarex")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
            
            Section {
                Text("Awarex uses AI to keep you informed about safety incidents in your area. Stay aware, stay safe.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("About")
    }
}

#Preview {
    ProfileView(authViewModel: AuthViewModel(), user: nil)
        .modelContainer(for: [User.self, SafetyContact.self], inMemory: true)
}
