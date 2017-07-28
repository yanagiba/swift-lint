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

@testable import Lint
@testable import Source

class XcodeReporterTests : XCTestCase {
  let xcodeReporter = XcodeReporter()

  func testReportIssues() {
    let testIssues = Issue.Severity.allSeverities.map {
      Issue(
        ruleIdentifier: "rule_id",
        description: "text description for testing",
        category: .badPractice,
        location: SourceRange(
          start: SourceLocation(identifier: "test/testXcodeReporterStart", line: 1, column: 2),
          end: SourceLocation(identifier: "test/testXcodeReporterEnd", line: 3, column: 4)),
        severity: $0,
        correction: nil)
    }
    XCTAssertEqual(
      xcodeReporter.handle(issues: testIssues),
      """
      test/testXcodeReporterStart:1:2: error: [rule_id] text description for testing
      test/testXcodeReporterStart:1:2: error: [rule_id] text description for testing
      test/testXcodeReporterStart:1:2: warning: [rule_id] text description for testing
      test/testXcodeReporterStart:1:2: warning: [rule_id] text description for testing
      """)
  }

  func testReportIssueWithCurrentDirectoryPathTrimmed() {
    let pwd = FileManager.default.currentDirectoryPath
    let testIssue = Issue(
      ruleIdentifier: "rule_id",
      description: "text description for testing",
      category: .badPractice,
      location: SourceRange(
        start: SourceLocation(identifier: "\(pwd)/test/testXcodeReporterStart", line: 1, column: 2),
        end: SourceLocation(identifier: "\(pwd)/test/testXcodeReporterEnd", line: 3, column: 4)),
      severity: .critical,
      correction: nil)
    XCTAssertEqual(
      xcodeReporter.handle(issues: [testIssue]),
      "\(pwd)/test/testXcodeReporterStart:1:2: error: [rule_id] text description for testing")
  }

  func testReportIssueWithEmptyDescription() {
    let testIssue = Issue(
      ruleIdentifier: "rule_id",
      description: "",
      category: .badPractice,
      location: SourceRange(
        start: SourceLocation(identifier: "test", line: 1, column: 2),
        end: SourceLocation(identifier: "testEnd", line: 3, column: 4)),
      severity: .minor,
      correction: nil)
    XCTAssertEqual(xcodeReporter.handle(issues: [testIssue]), "test:1:2: warning: [rule_id]")
  }

  func testReportSummary() {
    for (_, severity) in Issue.Severity.allSeverities.enumerated() {
      let testIssue = Issue(
        ruleIdentifier: "rule_id",
        description: "",
        category: .badPractice,
        location: .EMPTY,
        severity: severity,
        correction: nil)
      let issueSummary = IssueSummary(issues: [testIssue])
      XCTAssertTrue(xcodeReporter.handle(numberOfTotalFiles: 100, issueSummary: issueSummary).isEmpty)
    }
  }

  func testNoIssue() {
    let issueSummary = IssueSummary(issues: [])
    XCTAssertTrue(xcodeReporter.handle(numberOfTotalFiles: 100, issueSummary: issueSummary).isEmpty)
    XCTAssertTrue(xcodeReporter.handle(issues: []).isEmpty)
  }

  func testHeader() {
    XCTAssertTrue(xcodeReporter.header.isEmpty)
  }

  func testFooter() {
    XCTAssertTrue(xcodeReporter.footer.isEmpty)
  }

  func testSeparator() {
    XCTAssertEqual(xcodeReporter.separator, "\n")
  }

  static var allTests = [
    ("testReportIssues", testReportIssues),
    ("testReportIssueWithCurrentDirectoryPathTrimmed", testReportIssueWithCurrentDirectoryPathTrimmed),
    ("testReportIssueWithEmptyDescription", testReportIssueWithEmptyDescription),
    ("testReportSummary", testReportSummary),
    ("testNoIssue", testNoIssue),
    ("testHeader", testHeader),
    ("testFooter", testFooter),
    ("testSeparator", testSeparator),
  ]
}
