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

class RedundantInitializationToNilRule: RuleBase, ASTVisitorRule {
  let name = "Redundant Initialization to Nil"
  var description: String? {
    return """
    It is redundant to initialize an optional variable to `nil`,
    because if you don’t provide an initial value when you declare an optional variable or property,
    its value automatically defaults to `nil` by the compiler.
    """
  }
  var examples: [String]? {
    return [
      "var foo: Int? = nil // var foo: Int?",
    ]
  }
  let severity = Issue.Severity.minor
  let category = Issue.Category.badPractice

  func visit(_ varDecl: VariableDeclaration) throws -> Bool {
    if case .initializerList(let inits) = varDecl.body {
      let foundVariableNames = inits.flatMap { $0.identifier }
      if foundVariableNames.count > 0 {
        let variableText = getVariableForm(foundVariableNames)
        let nameString = getNameText(foundVariableNames)

        emitIssue(
          varDecl.sourceRange,
          description: "`nil` initialization can be safely removed for \(variableText) \(nameString)"
        )
      }
    }

    return true
  }

  private func getVariableForm(_ names: [String]) -> String {
    let pluralS = names.count > 1 ? "s" : ""
    return "variable\(pluralS)"
  }

  private func getNameText(_ names: [String]) -> String {
    let nameCount = names.count
    var nameString = ""
    for (index, name) in names.enumerated() {
      if nameCount > 1 && index == nameCount-1 {
        nameString += " and "
      } else if index > 0 {
        nameString += ", "
      }

      nameString += "`\(name)`"
    }
    return nameString
  }
}

fileprivate extension PatternInitializer {
  var identifier: Identifier? {
    if let initExpr = initializerExpression as? LiteralExpression,
      case .nil = initExpr.kind,
      let idPattern = pattern as? IdentifierPattern,
      let idTypeAnnotation = idPattern.typeAnnotation,
      idTypeAnnotation.type is OptionalType
    {
      return idPattern.identifier
    }

    return nil
  }
}
