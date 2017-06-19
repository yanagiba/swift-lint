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

@testable import Lint
@testable import Source

class HTMLReporterTests : XCTestCase {
  let htmlReporter = HTMLReporter()

  func testReportIssue() {
    let testIssue = Issue(
      ruleIdentifier: "rule_id",
      description: "text description for testing",
      category: .badPractice,
      location: SourceRange(
        start: SourceLocation(path: "test/testHTMLReporterStart", line: 1, column: 2),
        end: SourceLocation(path: "test/testHTMLReporterEnd", line: 3, column: 4)),
      severity: .major,
      correction: nil)
    XCTAssertEqual(
      htmlReporter.handle(issues: [testIssue]),
      """
      <hr />
      <table>
        <thead>
          <tr>
            <th>File</th>
            <th>Location</th>
            <th>Rule Identifier</th>
            <th>Rule Category</th>
            <th>Severity</th>
            <th>Message</th>
          </tr>
        </thead>
        <tbody><tr>
        <td>test/testHTMLReporterStart</td>
        <td>1:2</td>
        <td>rule_id</td>
        <td>bad practice</td>
        <td>major</td>
        <td>text description for testing</td>
      </tr></tbody></table>
      """)
  }

  func testReportIssueWithCurrentDirectoryPathTrimmed() {
    let pwd = FileManager.default.currentDirectoryPath
    let testIssue = Issue(
      ruleIdentifier: "rule_id",
      description: "text description for testing",
      category: .badPractice,
      location: SourceRange(
        start: SourceLocation(path: "\(pwd)/test/testHTMLReporterStart", line: 1, column: 2),
        end: SourceLocation(path: "\(pwd)/test/testHTMLReporterEnd", line: 3, column: 4)),
      severity: .critical,
      correction: nil)
    XCTAssertEqual(
      htmlReporter.handle(issues: [testIssue]),
      """
      <hr />
      <table>
        <thead>
          <tr>
            <th>File</th>
            <th>Location</th>
            <th>Rule Identifier</th>
            <th>Rule Category</th>
            <th>Severity</th>
            <th>Message</th>
          </tr>
        </thead>
        <tbody><tr>
        <td>test/testHTMLReporterStart</td>
        <td>1:2</td>
        <td>rule_id</td>
        <td>bad practice</td>
        <td>critical</td>
        <td>text description for testing</td>
      </tr></tbody></table>
      """)
  }

  func testReportIssueWithEmptyDescription() {
    let testIssue = Issue(
      ruleIdentifier: "rule_id",
      description: "",
      category: .badPractice,
      location: SourceRange(
        start: SourceLocation(path: "test", line: 1, column: 2),
        end: SourceLocation(path: "testEnd", line: 3, column: 4)),
      severity: .minor,
      correction: nil)
    XCTAssertEqual(
      htmlReporter.handle(issues: [testIssue]),
      """
      <hr />
      <table>
        <thead>
          <tr>
            <th>File</th>
            <th>Location</th>
            <th>Rule Identifier</th>
            <th>Rule Category</th>
            <th>Severity</th>
            <th>Message</th>
          </tr>
        </thead>
        <tbody><tr>
        <td>test</td>
        <td>1:2</td>
        <td>rule_id</td>
        <td>bad practice</td>
        <td>minor</td>
        <td></td>
      </tr></tbody></table>
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
      XCTAssertEqual(
        htmlReporter.handle(numberOfTotalFiles: index, issueSummary: issueSummary),
        """
        <table>
          <thead>
            <tr>
              <th>Total Files</th>
              <th>Files with Issues</th><th>Critical</th><th>Major</th><th>Minor</th><th>Cosmetic</th>    </tr>
          </thead>
          <tbody>
            <tr>
              <td>\(index)</td>
              <td>1</td><th class="severity-critical">\(numIssues[0])</th><th class="severity-major">\(numIssues[1])</th><th class="severity-minor">\(numIssues[2])</th><th class="severity-cosmetic">\(numIssues[3])</th>    </tr>
          </tbody>
        </table>
        """)
    }
  }

  func testNoIssue() {
    let issueSummary = IssueSummary(issues: [])
    XCTAssertEqual(
      htmlReporter.handle(numberOfTotalFiles: 100, issueSummary: issueSummary),
      """
      <table>
        <thead>
          <tr>
            <th>Total Files</th>
            <th>Files with Issues</th><th>Critical</th><th>Major</th><th>Minor</th><th>Cosmetic</th>    </tr>
        </thead>
        <tbody>
          <tr>
            <td>100</td>
            <td>0</td><th class="severity-critical">0</th><th class="severity-major">0</th><th class="severity-minor">0</th><th class="severity-cosmetic">0</th>    </tr>
        </tbody>
      </table>
      """)
    XCTAssertTrue(htmlReporter.handle(issues: []).isEmpty)
  }

  func testHeader() {
    XCTAssertEqual(htmlReporter.header,
    """
    <!DOCTYPE html>
    <html>
    <head>
    <title>Yanagiba's swift-lint Report</title>
    <style type='text/css'>
    .severity-critical, .severity-major, .severity-minor, .severity-cosmetic {
      font-weight: bold;
      text-align: center;
      color: #BF0A30;
    }
    .severity-critical { background-color: #FFC200; }
    .severity-major { background-color: #FFD3A6; }
    .severity-minor { background-color: #FFEEB5; }
    .severity-cosmetic { background-color: #FFAAB5; }
    table {
      border: 2px solid gray;
      border-collapse: collapse;
      -moz-box-shadow: 3px 3px 4px #AAA;
      -webkit-box-shadow: 3px 3px 4px #AAA;
      box-shadow: 3px 3px 4px #AAA;
    }
    td, th {
      border: 1px solid #D3D3D3;
      padding: 4px 20px 4px 20px;
    }
    th {
      text-shadow: 2px 2px 2px white;
      border-bottom: 1px solid gray;
      background-color: #E9F4FF;
    }
    </style>
    </head>
    <body>
    <h1>Yanagiba's swift-lint report</h1>
    <hr />
    """)
  }

  func testFooter() {
    XCTAssertTrue(htmlReporter.footer.hasPrefix("""
    <hr />
    <p>
    """))
    XCTAssertTrue(htmlReporter.footer.hasSuffix("""
    Generated with <a href='http://yanagiba.org/swift-lint'>Yanagiba's swift-lint v\(SWIFT_LINT_VERSION)</a>.</p>
    </body>
    </html>
    """))
  }

  func testSeparator() {
    XCTAssertTrue(htmlReporter.separator.isEmpty)
  }

  static var allTests = [
    ("testReportIssue", testReportIssue),
    ("testReportIssueWithCurrentDirectoryPathTrimmed", testReportIssueWithCurrentDirectoryPathTrimmed),
    ("testReportIssueWithEmptyDescription", testReportIssueWithEmptyDescription),
    ("testReportSummary", testReportSummary),
    ("testNoIssue", testNoIssue),
    ("testHeader", testHeader),
    ("testFooter", testFooter),
    ("testSeparator", testSeparator),
  ]
}
