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

class NPathComplexityRule : RuleBase, ASTVisitorRule {
  static let ThresholdKey = "NPATH_COMPLEXITY"
  static let DefaultThreshold = 200

  let name = "High NPath Complexity"
  let description = ""
  let markdown = ""

  private var threshold: Int {
    if let config = configurations,
      let customThreshold = config[NPathComplexityRule.ThresholdKey] as? Int
    {
      return customThreshold
    }
    return NPathComplexityRule.DefaultThreshold
  }

  private func emitIssue(_ npath: Int, _ sourceRange: SourceRange) {
    if npath > threshold {
      let foundIssue = Issue(
        ruleIdentifier: identifier,
        description: "NPath Complexity number of \(npath) exceeds limit of \(threshold)",
        category: .badPractice,
        location: sourceRange,
        severity: .normal,
        correction: nil)
      emitIssue(foundIssue)
    }
  }

  func visit(_ funcDecl: FunctionDeclaration) throws -> Bool {
    emitIssue(funcDecl.body?.nPathComplexity ?? 0, funcDecl.sourceRange)
    return true
  }

  func visit(_ initDecl: InitializerDeclaration) throws -> Bool {
    emitIssue(initDecl.body.nPathComplexity, initDecl.sourceRange)
    return true
  }

  func visit(_ deinitDecl: DeinitializerDeclaration) throws -> Bool {
    emitIssue(deinitDecl.body.nPathComplexity, deinitDecl.sourceRange)
    return true
  }

  func visit(_ subscriptDecl: SubscriptDeclaration) throws -> Bool {
    if case .codeBlock(let block) = subscriptDecl.body {
      emitIssue(block.nPathComplexity, subscriptDecl.sourceRange)
    }
    return true
  }
}
