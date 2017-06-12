/*
   Copyright 2015-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

import XCTest

@testable import Source
@testable import AST
@testable import Lint

fileprivate class TestDriverReporter : Reporter {
  var issues = [Issue]()

  func handle(issue: Issue) -> String {
    issues.append(issue)
    return ""
  }
}

fileprivate class TestDriverRule : Rule {
  var name: String {
    return "Test Driver"
  }

  func inspect(_ astContext: ASTContext, configurations: [String: Any]? = nil) {
    let content = astContext.sourceFile.content
    emitIssue(Issue(
      ruleIdentifier: identifier,
      description: content,
      category: .badPractice,
      location: SourceRange(
        start: SourceLocation(path: "test/testDriver", line: 0, column: 0),
        end: SourceLocation(path: "test/testDriver", line: 0, column: 0)),
      severity: .major,
      correction: nil))
  }
}

class DriverTests : XCTestCase {
  func testNoRule() {
    let testDriverReporter = TestDriverReporter()
    let testDriver = Driver()
    testDriver.updateOutputHandle(.nullDevice)
    testDriver.setReporter(testDriverReporter)
    testDriver.lint(sourceFiles: [
      SourceFile(path: "test/testDriver", content: "import foo"),
    ])
    XCTAssertTrue(testDriverReporter.issues.isEmpty)
  }

  func testLintContent() {
    let testDriverReporter = TestDriverReporter()
    let testDriver = Driver()
    testDriver.updateOutputHandle(.nullDevice)
    testDriver.setReporter(testDriverReporter)
    testDriver.registerRules([TestDriverRule()], ruleIdentifiers: ["test_driver"])
    testDriver.lint(sourceFiles: [
      SourceFile(path: "test/testDriver", content: "import foo"),
    ])
    XCTAssertEqual(testDriverReporter.issues.count, 1)
    XCTAssertEqual(testDriverReporter.issues[0].description, "import foo")
  }

  func testRegisterRuleDoesNotExist() {
    let testDriverReporter = TestDriverReporter()
    let testDriver = Driver()
    testDriver.updateOutputHandle(.nullDevice)
    testDriver.setReporter(testDriverReporter)
    testDriver.registerRules([TestDriverRule()], ruleIdentifiers: ["not_implemented"])
    testDriver.lint(sourceFiles: [
      SourceFile(path: "test/testDriver", content: "import foo"),
    ])
    XCTAssertTrue(testDriverReporter.issues.isEmpty)
  }

  static var allTests = [
    ("testNoRule", testNoRule),
    ("testLintContent", testLintContent),
    ("testRegisterRuleDoesNotExist", testRegisterRuleDoesNotExist),
  ]
}
