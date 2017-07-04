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
  func testProperties() {
    let rule = NoForceCastRule()

    XCTAssertEqual(rule.identifier, "no_force_cast")
    XCTAssertEqual(rule.name, "No Force Cast")
    XCTAssertEqual(rule.fileName, "NoForceCastRule.swift")
    XCTAssertEqual(rule.description, """
      Force casting `as!` should be avoided, because it could crash the program
      when the type casting fails.

      Although it is arguable that, in rare cases, having crashes may help developers
      identify issues easier, we recommend using a `guard` statement with optional casting
      and then handle the failed castings gently.
      """)
    XCTAssertEqual(rule.examples?.count, 1)
    XCTAssertEqual(rule.examples?[0], """
      let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! MyCustomCell

      // guard let cell =
      //   tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as? MyCustomCell
      // else {
      //   print("Failed in casting to MyCustomCell.")
      //   return UITableViewCell()
      // }

      return cell
      """)
    XCTAssertNil(rule.thresholds)
    XCTAssertNil(rule.additionalDocument)
    XCTAssertEqual(rule.severity, .minor)
    XCTAssertEqual(rule.category, .badPractice)
  }

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
    ("testProperties", testProperties),
    ("testNoForceCast", testNoForceCast),
    ("testOneForceCast", testOneForceCast),
  ]
}
