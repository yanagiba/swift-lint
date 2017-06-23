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

import Foundation

extension Issue {
  var jsonString: String {
    // TODO: as of today, swift-4-snapshot-2017-06-22-a,
    // awesome `Encodable` and `JSONEncoder` are not available on Linux yet
    // we will switch to that later when it is available
    // right now, just brutal string concatenation

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
