// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "CarFuturePackage",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "CarFuturePackage", targets: ["CarFuturePackage"])
    ],
    targets: [
        .target(
            name: "CarFuturePackage",
            path: "Sources/CarFuturePackage",
        )
    ]
)
