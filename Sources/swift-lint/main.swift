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

import Commander
import PathKit

import source
import lint

command(
  Option("report-type", "text", description: "Change output report type"),
  Flag("streaming", description: "Enable streaming outputs immediately when issues are emitted"),
  VaradicArgument<String>("<file paths>")
) { reportType, streaming, filePaths in
  var sourceFiles = [SourceFile]()
  for filePath in filePaths {
    let absolutePath = Path(filePath).absolute()

    guard let fileContent = try? absolutePath.read(NSUTF8StringEncoding) else {
      print("Error in reading file \(absolutePath)")
      continue
    }

    let sourceFile = SourceFile(path: "\(absolutePath)", content: fileContent)
    sourceFiles.append(sourceFile)
  }

  let driver = Driver(
    ruleIdentifiers: ["no_force_cast"],
    reportType: reportType,
    outputHandle: NSFileHandle.fileHandleWithStandardOutput(),
    streamingIssues: streaming)
  driver.lint(sourceFiles)
}.run(SWIFT_LINT_VERSION)
