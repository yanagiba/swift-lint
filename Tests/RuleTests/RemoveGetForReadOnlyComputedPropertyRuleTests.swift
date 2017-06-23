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

class RemoveGetForReadOnlyComputedPropertyRuleTests : XCTestCase {
  func testNotReadOnlyComputedProperty() {
    let issues = "var i = 1; var j: Int { get { return i } set { i = newValue } }"
      .inspect(withRule: RemoveGetForReadOnlyComputedPropertyRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testReadOnlyComputedPropertyWithoutGet() {
    let issues = "var i = 1; var j: Int { return i }"
      .inspect(withRule: RemoveGetForReadOnlyComputedPropertyRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testReadOnlyComputedPropertyWithGet() {
    let issues = "var i: Int { get { return 0 } }"
      .inspect(withRule: RemoveGetForReadOnlyComputedPropertyRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "remove_get_for_readonly_computed_property")
    XCTAssertEqual(issue.description,
      "read-only computed property `i` can be simplified by removing the `get` keyword and its braces")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .minor)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 32)
    guard let correction = issue.correction, correction.suggestions.count == 1 else {
      XCTFail("Failed in getting a suggestion.")
      return
    }
    let suggestion = correction.suggestions[0]
    XCTAssertEqual(suggestion, """
      var i: Int {
        return 0
      }
      """)
  }

  func testReadOnlyComputedPropertyWithGetAndAttributesOrModifier() {
    let issues = "var i: Int { @foo get { return 0 } }; var j: Int { mutating get { return 1 } }"
      .inspect(withRule: RemoveGetForReadOnlyComputedPropertyRule())
    XCTAssertTrue(issues.isEmpty)
  }

  static var allTests = [
    ("testNotReadOnlyComputedProperty", testNotReadOnlyComputedProperty),
    ("testReadOnlyComputedPropertyWithoutGet", testReadOnlyComputedPropertyWithoutGet),
    ("testReadOnlyComputedPropertyWithGet", testReadOnlyComputedPropertyWithGet),
    ("testReadOnlyComputedPropertyWithGetAndAttributesOrModifier",
      testReadOnlyComputedPropertyWithGetAndAttributesOrModifier),
  ]
}
