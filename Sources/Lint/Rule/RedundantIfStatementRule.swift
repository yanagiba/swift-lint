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

  func visit(_ ifStmt: IfStatement) throws -> Bool {
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

    // check if they are all boolean values
    guard let thenLiteral = thenExpr as? LiteralExpression,
      let elseLiteral = elseExpr as? LiteralExpression,
      case .boolean(let thenBool) = thenLiteral.kind,
      case .boolean(let elseBool) = elseLiteral.kind
    else {
      return true
    }

    // now if they are the same, we ignore this case, otherwise, we emit issue
    guard thenBool != elseBool else {
      return true
    }

    emitIssue(
      ifStmt.sourceRange,
      description: "if statement is redundant and can be simplified"
    )

    return true
  }
}
