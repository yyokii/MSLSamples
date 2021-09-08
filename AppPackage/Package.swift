// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppPackage",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "AppPackage",
            targets: ["AppPackage"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "AppPackage",
            dependencies: []),
        
        // Test
        .testTarget(
            name: "AppPackageTests",
            dependencies: ["AppPackage"]),
    ]
)
