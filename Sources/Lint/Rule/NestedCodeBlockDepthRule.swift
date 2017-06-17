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

import Source
import AST
import Metric

class NestedCodeBlockDepthRule : RuleBase, ASTVisitorRule {
  static let ThresholdKey = "NESTED_CODE_BLOCK_DEPTH"
  static let DefaultThreshold = 5

  let name = "Nested Code Block Depth"
  var description: String? {
    return "This rule indicates blocks nested more deeply than the upper limit."
  }
  var examples: [String]? {
    return [
      """
      if (1)
      {               // 1
          {           // 2
              {       // 3
              }
          }
      }
      """,
    ]
  }
  var thresholds: [String: String]? {
    return [
      NestedCodeBlockDepthRule.ThresholdKey:
        "The depth of a code block reporting threshold, default value is \(NestedCodeBlockDepthRule.DefaultThreshold)."
    ]
  }
  let severity = Issue.Severity.major
  let category = Issue.Category.readability

  private func getThreshold(of sourceRange: SourceRange) -> Int {
    return getConfiguration(
      forKey: NestedCodeBlockDepthRule.ThresholdKey,
      atLineNumber: sourceRange.start.line,
      orDefault: NestedCodeBlockDepthRule.DefaultThreshold)
  }

  func visit(_ codeBlock: CodeBlock) throws -> Bool {
    let codeBlockDpeth = codeBlock.depth
    let codeBlockRange = codeBlock.sourceRange
    let threshold = getThreshold(of: codeBlockRange)
    if codeBlockDpeth > threshold {
      emitIssue(
        codeBlockRange,
        description: "Code block depth of \(codeBlockDpeth) exceeds limit of \(threshold)")
    }

    return true
  }
}
