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

import Bocho
import Source
import Lint

let dotYanagibaLint = DotYanagibaLint.loadFromDisk()

var cliArgs = CommandLine.arguments
cliArgs.remove(at: 0)
let cliOption = CLIOption(cliArgs)

if cliOption.contains("help") {
  print("""
  swift-lint [options] <source0> [... <sourceN>]

  <source0> ... specify the paths of source files.

  -help, --help
    Display available options
  -version, --version
    Display the version

  --enable-rules <rule_identifier0>[,...,<rule_identifierN>]
    Enable rules, default to all rules
  --disable-rules <rule_identifier0>[,...,<rule_identifierN>]
    Disable rules, default to empty
  --rule-configurations <parameter0>=<value0>[,...,<parameterN>=<valueN>]
    Override the default rule configurations

  --report-type <report_identifier>
    Change output report type, default to `text`
  -o, --output <path>
    Write output to <path>, default to console

  --severity-thresholds <severity0>=<threshold0>[,...,<severityN>=<thresholdN>]
    The max allowed number of issues of each severity level.
    Critical is default to 0
    Major is default to 10
    Minor is default to 20
    Cosmetic is default to 50

  For more information, please visit http://yanagiba.org/swift-lint
  """)
  exit(0)
}

if cliOption.contains("version") {
  print("""
  Yanagiba's swift-lint (http://yanagiba.org/swift-lint):
    version \(SWIFT_LINT_VERSION).

  Yanagiba's swift-ast (http://yanagiba.org/swift-ast):
    version \(SWIFT_AST_VERSION).
  """)
  exit(0)
}

let enabledRules = computeEnabledRules(
  dotYanagibaLint, cliOption.readAsString("-enable-rules"), cliOption.readAsString("-disable-rules"))
let ruleConfigurations = computeRuleConfigurations(
  dotYanagibaLint, cliOption.readAsDictionary("-rule-configurations"))
let reportType = computeReportType(dotYanagibaLint, cliOption.readAsString("-report-type"))
let outputHandle =
  computeOutputHandle(dotYanagibaLint, cliOption.readAsString("o") ?? cliOption.readAsString("-output"))
let severityThresholds = computeSeverityThresholds(
  dotYanagibaLint, cliOption.readAsDictionary("-severity-thresholds"))

let filePaths = cliOption.arguments
var sourceFiles = [SourceFile]()
for filePath in filePaths {
  guard let sourceFile = try? SourceReader.read(at: filePath) else {
    print("Can't read file \(filePath)")
    exit(-1)
  }
  sourceFiles.append(sourceFile)
}

let driver = Driver(
  ruleIdentifiers: enabledRules,
  reportType: reportType,
  outputHandle: outputHandle)
let exitCode = driver.lint(
  sourceFiles: sourceFiles,
  ruleConfigurations: ruleConfigurations,
  severityThresholds: severityThresholds)
exit(exitCode.rawValue)
