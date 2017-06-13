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

class RedundantIfStatementRule: RuleBase, ASTVisitorRule {
  let name = "Redundant If Statement"
  var examples: [String]? {
    return [
      """
      if a == b {
        return true
      } else {
        return false
      }
      // return a == b
      """,
      """
      if a == b {
        return false
      } else {
        return true
      }
      // return a != b
      """,
    ]
  }
  let severity = Issue.Severity.minor
  let category = Issue.Category.badPractice

  private func emitIssue(_ ifStmt: IfStatement, _ suggestion: String) {
    emitIssue(
      ifStmt.sourceRange,
      description: "if statement is redundant and can be \(suggestion)")
  }

  func visit(_ ifStmt: IfStatement) throws -> Bool {
    let patternMatchingConditions = ifStmt.conditionList.filter({
      if case .expression = $0 {
        return false
      }
      return true
    })
    guard patternMatchingConditions.isEmpty else {
      return true
    }

    // check if both then-block and else-block exist and have one and only one statement
    guard ifStmt.codeBlock.statements.count == 1,
      let elseClause = ifStmt.elseClause,
      case .else(let elseBlock) = elseClause,
      elseBlock.statements.count == 1
    else {
      return true
    }

    let thenStmt = ifStmt.codeBlock.statements[0]
    let elseStmt = elseBlock.statements[0]

    // check then and else block each has one return statement that has expression
    guard let thenReturn = thenStmt as? ReturnStatement,
      let elseReturn = elseStmt as? ReturnStatement,
      let thenExpr = thenReturn.expression,
      let elseExpr = elseReturn.expression
    else {
      return true
    }

    switch (thenExpr, elseExpr) {
    case let (thenLiteral as LiteralExpression, elseLiteral as LiteralExpression):
      switch (thenLiteral.kind, elseLiteral.kind) {
      case let (.boolean(thenBool), .boolean(elseBool)):
        if thenBool == elseBool {
          emitIssue(ifStmt, "removed")
        } else {
          emitIssue(ifStmt, "simplified")
        }
      case let (.integer(thenInt), .integer(elseInt)) where thenInt == elseInt:
        emitIssue(ifStmt, "removed")
      case let (.floatingPoint(thenDouble), .floatingPoint(elseDouble)) where thenDouble == elseDouble:
        emitIssue(ifStmt, "removed")
      case let (.staticString(thenStr), .staticString(elseStr)) where thenStr == elseStr:
        emitIssue(ifStmt, "removed")
      default:
        return true
      }
    case let (thenIdExpr as IdentifierExpression, elseIdExpr as IdentifierExpression):
      if case .identifier(let thenId, nil) = thenIdExpr.kind,
        case .identifier(let elseId, nil) = elseIdExpr.kind,
        thenId == elseId
      {
        emitIssue(ifStmt, "removed")
      }
    default:
      return true
    }

    return true
  }
}
