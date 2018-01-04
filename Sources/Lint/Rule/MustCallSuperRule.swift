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

import Foundation

import Source
import AST

class MustCallSuperRule : RuleBase, ASTVisitorRule {
  let name = "Must Call Super"
  var description: String? {
    return """
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
    """
  }
  var examples: [String]? {
    return [
      """
      class MyVC : UIViewController {
        override func viewDidLoad() {
          // need to add `super.viewDidLoad()` here
          self.title = "Awesome Title"
        }
      }
      """,
      """
      class MyVCTest : XCTestCase {
        let myVC: MyVC!
        override func setUp() {
          // need to add `super.setUp()` here
          myVC = MyVC()
        }
      }
      """,
    ]
  }
  let severity = Issue.Severity.major
  let category = Issue.Category.cocoa

  private func emitIssue(_ funcDecl: FunctionDeclaration) {
    emitIssue(funcDecl.sourceRange, description: "")
  }

  private func checkAndReturnArguments(
    _ funcDecl: FunctionDeclaration, _ funcName: String
  ) -> FunctionCallExpression.ArgumentList? {
    guard let funcBody = funcDecl.body,
      let funcCallExpr = funcBody.statements.first as? FunctionCallExpression,
      let postfixExpr = funcCallExpr.postfixExpression as? SuperclassExpression,
      case .method(let methodName) = postfixExpr.kind,
      methodName.isSyntacticallyEqual(to: .name(funcName)),
      let arguments = funcCallExpr.argumentClause
    else {
      return nil
    }
    return arguments
  }

  private func checkBody(
    _ funcName: String,
    _ paramName: String?,
    _ funcDecl: FunctionDeclaration
  ) {
    guard let arguments = checkAndReturnArguments(funcDecl, funcName) else {
      emitIssue(funcDecl)
      return
    }

    if let paramName = paramName, arguments.count == 1 {
      switch arguments[0] {
      case .expression where paramName == "_":
        break
      case .namedExpression(let id, _) where id.isSyntacticallyEqual(to: .name(paramName)):
        break
      default:
        emitIssue(funcDecl)
      }
    } else if !arguments.isEmpty {
      emitIssue(funcDecl)
    }
  }

  func isFuncDeclDefMatch(_ funcDecl: FunctionDeclaration) -> Bool {
    return funcDecl.modifiers.contains(.override) &&
      funcDecl.genericParameterClause == nil &&
      funcDecl.genericWhereClause == nil &&
      funcDecl.signature.result == nil &&
      funcDecl.signature.throwsKind == .nothrowing
  }

  func visit(_ funcDecl: FunctionDeclaration) throws -> Bool {
    // TODO: when we can, from current node,
    // retrieve its lexical parent node and semantic parent node
    // we will need to match its base class.

    guard isFuncDeclDefMatch(funcDecl) else {
      return true
    }

    let methodNamesOfInterest = [
      ("viewDidLoad", nil, nil),
      ("viewDidAppear", "_", "Bool"),
      ("viewDidDisappear", "_", "Bool"),
      ("viewWillAppear", "_", "Bool"),
      ("viewWillDisappear", "_", "Bool"),
      ("addChildViewController", "_", "UIViewController"),
      ("removeFromParentViewController", nil, nil),
      ("didReceiveMemoryWarning", nil, nil),
      ("updateConstraints", nil, nil),
      ("invalidateLayout", nil, nil),
      ("invalidateLayout", "with", "UICollectionViewLayoutInvalidationContext"),
      ("setUp", nil, nil),
      ("tearDown", nil, nil),
    ]

    for (funcName, paramName, paramType) in methodNamesOfInterest
      where funcDecl.name.isSyntacticallyEqual(to: .name(funcName))
    {
      if let paramName = paramName, let paramType = paramType {
        let params = funcDecl.signature.parameterList
        if matchParameterList(params: params, paramName: paramName, paramType: paramType) {
          checkBody(funcName, paramName, funcDecl)
        }
      } else if funcDecl.signature.parameterList.isEmpty {
        checkBody(funcName, paramName, funcDecl)
      }
    }

    return true
  }

  private func matchParameterList(
    params: [FunctionSignature.Parameter], paramName: String, paramType: String
  ) -> Bool {
    if
      params.count == 1,
      let paramExtName = params[0].externalName,
      paramExtName.isSyntacticallyEqual(to: paramName == "_" ? .wildcard : .name(paramName)),
      params[0].typeAnnotation.textDescription == ": \(paramType)"
    {
      return true
    }
    return false
  }
}
