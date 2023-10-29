// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "SimpleSplitView",
  platforms: [.macOS(.v12),
              .iOS(.v15),
              .macCatalyst(.v15)],
  products: [
    .library(name: "SimpleSplitView", targets: ["SimpleSplitView"])
  ],
  dependencies: [],
  targets: [
    .target(name: "SimpleSplitView", dependencies: [])
  ]
)
