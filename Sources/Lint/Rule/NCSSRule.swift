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

class NCSSRule : RuleBase, ASTVisitorRule {
  static let ThresholdKey = "NCSS"
  static let DefaultThreshold = 30

  let name = "High Non-Commenting Source Statements"
  let identifier = "high_ncss"
  let fileName = "NCSSRule.swift"
  var description: String? {
    return """
    This rule counts number of lines for a method by
    counting Non Commenting Source Statements (NCSS).

    NCSS only takes actual statements into consideration,
    in other words, ignores empty statements, empty blocks,
    closing brackets or semicolons after closing brackets.

    Meanwhile, a statement that is broken into multiple lines contribute only one count.
    """
  }
  var examples: [String]? {
    return [
      """
      func example()          // 1
      {
          if (1)              // 2
          {
          }
          else                // 3
          {
          }
      }
      """,
    ]
  }
  var thresholds: [String: String]? {
    return [
      NCSSRule.ThresholdKey:
        "The high NCSS method reporting threshold, default value is \(NCSSRule.DefaultThreshold)."
    ]
  }
  let severity = Issue.Severity.major
  let category = Issue.Category.readability

  private func getThreshold(of sourceRange: SourceRange) -> Int {
    return getConfiguration(
      forKey: NCSSRule.ThresholdKey,
      atLineNumber: sourceRange.start.line,
      orDefault: NCSSRule.DefaultThreshold)
  }

  private func emitIssue(_ ncss: Int, _ sourceRange: SourceRange) {
    let threshold = getThreshold(of: sourceRange)
    guard ncss > threshold else {
      return
    }
    emitIssue(
      sourceRange,
      description: "Method of \(ncss) NCSS exceeds limit of \(threshold)")
  }

  func visit(_ funcDecl: FunctionDeclaration) throws -> Bool {
    emitIssue(funcDecl.ncssCount, funcDecl.sourceRange)
    return true
  }

  func visit(_ initDecl: InitializerDeclaration) throws -> Bool {
    emitIssue(initDecl.ncssCount, initDecl.sourceRange)
    return true
  }

  func visit(_ deinitDecl: DeinitializerDeclaration) throws -> Bool {
    emitIssue(deinitDecl.ncssCount, deinitDecl.sourceRange)
    return true
  }

  func visit(_ subscriptDecl: SubscriptDeclaration) throws -> Bool {
    emitIssue(subscriptDecl.ncssCount, subscriptDecl.sourceRange)
    return true
  }
}
