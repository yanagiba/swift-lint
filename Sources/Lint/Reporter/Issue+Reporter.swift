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

// import Foundation

extension Issue {
  var jsonString: String {
    /*
    struct IssueEntry : Encodable { // Note: because `implementation of 'Encodable' cannot
                                    // be automatically synthesized in an extension yet`
      let path: String
      let startLine: Int
      let startColumn: Int
      let endLine: Int
      let endColumn: Int
      let rule: String
      let category: String
      let severity: String
      let description: String

      init(issue: Issue) {
        path = issue.location.normalizedFilePath
        startLine = issue.location.start.line
        startColumn = issue.location.start.column
        endLine = issue.location.end.line
        endColumn = issue.location.end.column
        rule = issue.ruleIdentifier
        category = issue.category.rawValue
        severity = issue.severity.rawValue
        description = issue.description
      }
    }

    let jsonEncoder = JSONEncoder()
    do {
        let jsonData = try jsonEncoder.encode(IssueEntry(issue: self))
        let jsonString = String(data: jsonData, encoding: .utf8)
        return jsonString ?? ""
    }
    catch {
      return ""
    }
    */

    // Note: for our use case, simply string concatenation seems to be better, don't want to overcomplicate things.

    return """
    {
      "path": "\(location.normalizedFilePath)",
      "startLine": \(location.start.line),
      "startColumn": \(location.start.column),
      "endLine": \(location.end.line),
      "endColumn": \(location.end.column),
      "rule": "\(ruleIdentifier)",
      "category": "\(category.rawValue)",
      "severity": "\(severity.rawValue)",
      "description": "\(description)"
    }
    """
  }

  var pmdString: String {
    return """
    <file name="\(location.normalizedFilePath)">
    <violation
      begincolumn="\(location.start.column)"
      endcolumn="\(location.end.column)"
      beginline="\(location.start.line)"
      endline="\(location.end.line)"
      priority="\(severity.priority)"
      rule="\(ruleIdentifier)"
      ruleset="\(category.rawValue)">
    \(description)
    </violation>
    </file>
    """
  }

  var htmlString: String {
    return """
    <tr>
      <td>\(location.normalizedFilePath)</td>
      <td>\(location.startLineColumn)</td>
      <td>\(ruleIdentifier)</td>
      <td>\(category.rawValue)</td>
      <td>\(severity)</td>
      <td>\(description)</td>
    </tr>
    """
  }

  var xcodeString: String {
    var issueDescription = ""
    if !description.isEmpty {
      issueDescription = " \(description)"
    }
    let xcodeWarningText: String
    switch severity {
    case .critical, .major:
      xcodeWarningText = "error"
    case .minor, .cosmetic:
      xcodeWarningText = "warning"
    }

    let locationString = "\(location.start.path):\(location.startLineColumn)"
    return "\(locationString): \(xcodeWarningText): [\(ruleIdentifier)]\(issueDescription)"
  }

  var textString: String {
    var issueDescription = ""
    if !description.isEmpty {
      issueDescription = ": \(description)"
    }
    return "\(location.normalizedLocation): \(severity): \(ruleIdentifier)\(issueDescription)"
  }
}

extension Issue.Severity {
  static var allSeverities: [Issue.Severity] {
    return [
      .critical,
      .major,
      .minor,
      .cosmetic,
    ]
  }

  var priority: Int {
    switch self {
    case .critical:
      return 1
    case .major:
      return 2
    case .minor:
      return 3
    case .cosmetic:
      return 4
    }
  }
}
