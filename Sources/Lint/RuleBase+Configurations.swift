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

extension RuleBase {
  func getConfiguration<T>( // swift-lint:suppress(high_cyclomatic_complexity)
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
      case is Double:
        if let doubleConfig = Double(commentConfig), let tConfig = doubleConfig as? T {
          return tConfig
        }
      case is Bool where commentConfig == "true":
        let boolConfig = true
        if let tConfig = boolConfig as? T {
          return tConfig
        }
      case is Bool where commentConfig == "false":
        let boolConfig = false
        if let tConfig = boolConfig as? T {
          return tConfig
        }
      default:
        break
      }
    }
    return getConfiguration(forKey: key, orDefault: defaultValue)
  }

  func getConfiguration<T>(forKey key: String, orDefault defaultValue: T) -> T {
    if let configurations = configurations, let customThreshold = configurations[key] as? T {
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

  var commentBasedConfigurations: CommentBasedConfiguration {
    return astContext?.commentBasedConfigurations ?? [:]
  }
}
