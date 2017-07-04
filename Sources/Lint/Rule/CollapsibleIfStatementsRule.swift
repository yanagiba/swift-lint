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

class CollapsibleIfStatementsRule: RuleBase, ASTVisitorRule {
  let name = "Collapsible If Statements"
  var description: String? {
    return """
    This rule detects instances where the conditions of
    two consecutive if statements can be combined into one
    in order to increase code cleanness and readability.
    """
  }
  var examples: [String]? {
    return [
      """
      if (x) {
        if (y) {
          foo()
        }
      }
      // depends on the situation, could be collapsed into
      // if x && y { foo() }
      // or
      // if x, y { foo() }
      """,
    ]
  }
  let category = Issue.Category.badPractice

  func visit(_ ifStmt: IfStatement) throws -> Bool {
    // check (outer) if statement has no else-clause,
    // and it's only then-clause statement is also an (inner) if statement,
    // in addition, the inner if statement cannot have else-clause either.
    guard ifStmt.elseClause == nil,
      ifStmt.codeBlock.statements.count == 1,
      let innerIfStmt = ifStmt.codeBlock.statements[0] as? IfStatement,
      innerIfStmt.elseClause == nil
    else {
      return true
    }

    emitIssue(
      ifStmt.sourceRange,
      description: "This if statement can be collapsed with its inner if statement")

    return true
  }
}
