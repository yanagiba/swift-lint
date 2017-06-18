/*
   Copyright 2016-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

class TextReporterTests : XCTestCase {
  let textReporter = TextReporter()

  func testReportIssue() {
    let testIssue = Issue(
      ruleIdentifier: "rule_id",
      description: "text description for testing",
      category: .badPractice,
      location: SourceRange(
        start: SourceLocation(path: "test/testTextReporterStart", line: 1, column: 2),
        end: SourceLocation(path: "test/testTextReporterEnd", line: 3, column: 4)),
      severity: .major,
      correction: nil)
    XCTAssertEqual(
      textReporter.handle(issue: testIssue),
      "test/testTextReporterStart:1:2-3:4: major: rule_id: text description for testing")
  }

  func testReportIssueWithCurrentDirectoryPathTrimmed() {
    let pwd = FileManager.default.currentDirectoryPath
    let testIssue = Issue(
      ruleIdentifier: "rule_id",
      description: "text description for testing",
      category: .badPractice,
      location: SourceRange(
        start: SourceLocation(path: "\(pwd)/test/testTextReporterStart", line: 1, column: 2),
        end: SourceLocation(path: "\(pwd)/test/testTextReporterEnd", line: 3, column: 4)),
      severity: .critical,
      correction: nil)
    XCTAssertEqual(
      textReporter.handle(issue: testIssue),
      "test/testTextReporterStart:1:2-3:4: critical: rule_id: text description for testing")
  }

  func testReportIssueWithEmptyDescription() {
    let pwd = FileManager.default.currentDirectoryPath
    let testIssue = Issue(
      ruleIdentifier: "rule_id",
      description: "",
      category: .badPractice,
      location: SourceRange(
        start: SourceLocation(path: "test", line: 1, column: 2),
        end: SourceLocation(path: "testEnd", line: 3, column: 4)),
      severity: .minor,
      correction: nil)
    XCTAssertEqual(textReporter.handle(issue: testIssue), "test:1:2-3:4: minor: rule_id")
  }

  func testHeader() {
    XCTAssertTrue(textReporter.header().hasPrefix("Yanagiba's swift-lint (http://yanagiba.org/swift-lint) v"))
    XCTAssertTrue(textReporter.header().hasSuffix(" Report"))
  }

  func testFooter() {
    XCTAssertTrue(textReporter.footer().isEmpty)
  }

  func testSeparator() {
    XCTAssertEqual(textReporter.separator(), "\n")
  }

  static var allTests = [
    ("testReportIssue", testReportIssue),
    ("testReportIssueWithCurrentDirectoryPathTrimmed", testReportIssueWithCurrentDirectoryPathTrimmed),
    ("testReportIssueWithEmptyDescription", testReportIssueWithEmptyDescription),
    ("testHeader", testHeader),
    ("testFooter", testFooter),
    ("testSeparator", testSeparator),
  ]
}
