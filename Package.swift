// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CrystalsAndDragons",
    products: [
        .executable(name: "CrystalsAndDragons", targets: ["App"])
    ],
    targets: [
        .target(
            name: "Model",
            path: "Sources/CrystalsAndDragons/Model",
            swiftSettings: [
                .unsafeFlags(["-warnings-as-errors"])
            ]
        ),
        .target(
            name: "View",
            path: "Sources/CrystalsAndDragons/View",
            swiftSettings: [
                .unsafeFlags(["-warnings-as-errors"])
            ]
        ),
        .target(
            name: "Controller",
            dependencies: ["Model", "View"],
            path: "Sources/CrystalsAndDragons/Controller",
            swiftSettings: [
                .unsafeFlags(["-warnings-as-errors"])
            ]
        ),
        .executableTarget(
            name: "App",
            dependencies: ["Controller"],
            path: "Sources/CrystalsAndDragons/App",
//            swiftSettings: [
//                .unsafeFlags(["-warnings-as-errors"])
//            ]
        ),
    ]
)
