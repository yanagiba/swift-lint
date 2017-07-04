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

class InvertedLogicRule: RuleBase, ASTVisitorRule {
  let name = "Inverted Logic"
  var examples: [String]? {
    return [
      """
      if a != 0 {  // if a == 0 {
        i = 1      //   i = -1
      } else {     // } else {
        i = -1     //   i = 1
      }            // }
      """,
      "!foo ? -1 : 1  // foo ? 1 : -1",
    ]
  }
  let category = Issue.Category.badPractice

  func visit(_ ifStmt: IfStatement) throws -> Bool {
    guard let elseClause = ifStmt.elseClause,
      case .else = elseClause,
      ifStmt.conditionList.count == 1,
      case .expression(let expr) = ifStmt.conditionList[0]
    else {
      return true
    }

    if isExpressionLogicNegative(expr) {
      emitIssue(
        ifStmt.sourceRange,
        description: "If statement with inverted condition is confusing")
    }

    return true
  }

  func visit(_ condOpExpr: TernaryConditionalOperatorExpression) throws -> Bool {
    if isExpressionLogicNegative(condOpExpr.conditionExpression) {
      emitIssue(
        condOpExpr.sourceRange,
        description: "Conditional operator with inverted condition is confusing")
    }

    return true
  }
}
