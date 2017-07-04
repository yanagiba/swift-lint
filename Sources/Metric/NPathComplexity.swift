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

/*
 * References:
 * - Brian A. Nejmeh (1988). “NPATH: a measure of execution path complexity and
 *   its applications”. Communications of the ACM 31 (2) p. 188-200
 */
public class NPathComplexity {
  public func calculate(for codeBlock: CodeBlock) -> Int {
    return nPath(codeBlock)
  }

  private func nPath(_ codeBlock: CodeBlock) -> Int {
    return nPath(codeBlock.statements)
  }

  private func nPath(_ stmts: [Statement]) -> Int {
    return stmts.reduce(1) { $0 * nPath($1) }
  }

  private func nPath(_ stmt: Statement) -> Int { // swift-lint:suppress(high_cyclomatic_complexity)
    switch stmt {
    case let deferStmt as DeferStatement:
      return nPath(deferStmt.codeBlock)
    case let doStmt as DoStatement:
      return nPath(doStmt)
    case let forStmt as ForInStatement:
      return nPath(forStmt)
    case let guardStmt as GuardStatement:
      return nPath(guardStmt)
    case let ifStmt as IfStatement:
      return nPath(ifStmt)
    case let labeledStmt as LabeledStatement:
      return nPath(labeledStmt.statement)
    case let repeatWhileStmt as RepeatWhileStatement:
      return nPath(repeatWhileStmt)
    case let returnStmt as ReturnStatement:
      return 1 + (returnStmt.expression.map({ nPath(forExpression: $0) }) ?? 0)
    case let switchStmt as SwitchStatement:
      return nPath(switchStmt)
    case let throwStmt as ThrowStatement:
      return 1 + nPath(forExpression: throwStmt.expression)
    case let whileStmt as WhileStatement:
      return nPath(whileStmt)
    case let expr as Expression:
      return 1 + nPath(forExpression: expr)
    default:
      return 1
    }
  }

  private func nPath(_ doStmt: DoStatement) -> Int {
    return nPath(doStmt.codeBlock) + doStmt.catchClauses.reduce(0) {
      var npCatch = $0 + nPath($1.codeBlock)
      if let expr = $1.whereExpression {
        npCatch += nPath(forExpression: expr) + 1
      }
      return npCatch
    }
  }

  private func nPath(_ forStmt: ForInStatement) -> Int {
    return 1 +
      nPath(forStmt.codeBlock) +
      nPath(forExpression: forStmt.collection) +
      (forStmt.item.whereClause.map({ nPath(forExpression: $0) + 1 }) ?? 0)
  }

  private func nPath(_ guardStmt: GuardStatement) -> Int {
    return 1 + nPath(guardStmt.codeBlock) + nPath(guardStmt.conditionList)
  }

  private func nPath(_ ifStmt: IfStatement) -> Int {
    return nPath(ifStmt.codeBlock) +
      nPath(ifStmt.conditionList) +
      (
        ifStmt.elseClause.map({
          switch $0 {
          case .else(let block):
            return nPath(block)
          case .elseif(let ifStmt):
            return nPath(ifStmt)
          }
        }) ?? 1
      )
  }

  private func nPath(_ repeatWhileStmt: RepeatWhileStatement) -> Int {
    return 1 +
      nPath(repeatWhileStmt.codeBlock) +
      nPath(forExpression: repeatWhileStmt.conditionExpression)
  }

  private func nPath(_ switchStmt: SwitchStatement) -> Int {
    let npExpr = nPath(forExpression: switchStmt.expression)

    if switchStmt.cases.isEmpty {
      return 1 + npExpr
    }

    return npExpr + switchStmt.cases.reduce(0) {
      switch $1 {
      case let .case(items, stmts):
        let npItems = items.reduce(0) { carryOver, item in
          let npWhere = item.whereExpression.map({ nPath(forExpression: $0) + 1 }) ?? 0
          return carryOver + npWhere
        }
        return npItems + nPath(stmts) + $0
      case .default(let stmts):
        return nPath(stmts) + $0
      }
    }
  }

  private func nPath(_ whileStmt: WhileStatement) -> Int {
    return 1 + nPath(whileStmt.codeBlock) + nPath(whileStmt.conditionList)
  }

  private func nPath(forExpression expr: Expression) -> Int {
    class NPathExpressionVisitor : ASTVisitor {
      var _count = 0

      func cal(_ expr: Expression) -> Int {
        _count = 0
        do {
          _ = try traverse(expr)
          return _count
        } catch {
          return 0
        }
      }

      func visit(_ biOpExpr: BinaryOperatorExpression) throws -> Bool {
        let biOp = biOpExpr.binaryOperator
        if biOp == "&&" || biOp == "||" {
          _count += 1
        }
        return true
      }

      func visit(_ ternaryExpr: TernaryConditionalOperatorExpression) throws -> Bool {
        _count += 1
        return true
      }
    }

    return NPathExpressionVisitor().cal(expr)
  }

  private func nPath(_ conditionList: ConditionList) -> Int {
    return conditionList.reduce(0) {
      switch $1 {
      case .expression(let expr):
        return $0 + 1 + nPath(forExpression: expr)
      case .case(_, let expr):
        return $0 + 1 + nPath(forExpression: expr)
      case .let(_, let expr):
        return $0 + 1 + nPath(forExpression: expr)
      case .var(_, let expr):
        return $0 + 1 + nPath(forExpression: expr)
      default:
        return $0 + 1
      }
    } - 1
  }
}
