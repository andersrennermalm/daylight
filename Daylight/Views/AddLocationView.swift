import SwiftUI

struct AddLocationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var locationStore = LocationStore.shared

    @State private var searchQuery = ""
    @State private var searchResults: [Location] = []
    @State private var isSearching = false
    @State private var searchError: String?

    @State private var showManualEntry = false
    @State private var manualName = ""
    @State private var manualLatitude = ""
    @State private var manualLongitude = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add Location")
                    .font(.headline)
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
            }
            .padding()

            Divider()

            if showManualEntry {
                manualEntryView
            } else {
                searchView
            }

            Divider()

            // Toggle button
            Button(action: { showManualEntry.toggle() }) {
                Text(showManualEntry ? "Search by City" : "Enter Coordinates Manually")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .foregroundColor(.accentColor)
            .padding()
        }
        .frame(width: 320, height: 350)
    }

    private var searchView: some View {
        VStack {
            // Search field
            HStack {
                TextField("Search city...", text: $searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        performSearch()
                    }

                if isSearching {
                    ProgressIndicator()
                } else {
                    Button("Search") {
                        performSearch()
                    }
                    .disabled(searchQuery.isEmpty)
                }
            }
            .padding()

            if let error = searchError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            // Results
            List(searchResults) { location in
                Button(action: {
                    locationStore.addLocation(location)
                    dismiss()
                }) {
                    VStack(alignment: .leading) {
                        Text(location.name)
                        Text("\(location.latitude, specifier: "%.4f"), \(location.longitude, specifier: "%.4f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var manualEntryView: some View {
        Form {
            TextField("Name", text: $manualName)
            TextField("Latitude", text: $manualLatitude)
            TextField("Longitude", text: $manualLongitude)

            Button("Add") {
                addManualLocation()
            }
            .disabled(!isValidManualEntry)
        }
        .padding()
    }

    private var isValidManualEntry: Bool {
        guard !manualName.isEmpty,
              let lat = Double(manualLatitude), lat >= -90, lat <= 90,
              let lng = Double(manualLongitude), lng >= -180, lng <= 180
        else { return false }
        return true
    }

    private func performSearch() {
        guard !searchQuery.isEmpty else { return }

        isSearching = true
        searchError = nil

        Task {
            do {
                let results = try await GeocodingService.shared.searchCity(searchQuery)
                await MainActor.run {
                    searchResults = results
                    isSearching = false
                    if results.isEmpty {
                        searchError = "No results found"
                    }
                }
            } catch {
                await MainActor.run {
                    searchError = "Search failed: \(error.localizedDescription)"
                    isSearching = false
                }
            }
        }
    }

    private func addManualLocation() {
        guard let lat = Double(manualLatitude),
              let lng = Double(manualLongitude)
        else { return }

        let location = Location(
            name: manualName,
            latitude: lat,
            longitude: lng
        )
        locationStore.addLocation(location)
        dismiss()
    }
}

struct ProgressIndicator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSProgressIndicator {
        let indicator = NSProgressIndicator()
        indicator.style = .spinning
        indicator.controlSize = .small
        indicator.startAnimation(nil)
        return indicator
    }

    func updateNSView(_ nsView: NSProgressIndicator, context: Context) {}
}
