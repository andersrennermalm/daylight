import SwiftUI

struct LocationRowView: View {
    let location: Location
    let date: Date
    let isPrimary: Bool

    @State private var comparison: SunComparison?
    @State private var weekComparison: SunComparison?
    @State private var isLoading = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Location header
            HStack {
                Text(location.name)
                    .font(.headline)
                if isPrimary {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
                Spacer()
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                } else if let comparison = comparison {
                    Text(comparison.menuBarText)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(comparison.dayLengthDifference ?? 0 >= 0 ? .green : .orange)
                }
            }

            if let comparison = comparison {
                // Sun times
                HStack(spacing: 16) {
                    Label(comparison.today.sunriseFormatted(), systemImage: "sunrise.fill")
                        .foregroundColor(.orange)
                    Label(comparison.today.sunsetFormatted(), systemImage: "sunset.fill")
                        .foregroundColor(.purple)
                    Spacer()
                    Text(comparison.today.dayLengthFormatted)
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)

                // Comparison with previous day
                VStack(alignment: .leading, spacing: 4) {
                    Text("vs previous day:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "sunrise")
                                .font(.caption)
                            Text(comparison.formatSunriseDifference())
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)

                        HStack(spacing: 4) {
                            Image(systemName: "sunset")
                                .font(.caption)
                            Text(comparison.formatSunsetDifference())
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }

                // Week comparison
                if let weekComparison = weekComparison {
                    HStack {
                        Text("vs last week:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(weekComparison.formatDifference(weekComparison.dayLengthDifference))
                            .font(.caption)
                            .foregroundColor(weekComparison.dayLengthDifference ?? 0 >= 0 ? .green : .orange)
                    }
                }
            } else if !isLoading {
                Text("Failed to load data")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .task(id: date) {
            await loadData()
        }
    }

    private func loadData() async {
        isLoading = true
        async let comp = SolarService.shared.getComparison(for: location, on: date)
        async let weekComp = SolarService.shared.getWeekComparison(for: location, on: date)

        comparison = await comp
        weekComparison = await weekComp
        isLoading = false
    }
}
