# Write New Rule

As a rule based tool, we have many rules implemented and bundled when we release Swift Lint. We also made it quite flexible to extend the analysis with your own custom rules.

1. Create a new `XYZRule` class that conforms to `Rule` protocol and inherits `RuleBase` base class. In addition, two handy protocols `ASTVisitorRule` and `SourceCodeRule` are available for you, and each serves its own purposes well and eases detail implementations, as we described below:

  - `Rule, RuleBase`: `Rule` protocol is all you need for Swift Lint to recognize this is a rule, and by conforming to the properties and methods in this protocol, you instruct the system how this rule analyzes code and emits issues. `RuleBase` class contains properties that allows you refer to the current `ASTContext` and retrieve rule `configurations` during analysis.
  - `ASTVisitorRule, RuleBase`: extends the rule with abstract syntax tree (AST) traversal. Your AST visitor rules only need to `visit` the nodes that are interested to you, and you can leave the rest because the default workflow will just pass through them without doing anything. You can interrupt the traversal by returning `false` in your `visit` implementation. Majority of our rules are `ASTVisitorRule`s, so check them out.
  - `SourceCodeRule, RuleBase`: extends the rule with plain source code text loop over. The `inspect` method is called multiple times, each with the text of current line and its line number. You can work around the text of the source code, and emit issues when necessary.

2. Now open `RuleSet.swift` file, and simply add your rule to the array.

3. Run `make docgen`, and double check if rule properties and descriptions show up properly in [Rule Index](../Rules). Except the name of the rule, we provide default implementations for all other properties based on the name, but you can override them when necessary.

4. Add tests: we have a `RuleTests` test module, and please write your tests to verify the rule's behaviors.

5. Add the test cases to `RuleTests/XCTestManifests`, so that the tests run on Linux (for now, and hopefully SPM can address this soon).

6. Make sure `make test` pass on both Linux and macOS.

6. Run dogfooding (`./dogFooding.sh`) to make sure the code is inspected by the tool itself. Fix found issues if any.

7. You can share your rules with the entire community by sending us pull requests. Thanks.
