# Command Line Usage

You can analyze a list of files with Swift Lint by providing the paths of these files, such as `swift-lint path/to/foo.swift path/to/bar.swift`. This will run `swift-lint` with its default settings and workflow: loading all rules, using default thresholds while analyzing the code, rendering with text reporter, writing output to console, etc.

Using default settings works fine as a good starting point. Furthermore, by applying the options below, the behavior of the tool can be changed to meet your customization needs.

- [Help and Version](#help-and-version)
- [Rule](#rule)
- [Reporter and Output](#reporter-and-output)
- [Exit Code](#control-exit-code)

## Help and Version

### --help, -help

Prints out all options that the tool supports.

### --version, -version

Displays the versions of the tool and its dependencies.

## Rule

### --enable-rules and --disable-rules

Options `enable-rules` and `disable-rules` help you set what rules you want to use for analysis, and what rules are not.

```
--enable-rules <rule_identifier0>[,...,<rule_identifierN>]
  Enable rules, default to all rules
--disable-rules <rule_identifier0>[,...,<rule_identifierN>]
  Disable rules, default to empty
```

> **See Also:** Please checkout [Select Rules for Inspection](SelectRules.md) for details.

### --rule-configurations

You can configure the rule thresholds throughout the entire analysis by overriding the default ones with this option.

```
--rule-configurations <parameter0>=<value0>[,...,<parameterN>=<valueN>]
  Override the default rule configurations
```

> **See Also:** Details can be found at [Configure Rule Thresholds](RuleConfigurations.md).

## Reporter and Output

### --report-type

By default, the found issues are rendered in plain text format. This is primarily for console output.
More human readable report types, like HTML, can be used for reading in browsers;
some machine friendly report types, like PMD and Xcode, can be used, so that other tools may pick up the output, and render it in their integrated environment.

You can switch to another report type by `--report-type <report_identifier>`. Swift Lint bundles with the following reporters:

- text:
  - the default text output, mainly used in console
- html:
  - HTML format, optimized for human reading in web browsers
- json:
  - JSON format
- pmd:
  - mimic the PMD output, can be picked up by continuous integration tools, like Jenkins, and render in a human-readable fashion
- xcode:
  - allow the issues to be inline displayed inside Xcode source editor

### --output, -o

Swift Lint outputs the rendered output to console by default, by providing a path to the `-o` or `--output` option, you can redirect the output and save it to a specific file.

For example, combine with the `report-type` option, you can save an HTML report with `--report-type html --output swift_lint.html`. Once the analysis is done, you can simply open the `swift_lint.html` file in your browser, and read the report there.

## Control Exit Code

By convention, programs successfully finish the execution should exit with a zero code. By contract, when something needs your attention, in our case, when too many issues have been found during inspection, the tool exits with a non-zero code. It benefits even more when the tool is run in a Continuous Integration (CI) environment, because this triggers CI with a build failure, so that you can be notified early in the development cycle.

By default, Swift Lint returns a non-zero exit code when one or more conditions met:

- found any critical issues (more than 0 critical issue)
- found more than 10 major issues
- found more than 20 minor issues
- found more than 50 cosmetic issues

You can change the thresholds with

```
--severity-thresholds <severity0>=<threshold0>[,...,<severityN>=<thresholdN>]
```

For example,

```
--severity-thresholds critical=5
```

will allow maximum five critical issues, and

```
--severity-thresholds minor=50,cosmetic=100
```

will extend the tolerance for minor issues and cosmetic issues to 50 and 100 respectively.
