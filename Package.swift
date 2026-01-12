// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "HapticNotationLanguage",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "HapticNotationLanguage",
            targets: ["HapticNotationLanguage"]
        ),
    ],
    targets: [
        .target(
            name: "HapticNotationLanguage"
        ),
        .testTarget(
            name: "HapticNotationLanguageTests",
            dependencies: ["HapticNotationLanguage"]
        ),
    ]
)
