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

import AST

class RedundantConditionalOperatorRule: RuleBase, ASTVisitorRule {
  let name = "Redundant Conditional Operator"
  var description: String? {
    return """
    This rule detects three types of redundant conditional operators:

    - true-expression and false-expression are returning true/false or false/true respectively;
    - true-expression and false-expression are the same constant;
    - true-expression and false-expression are the same variable expression.

    They are usually introduced by mistake, and should be simplified or removed.
    """
  }
  var examples: [String]? {
    return [
      "return a > b ? true : false // return a > b",
      "return a == b ? false : true // return a != b",
      "return a > b ? true : true // return true",
      "return a < b ? \"foo\" : \"foo\" // return \"foo\"",
      "return a != b ? c : c // return c",
    ]
  }
  let category = Issue.Category.badPractice

  private func emitIssue(
    _ condOpExpr: TernaryConditionalOperatorExpression,
    _ suggestion: String
  ) {
    emitIssue(
      condOpExpr.sourceRange,
      description: "Conditional operator is redundant and can be \(suggestion)")
  }

  func visit(_ condOpExpr: TernaryConditionalOperatorExpression) throws -> Bool {
    if let suggestion = checkRedundant(
      trueExpression: condOpExpr.trueExpression,
      falseExpression: condOpExpr.falseExpression)
    {
      emitIssue(condOpExpr, suggestion)
    }

    return true
  }
}
