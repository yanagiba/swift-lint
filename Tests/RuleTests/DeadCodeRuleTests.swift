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

import XCTest

@testable import Lint

class DeadCodeRuleTests : XCTestCase {
  func testNoControlTransferStatement() {
    let issues = """
      func foo() {
        print("foo")
      }
      """.inspect(withRule: DeadCodeRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testBreak() {
    let issues = """
      func foo() {
        break
        print("foo")
      }
      """.inspect(withRule: DeadCodeRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "dead_code")
    XCTAssertEqual(issue.description, "")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .major)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 3)
    XCTAssertEqual(range.start.column, 3)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 3)
    XCTAssertEqual(range.end.column, 15)
  }

  func testContinue() {
    let issues = """
      func foo() {
        continue
        print("foo")
      }
      """.inspect(withRule: DeadCodeRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "dead_code")
    XCTAssertEqual(issue.description, "")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .major)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 3)
    XCTAssertEqual(range.start.column, 3)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 3)
    XCTAssertEqual(range.end.column, 15)
  }

  func testFallthrough() {
    let issues = """
      switch foo {
      case 1:
        fallthrough
        print("1")
      }
      """.inspect(withRule: DeadCodeRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "dead_code")
    XCTAssertEqual(issue.description, "")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .major)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 4)
    XCTAssertEqual(range.start.column, 3)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 4)
    XCTAssertEqual(range.end.column, 13)
  }

  func testReturn() {
    let issues = """
      foo() {
        return
        print("bar")
      }
      """.inspect(withRule: DeadCodeRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "dead_code")
    XCTAssertEqual(issue.description, "")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .major)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 3)
    XCTAssertEqual(range.start.column, 3)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 3)
    XCTAssertEqual(range.end.column, 15)
  }

  func testThrow() {
    let issues = """
      func foo() throws {
        throw .failed
        print("foo")
      }
      """.inspect(withRule: DeadCodeRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "dead_code")
    XCTAssertEqual(issue.description, "")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .major)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 3)
    XCTAssertEqual(range.start.column, 3)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 3)
    XCTAssertEqual(range.end.column, 15)
  }

  func testIfStmtsNotAllBranchesExit() {
    let issues = """
      func foo() {
        if foo { // no else
          return
        }

        if foo {
          print("foo")
        } else {
          return
        }

        if foo {
          return
        } else if bar {
          throw .failed
        } else {
          print("bar")
        }
      }
      """.inspect(withRule: DeadCodeRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testIfExitFromThenElse() {
    let issues = """
      func foo() throws {
        if foo {
          throw .failed
        } else {
          return
        }
        print("foo")
      }
      """.inspect(withRule: DeadCodeRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "dead_code")
    XCTAssertEqual(issue.description, "")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .major)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 7)
    XCTAssertEqual(range.start.column, 3)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 7)
    XCTAssertEqual(range.end.column, 15)
  }

  func testIfExitFromThenElseIfElse() {
    let issues = """
      func foo() throws {
        if foo {
          throw .failed
        } else if bar {
          return
        } else {
          throw .again
        }
        print("foo")
      }
      """.inspect(withRule: DeadCodeRule())
    XCTAssertEqual(issues.count, 1)
    let issue = issues[0]
    XCTAssertEqual(issue.ruleIdentifier, "dead_code")
    XCTAssertEqual(issue.description, "")
    XCTAssertEqual(issue.category, .badPractice)
    XCTAssertEqual(issue.severity, .major)
    let range = issue.location
    XCTAssertEqual(range.start.path, "test/test")
    XCTAssertEqual(range.start.line, 9)
    XCTAssertEqual(range.start.column, 3)
    XCTAssertEqual(range.end.path, "test/test")
    XCTAssertEqual(range.end.line, 9)
    XCTAssertEqual(range.end.column, 15)
  }

  func testDeadCodeInBothInnerAndOuterIfs() {
    let issues = """
      func foo() throws {
        if foo {
          throw .failed
        } else {
          return
          print("bar")
        }
        print("foo")
      }
      """.inspect(withRule: DeadCodeRule())
    XCTAssertEqual(issues.count, 2)
    let issue0 = issues[0]
    XCTAssertEqual(issue0.ruleIdentifier, "dead_code")
    XCTAssertEqual(issue0.description, "")
    XCTAssertEqual(issue0.category, .badPractice)
    XCTAssertEqual(issue0.severity, .major)
    let range0 = issue0.location
    XCTAssertEqual(range0.start.path, "test/test")
    XCTAssertEqual(range0.start.line, 8)
    XCTAssertEqual(range0.start.column, 3)
    XCTAssertEqual(range0.end.path, "test/test")
    XCTAssertEqual(range0.end.line, 8)
    XCTAssertEqual(range0.end.column, 15)
    let issue1 = issues[1]
    XCTAssertEqual(issue1.ruleIdentifier, "dead_code")
    XCTAssertEqual(issue1.description, "")
    XCTAssertEqual(issue1.category, .badPractice)
    XCTAssertEqual(issue1.severity, .major)
    let range1 = issue1.location
    XCTAssertEqual(range1.start.path, "test/test")
    XCTAssertEqual(range1.start.line, 6)
    XCTAssertEqual(range1.start.column, 5)
    XCTAssertEqual(range1.end.path, "test/test")
    XCTAssertEqual(range1.end.line, 6)
    XCTAssertEqual(range1.end.column, 17)
  }

  static var allTests = [
    ("testNoControlTransferStatement", testNoControlTransferStatement),
    ("testBreak", testBreak),
    ("testContinue", testContinue),
    ("testFallthrough", testFallthrough),
    ("testReturn", testReturn),
    ("testThrow", testThrow),
    ("testIfStmtsNotAllBranchesExit", testIfStmtsNotAllBranchesExit),
    ("testIfExitFromThenElse", testIfExitFromThenElse),
    ("testIfExitFromThenElseIfElse", testIfExitFromThenElseIfElse),
    ("testDeadCodeInBothInnerAndOuterIfs", testDeadCodeInBothInnerAndOuterIfs),
  ]
}
