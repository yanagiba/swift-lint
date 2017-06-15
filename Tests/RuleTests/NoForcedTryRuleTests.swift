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

class NoForcedTryRuleTests : XCTestCase {
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
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 11)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 27)
  }

  static var allTests = [
    ("testNoForcedTry", testNoForcedTry),
    ("testOneForcedTry", testOneForcedTry),
  ]
}
