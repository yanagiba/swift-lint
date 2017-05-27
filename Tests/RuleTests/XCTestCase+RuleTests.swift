/*
   Copyright 2015-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

@testable import AST
@testable import Parser
@testable import Source
@testable import Lint

extension String {
  func inspect(withRule rule: Rule, configurations: [String: Any]? = nil) -> [Issue] {
    let issueCollector = TestIssueCollector()
    let testDriver = Driver()
    testDriver.setReporter(issueCollector)
    testDriver.registerRule(rule, ruleIdentifiers: [rule.identifier])
    testDriver.updateOutputHandle(.nullDevice)
    testDriver.lint(
      sourceFiles: [SourceFile(path: "test/test", content: self)],
      ruleConfigurations: configurations)
    return issueCollector.issues
  }
}

fileprivate class TestIssueCollector : Reporter {
  fileprivate var issues = [Issue]()

  fileprivate func handle(issue: Issue) -> String {
    issues.append(issue)
    return ""
  }
}
