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

class RedundantVariableDeclarationKeywordRule: RuleBase, ASTVisitorRule {
  let name = "Redundant Variable Declaration Keyword"
  var description: String? {
    return """
    When the result of a function call or computed property is discarded by
    a wildcard variable `_`, its `let` or `var` keyword can be safely removed.
    """
  }
  var examples: [String]? {
    return [
      "let _ = foo() // _ = foo()",
      "var _ = bar // _ = bar",
    ]
  }
  let severity = Issue.Severity.minor
  let category = Issue.Category.badPractice

  private func containsOnlyOneWildcard(_ inits: [PatternInitializer]) -> Bool {
    guard inits.count == 1 else {
      return false
    }

    let pattrnInit = inits[0]
    if let wildcardPttrn = pattrnInit.pattern as? WildcardPattern,
      wildcardPttrn.typeAnnotation == nil,
      pattrnInit.initializerExpression != nil
    {
      return true
    }
    return false
  }

  func visit(_ varDecl: VariableDeclaration) throws -> Bool {
    if case .initializerList(let inits) = varDecl.body, containsOnlyOneWildcard(inits) {
      emitIssue(
        varDecl.sourceRange,
        description: "`var` keyword is redundant and can be safely removed"
      )
    }

    return true
  }

  func visit(_ constDecl: ConstantDeclaration) throws -> Bool {
    if containsOnlyOneWildcard(constDecl.initializerList) {
      emitIssue(
        constDecl.sourceRange,
        description: "`let` keyword is redundant and can be safely removed"
      )
    }

    return true
  }
}
