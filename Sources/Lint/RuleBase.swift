/*
   Copyright 2015 Ryuichi Saito, LLC and the Yanagiba project contributors

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

class RuleBase {
  var astContext: ASTContext?
  var configurations: [String: Any]?
}

extension RuleBase {
  func getConfiguration<T>(
    forKey key: String, atLineNumber line: Int, orDefault defaultValue: T
  ) -> T {
    if let commentConfig = getCommentBasedConfiguration(forKey: key, atLineNumber: line) {
      switch defaultValue {
      case is String:
        if let strConfig = commentConfig as? T {
          return strConfig
        }
      case is Int:
        if let intConfig = Int(commentConfig), let tConfig = intConfig as? T {
          return tConfig
        }
      default:
        break
      }
    }
    return getConfiguration(forKey: key, orDefault: defaultValue)
  }

  func getConfiguration<T>(forKey key: String, orDefault defaultValue: T) -> T {
    if let configurations = configurations,
      let customThreshold = configurations[key] as? T
    {
      return customThreshold
    }
    return defaultValue
  }

  func getCommentBasedConfiguration(
    forKey key: String, atLineNumber line: Int
  ) -> String?
  {
    guard let configurations = commentBasedConfigurations[line] else {
      return nil
    }
    return configurations[key]
  }
}

extension RuleBase {
  typealias CommentBasedSetting = [Int: [String?]]
  typealias CommentBasedSuppression = [Int: [String]]
  typealias CommentBasedConfiguration = [Int: [String: String]]

  // TODO: oppurtunity for performance improvements
  // these computations can be calculated once and cached per source file

  var commentBasedSuppressions: CommentBasedSuppression {
    let suppressConfigTuples = commentBasedConfigurations(forKey: "suppress")
      .map({ lineConfig -> (Int, [String]) in
        let line = lineConfig.0
        var suppressionConf: [String] = []
        for conf in lineConfig.1 {
          guard let selectedSuppressions = conf else {
            return (line, [])
          }
          if selectedSuppressions.isEmpty {
            return (line, [])
          }

          let ruleIds = selectedSuppressions.components(separatedBy: ",")
          suppressionConf += ruleIds
        }

        return (line, suppressionConf)
      })
    return toDictionary(fromTuples: suppressConfigTuples)
  }

  var commentBasedConfigurations: CommentBasedConfiguration {  // swift-lint:rule_configure(NESTED_CODE_BLOCK_DEPTH=6)
    let ruleConfigTuples = commentBasedConfigurations(forKey: "rule_configure")
      .map({ lineConfig -> (Int, [String: String]) in
        let line = lineConfig.0
        var ruleConfig: [String: String] = [:]
        for conf in lineConfig.1 {
          guard let ruleConf = conf else {
            continue
          }
          if ruleConf.isEmpty {
            continue
          }

          for e in ruleConf.components(separatedBy: ",") {
            let keyValuePair = e.components(separatedBy: "=")
            guard keyValuePair.count == 2 else {
              continue
            }
            ruleConfig[keyValuePair[0]] = keyValuePair[1]
          }
        }

        return (line, ruleConfig)
      })
    return toDictionary(fromTuples: ruleConfigTuples)
  }

  private func commentBasedConfigurations(
    forKey key: String
  ) -> CommentBasedSetting {
    guard let astContext = astContext else {
      return [:]
    }
    let configTuples = astContext.topLevelDeclaration.comments
      .map({ ($0.location.line, $0.content) })
      .filter({ $0.1.contains(SWIFT_LINT) && $0.1.contains(key) })
      .map({ lineContent -> (Int, [String?]) in
        let line = lineContent.0
        let configurations = lineContent.1.extractedConfigurations
          .filter({ $0.name == key })
          .map({ $0.args })
        return (line, configurations)
      })
    return toDictionary(fromTuples: configTuples)
  }
}

fileprivate func toDictionary<K, V>(fromTuples tuples: [(K, V)]) -> [K: V] {
  var dict:[K: V] = [K: V]()
  tuples.forEach { dict[$0.0] = $0.1 }
  return dict
}

fileprivate extension String {
  var extractedConfigurations: [(name: String, args: String?)] { // swift-lint:rule_configure(NESTED_CODE_BLOCK_DEPTH=6)
    guard let swiftLintKeywordRange = range(of: SWIFT_LINT) else {
      return []
    }

    let remainingString = String(self[swiftLintKeywordRange.upperBound...])
    var configurations: [(String, String?)] = []

    enum State {
      case head
      case keyword
      case argument
      case tail
    }

    var state = State.head
    var currentString = ""
    var currentKey = ""
    for c in remainingString {
      switch c {
      case ":":
        if state == .head ||
          (state == .tail &&
            (currentString == "" || currentString.hasSuffix(SWIFT_LINT)))
        {
          currentString = ""
          currentKey = ""
          state = .keyword
        } else if state == .keyword {
          configurations.append((currentString, nil))
          currentString = ""
          currentKey = ""
        } else {
          currentString += String(c)
        }
      case "(":
        if state == .keyword {
          currentKey = currentString
          currentString = ""
          state = .argument
        } else {
          currentString += String(c)
        }
      case ")":
        if state == .argument {
          configurations.append((currentKey, currentString))
          currentString = ""
          currentKey = ""
          state = .tail
        }
      default:
        if c != " " {
          currentString += String(c)
        }
      }
    }

    if state == .keyword && !currentString.isEmpty {
      configurations.append((currentString, nil))
    }

    return configurations
  }
}
