import SwiftUI

struct IncidentFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var incidentViewModel: IncidentViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section("Category") {
                    ForEach(IncidentCategory.allCases, id: \.self) { category in
                        Button {
                            if incidentViewModel.selectedCategory == category {
                                incidentViewModel.selectedCategory = nil
                            } else {
                                incidentViewModel.selectedCategory = category
                            }
                        } label: {
                            HStack {
                                Image(systemName: category.icon)
                                    .frame(width: 24)
                                
                                Text(category.rawValue)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                if incidentViewModel.selectedCategory == category {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
                
                Section("Severity") {
                    ForEach(IncidentSeverity.allCases, id: \.self) { severity in
                        Button {
                            if incidentViewModel.selectedSeverity == severity {
                                incidentViewModel.selectedSeverity = nil
                            } else {
                                incidentViewModel.selectedSeverity = severity
                            }
                        } label: {
                            HStack {
                                Circle()
                                    .fill(severityColor(for: severity))
                                    .frame(width: 12, height: 12)
                                
                                Text(severity.rawValue)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                if incidentViewModel.selectedSeverity == severity {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button("Clear All Filters", role: .destructive) {
                        incidentViewModel.clearFilters()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func severityColor(for severity: IncidentSeverity) -> Color {
        switch severity {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

#Preview {
    IncidentFiltersView(incidentViewModel: IncidentViewModel())
}
