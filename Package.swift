// swift-tools-version: 6.3

import PackageDescription

let package = Package(
	name: "swupdate",
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.7.1"),
	],
	targets: [
		.executableTarget(
			name: "swupdate",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			]
		),
		.testTarget(
			name: "swupdateTests",
			dependencies: ["swupdate"]
		),
	],
	swiftLanguageModes: [.v6]
)
