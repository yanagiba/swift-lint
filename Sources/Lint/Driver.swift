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
import Parser

public class Driver: NSObject {
  private var _reporter: Reporter
  private var _rules: [Rule]
  private var _outputHandle: FileHandle

  public init(
    ruleIdentifiers rules: [String] = [],
    reportType reporter: String = "text",
    outputHandle: FileHandle = .standardOutput
  ) {
    switch reporter {
    case "text":
      fallthrough
    default:
      _reporter = TextReporter()
    }
    _rules = []
    _outputHandle = outputHandle

    super.init()

    registerRule(NoForceCastRule(), ruleIdentifiers: rules)
  }


  func setReporter(_ reporter: Reporter) {
    _reporter = reporter
  }

  func registerRule(_ rule: Rule, ruleIdentifiers rules: [String]) {
    if rules.contains(rule.identifier) {
      _rules.append(rule)
    }
  }

  func updateOutputHandle(_ outputHandle: FileHandle) {
    _outputHandle = outputHandle
  }

  @discardableResult public func lint(
    sourceFiles: [SourceFile],
    ruleConfigurations: [String: Any]? = nil
  ) -> Int32 {
    IssuePool.shared.clearIssues()

    _outputHandle.puts(_reporter.header(), separator: _reporter.separator())
    _outputHandle.puts("", separator: _reporter.separator())

    for sourceFile in sourceFiles {
      let parser = Parser(source: sourceFile)
      guard let result = try? parser.parse() else {
        print("Failed in parsing file \(sourceFile.path)")
        // Ignore the errors for now
        return -2
      }

      let astContext =
        ASTContext(sourceFile: sourceFile, topLevelDeclaration: result)

      for rule in _rules {
        rule.inspect(astContext, configurations: ruleConfigurations)
      }
    }

    for issue in IssuePool.shared.issues {
      _outputHandle.puts(
        _reporter.handle(issue: issue), separator: _reporter.separator())
    }

    _outputHandle.puts("", separator: _reporter.separator())
    _outputHandle.puts(_reporter.footer(), separator: _reporter.separator())

    return 0
  }
}

private extension FileHandle {
  func puts(_ str: String, separator: String = "\n") {
    if let strData = "\(str)\(separator)".data(using: .utf8) {
      write(strData)
    }
  }
}
