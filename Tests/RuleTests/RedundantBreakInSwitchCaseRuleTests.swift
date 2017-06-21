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

class RedundantBreakInSwitchCaseRuleTests : XCTestCase {
  func testNoBreak() {
    let issues = """
      switch foo {
      case 0:
        f0()
      case 1:
        f1()
      default:
        fd()
      }
      """.inspect(withRule: RedundantBreakInSwitchCaseRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testBreakInDefault() {
    let issues = """
      switch foo {
      case 0:
        f0()
      case 1:
        f1()
      default:
        break
      }
      """.inspect(withRule: RedundantBreakInSwitchCaseRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testBreakInTheMiddle() {
    // Note: we don't emit this issue for this rule,
    // but this could results in dead code, which is a separate rule.

    let issues = """
      switch foo {
      case 0:
        f0()
        break
        b0()
      default:
        fd()
      }
      """.inspect(withRule: RedundantBreakInSwitchCaseRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testBreak() {
    let issues = """
      switch foo {
      case 0:
        f0()
        break
      case 1:
        f1()
        break
      default:
        fd()
      }
      """.inspect(withRule: RedundantBreakInSwitchCaseRule())
    XCTAssertEqual(issues.count, 2)

    let issue0 = issues[0]
    XCTAssertEqual(issue0.ruleIdentifier, "redundant_break_in_switch_case")
    XCTAssertEqual(issue0.description, "Break in swift case is redundant")
    XCTAssertEqual(issue0.category, .badPractice)
    XCTAssertEqual(issue0.severity, .minor)
    let range0 = issue0.location
    XCTAssertEqual(range0.start.path, "test/test")
    XCTAssertEqual(range0.start.line, 4)
    XCTAssertEqual(range0.start.column, 3)
    XCTAssertEqual(range0.end.path, "test/test")
    XCTAssertEqual(range0.end.line, 4)
    XCTAssertEqual(range0.end.column, 8)

    let issue1 = issues[1]
    XCTAssertEqual(issue1.ruleIdentifier, "redundant_break_in_switch_case")
    XCTAssertEqual(issue1.description, "Break in swift case is redundant")
    XCTAssertEqual(issue1.category, .badPractice)
    XCTAssertEqual(issue1.severity, .minor)
    let range1 = issue1.location
    XCTAssertEqual(range1.start.path, "test/test")
    XCTAssertEqual(range1.start.line, 7)
    XCTAssertEqual(range1.start.column, 3)
    XCTAssertEqual(range1.end.path, "test/test")
    XCTAssertEqual(range1.end.line, 7)
    XCTAssertEqual(range1.end.column, 8)
  }

  static var allTests = [
    ("testNoBreak", testNoBreak),
    ("testBreakInDefault", testBreakInDefault),
    ("testBreakInTheMiddle", testBreakInTheMiddle),
    ("testBreak", testBreak),
  ]
}
