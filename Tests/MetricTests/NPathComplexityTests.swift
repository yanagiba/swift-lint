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

class NPathComplexityTests : XCTestCase {
  func testEmptyBlock() {
    XCTAssertEqual(getNPathComplexity(for: ""), 1)
  }

  func testNonCountingStatements() {
    XCTAssertEqual(getNPathComplexity(for: "break"), 1)
    XCTAssertEqual(getNPathComplexity(for: "break;break"), 1)
    XCTAssertEqual(getNPathComplexity(for: "continue"), 1)
    XCTAssertEqual(getNPathComplexity(for: "continue;continue"), 1)
    XCTAssertEqual(getNPathComplexity(for: "fallthrough;fallthrough"), 1)
    XCTAssertEqual(getNPathComplexity(for: "foo;foo"), 1)
    XCTAssertEqual(getNPathComplexity(for: "1\n2"), 1)
  }

  func testDeferStatement() {
    XCTAssertEqual(getNPathComplexity(for: "defer {}"), 1)
    XCTAssertEqual(getNPathComplexity(for: "defer { defer {} }"), 1)
    XCTAssertEqual(getNPathComplexity(for: "defer { if foo {} }"), 2)
  }

  func testDoStatement() {
    XCTAssertEqual(getNPathComplexity(for: "do {}"), 1)
    XCTAssertEqual(getNPathComplexity(for: "do { if foo {} }"), 2)
    XCTAssertEqual(getNPathComplexity(for: "do {} catch {}"), 2)
    XCTAssertEqual(getNPathComplexity(for: "do {} catch e1 { if foo {} }"), 3)
    XCTAssertEqual(getNPathComplexity(for: "do {} catch e1 where bar { if foo {} }"), 4)
    XCTAssertEqual(getNPathComplexity(for: "do {} catch e1 where bar && foo { if foo {} }"), 5)
    XCTAssertEqual(getNPathComplexity(for: "do {} catch e1 where bar { if foo {} } catch e2 {}"), 5)
    XCTAssertEqual(getNPathComplexity(for: "do {} catch e1 where bar { if foo {} } catch e2 {} catch {}"), 6)
  }

  func testForStatement() {
    XCTAssertEqual(getNPathComplexity(for: "for _ in bar {}"), 2)
    XCTAssertEqual(getNPathComplexity(for: "for _ in bar where t {}"), 3)
    XCTAssertEqual(getNPathComplexity(for: "for _ in bar where t { if f {} }"), 4)
  }

  func testGuardStatement() {
    XCTAssertEqual(getNPathComplexity(for: "guard foo else {}"), 2)
    XCTAssertEqual(getNPathComplexity(for: "guard foo else {}; guard bar else {}"), 4)
    XCTAssertEqual(getNPathComplexity(for: "guard foo, bar else {}"), 3)
    XCTAssertEqual(getNPathComplexity(for: "guard foo, bar, x else {}"), 4)
    XCTAssertEqual(getNPathComplexity(for: "guard foo, bar, x || y else {}"), 5)
  }

  func testIfStatement() {
    XCTAssertEqual(getNPathComplexity(for: "if foo {}"), 2)
    XCTAssertEqual(getNPathComplexity(for: "if foo {}; if bar {}; foo"), 4)
    XCTAssertEqual(getNPathComplexity(for: "if foo, bar {}"), 3)
    XCTAssertEqual(getNPathComplexity(for: "if foo {} else {}"), 2)
    XCTAssertEqual(getNPathComplexity(for: "if foo {} else if bar {}"), 3)
    XCTAssertEqual(getNPathComplexity(for: "if foo {} else if bar {} else {}"), 3)
    XCTAssertEqual(getNPathComplexity(for: "if foo {} else if bar {} else if x {} else if y {} else {}"), 5)
  }

  func testLabeledStatement() {
    XCTAssertEqual(getNPathComplexity(for: "foo: for _ in foo {}"), 2)
    XCTAssertEqual(getNPathComplexity(for: "foo: while foo {}"), 2)
    XCTAssertEqual(getNPathComplexity(for: "foo: repeat {} while foo"), 2)
    XCTAssertEqual(getNPathComplexity(for: "foo: if foo {}"), 2)
    XCTAssertEqual(getNPathComplexity(for: "foo: switch foo {}"), 1)
    XCTAssertEqual(getNPathComplexity(for: "foo: do {}"), 1)
  }

  func testRepeatWhileStatement() {
    XCTAssertEqual(getNPathComplexity(for: "repeat {} while foo"), 2)
    XCTAssertEqual(getNPathComplexity(for: "repeat { if bar {} } while foo"), 3)
    XCTAssertEqual(getNPathComplexity(for: "repeat { if bar {} } while foo && bar"), 4)
  }

  func testReturnStatement() {
    XCTAssertEqual(getNPathComplexity(for: "return"), 1)
    XCTAssertEqual(getNPathComplexity(for: "return foo"), 1)
    XCTAssertEqual(getNPathComplexity(for: "return foo && bar"), 2)
  }

  func testSwitchStatement() {
    XCTAssertEqual(getNPathComplexity(for: "switch foo {}"), 1)
    XCTAssertEqual(getNPathComplexity(for: "switch bar { case a: break }"), 1)
    XCTAssertEqual(getNPathComplexity(for: "switch bar { case a: break\ncase b: break }"), 2)
    XCTAssertEqual(getNPathComplexity(for: "switch bar { case a: if x {};if y {} }"), 4)
    XCTAssertEqual(getNPathComplexity(for: "switch bar { case a where a == b: break }"), 2)
    XCTAssertEqual(getNPathComplexity(for: "switch bar { case a where a && b: break }"), 3)
    XCTAssertEqual(getNPathComplexity(for: "switch bar { case a, b, c: break }"), 1)
    XCTAssertEqual(getNPathComplexity(for: "switch bar { case a where a == x, b, c where c && y: break }"), 4)
    XCTAssertEqual(getNPathComplexity(for: "switch bar { default: break }"), 1)
    XCTAssertEqual(getNPathComplexity(for: "switch bar { case a: break\ndefault: break }"), 2)
    XCTAssertEqual(getNPathComplexity(for: "switch bar { case a: break\ncase b: break\ndefault: break }"), 3)
  }

  func testThrowStatement() {
    XCTAssertEqual(getNPathComplexity(for: "throw foo"), 1)
    XCTAssertEqual(getNPathComplexity(for: "throw foo && bar"), 2)
  }

  func testWhileStatement() {
    XCTAssertEqual(getNPathComplexity(for: "while foo {}"), 2)
    XCTAssertEqual(getNPathComplexity(for: "while foo { if bar {} }"), 3)
    XCTAssertEqual(getNPathComplexity(for: "while foo && bar { if bar {} }"), 4)
    XCTAssertEqual(getNPathComplexity(for: "while foo, bar {}"), 3)
    XCTAssertEqual(getNPathComplexity(for: "while foo, bar, x || y {}"), 5)
  }

  func testExpressions() {
    // binary operators
    XCTAssertEqual(getNPathComplexity(for: "foo"), 1)
    XCTAssertEqual(getNPathComplexity(for: "foo && bar"), 2)
    XCTAssertEqual(getNPathComplexity(for: "foo || bar"), 2)
    XCTAssertEqual(getNPathComplexity(for: "x || y && z ++ p"), 3)
    XCTAssertEqual(getNPathComplexity(for: "if foo && bar {}"), 3)
    XCTAssertEqual(getNPathComplexity(for: "if foo || bar {}"), 3)
    XCTAssertEqual(getNPathComplexity(for: "if x || y && z ++ p {}"), 4)
    // function calls
    XCTAssertEqual(getNPathComplexity(for: "foo()"), 1)
    XCTAssertEqual(getNPathComplexity(for: "foo() && bar()"), 2)
    XCTAssertEqual(getNPathComplexity(for: "foo() || bar()"), 2)
    XCTAssertEqual(getNPathComplexity(for: "x() || y() && z() ++ p()"), 3)
    XCTAssertEqual(getNPathComplexity(for: "if foo() && bar() {}"), 3)
    XCTAssertEqual(getNPathComplexity(for: "if foo() || bar() {}"), 3)
    XCTAssertEqual(getNPathComplexity(for: "if x() || y() && z() ++ p() {}"), 4)
    // ternary conditional operators
    XCTAssertEqual(getNPathComplexity(for: "foo ? t : f"), 2)
    XCTAssertEqual(getNPathComplexity(for: "foo && bar ? t : f"), 3)
    XCTAssertEqual(getNPathComplexity(for: "if foo ? t : f {}"), 3)
    XCTAssertEqual(getNPathComplexity(for: "if foo || bar ? t : f {}"), 4)
  }


  private func getNPathComplexity(for content: String) -> Int {
    let fullContent = "deinit { \(content)} }"
    let source = SourceFile(
      path: "MetricTests/NPathComplexityTests.swift", content: fullContent)
    guard
      let topLevelDecl = try? Parser(source: source).parse(),
      topLevelDecl.statements.count == 1,
      let deinitDecl = topLevelDecl.statements[0] as? DeinitializerDeclaration
    else {
      XCTFail("Failed in parsing content `\(content)`")
      return 0
    }
    return deinitDecl.body.nPathComplexity
  }

  static var allTests = [
    ("testEmptyBlock", testEmptyBlock),
    ("testNonCountingStatements", testNonCountingStatements),
    ("testDeferStatement", testDeferStatement),
    ("testDoStatement", testDoStatement),
    ("testForStatement", testForStatement),
    ("testGuardStatement", testGuardStatement),
    ("testIfStatement", testIfStatement),
    ("testLabeledStatement", testLabeledStatement),
    ("testRepeatWhileStatement", testRepeatWhileStatement),
    ("testReturnStatement", testReturnStatement),
    ("testSwitchStatement", testSwitchStatement),
    ("testThrowStatement", testThrowStatement),
    ("testWhileStatement", testWhileStatement),
    ("testExpressions", testExpressions),
  ]
}
