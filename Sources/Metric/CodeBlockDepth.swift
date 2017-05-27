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

import Foundation

import AST

public class CodeBlockDepth {
  public func calculate(for codeBlock: CodeBlock) -> Int {
    return depth(codeBlock)
  }

  private func depth(_ stmt: Statement) -> Int {
    switch stmt {
    case let deferStmt as DeferStatement:
      return deferStmt.codeBlock.depth
    case let doStmt as DoStatement:
      return depth(doStmt)
    case let forStmt as ForInStatement:
      return forStmt.codeBlock.depth
    case let guardStmt as GuardStatement:
      return guardStmt.codeBlock.depth
    case let ifStmt as IfStatement:
      return depth(ifStmt)
    case let labeledStmt as LabeledStatement:
      return depth(labeledStmt.statement)
    case let repeatWhileStmt as RepeatWhileStatement:
      return repeatWhileStmt.codeBlock.depth
    case let switchStmt as SwitchStatement:
      return depth(switchStmt)
    case let whileStmt as WhileStatement:
      return whileStmt.codeBlock.depth
    case let returnStmt as ReturnStatement:
      return returnStmt.expression.map({ depth($0) }) ?? 1
    case let throwStmt as ThrowStatement:
      return depth(throwStmt.expression)
    case let classDecl as ClassDeclaration:
      return depth(classDecl)
    case let initDecl as InitializerDeclaration:
      return depth(initDecl.body)
    case let deinitDecl as DeinitializerDeclaration:
      return depth(deinitDecl.body)
    case let enumDecl as EnumDeclaration:
      return depth(enumDecl)
    case let extensionDecl as ExtensionDeclaration:
      return depth(extensionDecl)
    case let funcDecl as FunctionDeclaration:
      return funcDecl.body.map({ depth($0) }) ?? 1
    case let precedenceGroupDecl as PrecedenceGroupDeclaration:
      return 1 + (precedenceGroupDecl.attributes.isEmpty ? 0 : 1)
    case let protocolDecl as ProtocolDeclaration:
      return depth(protocolDecl)
    case let structDecl as StructDeclaration:
      return depth(structDecl)
    case let subscriptDecl as SubscriptDeclaration:
      return depth(subscriptDecl)
    case let constantDecl as ConstantDeclaration:
      return depth(constantDecl)
    case let variableDecl as VariableDeclaration:
      return depth(variableDecl)
    case let expr as Expression:
      return depth(expr)
    default:
      return 1
    }
  }

  private func depth(_ classDecl: ClassDeclaration) -> Int {
    return 1 + classDecl.members.flatMap { member -> Int? in
      switch member {
      case .declaration(let decl):
        return depth(decl)
      default:
        return nil
      }
    }.reduce(0, max)
  }

  private func depth(_ enumDecl: EnumDeclaration) -> Int {
    return 1 + enumDecl.members.flatMap { member -> Int? in
      switch member {
      case .declaration(let decl):
        return depth(decl)
      case .union, .rawValue:
        return 1
      default:
        return nil
      }
    }.reduce(0, max)
  }

  private func depth(_ extDecl: ExtensionDeclaration) -> Int {
    return 1 + extDecl.members.flatMap { member -> Int? in
      switch member {
      case .declaration(let decl):
        return depth(decl)
      default:
        return nil
      }
    }.reduce(0, max)
  }

  private func depth(_ protocolDecl: ProtocolDeclaration) -> Int {
    return 1 + (protocolDecl.members.isEmpty ? 0 : 1)
  }

  private func depth(_ structDecl: StructDeclaration) -> Int {
    return 1 + structDecl.members.flatMap { member -> Int? in
      switch member {
      case .declaration(let decl):
        return depth(decl)
      default:
        return nil
      }
    }.reduce(0, max)
  }

  private func depth(_ doStmt: DoStatement) -> Int {
    return doStmt.catchClauses.reduce(doStmt.codeBlock.depth) { max($0, $1.codeBlock.depth) }
  }

  private func depth(_ ifStmt: IfStatement) -> Int {
    let depthCodeBlock = ifStmt.codeBlock.depth
    let depthElseClause = ifStmt.elseClause.map({
      switch $0 {
      case .else(let codeBlock):
        return codeBlock.depth
      case .elseif(let ifStmt):
        return depth(ifStmt)
      }
    }) ?? 0
    return max(depthCodeBlock, depthElseClause)
  }

  private func depth(_ switchStmt: SwitchStatement) -> Int {
    return 1 + switchStmt.cases.reduce(0) {
      switch $1 {
      case .case(_, let stmts):
        return stmts.reduce(2) { max($0, 1 + depth($1)) }
      case .default(let stmts):
        return stmts.reduce(2) { max($0, 1 + depth($1)) }
      }
    }
  }

  private func depth(_ subscriptDecl: SubscriptDeclaration) -> Int {
    switch subscriptDecl.body {
    case .codeBlock(let block):
      return block.depth
    case .getterSetterBlock(let block):
      return depth(block)
    case .getterSetterKeywordBlock:
      return 2
    }
  }

  private func depth(_ constDecl: ConstantDeclaration) -> Int {
    return 1 + depth(constDecl.initializerList)
  }

  private func depth(_ varDecl: VariableDeclaration) -> Int {
    switch varDecl.body {
    case .initializerList(let list):
      return 1 + depth(list)
    case .codeBlock(_, _, let block):
      return block.depth
    case .getterSetterBlock(_, _, let block):
      return depth(block)
    case .getterSetterKeywordBlock:
      return 2
    case .willSetDidSetBlock(_, _, _, let block):
      return depth(block)
    }
  }

  private func depth(_ initList: [PatternInitializer]) -> Int {
    return initList.flatMap({ $0.initializerExpression })
      .map({ depth($0) - 1 })
      .reduce(0, max)
  }

  private func depth(_ codeBlock: CodeBlock) -> Int {
    return 1 + codeBlock.statements.reduce(0) { max($0, depth($1)) }
  }

  private func depth(_ block: GetterSetterBlock) -> Int {
    let depthGetter = 1 + depth(block.getter.codeBlock)
    let depthSetter = block.setter.map({ 1 + $0.codeBlock.depth }) ?? 0
    return max(depthGetter, depthSetter)
  }

  private func depth(_ block: WillSetDidSetBlock) -> Int {
    let depthWillSet = block.willSetClause.map({ 1 + $0.codeBlock.depth }) ?? 0
    let depthDidSet = block.didSetClause.map({ 1 + $0.codeBlock.depth }) ?? 0
    return max(depthWillSet, depthDidSet)
  }

  private func depth(_ expr: Expression) -> Int {
    class DepthExpressionVisitor : ASTVisitor {
      var _depth = 1

      func cal(_ expr: Expression) -> Int {
        _depth = 1
        do {
          _ = try traverse(expr)
          return _depth
        } catch {
          return 0
        }
      }

      func visit(_ closureExpr: ClosureExpression) throws -> Bool {
        if closureExpr.signature != nil {
          _depth = max(_depth, 2)
        }
        let block = CodeBlock(statements: closureExpr.statements ?? [])
        _depth = max(_depth, block.depth)

        return true
      }
    }

    return DepthExpressionVisitor().cal(expr)
  }
}
