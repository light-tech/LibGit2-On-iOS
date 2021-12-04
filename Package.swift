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
			url: "https://github.com/light-tech/Clibgit2/releases/download/v1.1.0/Clibgit2.xcframework.zip",
			checksum: "f10e544f6180c23a4de9a965e6bc45ea3ee92b08ebbe9c7f8733446fb7c2d1db"
		),
	]
)
