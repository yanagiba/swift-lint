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

class RedundantEnumCaseStringValueRule: RuleBase, ASTVisitorRule {
  let name = "Redundant Enum-Case String Value"
  var description: String? {
    return """
    According to Swift language reference:
    
    > For cases of a raw-value typed enumeration declaration,
    if the raw-value type is specified as `String` and
    no values are assigned to the cases explicitly,
    each unassigned case is implicitly assigned a string with
    the same text as the name of that case.

    So the string literal can be omitted when it is the same as the case name.
    """
  }
  var examples: [String]? {
    return [
      """
      enum Foo: String {
        case a = "a"    // case a
        case b, c = "c" // case b, c
        case d
      }
      """,
    ]
  }
  let severity = Issue.Severity.minor
  let category = Issue.Category.badPractice

  private typealias RawValueEnumCase = EnumDeclaration.RawValueStyleEnumCase
  private typealias RawValueCase = RawValueEnumCase.Case

  func visit(_ enumDecl: EnumDeclaration) throws -> Bool {
    guard let typeInheritance = enumDecl.typeInheritanceClause,
      typeInheritance.typeInheritanceList.filter({ $0.textDescription == "String" }).count == 1
    else {
      return true
    }

    enumDecl.members.flatMap({ member -> RawValueEnumCase? in
      if case .rawValue(let rawValueCase) = member {
        return rawValueCase
      }
      return nil
    }).reduce([]) { carryOver, enumCase -> [RawValueCase] in
      carryOver + enumCase.cases
    }.forEach { e in
      if case .string(let stringValue)? = e.assignment, stringValue == e.name {
        emitIssue(
          enumDecl.sourceRange, // TODO: I am not pointing to the most precise location
          description: "`= \"\(stringValue)\"` is redundant and can be removed")
      }
    }

    return true
  }
}
