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

import AST

extension RuleBase {
  func checkRedundant( // swift-lint:suppress(high_cyclomatic_complexity)
    trueExpression: Expression, falseExpression: Expression
  ) -> String? {
    switch (trueExpression, falseExpression) {
    case let (thenLiteral as LiteralExpression, elseLiteral as LiteralExpression):
      switch (thenLiteral.kind, elseLiteral.kind) {
      case let (.boolean(thenBool), .boolean(elseBool)):
        if thenBool == elseBool {
          return "removed"
        } else {
          return "simplified"
        }
      case let (.integer(thenInt), .integer(elseInt)) where thenInt == elseInt:
        return "removed"
      case let (.floatingPoint(thenDouble), .floatingPoint(elseDouble)) where thenDouble == elseDouble:
        return "removed"
      case let (.staticString(thenStr), .staticString(elseStr)) where thenStr == elseStr:
        return "removed"
      default:
        return nil
      }
    case let (thenIdExpr as IdentifierExpression, elseIdExpr as IdentifierExpression):
      if case .identifier(let thenId, nil) = thenIdExpr.kind,
        case .identifier(let elseId, nil) = elseIdExpr.kind,
        thenId == elseId
      {
        return "removed"
      }
    default:
      return nil
    }
    return nil
  }

  func isExpressionConstant(_ expression: Expression) -> Bool {
    switch expression {
    case let literalExpr as LiteralExpression:
      switch literalExpr.kind {
      case .nil, .boolean, .integer, .floatingPoint, .staticString:
        return true
      default:
        return false
      }
    case let binaryOpExpr as BinaryOperatorExpression:
      guard binaryOpExpr.binaryOperator == "==" ||
        binaryOpExpr.binaryOperator == "!="
      else {
        return false
      }
      return isExpressionConstant(binaryOpExpr.leftExpression) &&
        isExpressionConstant(binaryOpExpr.rightExpression)
    case let parenExpr as ParenthesizedExpression:
      return isExpressionConstant(parenExpr.expression)
    default:
      return false
    }
  }

  func isConditionListConstant(_ conditionList: ConditionList) -> Bool {
    let patternMatchingConditions = conditionList.filter({
      if case .expression = $0 {
        return false
      }
      return true
    })
    guard patternMatchingConditions.isEmpty else {
      return false
    }

    let conditionExprs = conditionList.flatMap({ condition -> Expression? in
      if case .expression(let expr) = condition {
        return expr
      }
      return nil
    })

    return conditionExprs.filter({ !isExpressionConstant($0) }).isEmpty
  }

  func isExpressionLogicNegative(_ expression: Expression) -> Bool {
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
}
