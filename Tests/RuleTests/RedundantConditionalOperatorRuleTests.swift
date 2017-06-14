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
    ("testTrueFalseRespectively", testTrueFalseRespectively),
    ("testSameConstant", testSameConstant),
    ("testSameVariable", testSameVariable),
  ]
}
