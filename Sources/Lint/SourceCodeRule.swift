/*
   Copyright 2015 Ryuichi Saito, LLC and the Yanagiba project contributors

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
  func inspect(_ astContext: ASTContext, configurations: [String: Any]? = nil) {
    self.astContext = astContext
    self.configurations = configurations

    let sourceContent = astContext.sourceFile.content

    let lines = sourceContent.components(separatedBy: .newlines)
    for (lineNumber, line) in lines.enumerated() {
        inspect(line: line, lineNumber: lineNumber + 1)
    }
  }
}
