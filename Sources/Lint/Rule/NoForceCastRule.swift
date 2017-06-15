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
  var description: String? {
    return """
    Force casting `as!` should be avoided, because it could crash the program
    when the type casting fails.

    Although it is arguable that, in rare cases, having crashes may help developers
    identify issues easier, we recommend using a `guard` statement with optional casting
    and then handle the failed castings gently.
    """
  }
  var examples: [String]? {
    return [
      """
      let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! MyCustomCell

      // guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as? MyCustomCell else {
      //   print("Failed in casting to MyCustomCell.")
      //   return UITableViewCell()
      // }

      return cell
      """,
    ]
  }
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
