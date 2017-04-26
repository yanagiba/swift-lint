/*
   Copyright 2015-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

class RuleProtocolTests : XCTestCase {
  func testIdentifierConversion() {
    class DoNothingRule : Rule {
      var name: String {
        return "Do Nothing"
      }
      var description: String { return "" }
      var markdown: String { return "" }
      func emitIssue(_: Issue) {}
      func inspect(_: ASTContext, configurations: [String: Any]?) {}
    }

    let doNothingRule = DoNothingRule()
    XCTAssertEqual(doNothingRule.identifier, "do_nothing")
  }

  func testWhiteSpaces() {
    class TooManySpacesRule : Rule {
      var name: String {
        return "I   Typed     Too        Many                Spaces"
      }
      var description: String { return "" }
      var markdown: String { return "" }
      func emitIssue(_: Issue) {}
      func inspect(_: ASTContext, configurations: [String: Any]?) {}
    }

    let tooManySpacesRule = TooManySpacesRule()
    XCTAssertEqual(tooManySpacesRule.identifier, "i_typed_too_many_spaces")
  }

  func testIdentifierImplementation() {
    class WithCustomIdentifierRule : Rule {
      var name: String {
        return "Rule Name"
      }
      var identifier: String {
        return "rule_identifier"
      }
      var description: String { return "" }
      var markdown: String { return "" }
      func emitIssue(_: Issue) {}
      func inspect(_: ASTContext, configurations: [String: Any]?) {}
    }

    let customIdentifierRule = WithCustomIdentifierRule()
    XCTAssertEqual(customIdentifierRule.identifier, "rule_identifier")
  }

  func testNameContainsPunctuations() {
    class NameHasPunctuationsRule : Rule {
      var name: String {
        return "(I'am the one with the force) May the Force be with y'all, always!"
      }
      var description: String { return "" }
      var markdown: String { return "" }
      func emitIssue(_: Issue) {}
      func inspect(_: ASTContext, configurations: [String: Any]?) {}
    }

    let may4Rule = NameHasPunctuationsRule()
    XCTAssertEqual(
      may4Rule.identifier,
      "iam_the_one_with_the_force_may_the_force_be_with_yall_always")
  }

  static var allTests = [
    ("testIdentifierConversion", testIdentifierConversion),
    ("testWhiteSpaces", testWhiteSpaces),
    ("testIdentifierImplementation", testIdentifierImplementation),
    ("testNameContainsPunctuations", testNameContainsPunctuations),
  ]
}
