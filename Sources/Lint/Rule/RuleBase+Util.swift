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

extension RuleBase {
  func checkRedundant(
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
}
