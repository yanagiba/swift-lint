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

class RedundantBreakInSwitchCaseRuleTests : XCTestCase {
  func testProperties() {
    let rule = RedundantBreakInSwitchCaseRule()

    XCTAssertEqual(rule.identifier, "redundant_break_in_switch_case")
    XCTAssertEqual(rule.name, "Redundant Break In Switch Case")
    XCTAssertEqual(rule.fileName, "RedundantBreakInSwitchCaseRule.swift")
    XCTAssertEqual(rule.description, """
      According to Swift language reference:

      > After the code within a matched case has finished executing,
      > the program exits from the switch statement.
      > Program execution does not continue or “fall through” to the next case or default case.

      This means in Swift, it's safe to remove the `break` at the end of each switch case.
      """)
    XCTAssertEqual(rule.examples?.count, 1)
    XCTAssertEqual(rule.examples?[0], """
      switch foo {
      case 0:
        print(0)
        break        // redundant, can be removed
      case 1:
        print(1)
        break        // redundant, can be removed
      default:
        break
      }
      """)
    XCTAssertNil(rule.thresholds)
    XCTAssertNil(rule.additionalDocument)
    XCTAssertEqual(rule.severity, .minor)
    XCTAssertEqual(rule.category, .badPractice)
  }

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
    XCTAssertEqual(range0.start.identifier, "test/test")
    XCTAssertEqual(range0.start.line, 4)
    XCTAssertEqual(range0.start.column, 3)
    XCTAssertEqual(range0.end.identifier, "test/test")
    XCTAssertEqual(range0.end.line, 4)
    XCTAssertEqual(range0.end.column, 8)

    let issue1 = issues[1]
    XCTAssertEqual(issue1.ruleIdentifier, "redundant_break_in_switch_case")
    XCTAssertEqual(issue1.description, "Break in swift case is redundant")
    XCTAssertEqual(issue1.category, .badPractice)
    XCTAssertEqual(issue1.severity, .minor)
    let range1 = issue1.location
    XCTAssertEqual(range1.start.identifier, "test/test")
    XCTAssertEqual(range1.start.line, 7)
    XCTAssertEqual(range1.start.column, 3)
    XCTAssertEqual(range1.end.identifier, "test/test")
    XCTAssertEqual(range1.end.line, 7)
    XCTAssertEqual(range1.end.column, 8)
  }

  func testBreakOnly() {
    // Note: if break is the only statement, then it may be used to break logic flow
    let issues = """
      switch foo {
      case 0:
        break
      case 1:
        break
      default:
        fd()
      }
      """.inspect(withRule: RedundantBreakInSwitchCaseRule())
    XCTAssertTrue(issues.isEmpty)
  }

  static var allTests = [
    ("testProperties", testProperties),
    ("testNoBreak", testNoBreak),
    ("testBreakInDefault", testBreakInDefault),
    ("testBreakInTheMiddle", testBreakInTheMiddle),
    ("testBreak", testBreak),
    ("testBreakOnly", testBreakOnly),
  ]
}
