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

class NonCommentingSourceStatementsTests : XCTestCase {
  func testEmptyContent() {
    XCTAssertEqual(getNCSS(for: ""), 0)
  }

  func testSingleLineExpressions() {
    XCTAssertEqual(getNCSS(for: "1"), 1)
    XCTAssertEqual(getNCSS(for: "1;\"foo\";bar()"), 3)
    XCTAssertEqual(getNCSS(for: "_ = 3"), 1)
    XCTAssertEqual(getNCSS(for: "try a"), 1)
    XCTAssertEqual(getNCSS(for: "c ? t : f"), 1)
  }

  func testClosureExpressionsAndRelated() {
    XCTAssertEqual(getNCSS(for: "{}"), 1)
    XCTAssertEqual(getNCSS(for: "{ a in }"), 1)
    XCTAssertEqual(getNCSS(for: "{ a in\na;b;c}"), 4)
    XCTAssertEqual(getNCSS(for: "{ a;b;c}"), 3)
    XCTAssertEqual(getNCSS(for: "foo { }"), 1)
    XCTAssertEqual(getNCSS(for: "foo { a in }"), 1)
    XCTAssertEqual(getNCSS(for: "foo { a;b;c}"), 4)
    XCTAssertEqual(getNCSS(for: "foo { a in a;b;c}"), 4)
  }

  func testSingleLineStatements() {
    XCTAssertEqual(getNCSS(for: "break"), 1)
    XCTAssertEqual(getNCSS(for: "break foo"), 1)
    XCTAssertEqual(getNCSS(for: "continue"), 1)
    XCTAssertEqual(getNCSS(for: "continue foo"), 1)
    XCTAssertEqual(getNCSS(for: "fallthrough"), 1)
    XCTAssertEqual(getNCSS(for: "return"), 1)
    XCTAssertEqual(getNCSS(for: "return foo"), 1)
    XCTAssertEqual(getNCSS(for: "throw foo"), 1)
  }

  func testDeferStatement() {
    XCTAssertEqual(getNCSS(for: "defer {}"), 1)
    XCTAssertEqual(getNCSS(for: "defer { a }"), 2)
    XCTAssertEqual(getNCSS(for: "defer { a;b;c }"), 4)
  }

  func testDoStatement() {
    XCTAssertEqual(getNCSS(for: "do {}"), 1)
    XCTAssertEqual(getNCSS(for: "do { a }"), 2)
    XCTAssertEqual(getNCSS(for: "do { a;b;c }"), 4)
    XCTAssertEqual(getNCSS(for: "do {} catch e {}"), 2)
    XCTAssertEqual(getNCSS(for: "do {} catch e { a }"), 3)
    XCTAssertEqual(getNCSS(for: "do {} catch e1 { a } catch e2 { b }"), 5)
    XCTAssertEqual(getNCSS(for: "do {} catch e1 { a } catch e2 where x == y { b }"), 5)
    XCTAssertEqual(getNCSS(for: "do {} catch e1 { a } catch e2 where x == y { b } catch {}"), 6)
  }

  func testForStatement() {
    XCTAssertEqual(getNCSS(for: "for _ in foo {}"), 1)
    XCTAssertEqual(getNCSS(for: "for _ in foo { a }"), 2)
    XCTAssertEqual(getNCSS(for: "for _ in foo { a;b;c }"), 4)
  }

  func testGuardStatement() {
    XCTAssertEqual(getNCSS(for: "guard foo else {}"), 1)
    XCTAssertEqual(getNCSS(for: "guard foo else { a }"), 2)
    XCTAssertEqual(getNCSS(for: "guard foo else { a;b;c }"), 4)
  }

  func testIfStatement() {
    XCTAssertEqual(getNCSS(for: "if foo {}"), 1)
    XCTAssertEqual(getNCSS(for: "if foo { a }"), 2)
    XCTAssertEqual(getNCSS(for: "if foo { a;b;c }"), 4)
    XCTAssertEqual(getNCSS(for: "if foo { a } else {}"), 3)
    XCTAssertEqual(getNCSS(for: "if foo { a } else { b }"), 4)
    XCTAssertEqual(getNCSS(for: "if foo { a } else if bar { b }"), 4)
    XCTAssertEqual(getNCSS(for: "if foo { a } else if bar { b } else { c }"), 6)
    XCTAssertEqual(getNCSS(for: "if foo { a } else if bar { b } else if x, y. z { c } else { d }"), 8)
  }

  func testLabeledStatement() {
    XCTAssertEqual(getNCSS(for: "foo: for _ in foo {}"), 1)
    XCTAssertEqual(getNCSS(for: "foo: for _ in foo {a}"), 2)
    XCTAssertEqual(getNCSS(for: "foo: while foo {}"), 1)
    XCTAssertEqual(getNCSS(for: "foo: while foo {a}"), 2)
    XCTAssertEqual(getNCSS(for: "foo: repeat {} while foo"), 2)
    XCTAssertEqual(getNCSS(for: "foo: repeat {a} while foo"), 3)
    XCTAssertEqual(getNCSS(for: "foo: if foo {}"), 1)
    XCTAssertEqual(getNCSS(for: "foo: if foo {a}"), 2)
    XCTAssertEqual(getNCSS(for: "foo: switch foo {}"), 1)
    XCTAssertEqual(getNCSS(for: "foo: switch foo { case a: break }"), 3)
    XCTAssertEqual(getNCSS(for: "foo: do {}"), 1)
    XCTAssertEqual(getNCSS(for: "foo: do {a}"), 2)
  }

  func testRepeatWhileStatement() {
    XCTAssertEqual(getNCSS(for: "repeat {} while foo"), 2)
    XCTAssertEqual(getNCSS(for: "repeat {a} while foo"), 3)
    XCTAssertEqual(getNCSS(for: "repeat {a;b;c} while foo"), 5)
  }

  func testSwitchStatement() {
    XCTAssertEqual(getNCSS(for: "switch foo {}"), 1)
    XCTAssertEqual(getNCSS(for: "switch foo { case a: break }"), 3)
    XCTAssertEqual(getNCSS(for: "switch foo { case a: break\ncase b: break\ncase c: break }"), 7)
    XCTAssertEqual(getNCSS(for: "switch foo { case a: break\ncase b: break\ndefault: break }"), 7)
  }

  func testWhileStatement() {
    XCTAssertEqual(getNCSS(for: "while foo {}"), 1)
    XCTAssertEqual(getNCSS(for: "while foo { a }"), 2)
    XCTAssertEqual(getNCSS(for: "while foo { a;b;c }"), 4)
  }

  func testReturnStatementWithTrailingClosure() {
    XCTAssertEqual(getNCSS(for: "return foo { }"), 1)
    XCTAssertEqual(getNCSS(for: "return foo { a in }"), 1)
    XCTAssertEqual(getNCSS(for: "return foo { a;b;c}"), 4)
    XCTAssertEqual(getNCSS(for: "return foo { a in a;b;c}"), 4)
  }

  func testThrowStatementWithTrailingClosure() {
    XCTAssertEqual(getNCSS(for: "throw foo { }"), 1)
    XCTAssertEqual(getNCSS(for: "throw foo { a in }"), 1)
    XCTAssertEqual(getNCSS(for: "throw foo { a;b;c}"), 4)
    XCTAssertEqual(getNCSS(for: "throw foo { a in a;b;c}"), 4)
  }

  func testSingleLineDeclarations() {
    XCTAssertEqual(getNCSS(for: "let a = 1"), 1)
    XCTAssertEqual(getNCSS(for: "var a = 1"), 1)
    XCTAssertEqual(getNCSS(for: "import foo"), 1)
    XCTAssertEqual(getNCSS(for: "prefix operator <!>"), 1)
    XCTAssertEqual(getNCSS(for: "typealias Foo = Bar"), 1)
  }

  func testClassDeclaration() {
    XCTAssertEqual(getNCSS(for: "class foo {}"), 1)
    XCTAssertEqual(getNCSS(for: "class foo { let a = 1 }"), 2)
    XCTAssertEqual(getNCSS(for: "class foo { let a = 1\nfunc bar() {} }"), 3)
    XCTAssertEqual(getNCSS(for: "class foo {\n#if blah\nlet a = 1\n#endif}"), 2)
  }

  func testInitAndDeinitDeclarations() {
    XCTAssertEqual(getNCSS(for: "init() {}"), 1)
    XCTAssertEqual(getNCSS(for: "init() { let a = 1 }"), 2)
    XCTAssertEqual(getNCSS(for: "init() { let a = 1\nfunc bar() {} }"), 3)
    XCTAssertEqual(getNCSS(for: "deinit {}"), 1)
    XCTAssertEqual(getNCSS(for: "deinit { let a = 1 }"), 2)
    XCTAssertEqual(getNCSS(for: "deinit { let a = 1\nfunc bar() {} }"), 3)
  }

  func testEnumDeclaration() {
    XCTAssertEqual(getNCSS(for: "enum foo {}"), 1)
    XCTAssertEqual(getNCSS(for: "enum foo { let a = 1 }"), 2)
    XCTAssertEqual(getNCSS(for: "enum foo { let a = 1\nfunc bar() {} }"), 3)
    XCTAssertEqual(getNCSS(for: "enum foo { case a }"), 2)
    XCTAssertEqual(getNCSS(for: "enum foo { case a, b }"), 2)
    XCTAssertEqual(getNCSS(for: "enum foo { case a, b\ncase c }"), 3)
    XCTAssertEqual(getNCSS(for: "enum foo: Int { case a = 1 }"), 2)
    XCTAssertEqual(getNCSS(for: "enum foo: Int { case a = 1, b }"), 2)
    XCTAssertEqual(getNCSS(for: "enum foo: Int { case a = 1, b\ncase c }"), 3)
    XCTAssertEqual(getNCSS(for: "enum foo {\n#if blah\nlet a = 1\n#endif}"), 2)
  }

  func testExtensionDeclaration() {
    XCTAssertEqual(getNCSS(for: "extension foo {}"), 1)
    XCTAssertEqual(getNCSS(for: "extension foo { let a = 1 }"), 2)
    XCTAssertEqual(getNCSS(for: "extension foo { let a = 1\nfunc bar() {} }"), 3)
    XCTAssertEqual(getNCSS(for: "extension foo {\n#if blah\nlet a = 1\n#endif}"), 2)
  }

  func testFunctionDeclaration() {
    XCTAssertEqual(getNCSS(for: "func foo()"), 1)
    XCTAssertEqual(getNCSS(for: "func foo() {}"), 1)
    XCTAssertEqual(getNCSS(for: "func foo() { let a = 1 }"), 2)
    XCTAssertEqual(getNCSS(for: "func foo() { let a = 1\nfunc bar() {} }"), 3)
  }

  func testPrecedenceGroupDeclaration() {
    XCTAssertEqual(getNCSS(for: "precedencegroup foo {}"), 1)
    XCTAssertEqual(getNCSS(for: "precedencegroup foo {\nhigherThan: bar\n}"), 2)
    XCTAssertEqual(getNCSS(for: "precedencegroup foo {\nhigherThan: bar\nassociativity: none\n}"), 3)
  }

  func testProtocolDeclaration() {
    XCTAssertEqual(getNCSS(for: "protocol foo {}"), 1)
    XCTAssertEqual(getNCSS(for: "protocol foo { var a: Int { get } }"), 2)
    XCTAssertEqual(getNCSS(for: "protocol foo { var a: Int { get } func bar() }"), 3)
    XCTAssertEqual(getNCSS(for: "protocol foo {\n#if blah\nvar a: Int { get }\n#endif}"), 2)
  }

  func testStructDeclaration() {
    XCTAssertEqual(getNCSS(for: "struct foo {}"), 1)
    XCTAssertEqual(getNCSS(for: "struct foo { let a = 1 }"), 2)
    XCTAssertEqual(getNCSS(for: "struct foo { let a = 1\nfunc bar() {} }"), 3)
    XCTAssertEqual(getNCSS(for: "struct foo {\n#if blah\nlet a = 1\n#endif}"), 2)
  }

  func testSubscriptDeclaration() {
    XCTAssertEqual(getNCSS(for: "subscript() -> Self {}"), 1)
    XCTAssertEqual(getNCSS(for: "subscript() -> Self { let a = 1 }"), 2)
    XCTAssertEqual(getNCSS(for: "subscript() -> Self { let a = 1\nfunc bar() {} }"), 3)
    XCTAssertEqual(getNCSS(for: "subscript() -> Self { get { return _foo } }"), 3)
    XCTAssertEqual(getNCSS(for: "subscript() -> Self { get { let a = 1;return _foo } }"), 4)
    XCTAssertEqual(getNCSS(for: "subscript() -> Self { get { return _foo } set { _foo = newValue } }"), 5)
    XCTAssertEqual(getNCSS(for: "subscript() -> Self { get { return _foo } set { let a = 1; _foo = newValue } }"), 6)
    XCTAssertEqual(getNCSS(for: "subscript() -> Self { get }"), 2)
    XCTAssertEqual(getNCSS(for: "subscript() -> Self { get set }"), 3)
  }

  func testConstantAndVariableDeclarations() {
    XCTAssertEqual(getNCSS(for: "let a = foo { }"), 1)
    XCTAssertEqual(getNCSS(for: "let a, b"), 1)
    XCTAssertEqual(getNCSS(for: "let a = foo { }, b"), 1)
    XCTAssertEqual(getNCSS(for: "let a = foo { }, b = bar {}"), 1)
    XCTAssertEqual(getNCSS(for: "let a = foo { a in }"), 1)
    XCTAssertEqual(getNCSS(for: "let a = foo { f }, b"), 2)
    XCTAssertEqual(getNCSS(for: "let a, b = foo { f }"), 2)
    XCTAssertEqual(getNCSS(for: "let a = foo { f }, b = bar { b }"), 3)
    XCTAssertEqual(getNCSS(for: "let a = foo { a;b;c}"), 4)
    XCTAssertEqual(getNCSS(for: "let a = foo { a in a;b;c}"), 4)
    XCTAssertEqual(getNCSS(for: "var a = foo { }"), 1)
    XCTAssertEqual(getNCSS(for: "var a, b"), 1)
    XCTAssertEqual(getNCSS(for: "var a = foo { }, b"), 1)
    XCTAssertEqual(getNCSS(for: "var a = foo { }, b = bar {}"), 1)
    XCTAssertEqual(getNCSS(for: "var a = foo { a in }"), 1)
    XCTAssertEqual(getNCSS(for: "var a = foo { f }, b"), 2)
    XCTAssertEqual(getNCSS(for: "var a, b = foo { f }"), 2)
    XCTAssertEqual(getNCSS(for: "var a = foo { f }, b = bar { b }"), 3)
    XCTAssertEqual(getNCSS(for: "var a = foo { a;b;c}"), 4)
    XCTAssertEqual(getNCSS(for: "var a = foo { a in a;b;c}"), 4)
    XCTAssertEqual(getNCSS(for: "var a: Foo { let a = 1 }"), 2)
    XCTAssertEqual(getNCSS(for: "var a: Foo { let a = 1\nfunc bar() {} }"), 3)
    XCTAssertEqual(getNCSS(for: "var a: Foo { get { return _foo } }"), 3)
    XCTAssertEqual(getNCSS(for: "var a: Foo { get { let a = 1;return _foo } }"), 4)
    XCTAssertEqual(getNCSS(for: "var a: Foo { get { return _foo } set { _foo = newValue } }"), 5)
    XCTAssertEqual(getNCSS(for: "var a: Foo { get { return _foo } set { let a = 1; _foo = newValue } }"), 6)
    XCTAssertEqual(getNCSS(for: "var a: Foo { get }"), 2)
    XCTAssertEqual(getNCSS(for: "var a: Foo { get set }"), 3)
    XCTAssertEqual(getNCSS(for: "var foo: Foo { willSet { print(newValue) } }"), 3)
    XCTAssertEqual(getNCSS(for: "var foo: Foo { didSet { print(newValue) } }"), 3)
    XCTAssertEqual(getNCSS(for: "var foo: Foo { willSet { print(newValue) } didSet { print(newValue) } }"), 5)
    XCTAssertEqual(getNCSS(for: "var foo = _foo { willSet { print(newValue) } }"), 3)
    XCTAssertEqual(getNCSS(for: "var foo = _foo { didSet { print(newValue) } }"), 3)
    XCTAssertEqual(getNCSS(for: "var foo = _foo { willSet { print(newValue) } didSet { print(newValue) } }"), 5)
    XCTAssertEqual(getNCSS(for: "var foo = _foo { a;b;c } { willSet { print(newValue) } }"), 6)
    XCTAssertEqual(getNCSS(for: "var foo = _foo { a;b;c } { didSet { print(newValue) } }"), 6)
    XCTAssertEqual(getNCSS(for: "var foo = _foo { a;b;c } { willSet { print(newValue) } didSet { print(newValue) } }"), 8)
  }

  private func getNCSS(for content: String) -> Int {
    let source = SourceFile(
      path: "MetricTests/NonCommentingSourceStatementsTests.swift",
      content: content)
    guard let topLevelDecl = try? Parser(source: source).parse() else {
      XCTFail("Failed in parsing content `\(content)`")
      return 0
    }
    return topLevelDecl.ncssCount
  }

  static var allTests = [
    ("testEmptyContent", testEmptyContent),
    ("testSingleLineExpressions", testSingleLineExpressions),
    ("testClosureExpressionsAndRelated", testClosureExpressionsAndRelated),
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
    ("testSingleLineDeclarations", testSingleLineDeclarations),
    ("testClassDeclaration", testClassDeclaration),
    ("testInitAndDeinitDeclarations", testInitAndDeinitDeclarations),
    ("testEnumDeclaration", testEnumDeclaration),
    ("testExtensionDeclaration", testExtensionDeclaration),
    ("testFunctionDeclaration", testFunctionDeclaration),
    ("testPrecedenceGroupDeclaration", testPrecedenceGroupDeclaration),
    ("testProtocolDeclaration", testProtocolDeclaration),
    ("testStructDeclaration", testStructDeclaration),
    ("testSubscriptDeclaration", testSubscriptDeclaration),
    ("testConstantAndVariableDeclarations", testConstantAndVariableDeclarations),
  ]
}
