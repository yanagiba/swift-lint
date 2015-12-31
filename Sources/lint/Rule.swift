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

protocol Rule {
    var identifier: String { get }
    var name: String { get }
    var description: String { get }
    var markdown: String { get }

    func emitIssue(issue: Issue)
    func inspect(ast: ASTContext, configurations: [String: AnyObject]?)
}

extension Rule {
    var identifier: String {
        return name.toIdentifier
    }

    var description: String {
        return ""
    }

    var markdown: String {
        return ""
    }

    func emitIssue(issue: Issue) {
        NSNotificationCenter.defaultCenter().postNotificationName(EMIT_ISSUE_NOTIFICATION_NAME, object: issue)
    }
}

private extension String {
    private var toIdentifier: String {
        return self.lowercaseString
            .componentsSeparatedByCharactersInSet(NSCharacterSet.punctuationCharacterSet())
            .joinWithSeparator("")
            .componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            .filter { !$0.isEmpty }
            .joinWithSeparator("_")
    }
}
