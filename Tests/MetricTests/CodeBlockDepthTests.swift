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

class CodeBlockDepthTests : XCTestCase {
  func testEmptyBlock() {
    XCTAssertEqual(getDepth(for: ""), 1)
  }

  func testSingleLineDeclarations() {
    XCTAssertEqual(getDepth(for: "let a = 1"), 2)
    XCTAssertEqual(getDepth(for: "var a = 1"), 2)
    XCTAssertEqual(getDepth(for: "import foo"), 2)
    XCTAssertEqual(getDepth(for: "prefix operator <!>"), 2)
    XCTAssertEqual(getDepth(for: "typealias Foo = Bar"), 2)
  }

  func testDeinitializerDeclaration() {
    XCTAssertEqual(getDepth(for: "deinit {}"), 2)
    XCTAssertEqual(getDepth(for: "deinit { let a }"), 3)
  }

  func testFunctionDeclaration() {
    XCTAssertEqual(getDepth(for: "func foo()"), 2)
    XCTAssertEqual(getDepth(for: "func foo() {}"), 2)
    XCTAssertEqual(getDepth(for: "func foo() { let a }"), 3)
  }

  func testInitializerDeclaration() {
    XCTAssertEqual(getDepth(for: "init() {}"), 2)
    XCTAssertEqual(getDepth(for: "init() { let a }"), 3)
  }

  func testSubscriptDeclaration() {
    XCTAssertEqual(getDepth(for: "subscript() -> Self {}"), 2)
    XCTAssertEqual(getDepth(for: "subscript() -> Self { let a = 1 }"), 3)
    XCTAssertEqual(getDepth(for: "subscript() -> Self { let a = 1\nfunc bar() {} }"), 3)
    XCTAssertEqual(getDepth(for: "subscript() -> Self { get { return _foo } }"), 4)
    XCTAssertEqual(getDepth(for: "subscript() -> Self { get { let a = 1;return _foo } }"), 4)
    XCTAssertEqual(getDepth(for: "subscript() -> Self { get { return _foo } set { _foo = newValue } }"), 4)
    XCTAssertEqual(getDepth(for: "subscript() -> Self { get { return _foo } set { let a = 1; _foo = newValue } }"), 4)
    XCTAssertEqual(getDepth(for: "subscript() -> Self { get }"), 3)
    XCTAssertEqual(getDepth(for: "subscript() -> Self { get set }"), 3)
  }

  func testConstantAndVariableDeclarations() { // swift-lint:suppress()
    XCTAssertEqual(getDepth(for: "let a = 1"), 2)
    XCTAssertEqual(getDepth(for: "let a = foo { }"), 2)
    XCTAssertEqual(getDepth(for: "let a, b"), 2)
    XCTAssertEqual(getDepth(for: "let a = foo { }, b"), 2)
    XCTAssertEqual(getDepth(for: "let a = foo { }, b = bar {}"), 2)
    XCTAssertEqual(getDepth(for: "let a = foo { a in }"), 3)
    XCTAssertEqual(getDepth(for: "let a = foo { f }, b"), 3)
    XCTAssertEqual(getDepth(for: "let a, b = foo { f }"), 3)
    XCTAssertEqual(getDepth(for: "let a = foo { f }, b = bar { b }"), 3)
    XCTAssertEqual(getDepth(for: "let a = foo { a;b;c}"), 3)
    XCTAssertEqual(getDepth(for: "let a = foo { a in a;b;c}"), 3)
    XCTAssertEqual(getDepth(for: "var a = 1"), 2)
    XCTAssertEqual(getDepth(for: "var a = foo { }"), 2)
    XCTAssertEqual(getDepth(for: "var a, b"), 2)
    XCTAssertEqual(getDepth(for: "var a = foo { }, b"), 2)
    XCTAssertEqual(getDepth(for: "var a = foo { }, b = bar {}"), 2)
    XCTAssertEqual(getDepth(for: "var a = foo { a in }"), 3)
    XCTAssertEqual(getDepth(for: "var a = foo { f }, b"), 3)
    XCTAssertEqual(getDepth(for: "var a, b = foo { f }"), 3)
    XCTAssertEqual(getDepth(for: "var a = foo { f }, b = bar { b }"), 3)
    XCTAssertEqual(getDepth(for: "var a = foo { a;b;c}"), 3)
    XCTAssertEqual(getDepth(for: "var a = foo { a in a;b;c}"), 3)
    XCTAssertEqual(getDepth(for: "var a: Foo { let a = 1 }"), 3)
    XCTAssertEqual(getDepth(for: "var a: Foo { let a = 1\nfunc bar() {} }"), 3)
    XCTAssertEqual(getDepth(for: "var a: Foo { get { return _foo } }"), 4)
    XCTAssertEqual(getDepth(for: "var a: Foo { get { let a = 1;return _foo } }"), 4)
    XCTAssertEqual(getDepth(for: "var a: Foo { get { return _foo } set { _foo = newValue } }"), 4)
    XCTAssertEqual(getDepth(for: "var a: Foo { get { return _foo } set { let a = 1; _foo = newValue } }"), 4)
    XCTAssertEqual(getDepth(for: "var a: Foo { get }"), 3)
    XCTAssertEqual(getDepth(for: "var a: Foo { get set }"), 3)
    XCTAssertEqual(getDepth(for: "var foo: Foo { willSet { print(newValue) } }"), 4)
    XCTAssertEqual(getDepth(for: "var foo: Foo { didSet { print(newValue) } }"), 4)
    XCTAssertEqual(getDepth(for: "var foo: Foo { willSet { print(newValue) } didSet { print(newValue) } }"), 4)
    XCTAssertEqual(getDepth(for: "var foo = _foo { willSet { print(newValue) } }"), 4)
    XCTAssertEqual(getDepth(for: "var foo = _foo { didSet { print(newValue) } }"), 4)
    XCTAssertEqual(getDepth(for: "var foo = _foo { willSet { print(newValue) } didSet { print(newValue) } }"), 4)
    XCTAssertEqual(getDepth(for: "var foo = _foo { a;b;c } { willSet { print(newValue) } }"), 4)
    XCTAssertEqual(getDepth(for: "var foo = _foo { a;b;c } { didSet { print(newValue) } }"), 4)
    XCTAssertEqual(getDepth(for: "var foo = _foo { a;b;c } { willSet { print(newValue) } didSet { print(newValue) } }"), 4)
  }

  func testClassDeclaration() {
    XCTAssertEqual(getDepth(for: "class foo {}"), 2)
    XCTAssertEqual(getDepth(for: "class foo { let a = 1 }"), 3)
    XCTAssertEqual(getDepth(for: "class foo { let a = 1\nfunc bar() {} }"), 3)
    XCTAssertEqual(getDepth(for: "class foo {\n#if blah\nlet a = 1\n#endif}"), 3)
  }

  func testEnumDeclaration() {
    XCTAssertEqual(getDepth(for: "enum foo {}"), 2)
    XCTAssertEqual(getDepth(for: "enum foo { let a = 1 }"), 3)
    XCTAssertEqual(getDepth(for: "enum foo { let a = 1\nfunc bar() {} }"), 3)
    XCTAssertEqual(getDepth(for: "enum foo { case a }"), 3)
    XCTAssertEqual(getDepth(for: "enum foo { case a, b }"), 3)
    XCTAssertEqual(getDepth(for: "enum foo { case a, b\ncase c }"), 3)
    XCTAssertEqual(getDepth(for: "enum foo: Int { case a = 1 }"), 3)
    XCTAssertEqual(getDepth(for: "enum foo: Int { case a = 1, b }"), 3)
    XCTAssertEqual(getDepth(for: "enum foo: Int { case a = 1, b\ncase c }"), 3)
    XCTAssertEqual(getDepth(for: "enum foo {\n#if blah\nlet a = 1\n#endif}"), 3)
  }

  func testExtensionDeclaration() {
    XCTAssertEqual(getDepth(for: "extension foo {}"), 2)
    XCTAssertEqual(getDepth(for: "extension foo { let a = 1 }"), 3)
    XCTAssertEqual(getDepth(for: "extension foo { let a = 1\nfunc bar() {} }"), 3)
    XCTAssertEqual(getDepth(for: "extension foo {\n#if blah\nlet a = 1\n#endif}"), 3)
  }

  func testPrecedenceGroupDeclaration() {
    XCTAssertEqual(getDepth(for: "precedencegroup foo {}"), 2)
    XCTAssertEqual(getDepth(for: "precedencegroup foo {\nhigherThan: bar\n}"), 3)
    XCTAssertEqual(getDepth(for: "precedencegroup foo {\nhigherThan: bar\nassociativity: none\n}"), 3)
  }

  func testProtocolDeclaration() {
    XCTAssertEqual(getDepth(for: "protocol foo {}"), 2)
    XCTAssertEqual(getDepth(for: "protocol foo { var a: Int { get } }"), 3)
    XCTAssertEqual(getDepth(for: "protocol foo { var a: Int { get } func bar() }"), 3)
    XCTAssertEqual(getDepth(for: "protocol foo {\n#if blah\nvar a: Int { get }\n#endif}"), 3)
  }

  func testStructDeclaration() {
    XCTAssertEqual(getDepth(for: "struct foo {}"), 2)
    XCTAssertEqual(getDepth(for: "struct foo { let a = 1 }"), 3)
    XCTAssertEqual(getDepth(for: "struct foo { let a = 1\nfunc bar() {} }"), 3)
    XCTAssertEqual(getDepth(for: "struct foo {\n#if blah\nlet a = 1\n#endif}"), 3)
  }

  func testSingleLineStatements() {
    XCTAssertEqual(getDepth(for: "break"), 2)
    XCTAssertEqual(getDepth(for: "break foo"), 2)
    XCTAssertEqual(getDepth(for: "continue"), 2)
    XCTAssertEqual(getDepth(for: "continue foo"), 2)
    XCTAssertEqual(getDepth(for: "fallthrough"), 2)
    XCTAssertEqual(getDepth(for: "return"), 2)
    XCTAssertEqual(getDepth(for: "return foo"), 2)
    XCTAssertEqual(getDepth(for: "throw foo"), 2)
  }

  func testDeferStatement() {
    XCTAssertEqual(getDepth(for: "defer {}"), 2)
    XCTAssertEqual(getDepth(for: "defer { a }"), 3)
    XCTAssertEqual(getDepth(for: "defer { a;b;c }"), 3)
  }

  func testDoStatement() {
    XCTAssertEqual(getDepth(for: "do {}"), 2)
    XCTAssertEqual(getDepth(for: "do { a }"), 3)
    XCTAssertEqual(getDepth(for: "do { a;b;c }"), 3)
    XCTAssertEqual(getDepth(for: "do {} catch e {}"), 2)
    XCTAssertEqual(getDepth(for: "do {} catch e { a }"), 3)
    XCTAssertEqual(getDepth(for: "do {} catch e1 { a } catch e2 { b }"), 3)
    XCTAssertEqual(getDepth(for: "do {} catch e1 { a } catch e2 where x == y { b }"), 3)
    XCTAssertEqual(getDepth(for: "do {} catch e1 { a } catch e2 where x == y { b } catch {}"), 3)
  }

  func testForStatement() {
    XCTAssertEqual(getDepth(for: "for _ in foo {}"), 2)
    XCTAssertEqual(getDepth(for: "for _ in foo { a }"), 3)
    XCTAssertEqual(getDepth(for: "for _ in foo { a;b;c }"), 3)
  }

  func testGuardStatement() {
    XCTAssertEqual(getDepth(for: "guard foo else {}"), 2)
    XCTAssertEqual(getDepth(for: "guard foo else { a }"), 3)
    XCTAssertEqual(getDepth(for: "guard foo else { a;b;c }"), 3)
  }

  func testIfStatement() {
    XCTAssertEqual(getDepth(for: "if foo {}"), 2)
    XCTAssertEqual(getDepth(for: "if foo { a }"), 3)
    XCTAssertEqual(getDepth(for: "if foo { a;b;c }"), 3)
    XCTAssertEqual(getDepth(for: "if foo { a } else {}"), 3)
    XCTAssertEqual(getDepth(for: "if foo { a } else { b }"), 3)
    XCTAssertEqual(getDepth(for: "if foo { a } else if bar { b }"), 3)
    XCTAssertEqual(getDepth(for: "if foo { a } else if bar { b } else { c }"), 3)
    XCTAssertEqual(getDepth(for: "if foo { a } else if bar { b } else if x, y. z { c } else { d }"), 3)
  }

  func testLabeledStatement() {
    XCTAssertEqual(getDepth(for: "foo: for _ in foo {}"), 2)
    XCTAssertEqual(getDepth(for: "foo: for _ in foo {a}"), 3)
    XCTAssertEqual(getDepth(for: "foo: while foo {}"), 2)
    XCTAssertEqual(getDepth(for: "foo: while foo {a}"), 3)
    XCTAssertEqual(getDepth(for: "foo: repeat {} while foo"), 2)
    XCTAssertEqual(getDepth(for: "foo: repeat {a} while foo"), 3)
    XCTAssertEqual(getDepth(for: "foo: if foo {}"), 2)
    XCTAssertEqual(getDepth(for: "foo: if foo {a}"), 3)
    XCTAssertEqual(getDepth(for: "foo: switch foo {}"), 2)
    XCTAssertEqual(getDepth(for: "foo: switch foo { case a: break }"), 4)
    XCTAssertEqual(getDepth(for: "foo: do {}"), 2)
    XCTAssertEqual(getDepth(for: "foo: do {a}"), 3)
  }

  func testRepeatWhileStatement() {
    XCTAssertEqual(getDepth(for: "repeat {} while foo"), 2)
    XCTAssertEqual(getDepth(for: "repeat {a} while foo"), 3)
    XCTAssertEqual(getDepth(for: "repeat {a;b;c} while foo"), 3)
  }

  func testSwitchStatement() {
    XCTAssertEqual(getDepth(for: "switch foo {}"), 2)
    XCTAssertEqual(getDepth(for: "switch foo { case a: break }"), 4)
    XCTAssertEqual(getDepth(for: "switch foo { case a: break\ncase b: break\ncase c: break }"), 4)
    XCTAssertEqual(getDepth(for: "switch foo { case a: break\ncase b: break\ndefault: break }"), 4)
  }

  func testWhileStatement() {
    XCTAssertEqual(getDepth(for: "while foo {}"), 2)
    XCTAssertEqual(getDepth(for: "while foo { a }"), 3)
    XCTAssertEqual(getDepth(for: "while foo { a;b;c }"), 3)
  }

  func testReturnStatementWithTrailingClosure() {
    XCTAssertEqual(getDepth(for: "return foo { }"), 2)
    XCTAssertEqual(getDepth(for: "return foo { a in }"), 3)
    XCTAssertEqual(getDepth(for: "return foo { a;b;c}"), 3)
    XCTAssertEqual(getDepth(for: "return foo { a in a;b;c}"), 3)
  }

  func testThrowStatementWithTrailingClosure() {
    XCTAssertEqual(getDepth(for: "throw foo { }"), 2)
    XCTAssertEqual(getDepth(for: "throw foo { a in }"), 3)
    XCTAssertEqual(getDepth(for: "throw foo { a;b;c}"), 3)
    XCTAssertEqual(getDepth(for: "throw foo { a in a;b;c}"), 3)
  }

  func testSingleLineExpressions() {
    XCTAssertEqual(getDepth(for: "1"), 2)
    XCTAssertEqual(getDepth(for: "1;\"foo\";bar()"), 2)
    XCTAssertEqual(getDepth(for: "_ = 3"), 2)
    XCTAssertEqual(getDepth(for: "try a"), 2)
    XCTAssertEqual(getDepth(for: "c ? t : f"), 2)
  }

  func testClosureExpressionsAndRelated() {
    XCTAssertEqual(getDepth(for: "{}"), 2)
    XCTAssertEqual(getDepth(for: "{ a in }"), 3)
    XCTAssertEqual(getDepth(for: "{ a in\na;b;c}"), 3)
    XCTAssertEqual(getDepth(for: "{ a;b;c}"), 3)
    XCTAssertEqual(getDepth(for: "foo { }"), 2)
    XCTAssertEqual(getDepth(for: "foo { a in }"), 3)
    XCTAssertEqual(getDepth(for: "foo { a;b;c}"), 3)
    XCTAssertEqual(getDepth(for: "foo { a in a;b;c}"), 3)
  }

  private func getDepth(for content: String) -> Int {
    let fullContent = "deinit { \(content)} }"
    let source = SourceFile(
      path: "MetricTests/CodeBlockDepthTests.swift", content: fullContent)
    guard
      let topLevelDecl = try? Parser(source: source).parse(),
      topLevelDecl.statements.count == 1,
      let deinitDecl = topLevelDecl.statements[0] as? DeinitializerDeclaration
    else {
      XCTFail("Failed in parsing content `\(content)`")
      return 0
    }
    return deinitDecl.body.depth
  }

  static var allTests = [
    ("testEmptyBlock", testEmptyBlock),
    ("testSingleLineDeclarations", testSingleLineDeclarations),
    ("testDeinitializerDeclaration", testDeinitializerDeclaration),
    ("testFunctionDeclaration", testFunctionDeclaration),
    ("testInitializerDeclaration", testInitializerDeclaration),
    ("testSubscriptDeclaration", testSubscriptDeclaration),
    ("testConstantAndVariableDeclarations", testConstantAndVariableDeclarations),
    ("testClassDeclaration", testClassDeclaration),
    ("testEnumDeclaration", testEnumDeclaration),
    ("testExtensionDeclaration", testExtensionDeclaration),
    ("testPrecedenceGroupDeclaration", testPrecedenceGroupDeclaration),
    ("testProtocolDeclaration", testProtocolDeclaration),
    ("testStructDeclaration", testStructDeclaration),
    ("testSingleLineStatements", testSingleLineStatements),
    ("testDeferStatement", testDeferStatement),
    ("testDoStatement", testDoStatement),
    ("testForStatement", testForStatement),
    ("testGuardStatement", testGuardStatement),
    ("testIfStatement", testIfStatement),
    ("testLabeledStatement", testLabeledStatement),
    ("testRepeatWhileStatement", testRepeatWhileStatement),
    ("testSwitchStatement", testSwitchStatement),
    ("testWhileStatement", testWhileStatement),
    ("testReturnStatementWithTrailingClosure", testReturnStatementWithTrailingClosure),
    ("testThrowStatementWithTrailingClosure", testThrowStatementWithTrailingClosure),
    ("testSingleLineExpressions", testSingleLineExpressions),
    ("testClosureExpressionsAndRelated", testClosureExpressionsAndRelated),
  ]
}
