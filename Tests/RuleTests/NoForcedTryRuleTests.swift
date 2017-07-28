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

class NoForcedTryRuleTests : XCTestCase {
  func testProperties() {
    let rule = NoForcedTryRule()

    XCTAssertEqual(rule.identifier, "no_forced_try")
    XCTAssertEqual(rule.name, "No Forced Try")
    XCTAssertEqual(rule.fileName, "NoForcedTryRule.swift")
    XCTAssertEqual(rule.description, """
      Forced-try expression `try!` should be avoided, because it could crash the program
      at the runtime when the expression throws an error.

      We recommend using a `do-catch` statement with `try` operator and handle the errors
      in `catch` blocks accordingly; or a `try?` operator with `nil`-checking.
      """)
    XCTAssertEqual(rule.examples?.count, 1)
    XCTAssertEqual(rule.examples?[0], """
      let result = try! getResult()

      // do {
      //   let result = try getResult()
      // } catch {
      //   print("Failed in getting result with error: \\(error).")
      // }
      //
      // or
      //
      // guard let result = try? getResult() else {
      //   print("Failed in getting result.")
      // }
      """)
    XCTAssertNil(rule.thresholds)
    XCTAssertNil(rule.additionalDocument)
    XCTAssertEqual(rule.severity, .minor)
    XCTAssertEqual(rule.category, .badPractice)
  }

  func testNoForcedTry() {
    let issues = "let foo = try? getResult(); do { try getResult() } catch {}"
      .inspect(withRule: NoForcedTryRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testOneForcedTry() {
    let issues = "let foo = try! getResult()".inspect(withRule: NoForcedTryRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "no_forced_try")
    XCTAssertEqual(issue.description, "having forced-try expression is dangerous")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.identifier, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 11)
    XCTAssertEqual(range.end.identifier, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 27)
  }

  static var allTests = [
    ("testProperties", testProperties),
    ("testNoForcedTry", testNoForcedTry),
    ("testOneForcedTry", testOneForcedTry),
  ]
}
