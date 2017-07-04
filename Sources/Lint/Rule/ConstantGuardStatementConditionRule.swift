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

class ConstantGuardStatementConditionRule: RuleBase, ASTVisitorRule {
  let name = "Constant Guard Statement Condition"
  var examples: [String]? {
    return [
      """
      guard true else { // always true
        return true
      }
      """,
      """
      guard 1 == 0 else { // always false
        return false
      }
      """,
      """
      guard 1 != 0, true else { // always true
        return true
      }
      """,
    ]
  }
  let category = Issue.Category.badPractice

  func visit(_ guardStmt: GuardStatement) throws -> Bool {
    if isConditionListConstant(guardStmt.conditionList) {
      emitIssue(
        guardStmt.sourceRange,
        description: "Guard statement with constant condition is confusing")
    }

    return true
  }
}
