/*
   Copyright 2015-2017 Ryuichi Laboratories and the Yanagiba project contributors

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

public class Driver {
  private var _reporter: Reporter
  private var _rules: [Rule]
  private var _outputHandle: FileHandle

  public init(
    ruleIdentifiers rules: [String] = [],
    reportType: String = "text",
    outputHandle: FileHandle = .standardOutput
  ) {
    _reporter = TextReporter()
    _rules = []
    _outputHandle = outputHandle

    setReporter(with: reportType)
    registerRules(basedOn: rules)
  }

  private func setReporter(with type: String) {
    let reporter: Reporter
    switch type {
    case "html":
      reporter = HTMLReporter()
    case "json":
      reporter = JSONReporter()
    case "pmd":
      reporter = PMDReporter()
    case "xcode":
      reporter = XcodeReporter()
    default:
      reporter = TextReporter()
    }
    setReporter(reporter)
  }

  func setReporter(_ reporter: Reporter) {
    _reporter = reporter
  }

  func registerRules(basedOn ruleIdentifiers: [String]) {
    registerRules(RuleSet.rules, ruleIdentifiers: ruleIdentifiers)
  }

  func registerRules(_ rules: [Rule], ruleIdentifiers: [String]) {
    for rule in rules {
      registerRule(rule, ruleIdentifiers: ruleIdentifiers)
    }
  }

  func registerRule(_ rule: Rule, ruleIdentifiers: [String]) {
    if ruleIdentifiers.contains(rule.identifier) {
      _rules.append(rule)
    }
  }

  func updateOutputHandle(_ outputHandle: FileHandle) {
    _outputHandle = outputHandle
  }

  @discardableResult public func lint(
    sourceFiles: [SourceFile],
    ruleConfigurations: [String: Any]? = nil,
    severityThresholds: [String: Int]? = nil
  ) -> ExitStatus {
    IssuePool.shared.clearIssues()

    for sourceFile in sourceFiles {
      let parser = Parser(source: sourceFile)
      guard let result = try? parser.parse() else {
        print("Failed in parsing file \(sourceFile.identifier)")
        // Ignore the errors for now
        return .failedInParsingFile
      }

      let astContext =
        ASTContext(sourceFile: sourceFile, topLevelDeclaration: result)

      for rule in _rules {
        rule.inspect(astContext, configurations: ruleConfigurations)
      }
    }

    let issues = IssuePool.shared.issues

    renderReport(issues, sourceFiles.count)

    return IssueSummary(issues: issues)
      .exitCode(withSeverityThresholds: severityThresholds)
  }

  private func renderReport(_ issues: [Issue], _ numberOfTotalFiles: Int) {
    let issueSummary = IssueSummary(issues: issues)

    let headerOutput = _reporter.header
    if !headerOutput.isEmpty {
      _outputHandle.puts(headerOutput, separator: _reporter.separator)
      _outputHandle.puts("", separator: _reporter.separator)
    }

    let summaryOutput = _reporter.handle(
      numberOfTotalFiles: numberOfTotalFiles,
      issueSummary: issueSummary)
    if !summaryOutput.isEmpty {
      _outputHandle.puts(summaryOutput, separator: _reporter.separator)
      _outputHandle.puts("", separator: _reporter.separator)
    }

    _outputHandle.puts(
      _reporter.handle(issues: issues), separator: _reporter.separator)

    let footerOutput = _reporter.footer
    if !footerOutput.isEmpty {
      _outputHandle.puts("", separator: _reporter.separator)
      _outputHandle.puts(footerOutput, separator: _reporter.separator)
    }
  }
}

public enum ExitStatus : Int32 {
  case success = 0
  case failedInParsingFile = -10
  case tooManyIssues = -20
}

private extension IssueSummary {
  func exitCode(withSeverityThresholds thresholds: [String: Int]?) -> ExitStatus {
    let defaultThresholds: [Issue.Severity: Int] = [
      .critical: 0,
      .major: 10,
      .minor: 20,
      .cosmetic: 50,
    ]

    func threshold(for severity: Issue.Severity) -> Int {
      if let thresholds = thresholds, let threshold = thresholds[severity.rawValue] {
        return threshold
      }
      return defaultThresholds[severity] ?? 0
    }

    for (severity, _) in defaultThresholds {
      if numberOfIssues(withSeverity: severity) > threshold(for: severity) {
        return .tooManyIssues
      }
    }

    return .success
  }
}

private extension FileHandle {
  func puts(_ str: String, separator: String = "\n") {
    if let strData = "\(str)\(separator)".data(using: .utf8) {
      write(strData)
    }
  }
}
