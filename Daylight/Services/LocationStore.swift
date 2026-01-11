import Foundation
import Combine

class LocationStore: ObservableObject {
    static let shared = LocationStore()

    private let locationsKey = "savedLocations"
    private let primaryLocationKey = "primaryLocationId"

    @Published var locations: [Location] = []
    @Published var primaryLocationId: UUID?

    var primaryLocation: Location? {
        if let id = primaryLocationId {
            return locations.first { $0.id == id }
        }
        return locations.first
    }

    private init() {
        loadLocations()
    }

    func loadLocations() {
        if let data = UserDefaults.standard.data(forKey: locationsKey),
           let decoded = try? JSONDecoder().decode([Location].self, from: data) {
            locations = decoded
        } else {
            // Default to Stockholm
            locations = [Location.stockholm]
        }

        if let idString = UserDefaults.standard.string(forKey: primaryLocationKey),
           let id = UUID(uuidString: idString) {
            primaryLocationId = id
        } else {
            primaryLocationId = locations.first?.id
        }
    }

    func saveLocations() {
        if let encoded = try? JSONEncoder().encode(locations) {
            UserDefaults.standard.set(encoded, forKey: locationsKey)
        }
        if let id = primaryLocationId {
            UserDefaults.standard.set(id.uuidString, forKey: primaryLocationKey)
        }
    }

    func addLocation(_ location: Location) {
        locations.append(location)
        if locations.count == 1 {
            primaryLocationId = location.id
        }
        saveLocations()
    }

    func removeLocation(_ location: Location) {
        locations.removeAll { $0.id == location.id }
        if primaryLocationId == location.id {
            primaryLocationId = locations.first?.id
        }
        saveLocations()
    }

    func setPrimaryLocation(_ location: Location) {
        primaryLocationId = location.id
        saveLocations()
    }

    func moveLocation(from source: IndexSet, to destination: Int) {
        locations.move(fromOffsets: source, toOffset: destination)
        saveLocations()
    }
}
