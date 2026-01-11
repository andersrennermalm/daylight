# Daylight - Claude Instructions

## Project Overview
A macOS menu bar app showing sunrise/sunset times and day length changes for multiple locations.

## Tech Stack
- Swift 5.9+ / SwiftUI
- macOS 13+ (Ventura)
- sunrise-sunset.org API for solar calculations
- No external dependencies (removed Solar library)

## Architecture

```
Daylight/
├── DaylightApp.swift          # App entry, @main
├── AppDelegate.swift          # NSStatusItem menu bar setup
├── Info.plist                 # LSUIElement=true (hides from dock)
├── Models/
│   ├── Location.swift         # Location with coordinates & timezone
│   └── SunData.swift          # Sun times + SunComparison for diffs
├── Services/
│   ├── SolarService.swift     # API calls with in-memory cache
│   ├── LocationStore.swift    # UserDefaults persistence
│   └── GeocodingService.swift # CLGeocoder city search
└── Views/
    ├── MenuBarView.swift      # Main dropdown with date navigation
    ├── LocationRowView.swift  # Per-location sun data card
    ├── SettingsView.swift     # Location management + Launch at Login
    └── AddLocationView.swift  # City search or manual coordinates
```

## Key Implementation Details

### API Usage
- Endpoint: `https://api.sunrise-sunset.org/json?lat={lat}&lng={lng}&date={YYYY-MM-DD}&formatted=0`
- Returns times in UTC (ISO8601 format)
- Cached per location+date to avoid duplicate calls
- Async/await throughout

### Menu Bar
- Uses NSStatusItem with variable length
- Title shows day length change (e.g., "+2m 14s")
- Popover contains SwiftUI MenuBarView

### Persistence
- Locations stored in UserDefaults as JSON
- Keys: `savedLocations`, `primaryLocationId`
- Bundle ID: `com.andersrennermalm.daylight`

## Build Commands

```bash
# Development build
swift build

# Release build + create .app bundle
./build.sh

# Install to Applications
cp -r Daylight.app /Applications/
```

## Common Tasks

### Add a new data field from API
1. Add property to `APIResults` struct in `SolarService.swift`
2. Add property to `SunData` struct
3. Update `fetchFromAPI` to parse it
4. Display in `LocationRowView`

### Change menu bar display
- Edit `AppDelegate.updateMenuBarTitle()` for what's shown
- Edit `SunComparison.menuBarText` for formatting

### Add new settings
- Add UI in `SettingsView.swift`
- Store in UserDefaults via `LocationStore` or new service
