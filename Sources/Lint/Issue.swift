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

import Source

public struct Issue {
  public enum Category: String {
    case uncategorized

    case complexity
    case readability
    case size
    case badPractice = "bad practice"
    case cocoa
  }

  public enum Severity: String {
    case critical
    case major
    case minor
    case cosmetic
  }

  let ruleIdentifier: String
  let description: String
  let category: Category
  let location: SourceRange
  let severity: Severity
  let correction: Correction?
}
