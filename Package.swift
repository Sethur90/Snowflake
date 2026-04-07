// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Snowflake",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "Snowflake", targets: ["Snowflake"])
    ],
    targets: [
        .target(
            name: "Snowflake",
            path: "Sources/iOS"
        ),
        .testTarget(
            name: "SnowflakeTests",
            dependencies: ["Snowflake"],
            path: "SnowflakeTests/Shared"
        )
    ]
)
