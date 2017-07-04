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

class RedundantVariableDeclarationKeywordRuleTests : XCTestCase {
  func testProperties() {
    let rule = RedundantVariableDeclarationKeywordRule()

    XCTAssertEqual(rule.identifier, "redundant_variable_declaration_keyword")
    XCTAssertEqual(rule.name, "Redundant Variable Declaration Keyword")
    XCTAssertEqual(rule.fileName, "RedundantVariableDeclarationKeywordRule.swift")
    XCTAssertEqual(rule.description, """
      When the result of a function call or computed property is discarded by
      a wildcard variable `_`, its `let` or `var` keyword can be safely removed.
      """)
    XCTAssertEqual(rule.examples?.count, 2)
    XCTAssertEqual(rule.examples?[0], "let _ = foo() // _ = foo()")
    XCTAssertEqual(rule.examples?[1], "var _ = bar // _ = bar")
    XCTAssertNil(rule.thresholds)
    XCTAssertNil(rule.additionalDocument)
    XCTAssertEqual(rule.severity, .minor)
    XCTAssertEqual(rule.category, .badPractice)
  }

  func testNotWildcard() {
    let issues = """
      var foo = foo()
      let bar = bar()
      """
      .inspect(withRule: RedundantVariableDeclarationKeywordRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testNoKeyword() {
    let issues = """
      _ = foo()
      _ = bar()
      """
      .inspect(withRule: RedundantVariableDeclarationKeywordRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testExplicitTypeAnnotation() {
    let issues = """
      let _: Foo = foo()
      var _: Bar = bar()
      """
      .inspect(withRule: RedundantVariableDeclarationKeywordRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testMultipleVariables() {
    let issues = """
      var _ = foo(), _ = bar()
      let _ = bar(), _ = foo()
      """
      .inspect(withRule: RedundantVariableDeclarationKeywordRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testRedundantLetKeyword() {
    let issues = "let _ = foo()"
      .inspect(withRule: RedundantVariableDeclarationKeywordRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "redundant_variable_declaration_keyword")
    XCTAssertEqual(issue.description, "`let` keyword is redundant and can be safely removed")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 14)
  }

  func testRedundantVarKeyword() {
    let issues = "var _ = bar"
      .inspect(withRule: RedundantVariableDeclarationKeywordRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "redundant_variable_declaration_keyword")
    XCTAssertEqual(issue.description, "`var` keyword is redundant and can be safely removed")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 12)
  }

  static var allTests = [
    ("testProperties", testProperties),
    ("testNotWildcard", testNotWildcard),
    ("testNoKeyword", testNoKeyword),
    ("testExplicitTypeAnnotation", testExplicitTypeAnnotation),
    ("testMultipleVariables", testMultipleVariables),
    ("testRedundantLetKeyword", testRedundantLetKeyword),
    ("testRedundantVarKeyword", testRedundantVarKeyword),
  ]
}
