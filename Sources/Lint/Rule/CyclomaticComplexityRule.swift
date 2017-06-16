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
import Metric

class CyclomaticComplexityRule : RuleBase, ASTVisitorRule {
  static let ThresholdKey = "CYCLOMATIC_COMPLEXITY"
  /// In McBABE, 1976, A Complexity Measure, he suggested a reasonable number of 10
  static let DefaultThreshold = 10

  let name = "High Cyclomatic Complexity"
  let fileName = "CyclomaticComplexityRule.swift"
  var description: String? {
    return """
    Cyclomatic complexity is determined by the number of
    linearly independent paths through a program's source code.
    In other words, cyclomatic complexity of a method is measured by
    the number of decision points, like `if`, `while`, and `for` statements,
    plus one for the method entry.

    The experiments McCabe, the author of cyclomatic complexity,
    conclude that methods in the 3 to 7 complexity range are
    quite well structured. He also suggest
    the cyclomatic complexity of 10 is a reasonable upper limit.
    """
  }
  var examples: [String]? {
    return [
      """
      func example(a: Int, b: Int, c: Int) // 1
      {
          if (a == b)                      // 2
          {
              if (b == c)                  // 3
              {
              }
              else if (a == c)             // 3
              {
              }
              else
              {
              }
          }
          for i in 0..<c                   // 4
          {
          }
          switch(c)
          {
              case 1:                      // 5
                  break
              case 2:                      // 6
                  break
              default:                     // 7
                  break
          }
      }
      """,
    ]
  }
  var thresholds: [String: String]? {
    return [
      CyclomaticComplexityRule.ThresholdKey:
        "The cyclomatic complexity reporting threshold, default value is \(CyclomaticComplexityRule.DefaultThreshold)."
    ]
  }
  var additionalDocument: String? {
    return """

    ##### References:

    McCabe (December 1976). ["A Complexity Measure"](http://www.literateprogramming.com/mccabe.pdf).
    *IEEE Transactions on Software Engineering: 308–320*

    """
  }
  let severity = Issue.Severity.major
  let category = Issue.Category.complexity

  private func getThreshold(of sourceRange: SourceRange) -> Int {
    return getConfiguration(
      forKey: CyclomaticComplexityRule.ThresholdKey,
      atLineNumber: sourceRange.start.line,
      orDefault: CyclomaticComplexityRule.DefaultThreshold)
  }

  private func emitIssue(_ ccn: Int, _ sourceRange: SourceRange) {
    let threshold = getThreshold(of: sourceRange)
    guard ccn > threshold else {
      return
    }
    emitIssue(
      sourceRange,
      description: "Cyclomatic Complexity number of \(ccn) exceeds limit of \(threshold)")
  }

  func visit(_ funcDecl: FunctionDeclaration) throws -> Bool {
    emitIssue(funcDecl.cyclomaticComplexity, funcDecl.sourceRange)
    return true
  }

  func visit(_ initDecl: InitializerDeclaration) throws -> Bool {
    emitIssue(initDecl.cyclomaticComplexity, initDecl.sourceRange)
    return true
  }

  func visit(_ deinitDecl: DeinitializerDeclaration) throws -> Bool {
    emitIssue(deinitDecl.cyclomaticComplexity, deinitDecl.sourceRange)
    return true
  }

  func visit(_ subscriptDecl: SubscriptDeclaration) throws -> Bool {
    emitIssue(subscriptDecl.cyclomaticComplexity, subscriptDecl.sourceRange)
    return true
  }
}
