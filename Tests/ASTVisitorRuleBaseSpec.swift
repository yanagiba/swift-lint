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

@testable import ast
@testable import lint

func specASTVisitorRuleBase() {
    class ASTVisitorRuleForTesting: ASTVisitorRule, Rule {
        var name: String {
            return "Testing ASTVisitor"
        }

        func emitIssue(issue: Issue) {
            issues.append(issue)
        }

        override func inspect(statement: Statement) {
            if let
                importDeclaration = statement as? ImportDeclaration,
                configurations = configurations,
                moduleName = configurations["moduleName"] as? String
            where importDeclaration.module == moduleName {
                emitIssue(Issue(
                    ruleIdentifier: identifier,
                    description: "\(importDeclaration.module) is not allowed in import declaration for no reason",
                    type: .Size,
                    location: importDeclaration.sourceRange,
                    severity: .Info,
                    correction: nil))
            }
        }
    }

    describe("a rule checks on _correct_ module name") {
        $0.it("should leave an empty issue set") {
            setUp()
            let astVisitorRule = ASTVisitorRuleForTesting()
            astVisitorRule.inspect("import foo".toASTContext("test/astVisitorRuleBase"))
            try expect(issues.isEmpty).to.beTrue()
        }
    }

    describe("a rule checks on module name that is in the configurations") {
        $0.it("should emit issue with that import declaration") {
            setUp()
            let astVisitorRule = ASTVisitorRuleForTesting()
            astVisitorRule.inspect("import foo".toASTContext("test/astVisitorRuleBase"), configurations: ["moduleName": "foo"])
            guard let issue = issues.first else {
                throw failure("needs to have one issue")
            }
            try expect(issue.ruleIdentifier) == "testing_astvisitor"
            try expect(issue.description) == "foo is not allowed in import declaration for no reason"
            let range = issue.location
            try expect(range.start.path) == "test/astVisitorRuleBase"
            try expect(range.start.line) == 1
            try expect(range.start.column) == 1
            try expect(range.end.path) == "test/astVisitorRuleBase"
            try expect(range.end.line) == 1
            try expect(range.end.column) == 11
        }
    }

    describe("a rule checks on multiple module names that is in the configurations") {
        $0.it("should emit three issues with those import declarations") {
            setUp()
            let astVisitorRule = ASTVisitorRuleForTesting()
            astVisitorRule.inspect("import foo\nimport bar\nimport foo\nimport bar\nimport foo"
                .toASTContext("test/astVisitorRuleBase"), configurations: ["moduleName": "foo"])
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
            let astVisitorRule = ASTVisitorRuleForTesting()
            astVisitorRule.inspect("import foo".toASTContext("test/astVisitorRuleBase"), configurations: ["moduleName": "bar"])
            try expect(issues.isEmpty).to.beTrue()
        }
    }

}

private var issues = [Issue]()
private func setUp() {
    issues = [Issue]()
}
