import Foundation
import CoreLocation

class SolarService {
    static let shared = SolarService()

    private let baseURL = "https://api.sunrise-sunset.org/json"
    private var cache: [String: SunData] = [:]

    private init() {}

    func getSunData(for location: Location, on date: Date = Date()) async -> SunData {
        let cacheKey = "\(location.id)-\(dateKey(date))"

        // Return cached data if available
        if let cached = cache[cacheKey] {
            return cached
        }

        // Fetch from API
        do {
            let sunData = try await fetchFromAPI(location: location, date: date)
            cache[cacheKey] = sunData
            return sunData
        } catch {
            print("API error: \(error). Returning empty data.")
            return SunData(date: date, sunrise: nil, sunset: nil, timeZone: location.timeZone)
        }
    }

    func getComparison(for location: Location, on date: Date = Date()) async -> SunComparison {
        async let today = getSunData(for: location, on: date)
        async let yesterday = getSunData(for: location, on: Calendar.current.date(byAdding: .day, value: -1, to: date)!)

        return await SunComparison(today: today, yesterday: yesterday)
    }

    func getWeekComparison(for location: Location, on date: Date = Date()) async -> SunComparison {
        async let today = getSunData(for: location, on: date)
        async let weekAgo = getSunData(for: location, on: Calendar.current.date(byAdding: .day, value: -7, to: date)!)

        return await SunComparison(today: today, yesterday: weekAgo)
    }

    private func fetchFromAPI(location: Location, date: Date) async throws -> SunData {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        let urlString = "\(baseURL)?lat=\(location.latitude)&lng=\(location.longitude)&date=\(dateString)&formatted=0"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(APIResponse.self, from: data)

        guard response.status == "OK" else {
            throw URLError(.badServerResponse)
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // Try with fractional seconds first, then without
        let sunrise = isoFormatter.date(from: response.results.sunrise) ??
                      ISO8601DateFormatter().date(from: response.results.sunrise)
        let sunset = isoFormatter.date(from: response.results.sunset) ??
                     ISO8601DateFormatter().date(from: response.results.sunset)

        return SunData(
            date: date,
            sunrise: sunrise,
            sunset: sunset,
            timeZone: location.timeZone
        )
    }

    private func dateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - API Response Models

private struct APIResponse: Codable {
    let results: APIResults
    let status: String
}

private struct APIResults: Codable {
    let sunrise: String
    let sunset: String
    let solar_noon: String
    let day_length: Int
    let civil_twilight_begin: String
    let civil_twilight_end: String
    let nautical_twilight_begin: String
    let nautical_twilight_end: String
    let astronomical_twilight_begin: String
    let astronomical_twilight_end: String
}
