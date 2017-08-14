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

@testable import Source
@testable import Parser
@testable import Lint

class RuleBaseTests : XCTestCase {
  func testEmptyConfigurations() {
    let ruleBase = RuleBase()
    let integer: Int = 1
    XCTAssertEqual(ruleBase.getConfiguration(forKey: "integer", orDefault: integer), integer)
    let double: Double = 1.23
    XCTAssertEqual(ruleBase.getConfiguration(forKey: "double", orDefault: double), double)
    let string: String = "string"
    XCTAssertEqual(ruleBase.getConfiguration(forKey: "string", orDefault: string), string)
    let array: [Int] = [1, 2, 3]
    XCTAssertEqual(ruleBase.getConfiguration(forKey: "array", orDefault: array), array)
    let dictionary: [String: Any] = ["foo": 1, "bar": (2.34, "👌")]
    let defaultDict = ruleBase.getConfiguration(forKey: "dictionary", orDefault: dictionary)
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
    XCTAssertEqual(ruleBase.getConfiguration(forKey: "integer", orDefault: 1), -1)
    XCTAssertEqual(ruleBase.getConfiguration(forKey: "double", orDefault: 1.23), -1.23)
    XCTAssertEqual(ruleBase.getConfiguration(forKey: "string", orDefault: "string"), "foobar")
    XCTAssertEqual(ruleBase.getConfiguration(forKey: "array", orDefault: [1, 2, 3]), [3, 2, 1])
    let dictionary: [String: Any] = ["foo": 1, "bar": (2.34, "👌")]
    let defaultDict = ruleBase.getConfiguration(forKey: "dictionary", orDefault: dictionary)
    XCTAssertEqual(defaultDict.count, 1)
    XCTAssertEqual(defaultDict["foo"] as? String, "bar")
  }

  func testRetrieveFromCommentBasedConfigurations() {
    let ruleBase = parse("""
      /*
       swift-lint:rule_configure(integer=1,double=1.23):rule_configure(string=bar_foo)
       swift-lint:rule_configure(boolean=false)
       swift-lint:rule_configure(boolean2=true)
       */
      """)
    ruleBase.configurations = [
      "integer": -1,
      "double": -1.23,
      "string": "foobar",
      "boolean": true,
      "boolean2": false,
    ]
    XCTAssertEqual(ruleBase.getConfiguration(forKey: "integer", atLineNumber: 1, orDefault: 0), 1)
    XCTAssertEqual(ruleBase.getConfiguration(forKey: "integer", atLineNumber: 2, orDefault: 0), -1)
    XCTAssertEqual(ruleBase.getConfiguration(forKey: "double", atLineNumber: 1, orDefault: 0.0), 1.23)
    XCTAssertEqual(ruleBase.getConfiguration(forKey: "double", atLineNumber: 2, orDefault: 0.0), -1.23)
    XCTAssertEqual(ruleBase.getConfiguration(forKey: "string", atLineNumber: 1, orDefault: "defualt"), "bar_foo")
    XCTAssertEqual(ruleBase.getConfiguration(forKey: "string", atLineNumber: 2, orDefault: "defualt"), "foobar")
    XCTAssertEqual(ruleBase.getConfiguration(forKey: "boolean", atLineNumber: 1, orDefault: true), false)
    XCTAssertEqual(ruleBase.getConfiguration(forKey: "boolean", atLineNumber: 2, orDefault: false), true)
    XCTAssertEqual(ruleBase.getConfiguration(forKey: "boolean2", atLineNumber: 1, orDefault: false), true)
    XCTAssertEqual(ruleBase.getConfiguration(forKey: "boolean2", atLineNumber: 2, orDefault: true), false)
  }

  func testRetrieveFromCalculatedConfigurations() {
    let ruleBase = parse("""
      /*
       swift-lint:rule_configure(A=a,B=b):rule_configure(C=c)
       */
      """)
    XCTAssertEqual(ruleBase.getCommentBasedConfiguration(forKey: "A", atLineNumber: 1), "a")
    XCTAssertEqual(ruleBase.getCommentBasedConfiguration(forKey: "B", atLineNumber: 1), "b")
    XCTAssertEqual(ruleBase.getCommentBasedConfiguration(forKey: "C", atLineNumber: 1), "c")
    XCTAssertNil(ruleBase.getCommentBasedConfiguration(forKey: "D", atLineNumber: 1))
    XCTAssertNil(ruleBase.getCommentBasedConfiguration(forKey: "A", atLineNumber: 2))
  }

  func testCommentBasedSuppressions() { // swift-lint:suppress
    let ruleBase = parse("""
      // line doesn't have the looked keyword
      /* swift-lint:suppress() */
      // swift-lint:suppress(A)
      // swift-lint:suppress(A,B)
      /*
       swift-lint:suppress(A,B,C):suppress(D)
       swift-lint:suppress(E)
       */
      //swift-lint:suppress(A):suppress
      //swift-lint:suppress:suppress(A)
      /* swift-lint:only_other_flags() */
      //  swift-lint:suppress(A):other_flags(a):other_flags_no_args:suppress(B)
      """)
    let suppressions = ruleBase.commentBasedSuppressions
    XCTAssertEqual(suppressions.count, 7)
    XCTAssertNil(suppressions[0])
    XCTAssertNil(suppressions[1])
    guard let suppression2 = suppressions[2] else {
      XCTFail("Failed in getting the suppression settings from line 2.")
      return
    }
    XCTAssertTrue(suppression2.isEmpty)
    guard let suppression3 = suppressions[3] else {
      XCTFail("Failed in getting the suppression settings from line 3.")
      return
    }
    XCTAssertEqual(suppression3, ["A"])
    guard let suppression4 = suppressions[4] else {
      XCTFail("Failed in getting the suppression settings from line 4.")
      return
    }
    XCTAssertEqual(suppression4, ["A", "B"])
    guard let suppression5 = suppressions[5] else {
      XCTFail("Failed in getting the suppression settings from line 5.")
      return
    }
    XCTAssertEqual(suppression5, ["A", "B", "C", "D", "E"])
    XCTAssertNil(suppressions[6])
    XCTAssertNil(suppressions[7])
    XCTAssertNil(suppressions[8])
    guard let suppression9 = suppressions[9] else {
      XCTFail("Failed in getting the suppression settings from line 9.")
      return
    }
    XCTAssertTrue(suppression9.isEmpty)
    guard let suppression10 = suppressions[10] else {
      XCTFail("Failed in getting the suppression settings from line 10.")
      return
    }
    XCTAssertTrue(suppression10.isEmpty)
    XCTAssertNil(suppressions[11])
    guard let suppression12 = suppressions[12] else {
      XCTFail("Failed in getting the suppression settings from line 12.")
      return
    }
    XCTAssertEqual(suppression12, ["A", "B"])
    XCTAssertNil(suppressions[13])
    XCTAssertNil(suppressions[14])
    XCTAssertNil(suppressions[15])
  }

  func testCommentBasedRuleConfigurations() { // swift-lint:suppress
    let ruleBase = parse("""
      // line doesn't have the looked keyword
      /* swift-lint:rule_configure() */
      // swift-lint:rule_configure(A=a)
      // swift-lint:rule_configure(A=a, B = b)
      /*
       swift-lint:rule_configure(A=a,B=b,C=c):rule_configure(D=d)
       swift-lint:rule_configure(E=e)
       */
      //swift-lint:rule_configure(A=a):rule_configure
      //swift-lint:rule_configure:rule_configure(A=a)
      /* swift-lint:only_other_flags() */
      //  swift-lint:rule_configure(A=a):other_flags(a):other_flags_no_args:rule_configure(B=b)
      """)
    let ruleConfigurations = ruleBase.commentBasedConfigurations
    XCTAssertEqual(ruleConfigurations.count, 7)
    XCTAssertNil(ruleConfigurations[0])
    XCTAssertNil(ruleConfigurations[1])
    guard let ruleConfiguration2 = ruleConfigurations[2] else {
      XCTFail("Failed in getting the rule configuration settings from line 2.")
      return
    }
    XCTAssertTrue(ruleConfiguration2.isEmpty)
    guard let ruleConfiguration3 = ruleConfigurations[3] else {
      XCTFail("Failed in getting the rule configuration settings from line 3.")
      return
    }
    XCTAssertEqual(ruleConfiguration3, ["A": "a"])
    guard let ruleConfiguration4 = ruleConfigurations[4] else {
      XCTFail("Failed in getting the rule configuration settings from line 4.")
      return
    }
    XCTAssertEqual(ruleConfiguration4, ["A": "a", "B": "b"])
    guard let ruleConfiguration5 = ruleConfigurations[5] else {
      XCTFail("Failed in getting the rule configuration settings from line 5.")
      return
    }
    XCTAssertEqual(ruleConfiguration5, ["A": "a", "B": "b", "C": "c", "D": "d", "E": "e"])
    XCTAssertNil(ruleConfigurations[6])
    XCTAssertNil(ruleConfigurations[7])
    XCTAssertNil(ruleConfigurations[8])
    guard let ruleConfiguration9 = ruleConfigurations[9] else {
      XCTFail("Failed in getting the rule configuration settings from line 9.")
      return
    }
    XCTAssertEqual(ruleConfiguration9, ["A": "a"])
    guard let ruleConfiguration10 = ruleConfigurations[10] else {
      XCTFail("Failed in getting the rule configuration settings from line 10.")
      return
    }
    XCTAssertEqual(ruleConfiguration10, ["A": "a"])
    XCTAssertNil(ruleConfigurations[11])
    guard let ruleConfiguration12 = ruleConfigurations[12] else {
      XCTFail("Failed in getting the rule configuration settings from line 12.")
      return
    }
    XCTAssertEqual(ruleConfiguration12, ["A": "a", "B": "b"])
    XCTAssertNil(ruleConfigurations[13])
    XCTAssertNil(ruleConfigurations[14])
    XCTAssertNil(ruleConfigurations[15])
  }

  private func parse(_ str: String) -> RuleBase {
    let sourceFile = SourceFile(
      path: "LintTests/RuleBaseTests_\(UUID().uuidString)", content: str)
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
    ("testRetrieveFromCommentBasedConfigurations", testRetrieveFromCommentBasedConfigurations),
    ("testRetrieveFromCalculatedConfigurations", testRetrieveFromCalculatedConfigurations),
    ("testCommentBasedSuppressions", testCommentBasedSuppressions),
    ("testCommentBasedRuleConfigurations", testCommentBasedRuleConfigurations),
  ]
}
