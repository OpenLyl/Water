// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
//import CompilerPluginSupport

let package = Package(
    name: "Water",
    platforms: [.iOS(.v14), .macOS(.v10_15), .tvOS(.v11), .watchOS(.v4)],
    products: [
        .library(name: "Water", targets: ["Water"]),
//        .library(name: "WaterMacro", targets:["WaterMacro"])
    ],
    dependencies: [
//        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0-swift-5.9-DEVELOPMENT-SNAPSHOT-2023-04-25-b"),
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "12.0.0")
    ],
    targets: [
        .target(name: "Water"),
        .testTarget(name: "WaterTests", dependencies: [
            "Water",
            "Quick",
            "Nimble"
        ]),
//        .macro(
//            name: "WaterMacros",
//            dependencies: [
//                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
//                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
//            ]
//        ),
//        .target(name: "WaterMacro", dependencies: ["WaterMacros"]),
//        .testTarget(
//            name: "WaterMacroTests",
//            dependencies: [
//                "WaterMacros",
//                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
//            ]
//        ),
    ]
)
