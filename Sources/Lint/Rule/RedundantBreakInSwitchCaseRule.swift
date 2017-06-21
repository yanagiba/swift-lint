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

class RedundantBreakInSwitchCaseRule : RuleBase, ASTVisitorRule {
  let name = "Redundant Break In Switch Case"
  var description: String? {
    return """
    According to Swift language reference:

    > After the code within a matched case has finished executing,
    > the program exits from the switch statement.
    > Program execution does not continue or “fall through” to the next case or default case.

    This means in Swift, it's safe to remove the `break` at the end of each switch case.
    """
  }
  var examples: [String]? {
    return [
      """
      switch foo {
      case 0:
        print(0)
        break        // redundant, can be removed
      case 1:
        print(1)
        break        // redundant, can be removed
      default:
        break
      }
      """,
    ]
  }
  let severity = Issue.Severity.minor
  let category = Issue.Category.badPractice

  func visit(_ switchStmt: SwitchStatement) throws -> Bool {
    switchStmt.cases.flatMap({ switchCase -> BreakStatement? in
      guard case .case(_, let stmts) = switchCase,
        let breakStmt = stmts.last as? BreakStatement
      else {
        return nil
      }

      return breakStmt
    }).forEach {
      emitIssue(
        $0.sourceRange,
        description: "Break in swift case is redundant")
    }

    return true
  }
}
