/*
   Copyright 2015-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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
import Lint

var filePaths = CommandLine.arguments
filePaths.remove(at: 0)

var sourceFiles = [SourceFile]()
for filePath in filePaths {
  guard let sourceFile = try? SourceReader.read(at: filePath) else {
    print("Can't read file \(filePath)")
    exit(-1)
  }
  sourceFiles.append(sourceFile)
}

let driver = Driver(ruleIdentifiers: [
  "no_force_cast", // TODO: need better approach
  "no_forced_try",
  "high_cyclomatic_complexity",
  "high_npath_complexity",
  "high_ncss",
  "nested_code_block_depth",
  "remove_get_for_readonly_computed_property",
  "redundant_initialization_to_nil",
  "redundant_if_statement",
  "redundant_conditional_operator",
  "constant_if_statement_condition",
  "constant_guard_statement_condition",
  "constant_conditional_operator",
  "inverted_logic",
])
let exitCode = driver.lint(sourceFiles: sourceFiles)
exit(exitCode)
