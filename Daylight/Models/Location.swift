import Foundation
import CoreLocation

struct Location: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var timeZoneIdentifier: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var timeZone: TimeZone {
        TimeZone(identifier: timeZoneIdentifier) ?? .current
    }

    init(id: UUID = UUID(), name: String, latitude: Double, longitude: Double, timeZoneIdentifier: String? = nil) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.timeZoneIdentifier = timeZoneIdentifier ?? TimeZone.current.identifier
    }

    static let stockholm = Location(
        name: "Stockholm",
        latitude: 59.3293,
        longitude: 18.0686,
        timeZoneIdentifier: "Europe/Stockholm"
    )
}
