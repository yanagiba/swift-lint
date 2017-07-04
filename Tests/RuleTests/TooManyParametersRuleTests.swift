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

class TooManyParametersRuleTests : XCTestCase {
  func testProperties() {
    let rule = TooManyParametersRule()

    XCTAssertEqual(rule.identifier, "too_many_parameters")
    XCTAssertEqual(rule.name, "Too Many Parameters")
    XCTAssertEqual(rule.fileName, "TooManyParametersRule.swift")
    XCTAssertEqual(rule.description, """
      Methods with too many parameters are hard to understand and maintain,
      and are thirsty for refactorings, like
      [Replace Parameter With Method](http://www.refactoring.com/catalog/replaceParameterWithMethod.html),
      [Introduce Parameter Object](http://www.refactoring.com/catalog/introduceParameterObject.html),
      or
      [Preserve Whole Object](http://www.refactoring.com/catalog/preserveWholeObject.html).
      """)
    XCTAssertEqual(rule.examples?.count, 1)
    XCTAssertEqual(rule.examples?[0], """
      func example(
        a: Int,
        b: Int,
        c: Int,
        ...
        z: Int
      ) {}
      """)
    XCTAssertEqual(rule.thresholds?.count, 1)
    XCTAssertEqual(rule.thresholds?.keys.first, "MAX_PARAMETERS_COUNT")
    XCTAssertEqual(rule.thresholds?.values.first, "The reporting threshold for too many parameters, default value is 10.")
    XCTAssertEqual(rule.additionalDocument, """

      ##### References:

      Fowler, Martin (1999). *Refactoring: Improving the design of existing code.* Addison Wesley.

      """)
    XCTAssertEqual(rule.severity, .minor)
    XCTAssertEqual(rule.category, .size)
  }

  func testNoParameter() {
    XCTAssertTrue(getIssues(from: """
    func foo() {}
    init() {}
    subscript() -> Self {}
    let bar: () -> Void
    """).isEmpty)
  }

  func testOneParameter() {
    XCTAssertTrue(getIssues(from: """
    func foo(a: Int) {}
    init(b: Double) {}
    subscript(c: String) -> Self {}
    let bar: (Bool) -> Void
    """).isEmpty)
  }

  func testFunction() {
    let issues = getIssues(from: "func foo(a1: Int, a2: Int, a3: Int) {} }")
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "too_many_parameters")
    XCTAssertEqual(issue.description, "Method with 3 parameters exceeds limit of 1")
    XCTAssertEqual(issue.category, .size)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 39)
  }

  func testInitializer() {
    let issues = getIssues(from: "init(a1: Int, a2: Int) {} }")
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "too_many_parameters")
    XCTAssertEqual(issue.description, "Method with 2 parameters exceeds limit of 1")
    XCTAssertEqual(issue.category, .size)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 26)
  }

  func testSubscript() {
    let issues = getIssues(from: "subscript(a1: Int, a2: Int, a3: Int, a4: int) -> Self {} }")
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "too_many_parameters")
    XCTAssertEqual(issue.description, "Method with 4 parameters exceeds limit of 1")
    XCTAssertEqual(issue.category, .size)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 57)
  }

  private func getIssues(from content: String) -> [Issue] {
    return content.inspect(
      withRule: TooManyParametersRule(),
      configurations: [TooManyParametersRule.ThresholdKey: 1]
    )
  }

  static var allTests = [
    ("testProperties", testProperties),
    ("testNoParameter", testNoParameter),
    ("testOneParameter", testOneParameter),
    ("testFunction", testFunction),
    ("testInitializer", testInitializer),
    ("testSubscript", testSubscript),
  ]
}
