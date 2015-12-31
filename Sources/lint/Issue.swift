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

enum IssueType: String {
    case Complexity
    case Size
    case BadPractice
}

enum IssueSeverity: String {
    case Info
    case Normal
    case Critical
}

class Issue { // Since this is going to be posted via NSNotificationCenter, so it cannot be a struct
    let ruleIdentifier: String
    let description: String
    let type: IssueType
    let location: SourceRange
    let severity: IssueSeverity
    let correction: Correction?

    init(ruleIdentifier: String, description: String, type: IssueType, location: SourceRange, severity: IssueSeverity, correction: Correction?) {
        self.ruleIdentifier = ruleIdentifier
        self.description = description
        self.type = type
        self.location = location
        self.severity = severity
        self.correction = correction
    }
}
