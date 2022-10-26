// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WorkableConcurrency",
	platforms: [
		.iOS(.v13),
		.tvOS(.v13),
		.macOS(.v10_15),
		.macCatalyst(.v13),
		//TODO: watch os?
		//TODO: other os's?
	],
    products: [
        ///a library of helper methods for concurrency, particuarly for use with Combine and URLSession
        .library(
            name: "WorkableConcurrency",
			type: .dynamic,
            targets: ["WorkableConcurrency"]),
		
		///help for writing tests with concurrency
		.library(
			name: "WorkableXCTestConcurrency",
			type: .dynamic,
			targets: ["WorkableXCTestConcurrency"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "WorkableConcurrency",
            dependencies: []),
		.target(
			name: "WorkableXCTestConcurrency",
			dependencies: ["WorkableConcurrency"]),
        .testTarget(
            name: "WorkableConcurrencyTests",
            dependencies: ["WorkableConcurrency",
						   "WorkableXCTestConcurrency",
						  ]),
    ]
)
