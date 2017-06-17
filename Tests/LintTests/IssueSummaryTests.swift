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
@testable import Lint

class IssueSummaryTests : XCTestCase {
  func testNoIssue() {
    let summary = IssueSummary(issues: [])
    XCTAssertEqual(summary.numberOfFiles, 0)
    XCTAssertEqual(summary.numberOfIssues(withSeverity: .critical), 0)
    XCTAssertEqual(summary.numberOfIssues(withSeverity: .major), 0)
    XCTAssertEqual(summary.numberOfIssues(withSeverity: .minor), 0)
    XCTAssertEqual(summary.numberOfIssues(withSeverity: .cosmetic), 0)
  }

  func testTotalCounts() {
    let summary = IssueSummary(issues: [
      issue("a", .major),
      issue("a", .critical),
      issue("b", .major),
      issue("c", .major),
      issue("c", .minor),
      issue("c", .cosmetic),
    ])
    XCTAssertEqual(summary.numberOfFiles, 3)
    XCTAssertEqual(summary.numberOfIssues(withSeverity: .critical), 1)
    XCTAssertEqual(summary.numberOfIssues(withSeverity: .major), 3)
    XCTAssertEqual(summary.numberOfIssues(withSeverity: .minor), 1)
    XCTAssertEqual(summary.numberOfIssues(withSeverity: .cosmetic), 1)
  }

  private func issue(_ path: String, _ severity: Issue.Severity) -> Issue {
    return Issue(
      ruleIdentifier: "issue_summary_test_rule",
      description: "",
      category: .badPractice,
      location: SourceRange(
        start: SourceLocation(path: path, line: 0, column: 0),
        end: SourceLocation(path: path, line: 0, column: 0)),
      severity: severity,
      correction: nil)
  }

  static var allTests = [
    ("testNoIssue", testNoIssue),
    ("testTotalCounts", testTotalCounts),
  ]
}
