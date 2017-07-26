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

import Foundation

import Lint

func computeEnabledRules(
  _ dotYanagibaLint: DotYanagibaLint?,
  _ enableRulesOption: String?,
  _ disableRulesOption: String?
) -> [String] {
  var enabledRules = RuleSet.ruleIdentifiers
  if let dotYanagibaLint = dotYanagibaLint, let enableRules = dotYanagibaLint.enableRules {
    enabledRules = enableRules
  }
  if let enableRulesOption = enableRulesOption {
    enabledRules = enableRulesOption.components(separatedBy: ",")
  }
  if let disableRulesOption = disableRulesOption {
    let disabledRuleIdentifiers = disableRulesOption.components(separatedBy: ",")
    enabledRules = enabledRules.filter({ !disabledRuleIdentifiers.contains($0) })
  } else if let disabledRuleIdentifiers = dotYanagibaLint?.disableRules {
    enabledRules = enabledRules.filter({ !disabledRuleIdentifiers.contains($0) })
  }
  return enabledRules
}

func computeRuleConfigurations(
  _ dotYanagibaLint: DotYanagibaLint?,
  _ ruleConfigurationsOption: [String: Any]?
) -> [String: Any]? {
  var ruleConfigurations: [String: Any]?
  if let dotYanagibaLint = dotYanagibaLint, let customRuleConfigurations = dotYanagibaLint.ruleConfigurations {
    ruleConfigurations = customRuleConfigurations
  }
  if let customRuleConfigurations = ruleConfigurationsOption {
    ruleConfigurations = customRuleConfigurations
  }
  return ruleConfigurations
}

func computeReportType(
  _ dotYanagibaLint: DotYanagibaLint?,
  _ reportTypeOption: String?
) -> String {
  var reportType = "text"
  if let dotYanagibaLint = dotYanagibaLint, let reportTypeOption = dotYanagibaLint.reportType {
    reportType = reportTypeOption
  }
  if let reportTypeOption = reportTypeOption {
    reportType = reportTypeOption
  }
  return reportType
}

func computeOutputHandle(
  _ dotYanagibaLint: DotYanagibaLint?,
  _ outputPathOption: String?
) -> FileHandle {
  var outputPath: String?
  if let dotYanagibaLint = dotYanagibaLint, let outputPathOption = dotYanagibaLint.outputPath {
    outputPath = outputPathOption
  }
  if let outputPathOption = outputPathOption {
    outputPath = outputPathOption
  }

  var outputHandle: FileHandle = .standardOutput
  if let outputPath = outputPath {
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: outputPath) {
      _ = try? "".write(toFile: outputPath, atomically: true, encoding: .utf8)
    } else {
      _ = fileManager.createFile(atPath: outputPath, contents: nil)
    }
    if let fileHandle = FileHandle(forWritingAtPath: outputPath) {
      outputHandle = fileHandle
    }
  }
  return outputHandle
}

func computeSeverityThresholds(
  _ dotYanagibaLint: DotYanagibaLint?,
  _ severityThresholdsOption: [String: Any]?
) -> [String: Int] {
  var severityThresholds: [String: Int] = [:]
  if let dotYanagibaLint = dotYanagibaLint, let customSeverityThresholds = dotYanagibaLint.severityThresholds {
    severityThresholds = customSeverityThresholds
  }
  if let customSeverityThresholds = severityThresholdsOption {
    for (key, value) in customSeverityThresholds {
      if let intValue = value as? Int {
        severityThresholds[key] = intValue
      }
    }
  }
  return severityThresholds
}
