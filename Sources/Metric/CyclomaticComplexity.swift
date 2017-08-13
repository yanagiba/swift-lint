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
 * - McCabe (December 1976). “A Complexity Measure”.
 *   IEEE Transactions on Software Engineering: 308–320
 */
public class CyclomaticComplexity : ASTVisitor {
  private var _count = 0

  public func calculate(for decl: Declaration) -> Int {
    _count = 0

    do {
      _ = try traverse(decl)
    } catch {
      return 0
    }

    return _count + 1
  }

  public func visit(_ doStmt: DoStatement) throws -> Bool {
    _count += doStmt.catchClauses.count
    return true
  }

  public func visit(_: ForInStatement) throws -> Bool {
    _count += 1
    return true
  }

  public func visit(_ guardStmt: GuardStatement) throws -> Bool {
    _count += 1
    calculate(guardStmt.conditionList)
    return true
  }

  public func visit(_ ifStmt: IfStatement) throws -> Bool {
    _count += 1
    calculate(ifStmt.conditionList)
    return true
  }

  public func visit(_: RepeatWhileStatement) throws -> Bool {
    _count += 1
    return true
  }

  public func visit(_ switchStmt: SwitchStatement) throws -> Bool {
    _count += switchStmt.cases.filter({
      switch $0 {
      case .case:
        return true
      case .default:
        return false
      }
    }).count
    return true
  }

  public func visit(_ whileStmt: WhileStatement) throws -> Bool {
    _count += 1
    calculate(whileStmt.conditionList)
    return true
  }

  public func visit(_: TernaryConditionalOperatorExpression) throws -> Bool {
    _count += 1
    return true
  }

  public func visit(_ biOpExpr: BinaryOperatorExpression) throws -> Bool {
    let biOp = biOpExpr.binaryOperator
    if biOp == "&&" || biOp == "||" {
      _count += 1
    }
    return true
  }

  public func visit(_ seqExpr: SequenceExpression) throws -> Bool {
    for element in seqExpr.elements {
      if case .binaryOperator(let biOp) = element, biOp == "&&" || biOp == "||" {
        _count += 1
      }
    }
    return true
  }

  private func calculate(_ conditionList: ConditionList) {
    if conditionList.count > 1 {
      _count += conditionList.count - 1
    }
  }
}
