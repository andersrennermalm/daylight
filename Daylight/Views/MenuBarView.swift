import SwiftUI

struct MenuBarView: View {
    @ObservedObject private var locationStore = LocationStore.shared
    @State private var showingSettings = false
    @State private var showingCalendar = false
    @State private var selectedDate = Date()

    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E d MMM"
        return formatter
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with date navigation
            HStack {
                // Date on left (clickable for calendar)
                VStack(alignment: .leading, spacing: 2) {
                    Button(action: { showingCalendar.toggle() }) {
                        HStack(spacing: 4) {
                            Text(dateFormatter.string(from: selectedDate))
                                .font(.headline)
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $showingCalendar) {
                        VStack {
                            DatePicker(
                                "Select Date",
                                selection: $selectedDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .padding()

                            HStack {
                                Button("Today") {
                                    selectedDate = Date()
                                    showingCalendar = false
                                }
                                Spacer()
                                Button("Done") {
                                    showingCalendar = false
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                        .frame(width: 280)
                    }

                    if !isToday {
                        Button("Today") {
                            selectedDate = Date()
                        }
                        .font(.caption)
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                    }
                }

                Spacer()

                // Navigation buttons on right
                HStack(spacing: 12) {
                    Button(action: { changeDate(by: -1) }) {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.plain)

                    Button(action: { changeDate(by: 1) }) {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(.plain)

                    Button(action: { showingSettings.toggle() }) {
                        Image(systemName: "gear")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            // Location list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(locationStore.locations) { location in
                        LocationRowView(
                            location: location,
                            date: selectedDate,
                            isPrimary: location.id == locationStore.primaryLocationId
                        )
                    }
                }
                .padding()
            }

            Divider()

            // Footer
            HStack {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .frame(width: 320, height: 400)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    private func changeDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            selectedDate = newDate
        }
    }
}
