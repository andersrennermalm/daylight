import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @ObservedObject private var locationStore = LocationStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddLocation = false
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    dismiss()
                }
            }
            .padding()

            Divider()

            // Locations list
            List {
                Section("General") {
                    Toggle("Launch at Login", isOn: $launchAtLogin)
                        .onChange(of: launchAtLogin) { newValue in
                            do {
                                if newValue {
                                    try SMAppService.mainApp.register()
                                } else {
                                    try SMAppService.mainApp.unregister()
                                }
                            } catch {
                                print("Failed to update login item: \(error)")
                                // Revert on failure
                                DispatchQueue.main.async {
                                    launchAtLogin = !newValue
                                }
                            }
                        }
                }

                Section("Locations") {
                    ForEach(locationStore.locations) { location in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(location.name)
                                Text("\(location.latitude, specifier: "%.4f"), \(location.longitude, specifier: "%.4f")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if location.id == locationStore.primaryLocationId {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            } else {
                                Button(action: {
                                    locationStore.setPrimaryLocation(location)
                                }) {
                                    Image(systemName: "star")
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .contextMenu {
                            Button("Set as Primary") {
                                locationStore.setPrimaryLocation(location)
                            }
                            Divider()
                            Button("Delete", role: .destructive) {
                                locationStore.removeLocation(location)
                            }
                        }
                    }
                    .onMove { source, destination in
                        locationStore.moveLocation(from: source, to: destination)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            locationStore.removeLocation(locationStore.locations[index])
                        }
                    }

                    Button(action: { showingAddLocation = true }) {
                        Label("Add Location", systemImage: "plus")
                    }
                }
            }
        }
        .frame(width: 350, height: 400)
        .sheet(isPresented: $showingAddLocation) {
            AddLocationView()
        }
    }
}
