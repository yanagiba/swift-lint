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
import Bocho

struct DotYanagibaLint {
  var enableRules: [String]?
  var disableRules: [String]?
  var ruleConfigurations: [String: Any]?
  var reportType: String?
  var outputPath: String?
  var severityThresholds: [String: Int]?

  init?(dotYanagiba: DotYanagiba) {
    guard let module = dotYanagiba.modules["lint"] else {
      return nil
    }

    for (key, option) in module.options {
      switch (key, option) {
      case ("enable-rules", .listString(let options)):
        enableRules = options
      case ("disable-rules", .listString(let options)):
        disableRules = options
      case ("rule-configurations", .dictInt(let options)):
        ruleConfigurations = options
      case ("rule-configurations", .dictString(let options)):
        ruleConfigurations = options
      case ("report-type", .string(let option)):
        reportType = option
      case ("output-path", .string(let option)):
        outputPath = option
      case ("severity-thresholds", .dictInt(let options)):
        severityThresholds = options
      default:
        break
      }
    }
  }

  static func loadFromDisk() -> DotYanagibaLint? {
    guard let dotYanagiba = DotYanagibaReader.read() else {
      return nil
    }
    return DotYanagibaLint(dotYanagiba: dotYanagiba)
  }
}
