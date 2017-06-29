# Write New Rule

As a rule based tool, we have many rules implemented and bundled when we release Swift Lint. We also made it quite flexible to extend the analysis with your own custom rules.

1. Create a new `XYZRule` class that conforms to `Rule` protocol and inherits `RuleBase` base class. In addition, two handy protocols `ASTVisitorRule` and `SourceCodeRule` are available for you, and each serves its own purposes well and eases detail implementations, as we described below:

  - `Rule, RuleBase`: conforming to `Rule` protocol is all you need for Swift Lint to recognize this class is a rule. And by implementing the properties and methods of the protocol, you instruct the system how the rule analyzes code and emits issues. `RuleBase` class contains properties that allows you refer to the current `ASTContext` and retrieve the rule `configurations` during analysis.
  - `ASTVisitorRule, RuleBase`: extends the rule with abstract syntax tree (AST) traversal. The default logic will just pass through all the nodes without doing anything. So your AST visitor rules will need to `visit` the nodes that are in your interest. Based on requirement, you can interrupt the traversal by returning `false` in your `visit` implementation; otherwise, return `true` to continue the traversal. Majority of our rules are `ASTVisitorRule`s, so check them out.
  - `SourceCodeRule, RuleBase`: extends the rule with looping over each line of the plain source code text. The `inspect` method is called multiple times, each with the text of current line and its line number. You can work around the text of the source code, and emit issues when necessary.

2. Now open `RuleSet.swift` file, and simply add your rule to the array.

3. Run `make docgen`, and double check if rule properties and descriptions show up properly in [Rule Index](../Rules). Except for the name of the rule, we provide default implementations for all other properties based on the name, but you can override them when necessary.

4. Add tests: we have a `RuleTests` test module, and please write your tests to verify the rule's behaviors.

5. Add the test cases to `RuleTests/XCTestManifests` so that the tests run on Linux (for now, and hopefully SPM can address this soon).

6. Make sure `make test` pass on both Linux and macOS.

6. Run dogfooding (`./dogFooding.sh`) to make sure the code is inspected by the tool itself. Fix found issues if any.

7. You can share your rules with the entire community by sending us pull requests. Thanks.
