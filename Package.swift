// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "libgit2",
	platforms: [.iOS(.v13)],
	products: [
		.library(
			name: "libgit2",
			targets: [
				"libgit2",
				"libssh2",
				"openssl",
				"libpcre"
			]
		),
	],
	dependencies: [],
	targets: [
		.binaryTarget(
			name: "libgit2",
			url: "https://github.com/light-tech/LibGit2-On-iOS/releases/download/v1.1.0/libgit2.xcframework.zip",
			checksum: "44cffd144c2a4d399bd2709ac3b7dd962b9cf8bf574c3fd3d5e461b468d5adc3"
		),
		.binaryTarget(
			name: "libssh2",
			url: "https://github.com/light-tech/LibGit2-On-iOS/releases/download/v1.1.0/libssh2.xcframework.zip",
			checksum: "1943c1343715a78c75dc9bf51437e5be340d7a6ee12da32eebb72c1d5ad93292"
		),
		.binaryTarget(
			name: "openssl",
			url: "https://github.com/light-tech/LibGit2-On-iOS/releases/download/v1.1.0/openssl.xcframework.zip",
			checksum: "bc65ee3ba94a344e68baa0cecbbafab9c670eebe64ea04d874e701f26f8e6d2c"
		),
		.binaryTarget(
			name: "libpcre",
			url: "https://github.com/light-tech/LibGit2-On-iOS/releases/download/v1.1.0/libpcre.xcframework.zip",
			checksum: "9531c455c5e06c8225e4d24502cc4829e5de56ca8242fe249378b19a3cd7ba92"
		),
	]
)
