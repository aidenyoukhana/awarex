import SwiftUI
import SwiftData

struct AlertsView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var alertViewModel: AlertViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Segment
                Picker("Filter", selection: $alertViewModel.showUnreadOnly) {
                    Text("All").tag(false)
                    Text("Unread").tag(true)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Alerts List
                if alertViewModel.filteredAlerts.isEmpty {
                    Spacer()
                    ContentUnavailableView(
                        "No Alerts",
                        systemImage: "bell.slash",
                        description: Text("You're all caught up!")
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(alertViewModel.filteredAlerts) { alert in
                            AlertRowView(alert: alert, alertViewModel: alertViewModel)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        alertViewModel.deleteAlert(alert, modelContext: modelContext)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    if !alert.isRead {
                                        Button {
                                            alertViewModel.markAsRead(alert)
                                        } label: {
                                            Label("Read", systemImage: "envelope.open")
                                        }
                                        .tint(.blue)
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        alertViewModel.fetchAlerts(modelContext: modelContext)
                    }
                }
            }
            .navigationTitle("Alerts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            alertViewModel.markAllAsRead()
                        } label: {
                            Label("Mark All as Read", systemImage: "envelope.open")
                        }
                        
                        Divider()
                        
                        Menu("Filter by Type") {
                            Button {
                                alertViewModel.filterType = nil
                            } label: {
                                if alertViewModel.filterType == nil {
                                    Label("All Types", systemImage: "checkmark")
                                } else {
                                    Text("All Types")
                                }
                            }
                            
                            ForEach(AlertType.allCases, id: \.self) { type in
                                Button {
                                    alertViewModel.filterType = type
                                } label: {
                                    if alertViewModel.filterType == type {
                                        Label(type.rawValue, systemImage: "checkmark")
                                    } else {
                                        Text(type.rawValue)
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}

struct AlertRowView: View {
    let alert: Alert
    @Bindable var alertViewModel: AlertViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(alertColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: alert.alertType.icon)
                    .font(.title3)
                    .foregroundStyle(alertColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(alert.title)
                        .font(.headline)
                        .foregroundStyle(alert.isRead ? .secondary : .primary)
                    
                    Spacer()
                    
                    if !alert.isRead {
                        Circle()
                            .fill(.blue)
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text(alert.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                
                Text(alert.createdAt.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            alertViewModel.markAsRead(alert)
        }
    }
    
    private var alertColor: Color {
        switch alert.alertType {
        case .emergency: return .red
        case .warning: return .orange
        case .info: return .blue
        case .aiInsight: return .purple
        }
    }
}

#Preview {
    AlertsView(alertViewModel: AlertViewModel())
        .modelContainer(for: Alert.self, inMemory: true)
}
