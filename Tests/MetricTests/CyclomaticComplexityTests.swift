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

@testable import AST
@testable import Source
@testable import Parser
@testable import Metric

class CyclomaticComplexityTests : XCTestCase {
  func testEmptyDecl() {
    XCTAssertEqual(getDecl(from: "deinit {}").cyclomaticComplexity, 1)
  }

  func testDoStmt() {
    XCTAssertEqual(getDecl(from: "func foo() { do { try bar() } }").cyclomaticComplexity, 1)
    XCTAssertEqual(getDecl(from: "func foo() { do { try bar() } catch e1 {} }").cyclomaticComplexity, 2)
    XCTAssertEqual(getDecl(from: "func foo() { do { try bar() } catch e1 {} catch e2 {} }").cyclomaticComplexity, 3)
    XCTAssertEqual(getDecl(from: "func foo() { do { try bar() } catch e1 {} catch e2 {} catch {} }").cyclomaticComplexity, 4)
  }

  func testForStmt() {
    XCTAssertEqual(getDecl(from: "func foo() { for _ in foo {} }").cyclomaticComplexity, 2)
  }

  func testGuardStmt() {
    XCTAssertEqual(getDecl(from: "func foo() { guard bar else {} }").cyclomaticComplexity, 2)
  }

  func testIfStmt() {
    XCTAssertEqual(getDecl(from: "func foo() { if bar {} }").cyclomaticComplexity, 2)
    XCTAssertEqual(getDecl(from: "func foo() { if bar {} else {} }").cyclomaticComplexity, 2)
    XCTAssertEqual(getDecl(from: "func foo() { if bar1 {} else if bar2 {} }").cyclomaticComplexity, 3)
    XCTAssertEqual(getDecl(from: "func foo() { if bar1 {} else if bar2 {} else if bar3 {} }").cyclomaticComplexity, 4)
    XCTAssertEqual(getDecl(from: "func foo() { if bar1 {} else if bar2 {} else if bar3 {} else {} }").cyclomaticComplexity, 4)
  }

  func testRepeatWhileStatement() {
    XCTAssertEqual(getDecl(from: "func foo() { repeat {} while bar }").cyclomaticComplexity, 2)
  }

  func testSwitchStatement() {
    XCTAssertEqual(getDecl(from: "func foo() { switch bar {} }").cyclomaticComplexity, 1)
    XCTAssertEqual(getDecl(from: "func foo() { switch bar { case a: break } }").cyclomaticComplexity, 2)
    XCTAssertEqual(getDecl(from: "func foo() { switch bar { case a: break case b: break } }").cyclomaticComplexity, 3)
    XCTAssertEqual(getDecl(from: "func foo() { switch bar { default: break } }").cyclomaticComplexity, 1)
    XCTAssertEqual(getDecl(from: "func foo() { switch bar { case a: break default: break } }").cyclomaticComplexity, 2)
    XCTAssertEqual(getDecl(from: "func foo() { switch bar { case a: break case b: break default: break } }").cyclomaticComplexity, 3)
  }

  func testWhileStatement() {
    XCTAssertEqual(getDecl(from: "func foo() { while bar {} }").cyclomaticComplexity, 2)
  }

  private func getDecl(from content: String) -> Declaration {
    let source = SourceFile(path: "MetricTests/CyclomaticComplexityTests.swift", content: content)
    guard
      let topLevelDecl = try? Parser(source: source).parse(),
      topLevelDecl.statements.count == 1,
      let decl = topLevelDecl.statements[0] as? Declaration
    else {
      XCTFail("Failed in parsing content `\(content)`")
      return DeinitializerDeclaration(body: CodeBlock())
    }
    return decl
  }

  static var allTests = [
    ("testEmptyDecl", testEmptyDecl),
    ("testDoStmt", testDoStmt),
    ("testForStmt", testForStmt),
    ("testGuardStmt", testGuardStmt),
    ("testIfStmt", testIfStmt),
    ("testRepeatWhileStatement", testRepeatWhileStatement),
    ("testSwitchStatement", testSwitchStatement),
    ("testWhileStatement", testWhileStatement),
  ]
}
