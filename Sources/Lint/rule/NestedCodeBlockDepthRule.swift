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
  let description = ""
  let additionalDocument = ""
  let severity = Issue.Severity.major
  let category = Issue.Category.readability

  private var threshold: Int {
    return getConfiguration(
      for: NestedCodeBlockDepthRule.ThresholdKey,
      orDefault: NestedCodeBlockDepthRule.DefaultThreshold)
  }

  func visit(_ codeBlock: CodeBlock) throws -> Bool {
    let codeBlockDpeth = codeBlock.depth
    if codeBlockDpeth > threshold {
      emitIssue(
        codeBlock.sourceRange,
        description: "Code block depth of \(codeBlockDpeth) exceeds limit of \(threshold)")
    }

    return true
  }
}
