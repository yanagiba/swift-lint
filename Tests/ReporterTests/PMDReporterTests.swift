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

@testable import Lint
@testable import Source

class PMDReporterTests : XCTestCase {
  let pmdReporter = PMDReporter()

  func testReportIssues() {
    let testIssue = Issue(
      ruleIdentifier: "rule_id",
      description: "text description for testing",
      category: .badPractice,
      location: SourceRange(
        start: SourceLocation(identifier: "test/testPMDReporterStart", line: 1, column: 2),
        end: SourceLocation(identifier: "test/testPMDReporterEnd", line: 3, column: 4)),
      severity: .major,
      correction: nil)
    XCTAssertEqual(
      pmdReporter.handle(issues: [testIssue, testIssue, testIssue]),
      """
      <file name="test/testPMDReporterStart">
      <violation
        begincolumn="2"
        endcolumn="4"
        beginline="1"
        endline="3"
        priority="2"
        rule="rule_id"
        ruleset="bad practice">
      text description for testing
      </violation>
      </file><file name="test/testPMDReporterStart">
      <violation
        begincolumn="2"
        endcolumn="4"
        beginline="1"
        endline="3"
        priority="2"
        rule="rule_id"
        ruleset="bad practice">
      text description for testing
      </violation>
      </file><file name="test/testPMDReporterStart">
      <violation
        begincolumn="2"
        endcolumn="4"
        beginline="1"
        endline="3"
        priority="2"
        rule="rule_id"
        ruleset="bad practice">
      text description for testing
      </violation>
      </file>
      """)
  }

  func testReportIssueWithCurrentDirectoryPathTrimmed() {
    let pwd = FileManager.default.currentDirectoryPath
    let testIssue = Issue(
      ruleIdentifier: "rule_id",
      description: "text description for testing",
      category: .badPractice,
      location: SourceRange(
        start: SourceLocation(identifier: "\(pwd)/test/testPMDReporterStart", line: 1, column: 2),
        end: SourceLocation(identifier: "\(pwd)/test/testPMDReporterEnd", line: 3, column: 4)),
      severity: .critical,
      correction: nil)
    XCTAssertEqual(
      pmdReporter.handle(issues: [testIssue]),
      """
      <file name="test/testPMDReporterStart">
      <violation
        begincolumn="2"
        endcolumn="4"
        beginline="1"
        endline="3"
        priority="1"
        rule="rule_id"
        ruleset="bad practice">
      text description for testing
      </violation>
      </file>
      """)
  }

  func testReportIssueWithEmptyDescription() {
    let testIssues = [
      Issue(
        ruleIdentifier: "rule_id",
        description: "",
        category: .badPractice,
        location: SourceRange(
          start: SourceLocation(identifier: "test", line: 1, column: 2),
          end: SourceLocation(identifier: "testEnd", line: 3, column: 4)),
        severity: .minor,
        correction: nil),
      Issue(
        ruleIdentifier: "rule_id",
        description: "",
        category: .badPractice,
        location: SourceRange(
          start: SourceLocation(identifier: "test", line: 1, column: 2),
          end: SourceLocation(identifier: "testEnd", line: 3, column: 4)),
        severity: .cosmetic,
        correction: nil),
    ]
    XCTAssertEqual(
      pmdReporter.handle(issues: testIssues),
      """
      <file name="test">
      <violation
        begincolumn="2"
        endcolumn="4"
        beginline="1"
        endline="3"
        priority="3"
        rule="rule_id"
        ruleset="bad practice">

      </violation>
      </file><file name="test">
      <violation
        begincolumn="2"
        endcolumn="4"
        beginline="1"
        endline="3"
        priority="4"
        rule="rule_id"
        ruleset="bad practice">

      </violation>
      </file>
      """)
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
      XCTAssertTrue(pmdReporter.handle(numberOfTotalFiles: 100, issueSummary: issueSummary).isEmpty)
    }
  }

  func testNoIssue() {
    let issueSummary = IssueSummary(issues: [])
    XCTAssertTrue(pmdReporter.handle(numberOfTotalFiles: 100, issueSummary: issueSummary).isEmpty)
    XCTAssertTrue(pmdReporter.handle(issues: []).isEmpty)
  }

  func testHeader() {
    XCTAssertEqual(pmdReporter.header,
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <pmd version="yanagiba-swift-lint-\(SWIFT_LINT_VERSION)">
    """)
  }

  func testFooter() {
    XCTAssertEqual(pmdReporter.footer, "</pmd>")
  }

  func testSeparator() {
    XCTAssertTrue(pmdReporter.separator.isEmpty)
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
