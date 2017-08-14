/*
   Copyright 2015-2017 Ryuichi Laboratories and the Yanagiba project contributors

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
  func handle(issues: [Issue]) -> String {
    return issues.map({ $0.textString }).joined(separator: separator)
  }

  func handle(numberOfTotalFiles: Int, issueSummary: IssueSummary) -> String {
    if issueSummary.numberOfIssues == 0 {
      return "Good job! Inspected \(numberOfTotalFiles) files, found no issue."
    }

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
    return lines.joined(separator: separator)
  }

  var header: String {
    return """
    Yanagiba's \(SWIFT_LINT) (http://yanagiba.org/swift-lint) v\(SWIFT_LINT_VERSION) Report
    \(Date().formatted)
    """
  }

  var separator: String {
    return "\n"
  }
}
