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

class TooManyParametersRule : RuleBase, ASTVisitorRule {
  static let ThresholdKey = "MAX_PARAMETERS_COUNT"
  static let DefaultThreshold = 10

  let name = "Too Many Parameters"
  var description: String? {
    return """
    Methods with too many parameters are hard to understand and maintain,
    and are thirsty for refactorings, like
    [Replace Parameter With Method](http://www.refactoring.com/catalog/replaceParameterWithMethod.html),
    [Introduce Parameter Object](http://www.refactoring.com/catalog/introduceParameterObject.html),
    or
    [Preserve Whole Object](http://www.refactoring.com/catalog/preserveWholeObject.html).
    """
  }
  var examples: [String]? {
    return [
      """
      func example(
        a: Int,
        b: Int,
        c: Int,
        ...
        z: Int
      ) {}
      """,
    ]
  }
  var thresholds: [String: String]? {
    return [
      TooManyParametersRule.ThresholdKey:
        "The reporting threshold for too many parameters, default value is \(TooManyParametersRule.DefaultThreshold)."
    ]
  }
  var additionalDocument: String? {
    return """

    ##### References:

    Fowler, Martin (1999). *Refactoring: Improving the design of existing code.* Addison Wesley.

    """
  }
  let category = Issue.Category.size

  private func getThreshold(of sourceRange: SourceRange) -> Int {
    return getConfiguration(
      forKey: TooManyParametersRule.ThresholdKey,
      atLineNumber: sourceRange.start.line,
      orDefault: TooManyParametersRule.DefaultThreshold)
  }

  private func emitIssue(_ numParams: Int, _ sourceRange: SourceRange) {
    let threshold = getThreshold(of: sourceRange)
    guard numParams > threshold else {
      return
    }
    emitIssue(
      sourceRange,
      description: "Method with \(numParams) parameters exceeds limit of \(threshold)")
  }

  func visit(_ funcDecl: FunctionDeclaration) throws -> Bool {
    emitIssue(funcDecl.signature.parameterList.count, funcDecl.sourceRange)
    return true
  }

  func visit(_ initDecl: InitializerDeclaration) throws -> Bool {
    emitIssue(initDecl.parameterList.count, initDecl.sourceRange)
    return true
  }

  func visit(_ subscriptDecl: SubscriptDeclaration) throws -> Bool {
    emitIssue(subscriptDecl.parameterList.count, subscriptDecl.sourceRange)
    return true
  }
}
