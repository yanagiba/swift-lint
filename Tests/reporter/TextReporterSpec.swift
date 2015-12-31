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

@testable import lint
@testable import source

func specTextReporter() {
    let textReporter = TextReporter()

    describe("text reporter issue") {
        $0.it("should have location and description") {
            let testIssue = Issue(
                ruleIdentifier: "rule_id",
                description: "text description for testing",
                type: .BadPractice,
                location: SourceRange(
                    start: SourceLocation(path: "test/testTextReporterStart", line: 1, column: 2),
                    end: SourceLocation(path: "test/testTextReporterEnd", line: 3, column: 4)),
                severity: .Normal,
                correction: nil)
            try expect(textReporter.handleIssue(testIssue)) == "test/testTextReporterStart:1:2: warning: text description for testing"
        }
    }

    describe("text reporter header") {
        $0.it("should have header text") {
            try expect(textReporter.header()) == "Swift Lint Report"
        }
    }

    describe("text reporter footer") {
        $0.it("should have footer text") {
            try expect(textReporter.footer().hasPrefix("[Swift Lint (http://swiftlint.org) v")).to.beTrue()
            try expect(textReporter.footer().hasSuffix("]")).to.beTrue()
        }
    }

    describe("text reporter separator") {
        $0.it("should be \\n") {
            try expect(textReporter.separator()) == "\n"
        }
    }
}
