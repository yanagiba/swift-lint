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

class NoForcedTryRule: RuleBase, ASTVisitorRule {
  let name = "No Forced Try"
  var description: String? {
    return """
    Forced-try expression `try!` should be avoided, because it could crash the program
    at the runtime when the expression throws an error.

    We recommend using a `do-catch` statement with `try` operator and handle the errors
    in `catch` blocks accordingly; or a `try?` operator with `nil`-checking.
    """
  }
  var examples: [String]? {
    return [
      """
      let result = try! getResult()

      // do {
      //   let result = try getResult()
      // } catch {
      //   print("Failed in getting result with error: \\(error).")
      // }
      //
      // or
      //
      // guard let result = try? getResult() else {
      //   print("Failed in getting result.")
      // }
      """,
    ]
  }
  let category = Issue.Category.badPractice

  func visit(_ tryOpExpr: TryOperatorExpression) throws -> Bool {
    if case .forced = tryOpExpr.kind {
      emitIssue(
        tryOpExpr.sourceRange,
        description: "having forced-try expression is dangerous")
    }

    return true
  }
}
