import Foundation

struct SunData {
    let date: Date
    let sunrise: Date?
    let sunset: Date?
    let timeZone: TimeZone

    var dayLength: TimeInterval? {
        guard let sunrise = sunrise, let sunset = sunset else { return nil }
        return sunset.timeIntervalSince(sunrise)
    }

    var dayLengthFormatted: String {
        guard let dayLength = dayLength else { return "N/A" }
        let hours = Int(dayLength) / 3600
        let minutes = (Int(dayLength) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    func sunriseFormatted(style: DateFormatter.Style = .short) -> String {
        guard let sunrise = sunrise else { return "N/A" }
        let formatter = DateFormatter()
        formatter.timeStyle = style
        formatter.dateStyle = .none
        formatter.timeZone = timeZone
        return formatter.string(from: sunrise)
    }

    func sunsetFormatted(style: DateFormatter.Style = .short) -> String {
        guard let sunset = sunset else { return "N/A" }
        let formatter = DateFormatter()
        formatter.timeStyle = style
        formatter.dateStyle = .none
        formatter.timeZone = timeZone
        return formatter.string(from: sunset)
    }
}

struct SunComparison {
    let today: SunData
    let yesterday: SunData

    var sunriseDifference: TimeInterval? {
        guard let todaySunrise = today.sunrise, let yesterdaySunrise = yesterday.sunrise else { return nil }
        let todayTime = timeOfDay(todaySunrise, in: today.timeZone)
        let yesterdayTime = timeOfDay(yesterdaySunrise, in: yesterday.timeZone)
        return todayTime - yesterdayTime
    }

    var sunsetDifference: TimeInterval? {
        guard let todaySunset = today.sunset, let yesterdaySunset = yesterday.sunset else { return nil }
        let todayTime = timeOfDay(todaySunset, in: today.timeZone)
        let yesterdayTime = timeOfDay(yesterdaySunset, in: yesterday.timeZone)
        return todayTime - yesterdayTime
    }

    var dayLengthDifference: TimeInterval? {
        guard let todayLength = today.dayLength, let yesterdayLength = yesterday.dayLength else { return nil }
        return todayLength - yesterdayLength
    }

    private func timeOfDay(_ date: Date, in timeZone: TimeZone) -> TimeInterval {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0
        return TimeInterval(hours * 3600 + minutes * 60 + seconds)
    }

    func formatDifference(_ interval: TimeInterval?) -> String {
        guard let interval = interval else { return "N/A" }
        let absInterval = abs(interval)
        let minutes = Int(absInterval) / 60
        let seconds = Int(absInterval) % 60
        let sign = interval >= 0 ? "+" : "-"

        if minutes > 0 {
            return "\(sign)\(minutes)m \(seconds)s"
        } else {
            return "\(sign)\(seconds)s"
        }
    }

    func formatSunriseDifference() -> String {
        guard let diff = sunriseDifference else { return "N/A" }
        let absSeconds = abs(Int(diff))
        let minutes = absSeconds / 60
        let seconds = absSeconds % 60

        if diff < 0 {
            return "\(minutes)m \(seconds)s earlier"
        } else if diff > 0 {
            return "\(minutes)m \(seconds)s later"
        } else {
            return "same time"
        }
    }

    func formatSunsetDifference() -> String {
        guard let diff = sunsetDifference else { return "N/A" }
        let absSeconds = abs(Int(diff))
        let minutes = absSeconds / 60
        let seconds = absSeconds % 60

        if diff > 0 {
            return "\(minutes)m \(seconds)s later"
        } else if diff < 0 {
            return "\(minutes)m \(seconds)s earlier"
        } else {
            return "same time"
        }
    }

    var menuBarText: String {
        formatDifference(dayLengthDifference)
    }
}
