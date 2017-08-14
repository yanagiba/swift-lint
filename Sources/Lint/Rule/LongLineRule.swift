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

class LongLineRule : RuleBase, SourceCodeRule {
  static let ThresholdKey = "LONG_LINE"
  static let DefaultThreshold = 100

  let name = "Long Line"
  var description: String? {
    return """
    When a line of code is very long, it largely harms the readability.
    Break long lines of code into multiple lines.
    """
  }
  var examples: [String]? {
    return [
      "let a012345678901234567890123456789...1234567890123456789012345678901234567890123456789",
    ]
  }
  var thresholds: [String: String]? {
    return [
      LongLineRule.ThresholdKey:
        "The long line reporting threshold, default value is \(LongLineRule.DefaultThreshold)."
    ]
  }
  let category = Issue.Category.size

  private func getThreshold(of lineNumber: Int) -> Int {
    return getConfiguration(
      forKey: LongLineRule.ThresholdKey,
      atLineNumber: lineNumber,
      orDefault: LongLineRule.DefaultThreshold)
  }

  func inspect(line: String, lineNumber: Int) {
    let threshold = getThreshold(of: lineNumber)
    let lineCount = line.count
    guard lineCount > threshold else {
      return
    }
    emitIssue(
      lineNumber,
      description: "Line with \(lineCount) characters exceeds limit of \(threshold)")
  }
}
