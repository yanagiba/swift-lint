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

import source

class NoForceCastRule: SourceCodeRule, Rule {
    var name: String {
        return "No Force Cast"
    }

    override func inspect(line: String, lineNumber: Int) {
        var remainingLine = line
        var startIndex = 0
        var (contains, start, length) = remainingLine.contains("as!")
        while contains {
            let foundIssue = Issue(
                ruleIdentifier: identifier,
                description: "having force cast in line `\(line)` is dangerous",
                type: .BadPractice,
                location: SourceRange(
                    start: SourceLocation(path: sourceFile.path, line: lineNumber, column: 1 + startIndex + start),
                    end: SourceLocation(path: sourceFile.path, line: lineNumber, column: 1 + startIndex + start + length)),
                severity: .Normal,
                correction: nil)
            emitIssue(foundIssue)

            remainingLine = line[line.startIndex.advancedBy(startIndex + start + length)..<line.endIndex]
            startIndex += start + length
            (contains, start, length) = remainingLine.contains("as!")
        }
    }
}

private extension String {
    func contains(find: String) -> (Bool, Int, Int) {
        let range = NSString(string: self).rangeOfString(find)
        if range.location == NSNotFound {
            return (false, 0, 0)
        }
        else {
            return (true, range.location, range.length)
        }
    }
}
