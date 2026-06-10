// swift-tools-version: 6.3

import PackageDescription

let package = Package(
	name: "swupdate",
	platforms: [
		.macOS(.v15)
	],
	dependencies: [
		.package(url: "https://github.com/mxcl/Version.git", from: "2.2.1"),
		.package(url: "https://github.com/pointfreeco/swift-parsing.git", from: "0.14.1"),
	],
	targets: [
		.target(
			name: "SowftwareupdateParser",
			dependencies: [
				.product(name: "Parsing", package: "swift-parsing"),
				.product(name: "Version", package: "Version"),
			]
		),
		.testTarget(
			name: "SowftwareupdateParserTests",
			dependencies: [
				"SowftwareupdateParser",
				.product(name: "Version", package: "Version"),
			],
			resources: [
				.process("Resources"),
			]
		),
	],
	swiftLanguageModes: [.v6]
)
