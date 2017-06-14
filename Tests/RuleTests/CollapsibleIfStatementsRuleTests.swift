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

class CollapsibleIfStatementsRuleTests : XCTestCase {
  func testWithElses() {
    let issues = """
      if foo { if bar {} } else {}
      if foo { if bar {} } else if {}
      if foo { if bar {} else {} }
      if foo { if bar {} else if {} }
      if foo { if bar {} else {} } else {}
      """
      .inspect(withRule: CollapsibleIfStatementsRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testWithAdditionalStatements() {
    let issues = """
      if foo { print(); if bar {} }
      if foo { if bar {}; print() }
      """
      .inspect(withRule: CollapsibleIfStatementsRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testCollapsibles() {
    let constants: [(String, String, Int)] = [
      ("foo", "bar", 21),
      ("foo, x, y", "bar", 27),
      ("foo", "bar, z", 24),
      ("foo, x, y", "bar, z", 30),
    ]
    for (outerCond, innerCond, endColumn) in constants {
      let issues = "if \(outerCond) { if \(innerCond) {} }"
        .inspect(withRule: CollapsibleIfStatementsRule())
      XCTAssertEqual(issues.count, 1)
      let issue = issues[0]
      XCTAssertEqual(issue.ruleIdentifier, "collapsible_if_statements")
      XCTAssertEqual(issue.description, "This if statement can be collapsed with its inner if statement")
      XCTAssertEqual(issue.category, .badPractice)
      XCTAssertEqual(issue.severity, .minor)
      let range = issue.location
      XCTAssertEqual(range.start.path, "test/test")
      XCTAssertEqual(range.start.line, 1)
      XCTAssertEqual(range.start.column, 1)
      XCTAssertEqual(range.end.path, "test/test")
      XCTAssertEqual(range.end.line, 1)
      XCTAssertEqual(range.end.column, endColumn)
    }
  }

  func testElseIfCanBeCollapsed() {
    let constants: [(String, String, Int)] = [
      ("foo", "bar", 40),
      ("foo, x, y", "bar", 46),
      ("foo", "bar, z", 43),
      ("foo, x, y", "bar, z", 49),
    ]
    for (outerCond, innerCond, endColumn) in constants {
      let issues = "if a, b, c {} else if \(outerCond) { if \(innerCond) {} }"
        .inspect(withRule: CollapsibleIfStatementsRule())
      XCTAssertEqual(issues.count, 1)
      let issue = issues[0]
      XCTAssertEqual(issue.ruleIdentifier, "collapsible_if_statements")
      XCTAssertEqual(issue.description, "This if statement can be collapsed with its inner if statement")
      XCTAssertEqual(issue.category, .badPractice)
      XCTAssertEqual(issue.severity, .minor)
      let range = issue.location
      XCTAssertEqual(range.start.path, "test/test")
      XCTAssertEqual(range.start.line, 1)
      XCTAssertEqual(range.start.column, 20)
      XCTAssertEqual(range.end.path, "test/test")
      XCTAssertEqual(range.end.line, 1)
      XCTAssertEqual(range.end.column, endColumn)
    }
  }

  static var allTests = [
    ("testWithElses", testWithElses),
    ("testWithAdditionalStatements", testWithAdditionalStatements),
    ("testCollapsibles", testCollapsibles),
    ("testElseIfCanBeCollapsed", testElseIfCanBeCollapsed),
  ]
}
