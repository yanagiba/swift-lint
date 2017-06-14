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

class DoubleNegativeRule: RuleBase, ASTVisitorRule {
  let name = "Double Negative"
  var description: String? {
    return "Logically, double negative is positive. So prefer to write positively."
  }
  var examples: [String]? {
    return [
      "!!foo // foo",
      "!(a != b) // a == b",
    ]
  }
  let severity = Issue.Severity.minor
  let category = Issue.Category.badPractice

  private func isExpressionLogicNegative(_ expression: Expression) -> Bool {
    switch expression {
    case let binaryOpExpr as BinaryOperatorExpression:
      return binaryOpExpr.binaryOperator == "!="
    case let prefixOpExpr as PrefixOperatorExpression:
      return prefixOpExpr.prefixOperator == "!"
    case let parenExpr as ParenthesizedExpression:
      return isExpressionLogicNegative(parenExpr.expression)
    default:
      return false
    }
  }

  func visit(_ prefixOpExpr: PrefixOperatorExpression) throws -> Bool {
    let doubleExclams = prefixOpExpr.prefixOperator == "!!"
    let doubleNegatives = isExpressionLogicNegative(prefixOpExpr) &&
      isExpressionLogicNegative(prefixOpExpr.postfixExpression)

    if doubleExclams || doubleNegatives {
      emitIssue(
        prefixOpExpr.sourceRange,
        description: "Double negative logic can be written in a positive fashion")
    }

    return true
  }
}
