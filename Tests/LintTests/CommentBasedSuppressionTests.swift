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

fileprivate var issues = [Issue]()

class CommentBasedSuppressionTests : XCTestCase {
  override func setUp() {
    super.setUp()

    issues = [Issue]()
  }

  class CatchAllRuleForTesting : RuleBase, SourceCodeRule {
    var name: String {
      return "Testing Suppressions"
    }

    func emitIssue(_ issue: Issue) {
      issues.append(issue)
    }

    func inspect(line: String, lineNumber: Int) {
      let srcLoc = SourceLocation(
        path: astContext?.sourceFile.path ?? "", line: lineNumber, column: 0)
      emitIssue(SourceRange(start: srcLoc, end: srcLoc), description: "")
    }
  }

  private func inspect(_ str: String, configurations: [String: Any]? = nil) {
    let sourceFile = SourceFile(
      path: "LintTests/CommentBasedSuppressionTests_\(UUID().uuidString)", content: str)
    let parser = Parser(source: sourceFile)
    guard let topLevelDecl = try? parser.parse() else {
      fatalError("Failed in parsing content: \(str)")
    }
    let astContext =
      ASTContext(sourceFile: sourceFile, topLevelDeclaration: topLevelDecl)
    CatchAllRuleForTesting().inspect(
      astContext, configurations: configurations)
  }

  func testNoSuppression() {
    inspect("""
    if () {}
    if () {}
    if () {}
    if () {}
    """)
    XCTAssertEqual(issues.count, 4)
    for i in 0..<4 {
      XCTAssertEqual(issues[i].ruleIdentifier, "testing_suppressions")
      XCTAssertEqual(issues[i].location.start.line, i+1)
    }
  }

  func testSingleLineCommentSuppressions() {
    inspect("""
    if () {} // swift-lint:suppress
    if () {} // swift-lint:suppress()
    if () {} // swift-lint:suppress(testing_suppressions)
    if () {} // swift-lint:suppress(foo, testing_suppressions, bar)
    """)
    XCTAssertTrue(issues.isEmpty)
  }

  func testMultiLineCommentSuppressions() {
    inspect("""
    if () {} /* swift-lint:suppress */
    if () {} /* swift-lint:suppress() */
    if () {} /* swift-lint:suppress(testing_suppressions) */
    if () {} /* swift-lint:suppress(foo, testing_suppressions, bar) */
    """)
    XCTAssertTrue(issues.isEmpty)
  }

  static var allTests = [
    ("testNoSuppression", testNoSuppression),
    ("testSingleLineCommentSuppressions", testSingleLineCommentSuppressions),
    ("testMultiLineCommentSuppressions", testMultiLineCommentSuppressions),
  ]
}
