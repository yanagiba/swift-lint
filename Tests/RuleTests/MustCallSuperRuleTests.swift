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

class MustCallSuperRuleTests : XCTestCase {
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
      XCTAssertEqual(range.start.path, "test/test")
      XCTAssertEqual(range.start.line, 1)
      XCTAssertEqual(range.start.column, 1)
      XCTAssertEqual(range.end.path, "test/test")
      XCTAssertEqual(range.end.line, 1)
      XCTAssertEqual(range.end.column, testMethod.count+15)
    }
  }

  static var allTests = [
    ("testNotInMethodList", testNotInMethodList),
    ("testMissingOverriden", testMissingOverriden),
    ("testSuperCalled", testSuperCalled),
    ("testMissingSuperCalls", testMissingSuperCalls),
  ]
}
