# Swift Lint

[![Travis CI Status](https://api.travis-ci.org/yanagiba/swift-lint.svg?branch=master)](https://travis-ci.org/yanagiba/swift-lint)
[![codecov](https://codecov.io/gh/yanagiba/swift-lint/branch/master/graph/badge.svg)](https://codecov.io/gh/yanagiba/swift-lint)
![Swift 3.1](https://img.shields.io/badge/swift-3.1-brightgreen.svg)
[![swift-ast 0.2.0](https://img.shields.io/badge/swift‐ast-0.2.0-C70025.svg)](https://github.com/yanagiba/swift-ast)
![Swift Package Manager](https://img.shields.io/badge/SPM-ready-orange.svg)
![Platforms](https://img.shields.io/badge/platform-%20Linux%20|%20macOS%20-red.svg)
![License](https://img.shields.io/github/license/yanagiba/swift-lint.svg)

The Swift Lint is a static code analysis tool for improving quality and reducing
defects by inspecting [Swift](https://swift.org/about/) code and looking for
potential problems like possible bugs, unused code, complicated code, redundant
code, code smells, bad practices, and so on.

Swift Lint relies on the [abstract syntax tree](https://github.com/yanagiba/swift-ast)
of the source code for better accuracy and efficiency.

* * *

## A Work In Progress

Both the [Swift Abstract Syntax Tree](https://github.com/yanagiba/swift-ast)
and the Swift Lint are still in early design and development. Many features are
incomplete or partially implemented. Some with technical limitations.

Please also check out the [status](https://github.com/yanagiba/swift-ast#a-work-in-progress) from [swift-ast](https://github.com/yanagiba/swift-ast).

## Requirements

- [Swift 3.1](https://swift.org/download/)

## Installing

### Standalone Tool

To use it as a standalone tool, clone this repository to your local machine by

```bash
git clone https://github.com/yanagiba/swift-lint
```

Go to the repository folder, run the following command:

```bash
swift build
```

### Embed Into Your Project

Add the swift-lint dependency to your SPM dependencies in Package.swift:

```swift
import PackageDescription

let package = Package(
  name: "MyAwesomeProject",
  testDependencies: [
    .Package(url: "https://github.com/yanagiba/swift-lint.git", majorVersion: 0)
  ]
)
```

An example project will be added soon.

## Usage

### Command Line

Simply append the path(s) of the file(s) to `swift-lint`:

```bash
swift-lint path/to/Awesome.swift
swift-lint path1/to1/foo.swift path2/to2/bar.swift ... path3/to3/main.swift
```

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
- ryuichi@ryuichisaito.com

## License

Swift Lint is available under the Apache License 2.0.
See the [LICENSE](LICENSE) file for more info.
