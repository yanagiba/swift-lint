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

import Foundation

import Source

class JSONReporter : Reporter {
  func handle(issues: [Issue]) -> String {
    if issues.isEmpty {
      return """
      "issues": []
      """
    }

    let issuesText = issues.map({ $0.jsonString }).joined(separator: ",\n")
    return """
    "issues": [
    \(issuesText)
    ]
    """
  }

  func handle(numberOfTotalFiles: Int, issueSummary: IssueSummary) -> String {
    let numberOfIssueFiles = issueSummary.numberOfFiles
    var summaryJson = """
    "summary": {
      "numberOfFiles": \(numberOfTotalFiles),
      "numberOfFilesWithIssues": \(numberOfIssueFiles),

    """

    summaryJson += Issue.Severity.allSeverities
      .map({ """
        "numberOfIssuesIn\($0.rawValue.capitalized)": \(issueSummary.numberOfIssues(withSeverity: $0))
      """ }).joined(separator: ",\n")

    summaryJson += """

    },

    """

    return summaryJson
  }

  var header: String {
    return """
    {
    "version": "\(SWIFT_LINT_VERSION)",
    "url": "http://yanagiba.org/swift-lint",
    "timestamp": "\(Date().jsonFomatted)",

    """
  }

  var footer: String {
    return "}"
  }
}
