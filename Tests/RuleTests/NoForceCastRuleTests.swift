/*
   Copyright 2016-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

class NoForceCastRuleTests : XCTestCase {
  func testNoForceCast() {
    let issues = "let foo = 1.2 as? Bool\nlet a = 1 as? String; let b = false as? Int"
      .inspect(withRule: NoForceCastRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testOneForceCast() {
    let issues = "let a = 1 as! String".inspect(withRule: NoForceCastRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "no_force_cast")
    XCTAssertEqual(issue.description, "having forced type casting is dangerous")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 9)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 21)
  }

  static var allTests = [
    ("testNoForceCast", testNoForceCast),
    ("testOneForceCast", testOneForceCast),
  ]
}
