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

import AST

public class NonCommentingSourceStatements {
  public func calculate(for topLevelDecl: TopLevelDeclaration) -> Int {
    return ncss(topLevelDecl.statements)
  }

  public func calculate(for codeBlock: CodeBlock) -> Int {
    return ncss(codeBlock)
  }

  public func calculate(for stmt: Statement) -> Int {
    return ncss(stmt)
  }

  private func ncss(_ codeBlock: CodeBlock) -> Int {
    return ncss(codeBlock.statements)
  }

  private func ncss(_ stmts: [Statement]) -> Int {
    return stmts.reduce(0) { $0 + ncss($1) }
  }

  private func ncss(_ stmt: Statement) -> Int { // swift-lint:suppress(high_cyclomatic_complexity,high_ncss)
    switch stmt {
    case let deferStmt as DeferStatement:
      return 1 + deferStmt.codeBlock.ncssCount
    case let doStmt as DoStatement:
      return ncss(doStmt)
    case let forStmt as ForInStatement:
      return 1 + forStmt.codeBlock.ncssCount
    case let guardStmt as GuardStatement:
      return 1 + guardStmt.codeBlock.ncssCount
    case let ifStmt as IfStatement:
      return ncss(ifStmt)
    case let labeledStmt as LabeledStatement:
      return ncss(labeledStmt.statement)
    case let repeatWhileStmt as RepeatWhileStatement:
      return 2 + repeatWhileStmt.codeBlock.ncssCount
    case let switchStmt as SwitchStatement:
      return ncss(switchStmt)
    case let whileStmt as WhileStatement:
      return 1 + whileStmt.codeBlock.ncssCount
    case let returnStmt as ReturnStatement:
      return returnStmt.expression.map({ ncss($0) }) ?? 1
    case let throwStmt as ThrowStatement:
      return ncss(throwStmt.expression)
    case let classDecl as ClassDeclaration:
      return ncss(classDecl)
    case let initDecl as InitializerDeclaration:
      return 1 + initDecl.body.ncssCount
    case let deinitDecl as DeinitializerDeclaration:
      return 1 + deinitDecl.body.ncssCount
    case let enumDecl as EnumDeclaration:
      return ncss(enumDecl)
    case let extensionDecl as ExtensionDeclaration:
      return ncss(extensionDecl)
    case let funcDecl as FunctionDeclaration:
      return ncss(funcDecl)
    case let precedenceGroupDecl as PrecedenceGroupDeclaration:
      return 1 + precedenceGroupDecl.attributes.count
    case let protocolDecl as ProtocolDeclaration:
      return ncss(protocolDecl)
    case let structDecl as StructDeclaration:
      return ncss(structDecl)
    case let subscriptDecl as SubscriptDeclaration:
      return ncss(subscriptDecl)
    case let constantDecl as ConstantDeclaration:
      return ncss(constantDecl)
    case let variableDecl as VariableDeclaration:
      return ncss(variableDecl)
    case let expr as Expression:
      return ncss(expr)
    default:
      return 1
    }
  }

  private func ncss(_ doStmt: DoStatement) -> Int {
    return 1 +
      doStmt.codeBlock.ncssCount +
      doStmt.catchClauses.reduce(0) { $0 + 1 + $1.codeBlock.ncssCount }
  }

  private func ncss(_ ifStmt: IfStatement) -> Int {
    return 1 +
      ifStmt.codeBlock.ncssCount +
      (
        ifStmt.elseClause.map({
          switch $0 {
          case .else(let codeBlock):
            return 1 + codeBlock.ncssCount
          case .elseif(let ifStmt):
            return ncss(ifStmt)
          }
        }) ?? 0
      )
  }

  private func ncss(_ switchStmt: SwitchStatement) -> Int {
    return 1 +
      switchStmt.cases.reduce(0) {
        switch $1 {
        case .case(_, let stmts):
          return 1 + ncss(stmts) + $0
        case .default(let stmts):
          return 1 + ncss(stmts) + $0
        }
      }
  }

  private func ncss(_ classDecl: ClassDeclaration) -> Int {
    return 1 + classDecl.members.flatMap { member -> Int? in
      switch member {
      case .declaration(let decl):
        return decl.ncssCount
      default:
        return nil
      }
    }.reduce(0, +)
  }

  private func ncss(_ enumDecl: EnumDeclaration) -> Int {
    return 1 + enumDecl.members.flatMap { member -> Int? in
      switch member {
      case .declaration(let decl):
        return decl.ncssCount
      case .union, .rawValue:
        return 1
      default:
        return nil
      }
    }.reduce(0, +)
  }

  private func ncss(_ extDecl: ExtensionDeclaration) -> Int {
    return 1 + extDecl.members.flatMap { member -> Int? in
      switch member {
      case .declaration(let decl):
        return decl.ncssCount
      default:
        return nil
      }
    }.reduce(0, +)
  }

  private func ncss(_ funcDecl: FunctionDeclaration) -> Int {
    guard let body = funcDecl.body else {
      return 1
    }
    return 1 + body.ncssCount
  }

  private func ncss(_ protocolDecl: ProtocolDeclaration) -> Int {
    return 1 + protocolDecl.members.filter {
      switch $0 {
      case .compilerControl:
        return false
      default:
        return true
      }
    }.count
  }

  private func ncss(_ structDecl: StructDeclaration) -> Int {
    return 1 + structDecl.members.flatMap { member -> Int? in
      switch member {
      case .declaration(let decl):
        return decl.ncssCount
      default:
        return nil
      }
    }.reduce(0, +)
  }

  private func ncss(_ subscriptDecl: SubscriptDeclaration) -> Int {
    let ncssBody: Int
    switch subscriptDecl.body {
    case .codeBlock(let codeBlock):
      ncssBody = codeBlock.ncssCount
    case .getterSetterBlock(let block):
      ncssBody = ncss(block)
    case .getterSetterKeywordBlock(let block):
      ncssBody = ncss(block)
    }
    return 1 + ncssBody
  }

  private func ncss(_ constDecl: ConstantDeclaration) -> Int {
    return 1 + ncss(constDecl.initializerList)
  }

  private func ncss(_ varDecl: VariableDeclaration) -> Int {
    switch varDecl.body {
    case .initializerList(let list):
      return 1 + ncss(list)
    case .codeBlock(_, _, let block):
      return 1 + block.ncssCount
    case .getterSetterBlock(_, _, let block):
      return 1 + ncss(block)
    case .getterSetterKeywordBlock(_, _, let block):
      return 1 + ncss(block)
    case let .willSetDidSetBlock(_, _, expr, block):
      let ncssExpr = expr.map({ ncss($0) - 1 }) ?? 0
      return 1 + ncssExpr + ncss(block)
    }
  }

  private func ncss(_ initList: [PatternInitializer]) -> Int {
    return initList.flatMap({ $0.initializerExpression })
      .map({ ncss($0) - 1 })
      .reduce(0, +)
  }

  private func ncss(_ block: GetterSetterBlock) -> Int {
    let ncssGetter = block.getter.codeBlock.ncssCount + 1
    let ncssSetter = block.setter.map({ $0.codeBlock.ncssCount + 1 }) ?? 0
    return ncssGetter + ncssSetter
  }

  private func ncss(_ block: GetterSetterKeywordBlock) -> Int {
    return 1 + (block.setter == nil ? 0 : 1)
  }

  private func ncss(_ block: WillSetDidSetBlock) -> Int {
    let ncssWillSet = block.willSetClause.map({ $0.codeBlock.ncssCount + 1 }) ?? 0
    let ncssDidSet = block.didSetClause.map({ $0.codeBlock.ncssCount + 1 }) ?? 0
    return ncssWillSet + ncssDidSet
  }

  private func ncss(_ expr: Expression) -> Int { // swift-lint:suppress(nested_code_block_depth)
    class NPathExpressionVisitor : ASTVisitor {
      var _count = 0
      var _isTrailingClosure = false

      func cal(_ expr: Expression) -> Int {
        _count = 0
        _isTrailingClosure = false
        do {
          _ = try traverse(expr)
          if _count == 0 {
            return 1
          }
          return _count
        } catch {
          return 0
        }
      }

      func visit(_ funcCallExpr: FunctionCallExpression) throws -> Bool {
        if funcCallExpr.trailingClosure != nil {
          _isTrailingClosure = true
        }
        return true
      }

      func visit(_ closureExpr: ClosureExpression) throws -> Bool {
        if closureExpr.signature != nil || _isTrailingClosure {
          _count += 1
        }
        _count += CodeBlock(statements: closureExpr.statements ?? []).ncssCount
        _isTrailingClosure = false

        return true
      }
    }

    return NPathExpressionVisitor().cal(expr)
  }
}
