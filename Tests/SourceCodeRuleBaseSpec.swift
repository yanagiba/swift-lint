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

import Spectre

import Foundation

@testable import lint
@testable import source

func specSourceCodeRuleBase() {
    class SourceCodeRuleForTesting: SourceCodeRule, Rule {
        var name: String {
            return "Testing SourceCode"
        }

        func emitIssue(issue: Issue) {
            issues.append(issue)
        }

        override func inspect(line: String, lineNumber: Int) {
            if let
                configurations = configurations,
                contains = configurations["contains"] as? String
            where NSString(string: line).rangeOfString(contains).location != NSNotFound {
                emitIssue(Issue(
                    ruleIdentifier: identifier,
                    description: "`\(contains)` is quite dangerous for no reason",
                    type: .BadPractice,
                    location: SourceRange(
                        start: SourceLocation(path: sourceFile.path, line: lineNumber, column: 1),
                        end: SourceLocation(path: sourceFile.path, line: lineNumber, column: 1 + line.characters.count)),
                    severity: .Normal,
                    correction: nil))
            }
        }
    }

    describe("a rule checks on _correct_ line of code") {
        $0.it("should leave an empty issue set") {
            setUp()
            let sourceCodeRule = SourceCodeRuleForTesting()
            sourceCodeRule.inspect("this line doesn't contain _the_ word".toASTContext("test/sourceCodeRuleBase"))
            try expect(issues.isEmpty).to.beTrue()
        }
    }

    describe("a rule checks on single line code that contains the word") {
        $0.it("should emit issue with that line") {
            setUp()
            let sourceCodeRule = SourceCodeRuleForTesting()
            sourceCodeRule.inspect("line contains `contains`".toASTContext("test/sourceCodeRuleBase"), configurations: ["contains": "contains"])
            guard let issue = issues.first else {
                throw failure("needs to have one issue")
            }
            try expect(issue.ruleIdentifier) == "testing_sourcecode"
            try expect(issue.description) == "`contains` is quite dangerous for no reason"
            let range = issue.location
            try expect(range.start.path) == "test/sourceCodeRuleBase"
            try expect(range.start.line) == 1
            try expect(range.start.column) == 1
            try expect(range.end.path) == "test/sourceCodeRuleBase"
            try expect(range.end.line) == 1
            try expect(range.end.column) == 25
        }
    }

    describe("a rule checks on multiple module names that is in the configurations") {
        $0.it("should emit three issues with those import declarations") {
            setUp()
            let sourceCodeRule = SourceCodeRuleForTesting()
            sourceCodeRule.inspect("import foo\nimport bar\nimport foo\nimport bar\nimport foo"
                .toASTContext("test/sourceCodeRuleBase"), configurations: ["contains": "foo"])
            try expect(issues.count) == 3
            try expect(issues[0].location.start.line) == 1
            try expect(issues[0].location.end.line) == 1
            try expect(issues[1].location.start.line) == 3
            try expect(issues[1].location.end.line) == 3
            try expect(issues[2].location.start.line) == 5
            try expect(issues[2].location.end.line) == 5
        }
    }

    describe("a rule checks on module name that is not in the configurations") {
        $0.it("should leave an empty issue set") {
            setUp()
            let sourceCodeRule = SourceCodeRuleForTesting()
            sourceCodeRule.inspect("import foo".toASTContext("test/sourceCodeRuleBase"), configurations: ["contains": "bar"])
            try expect(issues.isEmpty).to.beTrue()
        }
    }

}

private var issues = [Issue]()
private func setUp() {
    issues = [Issue]()
}
