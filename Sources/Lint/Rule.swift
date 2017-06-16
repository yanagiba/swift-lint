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
import Source

public protocol Rule {
  var identifier: String { get }
  var name: String { get }
  var fileName: String { get }
  var description: String? { get }
  var examples: [String]? { get }
  var thresholds: [String: String]? { get }
  var additionalDocument: String? { get }

  var severity: Issue.Severity { get }
  var category: Issue.Category { get }

  func emitIssue(_: Issue)
  func inspect(_: ASTContext, configurations: [String: Any]?)
}

extension Rule {
  var identifier: String {
    return name.toIdentifier
  }

  var fileName: String {
    return name.toFileName
  }

  var description: String? {
    return nil
  }

  var examples: [String]? {
    return nil
  }

  var thresholds: [String: String]? {
    return nil
  }

  var additionalDocument: String? {
    return nil
  }

  var severity: Issue.Severity {
    return .minor
  }

  var category: Issue.Category {
    return .uncategorized
  }

  func emitIssue(_ issue: Issue) {
    IssuePool.shared.add(issue: issue)
  }
}

extension Rule where Self: RuleBase {
  func emitIssue(
    _ sourceRange: SourceRange,
    description: String,
    correction: Correction? = nil
  ) {
    if let suppressedRules = commentBasedSuppressions[sourceRange.start.line] {
      if suppressedRules.isEmpty {
        return
      } else if suppressedRules.contains(identifier) {
        return
      }
    }

    let foundIssue = Issue(
      ruleIdentifier: identifier,
      description: description,
      category: category,
      location: sourceRange,
      severity: severity,
      correction: correction)
    emitIssue(foundIssue)
  }
}

fileprivate extension String {
  fileprivate var toFileName: String {
    let fileName = punctutationAndWhitespaceRemoved.joined()
    return "\(fileName)Rule.swift"
  }

  fileprivate var toIdentifier: String {
    return punctutationAndWhitespaceRemoved.joined(separator: "_").lowercased()
  }

  private var punctutationAndWhitespaceRemoved: [String] {
    return self.components(separatedBy: .punctuationCharacters)
      .joined(separator: "")
      .components(separatedBy: .whitespaces)
      .filter { !$0.isEmpty }
  }
}
