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

class DoubleNegativeRuleTests : XCTestCase {
  func testProperties() {
    let rule = DoubleNegativeRule()

    XCTAssertEqual(rule.identifier, "double_negative")
    XCTAssertEqual(rule.name, "Double Negative")
    XCTAssertEqual(rule.fileName, "DoubleNegativeRule.swift")
    XCTAssertEqual(rule.description, "Logically, double negative is positive. So prefer to write positively.")
    XCTAssertEqual(rule.examples?.count, 2)
    XCTAssertEqual(rule.examples?[0], "!!foo // foo")
    XCTAssertEqual(rule.examples?[1], "!(a != b) // a == b")
    XCTAssertNil(rule.thresholds)
    XCTAssertNil(rule.additionalDocument)
    XCTAssertEqual(rule.severity, .minor)
    XCTAssertEqual(rule.category, .badPractice)
  }

  func testPositiveLogicFlow() {
    let issues = """
      if foo { return true } else { return false }
      if a == b { return true } else { return false }
      bar ? true : false
      x == y ? true : false
      """
      .inspect(withRule: DoubleNegativeRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testOneNegative() {
    let issues = """
      if !foo { return true }
      if !(a == b) { return true }
      if a != b { return true }
      """
      .inspect(withRule: DoubleNegativeRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testDoubleNegativePrefixOpAndPrefixOp() {
    let issues = "if !!foo {}"
      .inspect(withRule: DoubleNegativeRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "double_negative")
    XCTAssertEqual(issue.description, "Double negative logic can be written in a positive fashion")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 4)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 9)
  }

  func testDoubleNegativePrefixOpAndPrefixOpWithParen() {
    let issues = "if !(!foo) {}"
      .inspect(withRule: DoubleNegativeRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "double_negative")
    XCTAssertEqual(issue.description, "Double negative logic can be written in a positive fashion")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 4)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 11)
  }

  func testDoubleNegativePrefixOpAndBinaryOp() {
    let issues = "if !(a != b) {}"
      .inspect(withRule: DoubleNegativeRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "double_negative")
    XCTAssertEqual(issue.description, "Double negative logic can be written in a positive fashion")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 4)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 13)
  }

  static var allTests = [
    ("testProperties", testProperties),
    ("testPositiveLogicFlow", testPositiveLogicFlow),
    ("testOneNegative", testOneNegative),
    ("testDoubleNegativePrefixOpAndPrefixOp", testDoubleNegativePrefixOpAndPrefixOp),
    ("testDoubleNegativePrefixOpAndPrefixOpWithParen", testDoubleNegativePrefixOpAndPrefixOpWithParen),
    ("testDoubleNegativePrefixOpAndBinaryOp", testDoubleNegativePrefixOpAndBinaryOp),
  ]
}
