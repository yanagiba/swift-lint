# Rule Configurations

Although many rules emit issues on a boolean basis (either fire the issue or not),
some rules emit issues only when the metrics of the source code exceed the thresholds.
Rule system in Swift Lint is designed to be very flexible and dynamic to accommodate this requirement.

For example, according to [McCabe76](http://www.literateprogramming.com/mccabe.pdf), a reasonable cyclomatic complexity number for a method should be less than 10. So, default threshold in CyclomaticComplexityRule is set to 10. However, in practice, you might realize this value may not be the best for your project. For instance, a more sophisticated legacy codebase comes with high complexity, or on the other side, one team may in the middle of pushing a much more strict coding standard. For these cases, customizations can be achieved by changing thresholds.

There are three ways to configure the thresholds: from a higher precedence to lower, [Inline Comment](#inline-comment) > [Command Line](#command-line) > [Configuration File](#configuration-file).

> **See Also:** You can browse the [Rule Index](Rules),
and look for possible section `Thresholds`.
If the rule supports threshold configurations,
you can find the keys and default values in that section.

## Inline Comment

You can alter the thresholds for the nodes by

- appending single line comment to the same line
- adding multi-line comment block with its head `/*` on the same line

In addition, poorly written comments harm code quality as well.
So we support few syntaxes,
and let you choose the one with the best readability:

- Aggregate all threshold keys and values in `rule_configure` call inside single line comment

```
// swift-lint:rule_configure(threshold_key_1=value_1,...,threshold_key_N=value_N)
```

- Multiple `rule_configure` calls in single line comment

```
// swift-lint:rule_configure(threshold_key_1=value_1):rule_configure(threshold_key_2=value_2):...:rule_configure(threshold_key_N=value_N)
```

- One `rule_configure` call with all threshold keys and values inside a multi-line comment block

```
/*
 swift-lint:rule_configure(threshold_key_1=value_1,...,threshold_key_N=value_N)
 */
```

- Multiple `rule_configure` calls in multi-line comment block

```
/*
 swift-lint:rule_configure(threshold_key_1=value_1)
 swift-lint:rule_configure(threshold_key_2=value_2)
 ...
 swift-lint:rule_configure(threshold_key_N=value_N)
 */
```

For instances, when you have a function that you have a good reason to allow a higher cyclomatic complexity, then you can apply the configuration like this:

```
func foo() { // swift-lint:rule_configure(CYCLOMATIC_COMPLEXITY=15)
  .. some complicated code
}

```

Later, you want to increase the thresholds for NPath complexity and count of non-commenting source statements as well.
In this case, imagine if you write everything in one line,
the code will looks messy. So instead, you can use multi-line comment this time:

```
func foo() { /*
 swift-lint:rule_configure(CYCLOMATIC_COMPLEXITY=15)
 swift-lint:rule_configure(NPATH_COMPLEXITY=300)
 swift-lint:rule_configure(NCSS=50)
 */
  .. even more complex code
}
```

> **See Also:** You can mix `rule_configure` with other comment based annotations, like [suppressing issues](SuppressIssues.md), in the same comment block.

## Command Line

When the configurations are applied to all the files in your project, you can consider changing them through command line or save them in the configuration file (described in the section below).

The option to use is `rule-configurations`:

```
--rule-configurations <parameter0>=<value0>[,...,<parameterN>=<valueN>]
  Override the default rule configurations
```

No space among commas and equal signs.

For example, in order to change cyclomatic complexity number to 15, but to lower the long line to 50, following command can be given:

```
--rule-configurations CYCLOMATIC_COMPLEXITY=15,LONG_LINE=50
```

## Configuration File

The rule threshold configurations can be preserved in configuration files:

```
rule-configurations:
  - THRESHOLD_KEY_1: value_1
  - THRESHOLD_KEY_2: value_2
  ...
  - THRESHOLD_KEY_N: value_n
```

The example defined in last section can also be achieved by putting the following into project's `.yanagiba` file:

```
rule-configurations:
  - CYCLOMATIC_COMPLEXITY: 15
  - LONG_LINE: 50
```

> **See Also:** Check out [Configuration File](DotYanagibaFile.md) for additional documentation.
