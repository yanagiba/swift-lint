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

class NestedCodeBlockDepthRuleTests : XCTestCase {
  func testProperties() {
    let rule = NestedCodeBlockDepthRule()

    XCTAssertEqual(rule.identifier, "nested_code_block_depth")
    XCTAssertEqual(rule.name, "Nested Code Block Depth")
    XCTAssertEqual(rule.fileName, "NestedCodeBlockDepthRule.swift")
    XCTAssertEqual(rule.description, "This rule indicates blocks nested more deeply than the upper limit.")
    XCTAssertEqual(rule.examples?.count, 1)
    XCTAssertEqual(rule.examples?[0], """
      if (1)
      {               // 1
          {           // 2
              {       // 3
              }
          }
      }
      """)
    XCTAssertEqual(rule.thresholds?.count, 1)
    XCTAssertEqual(rule.thresholds?.keys.first, "NESTED_CODE_BLOCK_DEPTH")
    XCTAssertEqual(rule.thresholds?.values.first, "The depth of a code block reporting threshold, default value is 5.")
    XCTAssertNil(rule.additionalDocument)
    XCTAssertEqual(rule.severity, .major)
    XCTAssertEqual(rule.category, .readability)
  }

  func testEmptyCodeBlock() {
    XCTAssertTrue(getIssues(from: "func foo() {}").isEmpty)
    XCTAssertTrue(getIssues(from: "init() {}").isEmpty)
    XCTAssertTrue(getIssues(from: "deinit {}").isEmpty)
    XCTAssertTrue(getIssues(from: "subscript() -> Self {}").isEmpty)
  }

  func testIfStatement() {
    let issues = getIssues(from: "func foo() { if bar {} }")
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "nested_code_block_depth")
    XCTAssertEqual(issue.description, "Code block depth of 2 exceeds limit of 1")
    XCTAssertEqual(issue.category, .readability)
    XCTAssertEqual(issue.severity, .major)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 12)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 25)
  }

  func testSwitchStatement() {
    let issues = getIssues(from: "init() { switch foo  { case a, b where b && a: break; default: break;} }")
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "nested_code_block_depth")
    XCTAssertEqual(issue.description, "Code block depth of 4 exceeds limit of 1")
    XCTAssertEqual(issue.category, .readability)
    XCTAssertEqual(issue.severity, .major)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 8)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 73)
  }

  func testNestedCodeBlock() {
    let issues = getIssues(from: "deinit { if foo { let a = 2 } }")
    XCTAssertEqual(issues.count, 2)

    let issue1 = issues[0]
    XCTAssertEqual(issue1.ruleIdentifier, "nested_code_block_depth")
    XCTAssertEqual(issue1.description, "Code block depth of 3 exceeds limit of 1")
    XCTAssertEqual(issue1.category, .readability)
    XCTAssertEqual(issue1.severity, .major)
    let range1 = issue1.location
    XCTAssertEqual(range1.start.path, "test/test")
    XCTAssertEqual(range1.start.line, 1)
    XCTAssertEqual(range1.start.column, 8)
    XCTAssertEqual(range1.end.path, "test/test")
    XCTAssertEqual(range1.end.line, 1)
    XCTAssertEqual(range1.end.column, 32)

    let issue2 = issues[1]
    XCTAssertEqual(issue2.ruleIdentifier, "nested_code_block_depth")
    XCTAssertEqual(issue2.description, "Code block depth of 2 exceeds limit of 1")
    XCTAssertEqual(issue2.category, .readability)
    XCTAssertEqual(issue2.severity, .major)
    let range2 = issue2.location
    XCTAssertEqual(range2.start.path, "test/test")
    XCTAssertEqual(range2.start.line, 1)
    XCTAssertEqual(range2.start.column, 17)
    XCTAssertEqual(range2.end.path, "test/test")
    XCTAssertEqual(range2.end.line, 1)
    XCTAssertEqual(range2.end.column, 30)
  }

  func testParallelCodeBlock() {
    let issues = getIssues(from: "subscript() -> Self { do {} catch e1 {} catch e2 {} catch {} }")
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "nested_code_block_depth")
    XCTAssertEqual(issue.description, "Code block depth of 2 exceeds limit of 1")
    XCTAssertEqual(issue.category, .readability)
    XCTAssertEqual(issue.severity, .major)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 21)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 63)
  }

  private func getIssues(from content: String) -> [Issue] {
    return content.inspect(
      withRule: NestedCodeBlockDepthRule(),
      configurations: [NestedCodeBlockDepthRule.ThresholdKey: 1]
    )
  }

  static var allTests = [
    ("testProperties", testProperties),
    ("testEmptyCodeBlock", testEmptyCodeBlock),
    ("testIfStatement", testIfStatement),
    ("testSwitchStatement", testSwitchStatement),
    ("testNestedCodeBlock", testNestedCodeBlock),
    ("testParallelCodeBlock", testParallelCodeBlock),
  ]
}
