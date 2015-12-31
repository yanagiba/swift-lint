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

import ast
import parser
import source

class ASTVisitorRule {
    var astContext: ASTContext!
    var configurations: [String: AnyObject]?

    func inspect(statement: Statement) {
        // Do nothing here, waiting for subclass to override.
        // TODO: This currently does not follow visitor pattern yet.
    }
}

extension Rule where Self: ASTVisitorRule {
    func inspect(ast: ASTContext, configurations: [String: AnyObject]? = nil) {
        self.astContext = ast
        self.configurations = configurations

        let statements = astContext.topLevelDeclaration.statements
        for statement in statements {
            inspect(statement)
        }
    }
}
