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

class RedundantInitializationToNilRuleTests : XCTestCase {
  func testProperties() {
    let rule = RedundantInitializationToNilRule()

    XCTAssertEqual(rule.identifier, "redundant_initialization_to_nil")
    XCTAssertEqual(rule.name, "Redundant Initialization to Nil")
    XCTAssertEqual(rule.fileName, "RedundantInitializationToNilRule.swift")
    XCTAssertEqual(rule.description, """
      It is redundant to initialize an optional variable to `nil`,
      because if you don’t provide an initial value when you declare an optional variable or property,
      its value automatically defaults to `nil` by the compiler.
      """)
    XCTAssertEqual(rule.examples?.count, 1)
    XCTAssertEqual(rule.examples?[0], "var foo: Int? = nil // var foo: Int?")
    XCTAssertNil(rule.thresholds)
    XCTAssertNil(rule.additionalDocument)
    XCTAssertEqual(rule.severity, .minor)
    XCTAssertEqual(rule.category, .badPractice)
  }

  func testNotOptional() {
    let issues = "var foo: Int! = nil"
      .inspect(withRule: RedundantInitializationToNilRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testNoInitialization() {
    let issues = "var foo: Int?"
      .inspect(withRule: RedundantInitializationToNilRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testInitializationToNil() {
    let issues = "var foo: Int? = nil"
      .inspect(withRule: RedundantInitializationToNilRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "redundant_initialization_to_nil")
    XCTAssertEqual(issue.description, "`nil` initialization can be safely removed for variable `foo`")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 20)
  }

  func testTwoInitializationsToNil() {
    let issues = "var foo: Int? = nil, x: Double! = nil, y: String?, z: String? = nil"
      .inspect(withRule: RedundantInitializationToNilRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "redundant_initialization_to_nil")
    XCTAssertEqual(issue.description, "`nil` initialization can be safely removed for variables `foo` and `z`")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 68)
  }

  func testMultipleInitializationsToNil() {
    let issues = "var foo: Int? = nil, x: Double? = nil, y: String?, z: String? = nil"
      .inspect(withRule: RedundantInitializationToNilRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "redundant_initialization_to_nil")
    XCTAssertEqual(issue.description, "`nil` initialization can be safely removed for variables `foo`, `x` and `z`")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 68)
  }

  static var allTests = [
    ("testProperties", testProperties),
    ("testNotOptional", testNotOptional),
    ("testNoInitialization", testNoInitialization),
    ("testInitializationToNil", testInitializationToNil),
    ("testTwoInitializationsToNil", testTwoInitializationsToNil),
    ("testMultipleInitializationsToNil", testMultipleInitializationsToNil),
  ]
}
