/*
   Copyright 2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

@testable import Lint

class TooManyParametersRuleTests : XCTestCase {
  func testNoParameter() {
    XCTAssertTrue(getIssues(from: """
    func foo() {}
    init() {}
    subscript() -> Self {}
    let bar: () -> Void
    """).isEmpty)
  }

  func testOneParameter() {
    XCTAssertTrue(getIssues(from: """
    func foo(a: Int) {}
    init(b: Double) {}
    subscript(c: String) -> Self {}
    let bar: (Bool) -> Void
    """).isEmpty)
  }

  func testFunction() {
    let issues = getIssues(from: "func foo(a1: Int, a2: Int, a3: Int) {} }")
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "too_many_parameters")
    XCTAssertEqual(issue.description, "Method with 3 parameters exceeds limit of 1")
    XCTAssertEqual(issue.category, .readability)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 39)
  }

  func testInitializer() {
    let issues = getIssues(from: "init(a1: Int, a2: Int) {} }")
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "too_many_parameters")
    XCTAssertEqual(issue.description, "Method with 2 parameters exceeds limit of 1")
    XCTAssertEqual(issue.category, .readability)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 26)
  }

  func testSubscript() {
    let issues = getIssues(from: "subscript(a1: Int, a2: Int, a3: Int, a4: int) -> Self {} }")
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "too_many_parameters")
    XCTAssertEqual(issue.description, "Method with 4 parameters exceeds limit of 1")
    XCTAssertEqual(issue.category, .readability)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 57)
  }

  private func getIssues(from content: String) -> [Issue] {
    return content.inspect(
      withRule: TooManyParametersRule(),
      configurations: [TooManyParametersRule.ThresholdKey: 1]
    )
  }

  static var allTests = [
    ("testNoParameter", testNoParameter),
    ("testOneParameter", testOneParameter),
    ("testFunction", testFunction),
    ("testInitializer", testInitializer),
    ("testSubscript", testSubscript),
  ]
}
