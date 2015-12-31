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
@testable import ast

private class TestDriverReporter: lint.Reporter {
    var issues = [Issue]()

    func handleIssue(issue: Issue) -> String {
        issues.append(issue)
        return ""
    }
}

private class TestDriverRule: Rule {
    var name: String {
        return "Test Driver"
    }

    func inspect(ast: ASTContext, configurations: [String: AnyObject]? = nil) {
        let sourceContent = ast.source.content
        let lines = sourceContent.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        for (_, line) in lines.enumerate() {
            emitIssue(Issue(
                ruleIdentifier: identifier,
                description: line,
                type: .BadPractice,
                location: SourceRange(
                    start: SourceLocation(path: "test/testDriver", line: 0, column: 0),
                    end: SourceLocation(path: "test/testDriver", line: 0, column: 0)),
                severity: .Normal,
                correction: nil))
        }
    }
}

func specDriver() {
    describe("a driver that has no rule") {
        $0.it("test reporter should contains no issue") {
            let testDriverReporter = TestDriverReporter()
            let testDriver = Driver()
            testDriver.updateOutputHandle(NSFileHandle.fileHandleWithNullDevice())
            testDriver.setReporter(testDriverReporter)
            testDriver.lint([SourceFile(path: "test/testDriver", content: "import foo\nimport bar")])
            try expect(testDriverReporter.issues.count) == 0
        }
    }

    describe("a driver that has one test rule and one test reporter") {
        $0.it("test reporter should contains two issues, each line each") {
            let testDriverReporter = TestDriverReporter()
            let testDriver = Driver()
            testDriver.updateOutputHandle(NSFileHandle.fileHandleWithNullDevice())
            testDriver.setReporter(testDriverReporter)
            testDriver.registerRule(TestDriverRule(), ruleIdentifiers: ["test_driver"])
            testDriver.lint([SourceFile(path: "test/testDriver", content: "import foo\nimport bar")])
            try expect(testDriverReporter.issues.count) == 2
            try expect(testDriverReporter.issues[0].description) == "import foo"
            try expect(testDriverReporter.issues[1].description) == "import bar"
        }
    }

    describe("a driver that registers a rule that is not implemented") {
        $0.it("doesn't recognize that rule") {
            let testDriverReporter = TestDriverReporter()
            let testDriver = Driver()
            testDriver.updateOutputHandle(NSFileHandle.fileHandleWithNullDevice())
            testDriver.setReporter(testDriverReporter)
            testDriver.registerRule(TestDriverRule(), ruleIdentifiers: ["not_implemented"])
            testDriver.lint([SourceFile(path: "test/testDriver", content: "import foo\nimport bar")])
            try expect(testDriverReporter.issues.count) == 0
        }
    }
}
