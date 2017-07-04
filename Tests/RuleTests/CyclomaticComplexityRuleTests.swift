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

class CyclomaticComplexityRuleTests : XCTestCase {
  func testProperties() {
    let rule = CyclomaticComplexityRule()

    XCTAssertEqual(rule.identifier, "high_cyclomatic_complexity")
    XCTAssertEqual(rule.name, "High Cyclomatic Complexity")
    XCTAssertEqual(rule.fileName, "CyclomaticComplexityRule.swift")
    XCTAssertEqual(rule.description, """
      Cyclomatic complexity is determined by the number of
      linearly independent paths through a program's source code.
      In other words, cyclomatic complexity of a method is measured by
      the number of decision points, like `if`, `while`, and `for` statements,
      plus one for the method entry.

      The experiments McCabe, the author of cyclomatic complexity,
      conclude that methods in the 3 to 7 complexity range are
      quite well structured. He also suggest
      the cyclomatic complexity of 10 is a reasonable upper limit.
      """)
    XCTAssertEqual(rule.examples?.count, 1)
    XCTAssertEqual(rule.examples?[0], """
      func example(a: Int, b: Int, c: Int) // 1
      {
          if (a == b)                      // 2
          {
              if (b == c)                  // 3
              {
              }
              else if (a == c)             // 3
              {
              }
              else
              {
              }
          }
          for i in 0..<c                   // 4
          {
          }
          switch(c)
          {
              case 1:                      // 5
                  break
              case 2:                      // 6
                  break
              default:                     // 7
                  break
          }
      }
      """)
    XCTAssertEqual(rule.thresholds?.count, 1)
    XCTAssertEqual(rule.thresholds?.keys.first, "CYCLOMATIC_COMPLEXITY")
    XCTAssertEqual(rule.thresholds?.values.first, "The cyclomatic complexity reporting threshold, default value is 10.")
    XCTAssertEqual(rule.additionalDocument, """

      ##### References:

      McCabe (December 1976). ["A Complexity Measure"](http://www.literateprogramming.com/mccabe.pdf).
      *IEEE Transactions on Software Engineering: 308–320*

      """)
    XCTAssertEqual(rule.severity, .major)
    XCTAssertEqual(rule.category, .complexity)
  }

  func testNoDecisionPoint() {
    XCTAssertTrue(getIssues(from: "func foo() {}").isEmpty)
    XCTAssertTrue(getIssues(from: "init() {}").isEmpty)
    XCTAssertTrue(getIssues(from: "deinit {}").isEmpty)
    XCTAssertTrue(getIssues(from: "subscript() -> Self {}").isEmpty)
  }

  func testIfStatement() {
    let issues = getIssues(from: "func foo() { if bar {} }")
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "high_cyclomatic_complexity")
    XCTAssertEqual(issue.description, "Cyclomatic Complexity number of 2 exceeds limit of 1")
    XCTAssertEqual(issue.category, .complexity)
    XCTAssertEqual(issue.severity, .major)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 25)
  }

  func testSwitchStatement() {
    let issues = getIssues(from: "init() { switch foo  { case a, b where b && a: break; default: break;} }")
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "high_cyclomatic_complexity")
    XCTAssertEqual(issue.description, "Cyclomatic Complexity number of 3 exceeds limit of 1")
    XCTAssertEqual(issue.category, .complexity)
    XCTAssertEqual(issue.severity, .major)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 73)
  }

  func testTernaryConditionalOperatorExpression() {
    let issues = getIssues(from: "deinit { let a = c ? t : f }")
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "high_cyclomatic_complexity")
    XCTAssertEqual(issue.description, "Cyclomatic Complexity number of 2 exceeds limit of 1")
    XCTAssertEqual(issue.category, .complexity)
    XCTAssertEqual(issue.severity, .major)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 29)
  }

  func testDoStatement() {
    let issues = getIssues(from: "subscript() -> Self { do { try foo() } catch e1 {} catch e2 {} catch {} }")
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "high_cyclomatic_complexity")
    XCTAssertEqual(issue.description, "Cyclomatic Complexity number of 4 exceeds limit of 1")
    XCTAssertEqual(issue.category, .complexity)
    XCTAssertEqual(issue.severity, .major)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 74)
  }

  private func getIssues(from content: String) -> [Issue] {
    return content.inspect(
      withRule: CyclomaticComplexityRule(),
      configurations: [CyclomaticComplexityRule.ThresholdKey: 1]
    )
  }

  static var allTests = [
    ("testProperties", testProperties),
    ("testNoDecisionPoint", testNoDecisionPoint),
    ("testIfStatement", testIfStatement),
    ("testSwitchStatement", testSwitchStatement),
    ("testTernaryConditionalOperatorExpression", testTernaryConditionalOperatorExpression),
    ("testDoStatement", testDoStatement),
  ]
}
