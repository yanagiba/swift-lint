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

public struct RuleSet {
  public static var rules: [Rule] = [
    // TODO: this is clearly an OCP violation, I would take a technical debt here, and fix it in the near future
    NoForceCastRule(),
    NoForcedTryRule(),
    CyclomaticComplexityRule(),
    NPathComplexityRule(),
    NCSSRule(),
    NestedCodeBlockDepthRule(),
    RemoveGetForReadOnlyComputedPropertyRule(),
    RedundantInitializationToNilRule(),
    RedundantIfStatementRule(),
    RedundantConditionalOperatorRule(),
    ConstantIfStatementConditionRule(),
    ConstantGuardStatementConditionRule(),
    ConstantConditionalOperatorConditionRule(),
    InvertedLogicRule(),
    DoubleNegativeRule(),
    CollapsibleIfStatementsRule(),
    RedundantVariableDeclarationKeywordRule(),
    RedundantEnumCaseStringValueRule(),
    TooManyParametersRule(),
    LongLineRule(),
  ]

  public static var ruleIdentifiers: [String] {
    return rules.map({ $0.identifier })
  }
}
