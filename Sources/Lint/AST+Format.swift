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

// TODO: when swift-format is ready, we will see if we can reuse the code.

import AST

extension CodeBlock {
  var formatted: String {
    if statements.isEmpty {
      return "{}"
    }
    let indented = statements.map({ "  \($0.textDescription)" }).joined(separator: "\n")
    return """
    {
    \(indented)
    }
    """
  }
}

extension VariableDeclaration.Body {
  var formatted: String {
    switch self {
    case let .codeBlock(name, typeAnnotation, codeBlock):
      return "\(name)\(typeAnnotation) \(codeBlock.formatted)"
    default:
      return textDescription
    }
  }
}

extension VariableDeclaration {
  var formatted: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    return "\(attrsText)\(modifiersText)var \(body.formatted)"
  }
}
