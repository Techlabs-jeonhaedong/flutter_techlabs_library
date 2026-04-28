// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "flutter_techlabs_library",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "flutter-techlabs-library", targets: ["flutter_techlabs_library"])
    ],
    dependencies: [
        .package(url: "https://github.com/thyadang-techlabs/iOS-techlabs-library.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "flutter_techlabs_library",
            dependencies: [
                .product(name: "ios_techlabs_library", package: "iOS-techlabs-library")
            ],
            resources: []
        )
    ]
)
