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

struct DotYanagibaLint {
  var enableRules: [String]?
  var disableRules: [String]?
  var ruleConfigurations: [String: Any]?
  var reportType: String?
  var outputPath: String?
  var severityThresholds: [String: Int]?
}

extension DotYanagibaLint {
  mutating func merge(with other: DotYanagibaLint) {
    if let otherEnableRules = other.enableRules {
      var mergedEnableRules = enableRules ?? []
      mergedEnableRules += otherEnableRules
      enableRules = Array(Set(mergedEnableRules))
    }
    if let otherDisableRules = other.disableRules {
      var mergedDisableRules = disableRules ?? []
      mergedDisableRules += otherDisableRules
      disableRules = Array(Set(mergedDisableRules))
    }
    if let otherRuleConfigurations = other.ruleConfigurations {
      var mergedRuleConfigurations = ruleConfigurations ?? [:]
      for (key, value) in otherRuleConfigurations {
        mergedRuleConfigurations[key] = value
      }
      ruleConfigurations = mergedRuleConfigurations
    }
    if let otherReportType = other.reportType {
      reportType = otherReportType
    }
    if let otherOutputPath = other.outputPath {
      outputPath = otherOutputPath
    }
    if let otherSeverityThresholds = other.severityThresholds {
      var mergedSeverityThresholds = severityThresholds ?? [:]
      for (key, value) in otherSeverityThresholds {
        mergedSeverityThresholds[key] = value
      }
      severityThresholds = mergedSeverityThresholds
    }
  }
}

struct DotYanagibaLintReader {
  private static func extractLintLines(from content: String) -> [String] {
    var lines = [String]()

    var lintBlock = false
    for line in content.components(separatedBy: "\n") {
      if line.hasPrefix("lint:") {
        lintBlock = true
      } else if line.hasPrefix(" ") {
        if lintBlock {
          let whitespaceRemoved = line.components(separatedBy: .whitespaces).joined()
          lines.append(whitespaceRemoved)
        }
      } else {
        lintBlock = false
      }
    }

    return lines
  }

  private static func extractLintOptions(from lines: [String]) -> [String: [String]] {
    var lintOptions: [String: [String]] = [:]

    var currentKey = ""
    var currentOptions: [String] = []
    for line in lines {
      if line.hasPrefix("-") {
        let option = String(line[line.index(after: line.startIndex)...])
        currentOptions.append(option)
      } else {
        if !currentKey.isEmpty {
          if !currentOptions.isEmpty {
            lintOptions[currentKey] = currentOptions
            currentOptions = []
          }
          currentKey = ""
        }

        let keyValuePair = line.components(separatedBy: ":")
        if keyValuePair.count == 2 {
          let key = keyValuePair[0]
          let value = keyValuePair[1]
          if value.isEmpty {
            currentKey = key
          } else {
            lintOptions[key] = [value]
          }
        }
      }
    }

    if !currentKey.isEmpty && !currentOptions.isEmpty {
      lintOptions[currentKey] = currentOptions
    }

    return lintOptions
  }

  private static func extractKeyValuePair(from options: [String]) -> [String: Int] {
    var dict: [String: Int] = [:]

    for option in options {
      let keyValuePair = option.components(separatedBy: ":")
      if keyValuePair.count == 2, let value = Int(keyValuePair[1]) {
        let key = keyValuePair[0]
        dict[key] = value
      }
    }

    return dict
  }

  static func read(from path: String) -> DotYanagibaLint? {
    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: path),
      let content = try? String(contentsOfFile: path, encoding: .utf8)
    else {
      return nil
    }

    let lines = extractLintLines(from: content)
    let lintOptions = extractLintOptions(from: lines)

    var dotYanagibaLint = DotYanagibaLint()

    for (key, option) in lintOptions {
      switch key {
      case "enable-rules":
        dotYanagibaLint.enableRules = option
      case "diable-rules":
        dotYanagibaLint.disableRules = option
      case "rule-configurations":
        dotYanagibaLint.ruleConfigurations = extractKeyValuePair(from: option)
      case "report-type":
        dotYanagibaLint.reportType = option.first
      case "output-path":
        dotYanagibaLint.outputPath = option.first
      case "severity-thresholds":
        dotYanagibaLint.severityThresholds = extractKeyValuePair(from: option)
      default:
        break
      }
    }

    return dotYanagibaLint
  }
}
