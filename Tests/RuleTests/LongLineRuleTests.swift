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

class LongLineRuleTests : XCTestCase {
  func testProperties() {
    let rule = LongLineRule()

    XCTAssertEqual(rule.identifier, "long_line")
    XCTAssertEqual(rule.name, "Long Line")
    XCTAssertEqual(rule.fileName, "LongLineRule.swift")
    XCTAssertEqual(rule.description, """
      When a line of code is very long, it largely harms the readability.
      Break long lines of code into multiple lines.
      """)
    XCTAssertEqual(rule.examples?.count, 1)
    XCTAssertEqual(rule.examples?[0],
      "let a012345678901234567890123456789...1234567890123456789012345678901234567890123456789")
    XCTAssertEqual(rule.thresholds?.count, 1)
    XCTAssertEqual(rule.thresholds?.keys.first, "LONG_LINE")
    XCTAssertEqual(rule.thresholds?.values.first, "The long line reporting threshold, default value is 100.")
    XCTAssertNil(rule.additionalDocument)
    XCTAssertEqual(rule.severity, .minor)
    XCTAssertEqual(rule.category, .size)
  }

  func testShortText() {
    XCTAssertTrue(getIssues(from: """
    let a
    b
    """).isEmpty)
  }

  func testLongText() {
    let issues = getIssues(from: """
    let a = b
    foo() {}
    """)
    XCTAssertEqual(issues.count, 2)
    let issue0 = issues[0]
    XCTAssertEqual(issue0.ruleIdentifier, "long_line")
    XCTAssertEqual(issue0.description, "Line with 9 characters exceeds limit of 5")
    XCTAssertEqual(issue0.category, .size)
    XCTAssertEqual(issue0.severity, .minor)
    let range0 = issue0.location
    XCTAssertEqual(range0.start.path, "test/test")
    XCTAssertEqual(range0.start.line, 1)
    XCTAssertEqual(range0.start.column, 1)
    XCTAssertEqual(range0.end.path, "test/test")
    XCTAssertEqual(range0.end.line, 1)
    XCTAssertEqual(range0.end.column, 9)
    let issue1 = issues[1]
    XCTAssertEqual(issue1.ruleIdentifier, "long_line")
    XCTAssertEqual(issue1.description, "Line with 8 characters exceeds limit of 5")
    XCTAssertEqual(issue1.category, .size)
    XCTAssertEqual(issue1.severity, .minor)
    let range1 = issue1.location
    XCTAssertEqual(range1.start.path, "test/test")
    XCTAssertEqual(range1.start.line, 2)
    XCTAssertEqual(range1.start.column, 1)
    XCTAssertEqual(range1.end.path, "test/test")
    XCTAssertEqual(range1.end.line, 2)
    XCTAssertEqual(range1.end.column, 8)
  }

  private func getIssues(from content: String) -> [Issue] {
    return content.inspect(
      withRule: LongLineRule(),
      configurations: [LongLineRule.ThresholdKey: 5]
    )
  }

  static var allTests = [
    ("testProperties", testProperties),
    ("testShortText", testShortText),
    ("testLongText", testLongText),
  ]
}
