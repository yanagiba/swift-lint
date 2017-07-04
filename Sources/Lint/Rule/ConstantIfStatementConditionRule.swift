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

class ConstantIfStatementConditionRule: RuleBase, ASTVisitorRule {
  let name = "Constant If Statement Condition"
  var examples: [String]? {
    return [
      """
      if true { // always true
        return true
      }
      """,
      """
      if 1 == 0 { // always false
        return false
      }
      """,
      """
      if 1 != 0, true { // always true
        return true
      }
      """,
    ]
  }
  let category = Issue.Category.badPractice

  func visit(_ ifStmt: IfStatement) throws -> Bool {
    if isConditionListConstant(ifStmt.conditionList) {
      emitIssue(
        ifStmt.sourceRange,
        description: "If statement with constant condition is confusing")
    }

    return true
  }
}
