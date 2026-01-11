// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Daylight",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "Daylight",
            path: "Daylight",
            exclude: ["Info.plist"]
        )
    ]
)
