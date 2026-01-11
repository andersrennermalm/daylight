import Foundation
import CoreLocation

class GeocodingService {
    static let shared = GeocodingService()
    private let geocoder = CLGeocoder()

    private init() {}

    func searchCity(_ query: String) async throws -> [Location] {
        let placemarks = try await geocoder.geocodeAddressString(query)

        return placemarks.compactMap { placemark -> Location? in
            guard let coordinate = placemark.location?.coordinate else { return nil }

            let name = [placemark.locality, placemark.country]
                .compactMap { $0 }
                .joined(separator: ", ")

            guard !name.isEmpty else { return nil }

            return Location(
                name: name,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                timeZoneIdentifier: placemark.timeZone?.identifier
            )
        }
    }
}
