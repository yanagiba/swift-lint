# Write New Reporter

Swift Lint bundles with few reporters, such as `text`, `html`, `json`, and others. You can also write your custom ones:

1. Create a new `XYZReporter` class that conforms to `Reporter` protocol. Although all properties and methods in `Reporter` protocol have default implementations, you may change the behaviors of some (if not all) to meet your needs.

2. Now open `Driver.swift` file, and look for `setReporter(with:)` method. Inside here, give your reporter a name and then initialize `reporter` variable with it:

  ```
  switch type {
  ... existing reporters
  case "xyz":
    reporter = XYZReporter()
  default:
    reporter = TextReporter()
  }
  ```

3. Add tests to `ReporterTests` module, and please use existing reporter test cases as examples.

4. Add the test cases to `ReporterTests/XCTestManifests`. This is needed for running the tests on Linux (for now, and hopefully SPM can address this soon).

5. Make sure `make test` pass on both Linux and macOS.

6. Run dogfooding (`./dogFooding.sh`) to make sure the code is inspected by the tool itself. Fix found issues if any.

7. Send us a pull request with your newly implemented reporter, so others may benefit from your efforts. Thanks.
