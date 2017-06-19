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

import Source

extension SourceRange {
  var normalizedLocation: String {
    return "\(normalizedFilePath):\(startLineColumn)-\(endLineColumn)"
  }

  var normalizedFilePath: String {
    let pwd = FileManager.default.currentDirectoryPath
    var filePath = start.path
    if filePath.hasPrefix(pwd) {
      let prefixIndex = filePath.index(filePath.startIndex, offsetBy: pwd.count+1)
      filePath = String(filePath[prefixIndex...])
    }
    return filePath
  }

  var startLineColumn: String {
    return "\(start.line):\(start.column)"
  }

  var endLineColumn: String {
    return "\(end.line):\(end.column)"
  }
}
