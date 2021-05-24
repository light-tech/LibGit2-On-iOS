// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "Clibgit2",
	platforms: [.iOS(.v13)],
	products: [
		.library(
			name: "Clibgit2",
			targets: [ "Clibgit2" ]
		),
	],
	dependencies: [],
	targets: [
		.binaryTarget(
			name: "Clibgit2",
			url: "https://github.com/light-tech/LibGit2-On-iOS/releases/download/v1.1.0/libgit2.zip",
			checksum: "d3759b6d1a2afab954e4e2c392bf8b66d6a06f27bcd578dd5b00b5ccc48c21ab"
		),
	]
)
