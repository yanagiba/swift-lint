/*
   Copyright 2017 Ryuichi Laboratories and the Yanagiba project contributors

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

struct IssueSummary {
  private let issues: [Issue]

  init(issues: [Issue]) {
    self.issues = issues
  }

  var numberOfIssues: Int {
    return issues.count
  }

  var numberOfFiles: Int {
    let filePaths = issues.map({ $0.location.start.identifier })
    let uniqueFilePaths = Set(filePaths)
    return uniqueFilePaths.count
  }

  func numberOfIssues(withSeverity severity: Issue.Severity) -> Int {
    return issues.filter({ $0.severity == severity }).count
  }
}
