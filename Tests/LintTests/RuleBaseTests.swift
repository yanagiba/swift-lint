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

@testable import Source
@testable import Parser
@testable import Lint

class RuleBaseTests : XCTestCase {
  func testEmptyConfigurations() {
    let ruleBase = RuleBase()
    let integer: Int = 1
    XCTAssertEqual(ruleBase.getConfiguration(for: "integer", orDefault: integer), integer)
    let double: Double = 1.23
    XCTAssertEqual(ruleBase.getConfiguration(for: "double", orDefault: double), double)
    let string: String = "string"
    XCTAssertEqual(ruleBase.getConfiguration(for: "string", orDefault: string), string)
    let array: [Int] = [1, 2, 3]
    XCTAssertEqual(ruleBase.getConfiguration(for: "array", orDefault: array), array)
    let dictionary: [String: Any] = ["foo": 1, "bar": (2.34, "👌")]
    let defaultDict = ruleBase.getConfiguration(for: "dictionary", orDefault: dictionary)
    XCTAssertEqual(defaultDict.count, 2)
    XCTAssertEqual(defaultDict["foo"] as? Int, 1)
    guard let barValue = defaultDict["bar"] as? (Double, String) else {
      XCTFail("Failed in retrieving configuration for `bar`.")
      return
    }
    XCTAssertEqual(barValue.0, 2.34)
    XCTAssertEqual(barValue.1, "👌")
  }

  func testRetriveFromCustomConfigurations() {
    let ruleBase = RuleBase()
    ruleBase.configurations = [
      "integer": -1,
      "double": -1.23,
      "string": "foobar",
      "array": [3, 2, 1],
      "dictionary": ["foo": "bar"]
    ]
    XCTAssertEqual(ruleBase.getConfiguration(for: "integer", orDefault: 1), -1)
    XCTAssertEqual(ruleBase.getConfiguration(for: "double", orDefault: 1.23), -1.23)
    XCTAssertEqual(ruleBase.getConfiguration(for: "string", orDefault: "string"), "foobar")
    XCTAssertEqual(ruleBase.getConfiguration(for: "array", orDefault: [1, 2, 3]), [3, 2, 1])
    let dictionary: [String: Any] = ["foo": 1, "bar": (2.34, "👌")]
    let defaultDict = ruleBase.getConfiguration(for: "dictionary", orDefault: dictionary)
    XCTAssertEqual(defaultDict.count, 1)
    XCTAssertEqual(defaultDict["foo"] as? String, "bar")
  }

  func testCommentBasedSuppressions() {
    let ruleBase = parse("""
      // line doesn't have the looked keyword
      /* swift-lint:suppress() */
      // swift-lint:suppress(A)
      // swift-lint:suppress(A,B)
      /*
       swift-lint:suppress(A,B,C):suppress(D)
       swift-lint:suppress(E)
       */
      //swift-lint:suppress(A):suppress()
      //swift-lint:suppress():suppress(A)
      /* swift-lint:only_other_flags() */
      //  swift-lint:suppress(A):other_flags(a):other_flags_no_args():suppress(B)
      """)
    // print(ruleBase.commentBasedSuppressions)
    XCTAssertEqual(ruleBase.commentBasedSuppressions.count, 7)
  }

  private func parse(_ str: String) -> RuleBase {
    let sourceFile = SourceFile(
      path: "LintTests/RuleBaseTests", content: str)
    let parser = Parser(source: sourceFile)
    guard let topLevelDecl = try? parser.parse() else {
      fatalError("Failed in parsing content: \(str)")
    }

    let ruleBase = RuleBase()
    ruleBase.astContext =
      ASTContext(sourceFile: sourceFile, topLevelDeclaration: topLevelDecl)
    return ruleBase
  }

  static var allTests = [
    ("testEmptyConfigurations", testEmptyConfigurations),
    ("testRetriveFromCustomConfigurations", testRetriveFromCustomConfigurations),
    ("testCommentBasedSuppressions", testCommentBasedSuppressions),
  ]
}
