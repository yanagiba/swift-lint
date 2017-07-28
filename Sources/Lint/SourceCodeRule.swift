/*
   Copyright 2015 Ryuichi Laboratories and the Yanagiba project contributors

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
import Source

protocol SourceCodeRule : Rule {
  func inspect(line: String, lineNumber: Int)
}

extension SourceCodeRule where Self : RuleBase {
  private var lines: [String] {
    guard let astContext = astContext else {
      return []
    }

    return astContext.sourceFile.content.components(separatedBy: .newlines)
  }

  func inspect(_ astContext: ASTContext, configurations: [String: Any]? = nil) {
    self.astContext = astContext
    self.configurations = configurations

    for (lineNumber, line) in lines.enumerated() {
      inspect(line: line, lineNumber: lineNumber + 1)
    }
  }

  func emitIssue(
    _ lineNumber: Int,
    description: String,
    correction: Correction? = nil
  ) {
    guard lineNumber > 0 && lineNumber <= lines.count, let path = astContext?.sourceFile.identifier else {
      return
    }

    let lineIndex = lineNumber - 1
    let line = lines[lineIndex]
    let sourceRange = SourceRange(
      start: SourceLocation(identifier: path, line: lineNumber, column: 1),
      end: SourceLocation(identifier: path, line: lineNumber, column: line.count))
    emitIssue(sourceRange, description: description, correction: correction)
  }
}
