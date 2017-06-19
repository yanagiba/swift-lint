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

import Foundation

import Source

class TextReporter : Reporter {
  func handle(issue: Issue) -> String {
    var filePath = "\(issue.location)"
    let pwd = FileManager.default.currentDirectoryPath
    if filePath.hasPrefix(pwd) {
      let prefixIndex = filePath.index(filePath.startIndex, offsetBy: pwd.count+1)
      filePath = String(filePath[prefixIndex...])
    }
    var issueDescription = ""
    if !issue.description.isEmpty {
      issueDescription = ": \(issue.description)"
    }
    return "\(filePath): \(issue.severity): \(issue.ruleIdentifier)\(issueDescription)"
  }

  func handle(numberOfTotalFiles: Int, issueSummary: IssueSummary) -> String {
    let numberOfIssueFiles = issueSummary.numberOfFiles
    let filesText = numberOfIssueFiles == 1 ? "file" : "files"
    var lines = [
      "Summary:",
      "Within a total number of \(numberOfTotalFiles) files, \(numberOfIssueFiles) \(filesText) have issues.",
    ]
    for severity in Issue.Severity.allSeverities {
      let count = issueSummary.numberOfIssues(withSeverity: severity)
      let line = "Number of \(severity) issues: \(count)"
      lines.append(line)
    }
    return lines.joined(separator: separator())
  }

  func header() -> String {
    return "Yanagiba's \(SWIFT_LINT) (http://yanagiba.org/swift-lint) v\(SWIFT_LINT_VERSION) Report"
  }

  func separator() -> String {
    return "\n"
  }
}
