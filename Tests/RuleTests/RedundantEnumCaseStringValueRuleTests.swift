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

class RedundantEnumCaseStringValueRuleTests : XCTestCase {
  func testNotStringRawValueType() {
    let issues = """
      enum i: Int { case foo = 1, bar = 2 }
      enum f: Double { case foo = 1.23, bar = 4.56 }
      enum b: Bool { case foo = true, bar = false }
      """.inspect(withRule: RedundantEnumCaseStringValueRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testNoAssignment() {
    let issues = """
      enum str: String {
        case a
        case b, c
      }
      """.inspect(withRule: RedundantEnumCaseStringValueRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testAssignDifferentValue() {
    let issues = """
      enum str: String {
        case a = "A"
        case b = "B", c = "C"
      }
      """.inspect(withRule: RedundantEnumCaseStringValueRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testAssignSameValue() {
    let issues = """
      enum str: String {
        case a = "a"
        case b = "B", c = "c"
        case d, e = "e", f
      }
      """.inspect(withRule: RedundantEnumCaseStringValueRule())
    XCTAssertEqual(issues.count, 3)

    let expectations = ["a", "c", "e"]
    for (index, caseName) in expectations.enumerated() {
      let issue = issues[index]
      XCTAssertEqual(issue.ruleIdentifier, "redundant_enumcase_string_value")
      XCTAssertEqual(issue.description, "`= \"\(caseName)\"` is redundant and can be removed")
      XCTAssertEqual(issue.category, .badPractice)
      XCTAssertEqual(issue.severity, .minor)
      let range = issue.location
      XCTAssertEqual(range.start.path, "test/test")
      XCTAssertEqual(range.start.line, 1)
      XCTAssertEqual(range.start.column, 1)
      XCTAssertEqual(range.end.path, "test/test")
      XCTAssertEqual(range.end.line, 5)
      XCTAssertEqual(range.end.column, 2)
    }
  }

  static var allTests = [
    ("testNotStringRawValueType", testNotStringRawValueType),
    ("testNoAssignment", testNoAssignment),
    ("testAssignDifferentValue", testAssignDifferentValue),
    ("testAssignSameValue", testAssignSameValue),
  ]
}
