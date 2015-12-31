/*
   Copyright 2015 Ryuichi Saito, LLC

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

@testable import ast
@testable import parser
@testable import source
@testable import lint

extension String {
    func toASTContext(testPath: String = "test/test") -> ASTContext {
        let sourceFile = SourceFile(path: testPath, content: self)
        let (astContext, _) = Parser().parse(sourceFile)
        return astContext
    }

    func inspect(rule: Rule) -> [Issue] {
        let issueCollector = IssueCollector()
        let testDriver = Driver()
        testDriver.setReporter(issueCollector)
        testDriver.registerRule(rule, ruleIdentifiers: [rule.identifier])
        testDriver.updateOutputHandle(NSFileHandle.fileHandleWithNullDevice())
        testDriver.lint([SourceFile(path: "test/test", content: self)])
        return issueCollector.issues
    }
}


private class IssueCollector: Reporter {
    var issues = [Issue]()

    func handleIssue(issue: Issue) -> String {
        issues.append(issue)
        return ""
    }
}
