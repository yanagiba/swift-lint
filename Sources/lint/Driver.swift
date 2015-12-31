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
import parser

public class Driver: NSObject {
    private var _reporter: Reporter
    private var _rules: [Rule]
    private var _outputHandle: NSFileHandle
    private var _isStreamingIssues: Bool

    public init(ruleIdentifiers rules: [String], reportType reporter: String, outputHandle: NSFileHandle, streamingIssues: Bool) {
        switch reporter {
        case "text":
            fallthrough
        default:
            _reporter = TextReporter()
        }
        _rules = []
        _outputHandle = outputHandle
        _isStreamingIssues = streamingIssues

        super.init()

        registerRule(NoForceCastRule(), ruleIdentifiers: rules)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleIssueNotification:", name:EMIT_ISSUE_NOTIFICATION_NAME, object: nil)
    }

    public convenience override init() {
        self.init(ruleIdentifiers: [], reportType: "text", outputHandle: NSFileHandle.fileHandleWithStandardOutput(), streamingIssues: false)
    }


    func setReporter(reporter: Reporter) {
        _reporter = reporter
    }

    func registerRule(rule: Rule, ruleIdentifiers rules: [String]) {
        if rules.contains(rule.identifier) {
            _rules.append(rule)
        }
    }

    func updateOutputHandle(outputHandle: NSFileHandle) {
        _outputHandle = outputHandle
    }

    func updateStreamingIssueSetting(streamingIssues: Bool) {
        _isStreamingIssues = streamingIssues
    }

    public func lint(sourceFiles: [SourceFile]) {
        if !_isStreamingIssues {
            _outputHandle.puts(_reporter.header(), separator: _reporter.separator())
            _outputHandle.puts("", separator: _reporter.separator())
        }

        let parser = Parser()
        for sourceFile in sourceFiles {
            let (astContext, _) = parser.parse(sourceFile) // Ignore the errors for now

            for rule in _rules {
                rule.inspect(astContext, configurations: nil)
            }
        }

        if !_isStreamingIssues {
            _outputHandle.puts("", separator: _reporter.separator())
            _outputHandle.puts(_reporter.footer(), separator: _reporter.separator())
        }
    }

    func handleIssueNotification(notification: NSNotification) {
        if let issue = notification.object as? Issue {
            _outputHandle.puts(_reporter.handleIssue(issue), separator: _reporter.separator())
        }
    }

}

private extension NSFileHandle {
    func puts(str: String, separator: String = "\n") {
        if let strData = "\(str)\(separator)".dataUsingEncoding(NSUTF8StringEncoding) {
            writeData(strData)
        }
    }
}
