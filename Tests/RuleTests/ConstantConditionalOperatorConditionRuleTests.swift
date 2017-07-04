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

class ConstantConditionalOperatorConditionRuleTests : XCTestCase {
  func testProperties() {
    let rule = ConstantConditionalOperatorConditionRule()

    XCTAssertEqual(rule.identifier, "constant_conditional_operator_condition")
    XCTAssertEqual(rule.name, "Constant Conditional Operator Condition")
    XCTAssertEqual(rule.fileName, "ConstantConditionalOperatorConditionRule.swift")
    XCTAssertNil(rule.description)
    XCTAssertEqual(rule.examples?.count, 3)
    XCTAssertEqual(rule.examples?[0], "1 == 1 ? 1 : 0")
    XCTAssertEqual(rule.examples?[1], "true ? 1 : 0")
    XCTAssertEqual(rule.examples?[2], "false ? 1 : 0")
    XCTAssertNil(rule.thresholds)
    XCTAssertNil(rule.additionalDocument)
    XCTAssertEqual(rule.severity, .minor)
    XCTAssertEqual(rule.category, .badPractice)
  }

  func testOneVariable() {
    let issues = "foo ? true : false"
      .inspect(withRule: ConstantConditionalOperatorConditionRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testOneConstant() {
    let constants: [(String, Int)] = [
      ("nil", 12),
      ("true", 13),
      ("((true))", 17),
      ("false", 14),
      ("1", 10),
      ("1.23", 13),
      ("\"foo\"", 14),
    ]
    for (const, endColumn) in constants {
      let issues = "\(const) ? 1 : 0"
        .inspect(withRule: ConstantConditionalOperatorConditionRule())
      XCTAssertEqual(issues.count, 1)
      let issue = issues[0]
      XCTAssertEqual(issue.ruleIdentifier, "constant_conditional_operator_condition")
      XCTAssertEqual(issue.description, "Conditional operator with constant condition is confusing")
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

  func testVariableComparisons() {
    let issues = """
      1 > 0 ? true : false
      foo == 0 ? 1.23 : 4.56
      foo != 0 ? "foo" : "bar"
      """
      .inspect(withRule: ConstantConditionalOperatorConditionRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testConstantComparisons() {
    let constants: [(String, Int)] = [
      ("nil == nil", 26),
      ("true == false", 29),
      ("1 != 1.23", 25),
      ("\"foo\" == \"bar\"", 30),
      ("1.23 == 4.56", 28),
      ("\"foo\" != true", 29),
    ]
    for (const, endColumn) in constants {
      let issues = "\(const) ? false : true"
        .inspect(withRule: ConstantConditionalOperatorConditionRule())
      XCTAssertEqual(issues.count, 1)
      let issue = issues[0]
      XCTAssertEqual(issue.ruleIdentifier, "constant_conditional_operator_condition")
      XCTAssertEqual(issue.description, "Conditional operator with constant condition is confusing")
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
    ("testProperties", testProperties),
    ("testOneVariable", testOneVariable),
    ("testOneConstant", testOneConstant),
    ("testVariableComparisons", testVariableComparisons),
    ("testConstantComparisons", testConstantComparisons),
  ]
}
