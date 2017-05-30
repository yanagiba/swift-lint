/*
   Copyright 2015 Ryuichi Saito, LLC and the Yanagiba project contributors

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

class NoForceCastRule: RuleBase, ASTVisitorRule {
  let name = "No Force Cast"
  let description = ""
  let markdown = ""
  let severity = Issue.Severity.minor
  let category = Issue.Category.badPractice

  func visit(_ typeCasting: TypeCastingOperatorExpression) throws -> Bool {
    if case .forcedCast = typeCasting.kind {
      emitIssue(
        typeCasting.sourceRange,
        description: "having forced type casting is dangerous")
    }

    return true
  }
}
