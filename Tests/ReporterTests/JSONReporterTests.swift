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

class JSONReporterTests : XCTestCase {
  let jsonReporter = JSONReporter()

  func testReportIssues() {
    let testIssue = Issue(
      ruleIdentifier: "rule_id",
      description: "text description for testing",
      category: .badPractice,
      location: SourceRange(
        start: SourceLocation(identifier: "test/testJSONReporterStart", line: 1, column: 2),
        end: SourceLocation(identifier: "test/testJSONReporterEnd", line: 3, column: 4)),
      severity: .major,
      correction: nil)
    XCTAssertEqual(
      jsonReporter.handle(issues: [testIssue, testIssue, testIssue]),
      """
      "issues": [
      {
        "path": "test/testJSONReporterStart",
        "startLine": 1,
        "startColumn": 2,
        "endLine": 3,
        "endColumn": 4,
        "rule": "rule_id",
        "category": "bad practice",
        "severity": "major",
        "description": "text description for testing"
      },
      {
        "path": "test/testJSONReporterStart",
        "startLine": 1,
        "startColumn": 2,
        "endLine": 3,
        "endColumn": 4,
        "rule": "rule_id",
        "category": "bad practice",
        "severity": "major",
        "description": "text description for testing"
      },
      {
        "path": "test/testJSONReporterStart",
        "startLine": 1,
        "startColumn": 2,
        "endLine": 3,
        "endColumn": 4,
        "rule": "rule_id",
        "category": "bad practice",
        "severity": "major",
        "description": "text description for testing"
      }
      ]
      """)
  }

  func testReportIssueWithCurrentDirectoryPathTrimmed() {
    let pwd = FileManager.default.currentDirectoryPath
    let testIssue = Issue(
      ruleIdentifier: "rule_id",
      description: "text description for testing",
      category: .badPractice,
      location: SourceRange(
        start: SourceLocation(identifier: "\(pwd)/test/testJSONReporterStart", line: 1, column: 2),
        end: SourceLocation(identifier: "\(pwd)/test/testJSONReporterEnd", line: 3, column: 4)),
      severity: .critical,
      correction: nil)
    XCTAssertEqual(
      jsonReporter.handle(issues: [testIssue]),
      """
      "issues": [
      {
        "path": "test/testJSONReporterStart",
        "startLine": 1,
        "startColumn": 2,
        "endLine": 3,
        "endColumn": 4,
        "rule": "rule_id",
        "category": "bad practice",
        "severity": "critical",
        "description": "text description for testing"
      }
      ]
      """)
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
    XCTAssertEqual(
      jsonReporter.handle(issues: [testIssue]),
      """
      "issues": [
      {
        "path": "test",
        "startLine": 1,
        "startColumn": 2,
        "endLine": 3,
        "endColumn": 4,
        "rule": "rule_id",
        "category": "bad practice",
        "severity": "minor",
        "description": ""
      }
      ]
      """)
  }

  func testReportSummary() {
    for (index, severity) in Issue.Severity.allSeverities.enumerated() {
      let testIssue = Issue(
        ruleIdentifier: "rule_id",
        description: "",
        category: .badPractice,
        location: .EMPTY,
        severity: severity,
        correction: nil)
      let issueSummary = IssueSummary(issues: [testIssue])
      var numIssues = [0, 0, 0, 0]
      numIssues[index] = 1
      XCTAssertEqual(jsonReporter.handle(numberOfTotalFiles: 100, issueSummary: issueSummary), """
        "summary": {
          "numberOfFiles": 100,
          "numberOfFilesWithIssues": 1,
          "numberOfIssuesInCritical": \(numIssues[0]),
          "numberOfIssuesInMajor": \(numIssues[1]),
          "numberOfIssuesInMinor": \(numIssues[2]),
          "numberOfIssuesInCosmetic": \(numIssues[3])
        },

        """)
    }
  }

  func testNoIssue() {
    let issueSummary = IssueSummary(issues: [])
    XCTAssertEqual(jsonReporter.handle(numberOfTotalFiles: 100, issueSummary: issueSummary), """
      "summary": {
        "numberOfFiles": 100,
        "numberOfFilesWithIssues": 0,
        "numberOfIssuesInCritical": 0,
        "numberOfIssuesInMajor": 0,
        "numberOfIssuesInMinor": 0,
        "numberOfIssuesInCosmetic": 0
      },

      """)
    XCTAssertEqual(jsonReporter.handle(issues: []), """
      "issues": []
      """)
  }

  func testHeader() {
    XCTAssertTrue(jsonReporter.header.hasPrefix("""
      {
      "version": "\(SWIFT_LINT_VERSION)",
      "url": "http://yanagiba.org/swift-lint",
      "timestamp": "
      """))
    XCTAssertTrue(jsonReporter.header.hasSuffix("\",\n"))
  }

  func testFooter() {
    XCTAssertEqual(jsonReporter.footer, "}")
  }

  func testSeparator() {
    XCTAssertTrue(jsonReporter.separator.isEmpty)
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
