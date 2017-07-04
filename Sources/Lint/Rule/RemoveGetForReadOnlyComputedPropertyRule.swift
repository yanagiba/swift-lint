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

class RemoveGetForReadOnlyComputedPropertyRule: RuleBase, ASTVisitorRule {
  let name = "Remove Get For Read-Only Computed Property"
  var description: String? {
    return """
    A computed property with a getter but no setter is known as
    a *read-only computed property*.

    You can simplify the declaration of a read-only computed property
    by removing the get keyword and its braces.
    """
  }
  var examples: [String]? {
    return [
      """
      var foo: Int {
        get {
          return 1
        }
      }

      // var foo: Int {
      //   return 1
      // }
      """,
    ]
  }
  let category = Issue.Category.badPractice

  func visit(_ varDecl: VariableDeclaration) throws -> Bool {
    if case let .getterSetterBlock(name, typeAnnotation, getterSetterBlock) = varDecl.body,
      getterSetterBlock.setter == nil,
      getterSetterBlock.getter.attributes.isEmpty,
      getterSetterBlock.getter.mutationModifier == nil
    {
      let refactoredVarDecl = VariableDeclaration(
        attributes: varDecl.attributes,
        modifiers: varDecl.modifiers,
        variableName: name,
        typeAnnotation: typeAnnotation,
        codeBlock: getterSetterBlock.getter.codeBlock
      )
      emitIssue(
        varDecl.sourceRange,
        description: "read-only computed property `\(name)` " +
          "can be simplified by removing the `get` keyword and its braces",
        correction: Correction(suggestion: refactoredVarDecl.formatted)
      )
    }

    return true
  }
}
