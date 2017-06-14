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

class ConstantGuardStatementConditionRuleTests : XCTestCase {
  func testOneVariable() {
    let issues = "guard foo else { return true }"
      .inspect(withRule: ConstantGuardStatementConditionRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testConditionHasVariable() {
    let issues = """
      guard let a = b else { return true }
      guard case .a = b else { return false }
      guard var a = b else { return 1 }
      guard foo, true else { return true }
      guard foo, bar, 1 == 0 else { return false }
      """
      .inspect(withRule: ConstantGuardStatementConditionRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testOneConstant() {
    let constants: [(String, Int)] = [
      ("nil", 31),
      ("true", 32),
      ("((true))", 36),
      ("false", 33),
      ("1", 29),
      ("1.23", 32),
      ("\"foo\"", 33),
    ]
    for (const, endColumn) in constants {
      let issues = "guard \(const) else { return true }"
        .inspect(withRule: ConstantGuardStatementConditionRule())
      XCTAssertEqual(issues.count, 1)
      let issue = issues[0]
      XCTAssertEqual(issue.ruleIdentifier, "constant_guard_statement_condition")
      XCTAssertEqual(issue.description, "Guard statement with constant condition is confusing")
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

  func testConditionsAllConstant() {
    let constants: [(String, Int)] = [
      ("nil, nil", 36),
      ("true, false", 39),
      ("false, 1, 1.23", 42),
      ("1, \"foo\", \"bar\"", 43),
      ("1.23, 4.56, 7.89", 44),
      ("\"foo\", true", 39),
    ]
    for (const, endColumn) in constants {
      let issues = "guard \(const) else { return true }"
        .inspect(withRule: ConstantGuardStatementConditionRule())
      XCTAssertEqual(issues.count, 1)
      let issue = issues[0]
      XCTAssertEqual(issue.ruleIdentifier, "constant_guard_statement_condition")
      XCTAssertEqual(issue.description, "Guard statement with constant condition is confusing")
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

  func testConditionsWithVariableComparisons() {
    let issues = """
      guard true, 1 > 0 else { return true }
      guard true, foo == 0 else { return true }
      guard true, foo != 0 else { return true }
      """
      .inspect(withRule: ConstantGuardStatementConditionRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testConditionsWithConstantComparison() {
    let constants: [(String, Int)] = [
      ("nil == nil", 38),
      ("true == false", 41),
      ("false, 1 != 1.23", 44),
      ("1, \"foo\" == \"bar\"", 45),
      ("1.23 == 4.56, 7.89", 46),
      ("\"foo\" != true", 41),
    ]
    for (const, endColumn) in constants {
      let issues = "guard \(const) else { return true }"
        .inspect(withRule: ConstantGuardStatementConditionRule())
      XCTAssertEqual(issues.count, 1)
      let issue = issues[0]
      XCTAssertEqual(issue.ruleIdentifier, "constant_guard_statement_condition")
      XCTAssertEqual(issue.description, "Guard statement with constant condition is confusing")
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

  static var allTests = [
    ("testOneVariable", testOneVariable),
    ("testConditionHasVariable", testConditionHasVariable),
    ("testOneConstant", testOneConstant),
    ("testConditionsAllConstant", testConditionsAllConstant),
    ("testConditionsWithVariableComparisons", testConditionsWithVariableComparisons),
    ("testConditionsWithConstantComparison", testConditionsWithConstantComparison),
  ]
}
