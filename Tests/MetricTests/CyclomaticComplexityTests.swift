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
    XCTAssertEqual(getCyclomaticComplexity(for: ""), 1)
  }

  func testDoStmt() {
    XCTAssertEqual(getCyclomaticComplexity(for: "do { try bar() }"), 1)
    XCTAssertEqual(getCyclomaticComplexity(for: "do { try bar() } catch e1 {}"), 2)
    XCTAssertEqual(getCyclomaticComplexity(for: "do { try bar() } catch e1 where x {}"), 2)
    XCTAssertEqual(getCyclomaticComplexity(for: "do { try bar() } catch e1 where x || y {}"), 3)
    XCTAssertEqual(getCyclomaticComplexity(for: "do { try bar() } catch e1 where x {} catch e1 where y {}"), 3)
    XCTAssertEqual(getCyclomaticComplexity(for: "do { try bar() } catch e1 {} catch e2 {}"), 3)
    XCTAssertEqual(getCyclomaticComplexity(for: "do { try bar() } catch e1 {} catch e2 {} catch {}"), 4)
  }

  func testForStmt() {
    XCTAssertEqual(getCyclomaticComplexity(for: "for _ in foo {}"), 2)
  }

  func testGuardStmt() {
    XCTAssertEqual(getCyclomaticComplexity(for: "guard bar else {}"), 2)
  }

  func testIfStmt() {
    XCTAssertEqual(getCyclomaticComplexity(for: "if bar {}"), 2)
    XCTAssertEqual(getCyclomaticComplexity(for: "if bar && bar {}"), 3)
    XCTAssertEqual(getCyclomaticComplexity(for: "if bar {} else {}"), 2)
    XCTAssertEqual(getCyclomaticComplexity(for: "if bar1 {} else if bar2 {}"), 3)
    XCTAssertEqual(getCyclomaticComplexity(for: "if bar1 {} else if bar2 {} else if bar3 {}"), 4)
    XCTAssertEqual(getCyclomaticComplexity(for: "if bar1 {} else if bar2 {} else if bar3 {} else {}"), 4)
  }

  func testRepeatWhileStatement() {
    XCTAssertEqual(getCyclomaticComplexity(for: "repeat {} while bar"), 2)
  }

  func testSwitchStatement() {
    XCTAssertEqual(getCyclomaticComplexity(for: "switch bar {}"), 1)
    XCTAssertEqual(getCyclomaticComplexity(for: "switch bar { case a: break }"), 2)
    XCTAssertEqual(getCyclomaticComplexity(for: "switch bar { case a, b: break }"), 2)
    XCTAssertEqual(getCyclomaticComplexity(for: "switch bar { case a, b where b: break }"), 2)
    XCTAssertEqual(getCyclomaticComplexity(for: "switch bar { case a, b where b && c: break }"), 3)
    XCTAssertEqual(getCyclomaticComplexity(for: "switch bar { case a: break\ncase b: break }"), 3)
    XCTAssertEqual(getCyclomaticComplexity(for: "switch bar { default: break }"), 1)
    XCTAssertEqual(getCyclomaticComplexity(for: "switch bar { case a: break\ndefault: break }"), 2)
    XCTAssertEqual(getCyclomaticComplexity(for: "switch bar { case a: break\ncase b: break\ndefault: break }"), 3)
  }

  func testWhileStatement() {
    XCTAssertEqual(getCyclomaticComplexity(for: "while bar {}"), 2)
  }

  func testTernaryConditionalOperatorExpression() {
    XCTAssertEqual(getCyclomaticComplexity(for: "bar ? t : f"), 2)
  }

  func testBinaryOperatorExpression() {
    XCTAssertEqual(getCyclomaticComplexity(for: "bar1 && bar2"), 2)
    XCTAssertEqual(getCyclomaticComplexity(for: "bar1 || bar2"), 2)
    XCTAssertEqual(getCyclomaticComplexity(for: "bar1 ++ bar2"), 1)
  }

  func testConditionList() {
    XCTAssertEqual(getCyclomaticComplexity(for: "while a, b {}"), 3)
    XCTAssertEqual(getCyclomaticComplexity(for: "if a, b, c {}"), 4)
    XCTAssertEqual(getCyclomaticComplexity(for: "guard a, b, c || d else {}"), 5)
  }

  func testMultipleDecisionPoints() {
    let content = "switch bar {\n" +
      "case 1:\n" +
      "do {\n" +
      "try d ? e : f\n" +
      "} catch e1 {\n" +
      "repeat {} while w\n" +
      "} catch e2 {\n" +
      "for f in q {}\n" +
      "} catch {\n" +
      "while a, b, c {}\n" +
      "}\n" +
      "case 2:\n" +
      "if x || y && z {}\n" +
      "case 3:\n" +
      "guard o, p == q else {}\n" +
      "default:\n" +
      "break\n" +
      "}\n"
    XCTAssertEqual(getCyclomaticComplexity(for: content), 18)
  }

  private func getCyclomaticComplexity(for content: String) -> Int {
    let fullContent = "func foo() { \(content)} }"
    let source = SourceFile(
      path: "MetricTests/CyclomaticComplexityTests.swift", content: fullContent)
    guard
      let topLevelDecl = try? Parser(source: source).parse(),
      topLevelDecl.statements.count == 1,
      let decl = topLevelDecl.statements[0] as? Declaration
    else {
      XCTFail("Failed in parsing content `\(content)`")
      return 0
    }
    return decl.cyclomaticComplexity
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
    ("testTernaryConditionalOperatorExpression", testTernaryConditionalOperatorExpression),
    ("testBinaryOperatorExpression", testBinaryOperatorExpression),
    ("testConditionList", testConditionList),
    ("testMultipleDecisionPoints", testMultipleDecisionPoints),
  ]
}
