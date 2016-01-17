# Swift Lint

[![Travis CI Status](https://api.travis-ci.org/yanagiba/swift-lint.svg?branch=master)](https://travis-ci.org/yanagiba/swift-lint)

The Swift Lint is a static code analysis tool for improving quality and reducing
defects by inspecting [Swift](https://swift.org/about/) code and looking for
potential problems like possible bugs, unused code, complicated code, redundant
code, code smells, bad practices, and so on.

Swift Lint replies on the [abstract syntax tree](https://github.com/yanagiba/swift-ast)
of the source code for better accuracy and efficiency.

* * *

## A Work In Progress

Both the [Swift Abstract Syntax Tree](https://github.com/yanagiba/swift-ast)
and the Swift Lint are still in early design and development. Many features are
incomplete or partially implemented. Some with technical limitations.

Please also check out the [status](https://github.com/yanagiba/swift-ast#a-work-in-progress) and [technical limitations](https://github.com/yanagiba/swift-ast#known-limitations) from [swift-ast](https://github.com/yanagiba/swift-ast).

## Requirements

- [Swift 2.2 Snapshot](https://swift.org/download/)

## Installing

### Standalone Tool

To use it as a standalone tool, clone this repository to your local machine by

```bash
git clone https://github.com/yanagiba/swift-lint
```

Go to the repository folder, run the following command:

```bash
make && make install
```

For Mac users, it will prompt for `sudo` passcode. This will automatically finds
the path for the current swift you are using, and install the executable to
the correct location.

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

```bash
$ swift lint --help
Usage:

    $ /usr/bin/swift-lint <file paths>

Options:
    --report-type - Change output report type
    --streaming - Enable streaming outputs immediately when issues are emitted
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

### Running [Spectre](https://github.com/kylef/Spectre) Tests

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
