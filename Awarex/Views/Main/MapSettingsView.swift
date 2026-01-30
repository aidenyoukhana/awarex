import SwiftUI

struct MapSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var mapViewModel: MapViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section("Map Style") {
                    ForEach(MapStyleOption.allCases, id: \.self) { style in
                        Button {
                            mapViewModel.mapStyle = style
                        } label: {
                            HStack {
                                Text(style.rawValue)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                if mapViewModel.mapStyle == style {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
                
                Section("Display") {
                    Toggle("Show My Location", isOn: $mapViewModel.showUserLocation)
                }
                
                Section {
                    Button("Center on My Location") {
                        mapViewModel.centerOnUserLocation()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Map Settings")
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
}

#Preview {
    MapSettingsView(mapViewModel: MapViewModel())
}
