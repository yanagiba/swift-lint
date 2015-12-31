/*
   Copyright 2015 Ryuichi Saito, LLC

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

import ast
import source

class SourceCodeRule {
    var sourceFile: SourceFile!
    var configurations: [String: AnyObject]?

    func inspect(line: String, lineNumber: Int) {
        // Do nothing here, waiting for subclass to override
    }
}

extension Rule where Self: SourceCodeRule {
    func inspect(ast: ASTContext, configurations: [String: AnyObject]? = nil) {
        self.sourceFile = ast.source
        self.configurations = configurations

        let sourceContent = sourceFile.content

        let lines = sourceContent.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        for (lineNumber, line) in lines.enumerate() {
            inspect(line, lineNumber: lineNumber + 1)
        }
    }
}
