// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Gini",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "Gini",
            targets: ["Gini"]),
    ],
    dependencies: [
        .package(url: "https://github.com/datatheorem/TrustKit", from: "1.6.5")
    ],
    targets: [
        .target(
            name: "Gini",
            dependencies: ["TrustKit"],
            path: "Gini/Classes"),
        
        
        // Unit Tests are currently unsupported using Swift Package Manager due to the lack
        // of resources support. Hence, the Tests/Assets/.json files cannot be embedded into
        // the test target, leading to runtime crashes in the tests due to missing resources.
        // Resources support for SPM has been implemented with SE-0271 and will be released
        // as part of Swift 5.3.
        // https://github.com/apple/swift-evolution/blob/master/proposals/0271-package-manager-resources.md
        
        /*.testTarget(
            name: "GiniTests",
            dependencies: ["Gini"],
            path: "Gini/Tests"),*/
    ]
)
