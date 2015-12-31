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

func specNoForceCastRule() {
    let noForceCast = NoForceCastRule()

    describe("lines doesn't contain force casts") {
        $0.it("should have no issues") {
            let issues = "let foo = 1.2 as? Bool\nlet a = 1 as? String; let b = false as? Int".inspect(noForceCast)
            try expect(issues.isEmpty).to.beTrue()
        }
    }

    describe("a line contains one force cast") {
        $0.it("should has one issue") {
            let issues = "let a = 1 as! String".inspect(noForceCast)
            try expect(issues.count) == 1
            let issue = issues[0]
            try expect(issue.ruleIdentifier) == "no_force_cast"
            try expect(issue.description) == "having force cast in line `let a = 1 as! String` is dangerous"
            try expect(issue.type) == .BadPractice
            try expect(issue.severity) == .Normal
            let range = issue.location
            try expect(range.start.path) == "test/test"
            try expect(range.start.line) == 1
            try expect(range.start.column) == 11
            try expect(range.end.path) == "test/test"
            try expect(range.end.line) == 1
            try expect(range.end.column) == 14
        }
    }

    describe("a line contains multiple force casts") {
        $0.it("should have two issues") {
            let issues = "let a = 1 as! String; let b = false as! Int".inspect(noForceCast)
            try expect(issues.count) == 2
            try expect(issues[0].description) == "having force cast in line `let a = 1 as! String; let b = false as! Int` is dangerous"
            try expect(issues[0].location.start.line) == 1
            try expect(issues[0].location.start.column) == 11
            try expect(issues[0].location.end.line) == 1
            try expect(issues[0].location.end.column) == 14
            try expect(issues[1].description) == "having force cast in line `let a = 1 as! String; let b = false as! Int` is dangerous"
            try expect(issues[1].location.start.line) == 1
            try expect(issues[1].location.start.column) == 37
            try expect(issues[1].location.end.line) == 1
            try expect(issues[1].location.end.column) == 40
        }
    }

    describe("multiple lines contain multiple force casts") {
        $0.it("should have three issues") {
            let issues = "let foo = 1.2 as! Bool\nlet a = 1 as! String; let b = false as! Int".inspect(noForceCast)
            try expect(issues.count) == 3
            try expect(issues[0].description) == "having force cast in line `let foo = 1.2 as! Bool` is dangerous"
            try expect(issues[0].location.start.line) == 1
            try expect(issues[0].location.start.column) == 15
            try expect(issues[0].location.end.line) == 1
            try expect(issues[0].location.end.column) == 18
            try expect(issues[1].description) == "having force cast in line `let a = 1 as! String; let b = false as! Int` is dangerous"
            try expect(issues[1].location.start.line) == 2
            try expect(issues[1].location.start.column) == 11
            try expect(issues[1].location.end.line) == 2
            try expect(issues[1].location.end.column) == 14
            try expect(issues[2].description) == "having force cast in line `let a = 1 as! String; let b = false as! Int` is dangerous"
            try expect(issues[2].location.start.line) == 2
            try expect(issues[2].location.start.column) == 37
            try expect(issues[2].location.end.line) == 2
            try expect(issues[2].location.end.column) == 40
        }
    }
}
