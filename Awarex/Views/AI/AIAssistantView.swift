import SwiftUI
import MapKit

struct AIAssistantView: View {
    @Bindable var aiViewModel: AIAssistantViewModel
    @Bindable var incidentViewModel: IncidentViewModel
    @Bindable var mapViewModel: MapViewModel
    
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chat Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(aiViewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if aiViewModel.isProcessing {
                                HStack {
                                    TypingIndicator()
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: aiViewModel.messages.count) { _, _ in
                        if let lastMessage = aiViewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Quick Actions
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        QuickActionButton(title: "Is it safe?", icon: "shield.checkered") {
                            aiViewModel.inputText = "Is my area safe right now?"
                            Task { await aiViewModel.sendMessage(incidents: incidentViewModel.incidents) }
                        }
                        
                        QuickActionButton(title: "Nearby", icon: "mappin.circle") {
                            aiViewModel.inputText = "What incidents are near me?"
                            Task { await aiViewModel.sendMessage(incidents: incidentViewModel.incidents) }
                        }
                        
                        QuickActionButton(title: "Tips", icon: "lightbulb") {
                            aiViewModel.inputText = "Give me safety tips"
                            Task { await aiViewModel.sendMessage(incidents: incidentViewModel.incidents) }
                        }
                        
                        QuickActionButton(title: "Summarize", icon: "doc.text") {
                            aiViewModel.inputText = "Summarize today's incidents"
                            Task { await aiViewModel.sendMessage(incidents: incidentViewModel.incidents) }
                        }
                        
                        QuickActionButton(title: "Trends", icon: "chart.line.uptrend.xyaxis") {
                            aiViewModel.inputText = "What are the incident trends?"
                            Task { await aiViewModel.sendMessage(incidents: incidentViewModel.incidents) }
                        }
                        
                        QuickActionButton(title: "Safe route", icon: "map") {
                            aiViewModel.inputText = "Find me a safe route"
                            Task { await aiViewModel.sendMessage(incidents: incidentViewModel.incidents) }
                        }
                        
                        QuickActionButton(title: "Emergency", icon: "phone.fill") {
                            aiViewModel.inputText = "Emergency contacts"
                            Task { await aiViewModel.sendMessage(incidents: incidentViewModel.incidents) }
                        }
                        
                        QuickActionButton(title: "Report", icon: "plus.circle") {
                            aiViewModel.inputText = "How do I report an incident?"
                            Task { await aiViewModel.sendMessage(incidents: incidentViewModel.incidents) }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                // Input Field - iMessage style
                HStack(alignment: .bottom, spacing: 10) {
                    HStack(spacing: 8) {
                        TextField("Message", text: $aiViewModel.inputText, axis: .vertical)
                            .lineLimit(1...6)
                            .focused($isInputFocused)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    Button {
                        Task {
                            await aiViewModel.sendMessage(incidents: incidentViewModel.incidents)
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(aiViewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color(.systemGray3) : .accentColor)
                    }
                    .disabled(aiViewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || aiViewModel.isProcessing)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .navigationTitle("AI Assistant")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            aiViewModel.clearChat()
                        } label: {
                            Label("Clear Chat", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}

struct MessageBubble: View {
    let message: AIAssistantViewModel.AIMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                if !message.isUser {
                    // Apple Intelligence style header
                    HStack(spacing: 6) {
                        Image(systemName: "apple.intelligence")
                            .font(.caption)
                            .foregroundStyle(.purple)
                        
                        Text("Apple Intelligence")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    HStack(spacing: 6) {
                        Text("You")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                switch message.messageType {
                case .safetyStatus:
                    SafetyStatusCard(message: message)
                case .safetyTips:
                    SafetyTipsCard()
                case .incidentsList where !message.incidents.isEmpty:
                    IncidentsListCard(message: message)
                case .summary:
                    SummaryCard(incidents: message.incidents)
                case .trends:
                    TrendsCard(incidents: message.incidents)
                case .safeRoute:
                    SafeRouteCard(incidents: message.incidents)
                case .emergency:
                    EmergencyCard()
                default:
                    Text(message.content)
                        .padding(12)
                        .background(message.isUser ? Color.blue : Color(.systemGray5))
                        .foregroundStyle(message.isUser ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            
            if !message.isUser {
                Spacer(minLength: 60)
            }
        }
    }
}

struct SafetyStatusCard: View {
    let message: AIAssistantViewModel.AIMessage
    
    private var statusColor: Color {
        if message.safetyScore >= 80 { return .green }
        if message.safetyScore >= 60 { return .yellow }
        if message.safetyScore >= 40 { return .orange }
        return .red
    }
    
    private var statusText: String {
        if message.safetyScore >= 80 { return "Safe" }
        if message.safetyScore >= 60 { return "Moderate" }
        if message.safetyScore >= 40 { return "Caution" }
        return "Alert"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Status Header
            HStack {
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: message.safetyScore >= 70 ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                        .font(.title2)
                        .foregroundStyle(statusColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Area Status: \(statusText)")
                        .font(.headline)
                    
                    Text("\(message.incidents.count) active incident\(message.incidents.count == 1 ? "" : "s") nearby")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("\(message.safetyScore)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(statusColor)
            }
            
            // Map if incidents exist
            if !message.incidents.isEmpty {
                IncidentsMapView(incidents: message.incidents)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            // Summary
            Text(message.safetyScore >= 70 
                 ? "Your area appears safe. Stay aware of your surroundings."
                 : "Exercise caution. Check nearby incidents for details.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct SafetyTipsCard: View {
    let tips = [
        ("location.fill", "Share your location with trusted contacts"),
        ("eye.fill", "Stay aware of your surroundings"),
        ("battery.100", "Keep your phone charged"),
        ("moon.fill", "Avoid poorly lit areas at night"),
        ("figure.walk", "Trust your instincts")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "shield.checkered")
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                Text("Safety Tips")
                    .font(.headline)
            }
            
            VStack(spacing: 10) {
                ForEach(tips, id: \.1) { tip in
                    HStack(spacing: 12) {
                        Image(systemName: tip.0)
                            .font(.body)
                            .foregroundStyle(.blue)
                            .frame(width: 24)
                        
                        Text(tip.1)
                            .font(.subheadline)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct IncidentsListCard: View {
    let message: AIAssistantViewModel.AIMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(message.content)
                .padding(.horizontal, 12)
                .padding(.top, 12)
            
            // Mini Map
            IncidentsMapView(incidents: message.incidents)
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 12)
            
            // Incident Cards
            VStack(spacing: 8) {
                ForEach(message.incidents) { incident in
                    IncidentCardView(incident: incident)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct IncidentsMapView: View {
    let incidents: [Incident]
    
    var body: some View {
        Map {
            ForEach(incidents) { incident in
                Annotation(
                    incident.title,
                    coordinate: incident.coordinate,
                    anchor: .bottom
                ) {
                    ZStack {
                        Circle()
                            .fill(severityColor(for: incident))
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: incident.category.icon)
                            .font(.system(size: 12))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .mapStyle(.standard)
        .disabled(true)
    }
    
    private func severityColor(for incident: Incident) -> Color {
        switch incident.severity {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

struct IncidentCardView: View {
    let incident: Incident
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(severityColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: incident.category.icon)
                    .foregroundStyle(severityColor)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(incident.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(incident.address ?? incident.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Severity indicator
            Text(incident.severity.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(severityColor.opacity(0.15))
                .foregroundStyle(severityColor)
                .clipShape(Capsule())
        }
        .padding(10)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
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

struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground))
            .foregroundStyle(.primary)
            .clipShape(Capsule())
        }
    }
}

struct TypingIndicator: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(.gray)
                    .frame(width: 8, height: 8)
                    .opacity(animationPhase == index ? 1 : 0.3)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
                animationPhase = (animationPhase + 1) % 3
            }
        }
    }
}

struct SummaryCard: View {
    let incidents: [Incident]
    
    private var categoryCounts: [(IncidentCategory, Int)] {
        let grouped = Dictionary(grouping: incidents, by: { $0.category })
        return grouped.map { ($0.key, $0.value.count) }.sorted { $0.1 > $1.1 }
    }
    
    private var severityCounts: [(String, Int, Color)] {
        let low = incidents.filter { $0.severity == .low }.count
        let medium = incidents.filter { $0.severity == .medium }.count
        let high = incidents.filter { $0.severity == .high }.count
        let critical = incidents.filter { $0.severity == .critical }.count
        return [
            ("Critical", critical, .red),
            ("High", high, .orange),
            ("Medium", medium, .yellow),
            ("Low", low, .green)
        ].filter { $0.1 > 0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.title2)
                    .foregroundStyle(.purple)
                
                Text("Today's Summary")
                    .font(.headline)
                
                Spacer()
                
                Text("\(incidents.count)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.purple)
            }
            
            Divider()
            
            // By Category
            Text("By Category")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            ForEach(categoryCounts.prefix(4), id: \.0) { category, count in
                HStack {
                    Image(systemName: category.icon)
                        .frame(width: 24)
                        .foregroundStyle(.secondary)
                    Text(category.rawValue)
                        .font(.subheadline)
                    Spacer()
                    Text("\(count)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            Divider()
            
            // By Severity
            Text("By Severity")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                ForEach(severityCounts, id: \.0) { name, count, color in
                    VStack {
                        Text("\(count)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(color)
                        Text(name)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct TrendsCard: View {
    let incidents: [Incident]
    
    private var topCategory: IncidentCategory? {
        let grouped = Dictionary(grouping: incidents, by: { $0.category })
        return grouped.max(by: { $0.value.count < $1.value.count })?.key
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundStyle(.orange)
                
                Text("Incident Trends")
                    .font(.headline)
            }
            
            Divider()
            
            // Insights
            VStack(alignment: .leading, spacing: 12) {
                if let top = topCategory {
                    InsightRow(
                        icon: "arrow.up.circle.fill",
                        color: .orange,
                        text: "Most common: \(top.rawValue)"
                    )
                }
                
                InsightRow(
                    icon: "clock.fill",
                    color: .blue,
                    text: "Peak activity: Evening hours"
                )
                
                InsightRow(
                    icon: "location.fill",
                    color: .green,
                    text: "Hotspot: Downtown area"
                )
                
                InsightRow(
                    icon: "arrow.down.circle.fill",
                    color: .green,
                    text: "Overall trend: Decreasing"
                )
            }
            
            Text("Based on \(incidents.count) incidents in your area")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct InsightRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
        }
    }
}

struct SafeRouteCard: View {
    let incidents: [Incident]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "map.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                
                Text("Safe Route")
                    .font(.headline)
            }
            
            // Mini map showing incidents to avoid
            if !incidents.isEmpty {
                IncidentsMapView(incidents: incidents)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Avoid \(incidents.count) incident area\(incidents.count == 1 ? "" : "s")")
                        .font(.subheadline)
                }
                
                HStack(spacing: 10) {
                    Image(systemName: "figure.walk")
                        .foregroundStyle(.blue)
                    Text("Use well-lit main streets")
                        .font(.subheadline)
                }
                
                HStack(spacing: 10) {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.orange)
                    Text("Consider timing of travel")
                        .font(.subheadline)
                }
            }
            
            Text("Tap on incidents to see areas to avoid")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct EmergencyCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "phone.fill")
                    .font(.title2)
                    .foregroundStyle(.red)
                
                Text("Emergency Contacts")
                    .font(.headline)
            }
            
            Divider()
            
            VStack(spacing: 12) {
                EmergencyContactRow(name: "Emergency", number: "911", icon: "staroflife.fill", color: .red)
                EmergencyContactRow(name: "Police (Non-Emergency)", number: "311", icon: "shield.fill", color: .blue)
                EmergencyContactRow(name: "Poison Control", number: "1-800-222-1222", icon: "cross.vial.fill", color: .purple)
                EmergencyContactRow(name: "Crisis Hotline", number: "988", icon: "heart.fill", color: .pink)
            }
            
            Text("Tap a number to call")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct EmergencyContactRow: View {
    let name: String
    let number: String
    let icon: String
    let color: Color
    
    var body: some View {
        Link(destination: URL(string: "tel:\(number.replacingOccurrences(of: "-", with: ""))")!) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    Text(number)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "phone.circle.fill")
                    .font(.title2)
                    .foregroundStyle(color)
            }
        }
    }
}

#Preview {
    AIAssistantView(
        aiViewModel: AIAssistantViewModel(),
        incidentViewModel: IncidentViewModel(),
        mapViewModel: MapViewModel()
    )
}
