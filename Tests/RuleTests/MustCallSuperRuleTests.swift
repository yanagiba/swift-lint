/*
   Copyright 2017 Ryuichi Laboratories and the Yanagiba project contributors

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

class MustCallSuperRuleTests : XCTestCase {
  func testProperties() {
    let rule = MustCallSuperRule()

    XCTAssertEqual(rule.identifier, "must_call_super")
    XCTAssertEqual(rule.name, "Must Call Super")
    XCTAssertEqual(rule.fileName, "MustCallSuperRule.swift")
    XCTAssertEqual(rule.description, """
      By convention, these overridden cocoa methods should always call super:

      - UIViewController
        - viewDidLoad()
        - viewDidAppear(_:)
        - viewDidDisappear(_:)
        - viewWillAppear(_:)
        - viewWillDisappear(_:)
        - addChildViewController(_:)
        - removeFromParentViewController()
        - didReceiveMemoryWarning()
      - UIView
        - updateConstraints()
      - UICollectionViewLayout
        - invalidateLayout()
        - invalidateLayout(with:)
      - XCTestCase
        - setUp()
        - tearDown()

      Apparently, this is not a comprehensive list.
      More will be added by our contributors in the future.
      The goal is to fully automate this list,
      so pull request is welcomed while we address other priorities.
      """)
    XCTAssertEqual(rule.examples?.count, 2)
    XCTAssertEqual(rule.examples?[0], """
      class MyVC : UIViewController {
        override func viewDidLoad() {
          // need to add `super.viewDidLoad()` here
          self.title = "Awesome Title"
        }
      }
      """)
    XCTAssertEqual(rule.examples?[1], """
      class MyVCTest : XCTestCase {
        let myVC: MyVC!
        override func setUp() {
          // need to add `super.setUp()` here
          myVC = MyVC()
        }
      }
      """)
    XCTAssertNil(rule.thresholds)
    XCTAssertNil(rule.additionalDocument)
    XCTAssertEqual(rule.severity, .major)
    XCTAssertEqual(rule.category, .cocoa)
  }

  func testNotInMethodList() {
    let issues = """
      override func viewDidAppear() {}
      override func viewDidLoad(_: Bool) {}
      override func viewDidLoad() -> Bool {}
      """.inspect(withRule: MustCallSuperRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testMissingOverriden() {
    let issues = "func viewDidAppear(_ animated: Bool) {}".inspect(withRule: MustCallSuperRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testSuperCalled() {
    let issues = """
      override func viewDidLoad() {
        super.viewDidLoad()
      }
      override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      }
      override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
      }
      """.inspect(withRule: MustCallSuperRule())
    XCTAssertTrue(issues.isEmpty)
  }

  func testMissingSuperCalls() {
    let testMethods = [
      "viewDidLoad()",
      "viewDidAppear(_: Bool)",
      "viewDidDisappear(_: Bool)",
      "viewWillAppear(_: Bool)",
      "viewWillDisappear(_: Bool)",
      "addChildViewController(_: UIViewController)",
      "removeFromParentViewController()",
      "didReceiveMemoryWarning()",
      "updateConstraints()",
      "invalidateLayout()",
      "invalidateLayout(with context: UICollectionViewLayoutInvalidationContext)",
      "setUp()",
      "tearDown()",
    ]
    for testMethod in testMethods {
      let issues = "override func \(testMethod)".inspect(withRule: MustCallSuperRule())
      XCTAssertEqual(issues.count, 1)
      let issue = issues[0]
      XCTAssertEqual(issue.ruleIdentifier, "must_call_super")
      XCTAssertEqual(issue.description, "")
      XCTAssertEqual(issue.category, .cocoa)
      XCTAssertEqual(issue.severity, .major)
      let range = issue.location
      XCTAssertEqual(range.start.identifier, "test/test")
      XCTAssertEqual(range.start.line, 1)
      XCTAssertEqual(range.start.column, 1)
      XCTAssertEqual(range.end.identifier, "test/test")
      XCTAssertEqual(range.end.line, 1)
      XCTAssertEqual(range.end.column, testMethod.count+15)
    }
  }

  func testMismatchSuperCalls() {
    let testMethods = [
      """
      override func viewDidLoad() {
        super.viewDidLoad(a, b)
      }
      """,
      """
      override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(&animated)
      }
      """,
      """
      override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(context)
      }
      """,
    ]

    for testMethod in testMethods {
      let issues = testMethod.inspect(withRule: MustCallSuperRule())
      XCTAssertEqual(issues.count, 1)
      let issue = issues[0]
      XCTAssertEqual(issue.ruleIdentifier, "must_call_super")
      XCTAssertEqual(issue.description, "")
      XCTAssertEqual(issue.category, .cocoa)
      XCTAssertEqual(issue.severity, .major)
      let range = issue.location
      XCTAssertEqual(range.start.identifier, "test/test")
      XCTAssertEqual(range.start.line, 1)
      XCTAssertEqual(range.start.column, 1)
      XCTAssertEqual(range.end.identifier, "test/test")
      XCTAssertEqual(range.end.line, 3)
      XCTAssertEqual(range.end.column, 2)
    }
  }

  static var allTests = [
    ("testProperties", testProperties),
    ("testNotInMethodList", testNotInMethodList),
    ("testMissingOverriden", testMissingOverriden),
    ("testSuperCalled", testSuperCalled),
    ("testMissingSuperCalls", testMissingSuperCalls),
    ("testMismatchSuperCalls", testMismatchSuperCalls),
  ]
}
