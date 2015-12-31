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

import source

class TextReporter: Reporter {
    func handleIssue(issue: Issue) -> String {
        return "\(issue.location.toText): warning: \(issue.description)"
                                        // ^ this format can be used in Xcode directly
    }

    func header() -> String {
        return "Swift Lint Report"
    }

    func footer() -> String {
        return "[Swift Lint (http://swiftlint.org) v\(SWIFT_LINT_VERSION)]"
    }

    func separator() -> String {
        return "\n"
    }
}

private extension SourceLocation {
    var toText: String {
        return "\(path):\(line):\(column)"
    }
}

private extension SourceRange {
    var toText: String {
        return "\(start.toText)"
    }
}
