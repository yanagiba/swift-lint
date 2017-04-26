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

@testable import Source
@testable import Parser
@testable import Lint

fileprivate var issues = [Issue]()

class SourceCodeRuleTests : XCTestCase {
  override func setUp() {
    issues = [Issue]()
  }

  class SourceCodeRuleForTesting : RuleBase, SourceCodeRule {
    var name: String {
      return "Testing SourceCode"
    }
    var description: String { return "" }
    var markdown: String { return "" }

    func emitIssue(_ issue: Issue) {
      issues.append(issue)
    }

    func inspect(line: String, lineNumber: Int) {
      if let configurations = configurations,
        let contains = configurations["contains"] as? String,
        let containsRange = line.range(of: contains),
        let sourceFile = astContext?.sourceFile
      {
        let startLocation = line.distance(
          from: line.startIndex, to: containsRange.lowerBound)
        let endLocation = line.distance(
          from: line.startIndex, to: containsRange.upperBound)

        emitIssue(Issue(
          ruleIdentifier: identifier,
          description: "`\(contains)` is quite dangerous for testing purposes",
          category: .badPractice,
          location: SourceRange(
            start: SourceLocation(
              path: sourceFile.path, line: lineNumber, column: startLocation),
            end: SourceLocation(
              path: sourceFile.path, line: lineNumber, column: endLocation)),
          severity: .normal,
          correction: nil))
      }
    }
  }

  private func inspect(_ str: String, configurations: [String: Any]? = nil) {
    let sourceFile = SourceFile(
      path: "LintTests/SourceCodeRuleTests", content: str)
    let parser = Parser(source: sourceFile)
    guard let topLevelDecl = try? parser.parse() else {
      XCTFail("Failed in parsing content: \(str)")
      return
    }
    let astContext =
      ASTContext(sourceFile: sourceFile, topLevelDeclaration: topLevelDecl)
    SourceCodeRuleForTesting().inspect(
      astContext, configurations: configurations)
  }

  func testNoIssue() {
    inspect("// this line doesn't contain the word")
    XCTAssertTrue(issues.isEmpty)
  }

  func testOneIssue() {
    inspect(
      "// this line contains",
      configurations: ["contains": "contains"])
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "testing_sourcecode")
    XCTAssertEqual(issue.description, "`contains` is quite dangerous for testing purposes")
    let range = issue.location
    XCTAssertEqual(range.start.path, "LintTests/SourceCodeRuleTests")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 13)
    XCTAssertEqual(range.end.path, "LintTests/SourceCodeRuleTests")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 21)
  }

  func testNoIssueDueToMismatchConfiguration() {
    inspect("import foo", configurations: ["contains": "bar"])
    XCTAssertTrue(issues.isEmpty)
  }

  static var allTests = [
    ("testNoIssue", testNoIssue),
    ("testOneIssue", testOneIssue),
    ("testNoIssueDueToMismatchConfiguration", testNoIssueDueToMismatchConfiguration),
  ]
}
