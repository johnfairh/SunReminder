// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "SunReminder",
    platforms: [
      .macOS("26.0"),
      .iOS("26.0")
    ],
    products: [
        .library(
            name: "SunReminder",
            targets: ["SunReminder"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/johnfairh/swift-sunrise-sunset.git",
            from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SunReminder",
            dependencies: [
                .product(name: "SwiftSunriseSunset",
                         package: "swift-sunrise-sunset")
            ]
        ),
        .testTarget(
            name: "SunReminderTests",
            dependencies: ["SunReminder"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
