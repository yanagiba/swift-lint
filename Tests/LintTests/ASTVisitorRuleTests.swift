/*
   Copyright 2016-2017 Ryuichi Laboratories and the Yanagiba project contributors

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
@testable import AST
@testable import Parser
@testable import Lint

fileprivate var issues = [Issue]()

class ASTVisitorRuleTests : XCTestCase {
  override func setUp() {
    super.setUp()

    issues = [Issue]()
  }

  class ASTVisitorRuleForTesting : RuleBase, ASTVisitorRule {
    var name: String {
      return "Testing ASTVisitor"
    }

    func emitIssue(_ issue: Issue) {
      issues.append(issue)
    }

    func visit(_ importDecl: ImportDeclaration) throws -> Bool {
      let pathText = importDecl.path.joined(separator: ".")
      if let configurations = configurations,
        let moduleName = configurations["moduleName"] as? String,
        pathText == moduleName
      {
        emitIssue(Issue(
          ruleIdentifier: identifier,
          description: "\(pathText) is not allowed in import declaration for testing purposes",
          category: .size,
          location: importDecl.sourceRange,
          severity: .cosmetic,
          correction: nil))
      }

      return true
    }
  }

  private func inspect(_ str: String, configurations: [String: Any]? = nil) {
    let sourceFile = SourceFile(
      path: "LintTests/ASTVisitorRuleTests", content: str)
    let parser = Parser(source: sourceFile)
    guard let topLevelDecl = try? parser.parse() else {
      XCTFail("Failed in parsing content: \(str)")
      return
    }
    let astContext =
      ASTContext(sourceFile: sourceFile, topLevelDeclaration: topLevelDecl)
    ASTVisitorRuleForTesting().inspect(astContext, configurations: configurations)
  }

  func testNoIssue() {
    inspect("import foo")
    XCTAssertTrue(issues.isEmpty)
  }

  func testOneIssue() {
    inspect("import foo", configurations: ["moduleName": "foo"])
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "testing_astvisitor")
    XCTAssertEqual(issue.description, "foo is not allowed in import declaration for testing purposes")
    let range = issue.location
    XCTAssertEqual(range.start.identifier, "LintTests/ASTVisitorRuleTests")
    XCTAssertEqual(range.start.line, 1)
    XCTAssertEqual(range.start.column, 1)
    XCTAssertEqual(range.end.identifier, "LintTests/ASTVisitorRuleTests")
    XCTAssertEqual(range.end.line, 1)
    XCTAssertEqual(range.end.column, 11)
  }

  func testMultipleIssues() {
    inspect(
      "import foo\nimport bar\nimport foo\nimport bar\nimport foo",
      configurations: ["moduleName": "foo"])
    XCTAssertEqual(issues.count, 3)
  }

  func testNoIssueDueToMismatchConfiguration() {
    inspect("import foo", configurations: ["moduleName": "bar"])
    XCTAssertTrue(issues.isEmpty)
  }

  static var allTests = [
    ("testNoIssue", testNoIssue),
    ("testOneIssue", testOneIssue),
    ("testMultipleIssues", testMultipleIssues),
    ("testNoIssueDueToMismatchConfiguration", testNoIssueDueToMismatchConfiguration),
  ]
}
