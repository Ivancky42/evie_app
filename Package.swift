// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Evie-Flutter-App",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Evie-Flutter-App",
            targets: ["Evie-Flutter-App"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        // Latest stable release
        .package(name: "MapboxNavigation", url: "https://github.com/mapbox/mapbox-navigation-ios.git", from: "2.6.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Evie-Flutter-App",
            dependencies: []),
        .testTarget(
            name: "Evie-Flutter-AppTests",
            dependencies: ["Evie-Flutter-App"]),
    ]
)
