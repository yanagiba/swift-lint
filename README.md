# Swift Lint

[![swift-ast 0.3.5](https://img.shields.io/badge/swift‐ast-0.3.5-C70025.svg)](https://github.com/yanagiba/swift-ast)
[![swift-lint master](https://img.shields.io/badge/swift‐lint-master-C70025.svg)](https://github.com/yanagiba/swift-lint)
[![swift-transform pending](https://img.shields.io/badge/swift‐transform-pending-C70025.svg)](https://github.com/yanagiba/swift-transform)

[![Travis CI Status](https://api.travis-ci.org/yanagiba/swift-lint.svg?branch=master)](https://travis-ci.org/yanagiba/swift-lint)
[![codecov](https://codecov.io/gh/yanagiba/swift-lint/branch/master/graph/badge.svg)](https://codecov.io/gh/yanagiba/swift-lint)
![Swift 4.0-beta](https://img.shields.io/badge/swift-4.0‐beta-brightgreen.svg)
![Swift Package Manager](https://img.shields.io/badge/SPM-ready-orange.svg)
![Platforms](https://img.shields.io/badge/platform-%20Linux%20|%20macOS%20-red.svg)
![License](https://img.shields.io/github/license/yanagiba/swift-lint.svg)

Swift Lint (`swift-lint`) is a static code analysis tool for improving quality and reducing
defects by inspecting [Swift](https://swift.org/about/) code and looking for
potential problems, such as possible bugs, unused code, complicated code, redundant
code, code smells, bad practices, and so on.

Swift Lint relies on [Swift Abstract Syntax Tree (`swift-ast`)](http://yanagiba.org/swift-ast)
of the source code for better accuracy and efficiency.

Swift Lint is part of [Yanagiba Project](http://yanagiba.org). Yanagiba umbrella project is a toolchain of compiler modules, libraries, and utilities, written in Swift and for Swift.

* * *

- [Requirements](#requirements)
- [Installation](#installation)
  - [Standalone Tool](#standalone-tool)
  - [Embed Into Your Project](#embed-into-your-project)
- [Usage and Documentation](#usage--documentation)
  - [Command Line](#command-line)
  - [Documentation](#documentation)
- [Development](#development)
- [Contact](#contact)
- [License](#license)

* * *

## A Work In Progress

Both Swift Abstract Syntax Tree and Swift Lint are in active development.
Though many features are implemented, some are with limitations.

Swift Lint doesn't modify your code, therefore,
the tool is safe to be deployed in production environment while we are working hard towards 1.0 release.
Please be cautious with bugs, edge cases and false positives (issues and pull requests are welcomed).

Please also check out the [status](https://github.com/yanagiba/swift-ast#a-work-in-progress) from [swift-ast](https://github.com/yanagiba/swift-ast).

## Requirements

- [Swift 4.0-DEVELOPMENT-SNAPSHOT-2017-06-06-a](https://swift.org/download/)

## Installation

### Standalone Tool

To use it as a standalone tool, clone this repository to your local machine by

```bash
git clone https://github.com/yanagiba/swift-lint
```

Go to the repository folder, run the following command:

```bash
swift build -c release
```

This will generate a `swift-lint` executable inside `.build/release` folder.

#### Adding to `swift` Path (Recommended, but Optional)

It is recommended to copy the `swift-lint` to the same folder that your `swift` binary resides.

For example, if `swift` is installed at (Linux) or the toolchain (macOS)'s `bin` path is

```
/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
```

Then copy `swift-lint` to it by

```
cp .build/release/swift-lint /Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-lint
```

Once you have done this, you can invoke `swift-lint` by
calling `swift lint` in your terminal directly.

### Embed Into Your Project

Add the `swift-lint` dependency to your Swift Package Manager (SPM) dependencies in `Package.swift`:

```swift
// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "MyPackage",
  dependencies: [
    .package(url: "https://github.com/yanagiba/swift-lint.git", from: "0.2.0")
  ],
  targets: [
    .target(name: "MyTarget", dependencies: ["SwiftMetric", "SwiftLint"]),
  ],
  swiftLanguageVersions: [4]
)
```

An example project will be added in the future.

## Usage & Documentation

### Command Line

Simply provide the file paths to `swift-lint`:

```bash
swift-lint path/to/Awesome.swift
swift-lint path1/to1/foo.swift path2/to2/bar.swift ... path3/to3/main.swift
```

#### CLI Options

Run `swift-lint --help` to get the updated command line options.

### Documentation

Go to [Documentation](Documentation/README.md) for details.

## Development

### Build & Run

Building the entire project can be done by simply calling:

```bash
make
```

This is equivalent to

```bash
swift build
```

The dev version of the tool will be generated to `.build/debug/swift-lint`.

### Running Tests

Compile and run the entire tests by:

```bash
make test
```

## Contact

Ryuichi Saito

- http://github.com/ryuichis
- ryuichi@yanagiba.org

## License

Swift Lint is available under the Apache License 2.0.
See the [LICENSE](LICENSE) file for more info.
