# Daylight

A macOS menu bar app that shows sunrise/sunset times and tracks how daylight changes day-to-day.

![macOS](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)

## Features

- **Menu bar display** - Shows daily daylight change (e.g., "+2m 14s")
- **Multiple locations** - Track sunrise/sunset for different cities
- **Date navigation** - Browse past/future dates with arrows or calendar picker
- **Day comparisons** - See changes vs previous day and vs last week
- **City search** - Find locations by name or enter coordinates manually
- **Launch at Login** - Optional auto-start on system boot
- **Offline caching** - Previously fetched data is cached in memory

## Screenshots

The app lives in your menu bar showing the day length change:
```
+2m 14s
```

Click to see full details for all your locations:
```
┌─────────────────────────────────────┐
│ Sat 11 Jan 📅        < > ⚙         │
├─────────────────────────────────────┤
│ Stockholm                   +2m 14s │
│ 🌅 08:32    🌇 15:18       6h 46m   │
│ vs previous day:                    │
│   ☀ 1m 9s earlier  🌙 1m 57s later │
│ vs last week: +15m 23s              │
├─────────────────────────────────────┤
│ Älvdalen                    +2m 08s │
│ 🌅 08:45    🌇 14:52       6h 7m    │
│ ...                                 │
└─────────────────────────────────────┘
```

## Installation

### From Source

Requires Xcode 15+ or Swift 5.9+.

```bash
git clone <repo>
cd daylight
./build.sh
cp -r Daylight.app /Applications/
```

### Running

```bash
open /Applications/Daylight.app
```

Or just double-click the app in Finder.

## Usage

1. **Click the menu bar text** to open the dropdown
2. **Add locations** via Settings (gear icon) → Add Location
3. **Navigate dates** using `<` `>` arrows or click the date for a calendar
4. **Set primary location** by clicking the star icon (determines menu bar display)
5. **Enable auto-start** in Settings → Launch at Login

## Data Source

Sunrise/sunset times are fetched from [sunrise-sunset.org](https://sunrise-sunset.org/api), a free API that provides accurate solar calculation data.

## Building

```bash
# Quick build (debug)
swift build

# Release build with .app bundle
./build.sh
```

The build script creates a signed `Daylight.app` bundle ready for use.

## Project Structure

```
Daylight/
├── Models/          # Data structures
├── Services/        # API, persistence, geocoding
├── Views/           # SwiftUI views
├── AppDelegate.swift
├── DaylightApp.swift
└── Info.plist
```

## Requirements

- macOS 13.0 (Ventura) or later
- Internet connection (for fetching sun data)

## License

MIT
