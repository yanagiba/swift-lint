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

class RedundantReturnVoidTypeRule : RuleBase, ASTVisitorRule {
  let name = "Redundant Return Void Type"
  var description: String? {
    return "For functions that do not return, the `-> Void` can be removed."
  }
  var examples: [String]? {
    return [
      "func foo() -> Void // func foo()",
      "func foo() -> () // func foo()",
    ]
  }
  let severity = Issue.Severity.minor
  let category = Issue.Category.badPractice

  func visit(_ funcDecl: FunctionDeclaration) throws -> Bool {
    guard let funcResult = funcDecl.signature.result else {
      return true
    }

    switch funcResult.type {
    case let idType as TypeIdentifier where idType.names.count == 1:
      let idTypeName = idType.names[0]
      if idTypeName.name == "Void" && idTypeName.genericArgumentClause == nil {
        emitIssue(funcDecl.sourceRange, description: "`-> Void` is redundant and can be removed")
      }
    case let tupleType as TupleType where tupleType.elements.isEmpty:
      emitIssue(funcDecl.sourceRange, description: "`-> ()` is redundant and can be removed")
    default:
      return true
    }

    return true
  }
}
