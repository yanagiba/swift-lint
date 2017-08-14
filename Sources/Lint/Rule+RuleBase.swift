/*
   Copyright 2017 Ryuichi Laboratories and the Yanagiba project contributors

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

import Source

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
