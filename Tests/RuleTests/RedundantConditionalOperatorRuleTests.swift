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

class RedundantConditionalOperatorRuleTests : XCTestCase {
  func testProperties() {
    let rule = RedundantConditionalOperatorRule()

    XCTAssertEqual(rule.identifier, "redundant_conditional_operator")
    XCTAssertEqual(rule.name, "Redundant Conditional Operator")
    XCTAssertEqual(rule.fileName, "RedundantConditionalOperatorRule.swift")
    XCTAssertEqual(rule.description, """
      This rule detects three types of redundant conditional operators:

      - true-expression and false-expression are returning true/false or false/true respectively;
      - true-expression and false-expression are the same constant;
      - true-expression and false-expression are the same variable expression.

      They are usually introduced by mistake, and should be simplified or removed.
      """)
    XCTAssertEqual(rule.examples?.count, 5)
    XCTAssertEqual(rule.examples?[0], "return a > b ? true : false // return a > b")
    XCTAssertEqual(rule.examples?[1], "return a == b ? false : true // return a != b")
    XCTAssertEqual(rule.examples?[2], "return a > b ? true : true // return true")
    XCTAssertEqual(rule.examples?[3], "return a < b ? \"foo\" : \"foo\" // return \"foo\"")
    XCTAssertEqual(rule.examples?[4], "return a != b ? c : c // return c")
    XCTAssertNil(rule.thresholds)
    XCTAssertNil(rule.additionalDocument)
    XCTAssertEqual(rule.severity, .minor)
    XCTAssertEqual(rule.category, .badPractice)
  }

  func testTrueFalseRespectively() {
    let returns: [(String, String)] = [
      ("true", "false"),
      ("false", "true"),
    ]
    for (trueString, elseString) in returns {
      let issues = "a == b ? \(trueString) : \(elseString)"
        .inspect(withRule: RedundantConditionalOperatorRule())
      XCTAssertEqual(issues.count, 1)
      let issue = issues[0]
      XCTAssertEqual(issue.ruleIdentifier, "redundant_conditional_operator")
      XCTAssertEqual(issue.description, "Conditional operator is redundant and can be simplified")
      XCTAssertEqual(issue.category, .badPractice)
      XCTAssertEqual(issue.severity, .minor)
      let range = issue.location
      XCTAssertEqual(range.start.path, "test/test")
      XCTAssertEqual(range.start.line, 1)
      XCTAssertEqual(range.start.column, 1)
      XCTAssertEqual(range.end.path, "test/test")
      XCTAssertEqual(range.end.line, 1)
      XCTAssertEqual(range.end.column, 22)
    }
  }

  func testSameConstant() {
    let returns: [(String, String, Int)] = [
      ("true", "true", 21),
      ("false", "false", 23),
      ("1", "1", 15),
      ("1.23", "1.23", 21),
      ("\"foo\"", "\"foo\"", 23),
    ]
    for (trueString, elseString, endColumn) in returns {
      let issues = "a == b ? \(trueString) : \(elseString)"
        .inspect(withRule: RedundantConditionalOperatorRule())
      XCTAssertEqual(issues.count, 1)
      let issue = issues[0]
      XCTAssertEqual(issue.ruleIdentifier, "redundant_conditional_operator")
      XCTAssertEqual(issue.description, "Conditional operator is redundant and can be removed")
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

  func testSameVariable() {
    let issues = "a > b ? foo : foo"
      .inspect(withRule: RedundantConditionalOperatorRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "redundant_conditional_operator")
    XCTAssertEqual(issue.description, "Conditional operator is redundant and can be removed")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 18)
  }

  static var allTests = [
    ("testProperties", testProperties),
    ("testTrueFalseRespectively", testTrueFalseRespectively),
    ("testSameConstant", testSameConstant),
    ("testSameVariable", testSameVariable),
  ]
}
