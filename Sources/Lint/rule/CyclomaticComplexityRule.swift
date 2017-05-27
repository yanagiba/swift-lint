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

class CyclomaticComplexityRule : RuleBase, ASTVisitorRule {
  static let ThresholdKey = "CYCLOMATIC_COMPLEXITY"
  /// In McBABE, 1976, A Complexity Measure, he suggested a reasonable number of 10
  static let DefaultThreshold = 10

  let name = "High Cyclomatic Complexity"
  let description = ""
  let markdown = ""

  private var threshold: Int {
    if let config = configurations,
      let customThreshold = config[CyclomaticComplexityRule.ThresholdKey] as? Int
    {
      return customThreshold
    }
    return CyclomaticComplexityRule.DefaultThreshold
  }

  private func emitIssue(_ ccn: Int, _ sourceRange: SourceRange) {
    if ccn > threshold {
      let foundIssue = Issue(
        ruleIdentifier: identifier,
        description: "Cyclomatic Complexity number of \(ccn) exceeds limit of \(threshold)",
        category: .badPractice,
        location: sourceRange,
        severity: .normal,
        correction: nil)
      emitIssue(foundIssue)
    }
  }

  func visit(_ funcDecl: FunctionDeclaration) throws -> Bool {
    emitIssue(funcDecl.cyclomaticComplexity, funcDecl.sourceRange)
    return true
  }

  func visit(_ initDecl: InitializerDeclaration) throws -> Bool {
    emitIssue(initDecl.cyclomaticComplexity, initDecl.sourceRange)
    return true
  }

  func visit(_ deinitDecl: DeinitializerDeclaration) throws -> Bool {
    emitIssue(deinitDecl.cyclomaticComplexity, deinitDecl.sourceRange)
    return true
  }

  func visit(_ subscriptDecl: SubscriptDeclaration) throws -> Bool {
    emitIssue(subscriptDecl.cyclomaticComplexity, subscriptDecl.sourceRange)
    return true
  }
}
