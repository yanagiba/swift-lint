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

class InvertedLogicRuleTests : XCTestCase {
  func testProperties() {
    let rule = InvertedLogicRule()

    XCTAssertEqual(rule.identifier, "inverted_logic")
    XCTAssertEqual(rule.name, "Inverted Logic")
    XCTAssertEqual(rule.fileName, "InvertedLogicRule.swift")
    XCTAssertNil(rule.description)
    XCTAssertEqual(rule.examples?.count, 2)
    XCTAssertEqual(rule.examples?[0], """
      if a != 0 {  // if a == 0 {
        i = 1      //   i = -1
      } else {     // } else {
        i = -1     //   i = 1
      }            // }
      """)
    XCTAssertEqual(rule.examples?[1], "!foo ? -1 : 1  // foo ? 1 : -1")
    XCTAssertNil(rule.thresholds)
    XCTAssertNil(rule.additionalDocument)
    XCTAssertEqual(rule.severity, .minor)
    XCTAssertEqual(rule.category, .badPractice)
  }

  func testSmoothLogicFlow() {
    let issues = """
      if foo { return true } else { return false }
      if a == b { return true } else { return false }
      bar ? true : false
      x == y ? true : false
      """
      .inspect(withRule: InvertedLogicRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testIfWithLogicalNotOperator() {
    let issues = "if !foo { return true } else { return false }"
      .inspect(withRule: InvertedLogicRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "inverted_logic")
    XCTAssertEqual(issue.description, "If statement with inverted condition is confusing")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 46)
  }

  func testIfWithNotEqualOperator() {
    let issues = "if a != b { return true } else { return false }"
      .inspect(withRule: InvertedLogicRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "inverted_logic")
    XCTAssertEqual(issue.description, "If statement with inverted condition is confusing")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 48)
  }

  func testIfWithoutElseBlock() {
    let issues = """
      if !foo { return true }
      if a != b { return true }
      """
      .inspect(withRule: InvertedLogicRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testIfWithElseIf() {
    let issues = "if a != nil { return true } else if a != b { return false }"
      .inspect(withRule: InvertedLogicRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testConditionalOperatorWithLogicalNotOperator() {
    let issues = "!foo ? true : false"
      .inspect(withRule: InvertedLogicRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "inverted_logic")
    XCTAssertEqual(issue.description, "Conditional operator with inverted condition is confusing")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 20)
  }

  func testConditionalOperatorWithNotEqualOperator() {
    let issues = "(a != b) ? true : false"
      .inspect(withRule: InvertedLogicRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "inverted_logic")
    XCTAssertEqual(issue.description, "Conditional operator with inverted condition is confusing")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 24)
  }

  static var allTests = [
    ("testProperties", testProperties),
    ("testSmoothLogicFlow", testSmoothLogicFlow),
    ("testIfWithLogicalNotOperator", testIfWithLogicalNotOperator),
    ("testIfWithNotEqualOperator", testIfWithNotEqualOperator),
    ("testIfWithoutElseBlock", testIfWithoutElseBlock),
    ("testIfWithElseIf", testIfWithElseIf),
    ("testConditionalOperatorWithLogicalNotOperator", testConditionalOperatorWithLogicalNotOperator),
    ("testConditionalOperatorWithNotEqualOperator", testConditionalOperatorWithNotEqualOperator),
  ]
}
