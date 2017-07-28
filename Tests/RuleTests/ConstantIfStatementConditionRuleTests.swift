/*
   Copyright 2017 Ryuichi Laboratories and the Yanagiba project contributors

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

class ConstantIfStatementConditionRuleTests : XCTestCase {
  func testProperties() {
    let rule = ConstantIfStatementConditionRule()

    XCTAssertEqual(rule.identifier, "constant_if_statement_condition")
    XCTAssertEqual(rule.name, "Constant If Statement Condition")
    XCTAssertEqual(rule.fileName, "ConstantIfStatementConditionRule.swift")
    XCTAssertNil(rule.description)
    XCTAssertEqual(rule.examples?.count, 3)
    XCTAssertEqual(rule.examples?[0], """
      if true { // always true
        return true
      }
      """)
    XCTAssertEqual(rule.examples?[1], """
      if 1 == 0 { // always false
        return false
      }
      """)
    XCTAssertEqual(rule.examples?[2], """
      if 1 != 0, true { // always true
        return true
      }
      """)
    XCTAssertNil(rule.thresholds)
    XCTAssertNil(rule.additionalDocument)
    XCTAssertEqual(rule.severity, .minor)
    XCTAssertEqual(rule.category, .badPractice)
  }

  func testOneVariable() {
    let issues = "if foo { return true }"
      .inspect(withRule: ConstantIfStatementConditionRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testConditionHasVariable() {
    let issues = """
      if let a = b { return true } else { return false }
      if case .a = b { return false } else { return false }
      if var a = b { return 1 } else { return 1 }
      if foo, true { return true }
      if foo, bar, 1 == 0 { return false }
      """
      .inspect(withRule: ConstantIfStatementConditionRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testOneConstant() {
    let constants: [(String, Int)] = [
      ("nil", 23),
      ("true", 24),
      ("((true))", 28),
      ("false", 25),
      ("1", 21),
      ("1.23", 24),
      ("\"foo\"", 25),
    ]
    for (const, endColumn) in constants {
      let issues = "if \(const) { return true }"
        .inspect(withRule: ConstantIfStatementConditionRule())
      XCTAssertEqual(issues.count, 1)
      let issue = issues[0]
      XCTAssertEqual(issue.ruleIdentifier, "constant_if_statement_condition")
      XCTAssertEqual(issue.description, "If statement with constant condition is confusing")
      XCTAssertEqual(issue.category, .badPractice)
      XCTAssertEqual(issue.severity, .minor)
      let range = issue.location
      XCTAssertEqual(range.start.identifier, "test/test")
      XCTAssertEqual(range.start.line, 1)
      XCTAssertEqual(range.start.column, 1)
      XCTAssertEqual(range.end.identifier, "test/test")
      XCTAssertEqual(range.end.line, 1)
      XCTAssertEqual(range.end.column, endColumn)
    }
  }

  func testConditionsAllConstant() {
    let constants: [(String, Int)] = [
      ("nil, nil", 28),
      ("true, false", 31),
      ("false, 1, 1.23", 34),
      ("1, \"foo\", \"bar\"", 35),
      ("1.23, 4.56, 7.89", 36),
      ("\"foo\", true", 31),
    ]
    for (const, endColumn) in constants {
      let issues = "if \(const) { return true }"
        .inspect(withRule: ConstantIfStatementConditionRule())
      XCTAssertEqual(issues.count, 1)
      let issue = issues[0]
      XCTAssertEqual(issue.ruleIdentifier, "constant_if_statement_condition")
      XCTAssertEqual(issue.description, "If statement with constant condition is confusing")
      XCTAssertEqual(issue.category, .badPractice)
      XCTAssertEqual(issue.severity, .minor)
      let range = issue.location
      XCTAssertEqual(range.start.identifier, "test/test")
      XCTAssertEqual(range.start.line, 1)
      XCTAssertEqual(range.start.column, 1)
      XCTAssertEqual(range.end.identifier, "test/test")
      XCTAssertEqual(range.end.line, 1)
      XCTAssertEqual(range.end.column, endColumn)
    }
  }

  func testConditionsWithVariableComparisons() {
    let issues = """
      if true, 1 > 0 { return true }
      if true, foo == 0 { return true }
      if true, foo != 0 { return true }
      """
      .inspect(withRule: ConstantIfStatementConditionRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testConditionsWithConstantComparison() {
    let constants: [(String, Int)] = [
      ("nil == nil", 30),
      ("true == false", 33),
      ("false, 1 != 1.23", 36),
      ("1, \"foo\" == \"bar\"", 37),
      ("1.23 == 4.56, 7.89", 38),
      ("\"foo\" != true", 33),
    ]
    for (const, endColumn) in constants {
      let issues = "if \(const) { return true }"
        .inspect(withRule: ConstantIfStatementConditionRule())
      XCTAssertEqual(issues.count, 1)
      let issue = issues[0]
      XCTAssertEqual(issue.ruleIdentifier, "constant_if_statement_condition")
      XCTAssertEqual(issue.description, "If statement with constant condition is confusing")
      XCTAssertEqual(issue.category, .badPractice)
      XCTAssertEqual(issue.severity, .minor)
      let range = issue.location
      XCTAssertEqual(range.start.identifier, "test/test")
      XCTAssertEqual(range.start.line, 1)
      XCTAssertEqual(range.start.column, 1)
      XCTAssertEqual(range.end.identifier, "test/test")
      XCTAssertEqual(range.end.line, 1)
      XCTAssertEqual(range.end.column, endColumn)
    }
  }

  static var allTests = [
    ("testProperties", testProperties),
    ("testOneVariable", testOneVariable),
    ("testConditionHasVariable", testConditionHasVariable),
    ("testOneConstant", testOneConstant),
    ("testConditionsAllConstant", testConditionsAllConstant),
    ("testConditionsWithVariableComparisons", testConditionsWithVariableComparisons),
    ("testConditionsWithConstantComparison", testConditionsWithConstantComparison),
  ]
}
