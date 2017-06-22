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

class DeadCodeRule : RuleBase, ASTVisitorRule {
  let name = "Dead Code"
  var description: String? {
    return """
    Control transfer statements (`break`, `continue`, `fallthrough`, `return`, and `throw`)
    can change the order of program execution.
    In the same scope of code block, the code after control transfer statements
    is unreachable and will never be executed.
    So they are considered as dead, and suggested to be removed.
    """
  }
  var examples: [String]? {
    return [
      """
      for _ in 0..<10 {
        if foo {
          break
          print("foo") // dead code, never print
        }
      }
      """,
      """
      while foo {
        if bar {
          continue
          print("bar") // dead code, never print
        }
      }
      """,
      """
      func foo() {
        if isJobDone {
          return
          startNewJob() // dead code, new job won't start
        }
      }
      """,
      """
      func foo() throws {
        if isJobFailed {
          throw JobError.failed
          restartJob() // dead code, job won't restart
        }
      }
      """,
    ]
  }
  let severity = Issue.Severity.major
  let category = Issue.Category.badPractice

  private func isControlTransferStatement(_ stmt: Statement) -> Bool {
    switch stmt {
    case is BreakStatement,
      is ContinueStatement,
      is FallthroughStatement,
      is ReturnStatement,
      is ThrowStatement:
      return true
    default:
      return false
    }
  }

  private func checkStatements(_ statements: Statements) {
    var foundCtrlStmt = false

    for stmt in statements {
      if foundCtrlStmt {
        emitIssue(stmt.sourceRange, description: "")
        return
      }

      foundCtrlStmt = isControlTransferStatement(stmt)
    }
  }

  func visit(_ codeBlock: CodeBlock) throws -> Bool {
    checkStatements(codeBlock.statements)
    return true
  }

  func visit(_ switchStmt: SwitchStatement) throws -> Bool {
    for eachCase in switchStmt.cases {
      switch eachCase {
      case .case(_, let statements):
        checkStatements(statements)
      case .default(let statements):
        checkStatements(statements)
      }
    }
    return true
  }

  func visit(_ closureExpr: ClosureExpression) throws -> Bool {
    if let statements = closureExpr.statements {
      checkStatements(statements)
    }
    return true
  }
}
