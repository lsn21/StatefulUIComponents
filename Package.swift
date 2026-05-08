// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "StatefulUIComponents",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "StatefulUIComponents",
            targets: ["StatefulUIComponents"]
        )
    ],
    targets: [
        .target(
            name: "StatefulUIComponents",
            path: "Classes"
        )
    ]
)
