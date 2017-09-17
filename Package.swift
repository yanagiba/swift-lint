// swift-tools-version:4.0

/*
   Copyright 2015-2017 Ryuichi Laboratories and the Yanagiba project contributors

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

import PackageDescription

let package = Package(
  name: "swift-lint",
  products: [
    .executable(
      name: "swift-lint",
      targets: [
        "swift-lint",
      ]
    ),
    .library(
      name: "SwiftMetric",
      targets: [
        "Metric",
      ]
    ),
    .library(
      name: "SwiftLint",
      targets: [
        "Lint",
      ]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/yanagiba/swift-ast",
      .revision("a43c70f939040106a5bdb988aecfe3d473c3900c")
    ),
    .package(
      url: "https://github.com/yanagiba/bocho",
      .revision("0ae6150eb446c772c03574a911ff5682f8bba72c")
    ),
  ],
  targets: [
    .target(
      name: "Metric",
      dependencies: [
        "SwiftAST",
      ]
    ),
    .target(
      name: "Lint",
      dependencies: [
        "Metric",
        "SwiftAST+Tooling",
      ]
    ),
    .target(
      name: "swift-lint",
      dependencies: [
        "Lint",
        "Bocho",
      ]
    ),
    .target(
      name: "swift-lint-docgen",
      dependencies: [
        "Lint",
      ]
    ),

    // MARK: Tests

    .testTarget(
      name: "CrithagraTests"
    ),
    .testTarget(
      name: "MetricTests",
      dependencies: [
        "Metric",
      ]
    ),
    .testTarget(
      name: "LintTests",
      dependencies: [
        "Lint",
      ]
    ),
    .testTarget(
      name: "RuleTests",
      dependencies: [
        "Lint",
      ]
    ),
    .testTarget(
      name: "ReporterTests",
      dependencies: [
        "Lint",
      ]
    ),
  ],
  swiftLanguageVersions: [4]
)
