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

class RedundantIfStatementRuleTests : XCTestCase {
  func testNoElseBlock() {
    let issues = "if a == b { return true }"
      .inspect(withRule: RedundantIfStatementRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testSameReturns() {
    let issues = """
      if a == b { return true } else { return true }
      if a == b { return false } else { return false }
      """
      .inspect(withRule: RedundantIfStatementRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testThenTrueElseFalse() {
    let issues = "if a == b { return true } else { return false }"
      .inspect(withRule: RedundantIfStatementRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "redundant_if_statement")
    XCTAssertEqual(issue.description, "if statement is redundant and can be simplified")
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

  func testThenFalseElseTrue() {
    let issues = "if a == b { return false } else { return true }"
      .inspect(withRule: RedundantIfStatementRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "redundant_if_statement")
    XCTAssertEqual(issue.description, "if statement is redundant and can be simplified")
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

  func testExtraStatements() {
    let issues = """
      if a == b { a = 1; return false } else { return true }
      if a == b { return true } else { a = 1; return false }
      if a == b { a = 1; return true } else { return false }
      if a == b { return false } else { a = 1; return true }
      """.inspect(withRule: RedundantIfStatementRule())
    XCTAssertTrue(issues.isEmpty)
  }

  static var allTests = [
    ("testNoElseBlock", testNoElseBlock),
    ("testSameReturns", testSameReturns),
    ("testThenTrueElseFalse", testThenTrueElseFalse),
    ("testThenFalseElseTrue", testThenFalseElseTrue),
    ("testExtraStatements", testExtraStatements),
  ]
}
