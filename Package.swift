// swift-tools-version: 6.0
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

import PackageDescription

let package = Package(
    name: "bare-swift-cli",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "bare-swift", targets: ["BareSwiftCLI"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0")
    ],
    targets: [
        .executableTarget(
            name: "BareSwiftCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            resources: [.copy("Resources")]
        ),
        .testTarget(
            name: "BareSwiftCLITests",
            dependencies: ["BareSwiftCLI"]
        )
    ]
)
