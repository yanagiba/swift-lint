/*
   Copyright 2015-2017 Ryuichi Laboratories and the Yanagiba project contributors

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

class CorrectionTests : XCTestCase {
  func testOneSuggestion() {
    let correction = Correction(suggestion: "one suggestion")
    XCTAssertEqual(correction.suggestions.count, 1)
    XCTAssertEqual(correction.description, "one suggestion")
  }

  func testMultipleSuggestions() {
    let correction = Correction(suggestions: ["foo", "bar", "abc", "xyz"])
    XCTAssertEqual(correction.suggestions.count, 4)
    XCTAssertEqual(correction.description, "foo;bar;abc;xyz")
  }

  static var allTests = [
    ("testOneSuggestion", testOneSuggestion),
    ("testMultipleSuggestions", testMultipleSuggestions),
  ]
}
