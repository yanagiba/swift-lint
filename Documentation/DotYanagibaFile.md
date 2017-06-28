# Configuration File (`.yanagiba`)

When your team discussed and decided upon a set of rules, a tuned configurations, output format, etc., you may want to save them into a configuration file, and name it with `.yanagiba`. This way, you don't need to remember these flags and type them repeatedly every time you run Swift Lint. And you can check in this file to your source control repository, so that your teammates also get the same settings. Even better, if you have Continuous Integration set up, it will use the same configurations as well.

> **Warning:** Definitely check with your teammates before you check in local configuration file to avoid unnecessary surprises.

## Location and Scope

You can save `.yanagiba` at

- home directory (`~`)
- the root of project folder

The configurations defined in home directory's `.yanagiba` file are applied to all analysis triggered by the specific user. Meanwhile, the ones defined in project's `.yanagiba` file are only applied to the specific project.

When Swift Lint launches, it searches both locations, and tries to read from both if any exists. Please be advised that,
the project scoped configurations will override the ones defined in the home directory.

> **Warning:** The inline configurations have the highest precedence, the next highest is the command line options, and then the configurations in project's `.yanagiba` file, and the lowest is the ones defined in user home directory's `yanagiba` file.

## Format and Supported Configurations

The acceptable configuration file is written in YAML format, with `lint` as the root key, and the following available options under. They are all optional.

| Key | Value | Mapping CLI Option |
| :---: | :---: | :---: |
| enable-rules | List of rule identifiers | --enable-rules |
| disable-rules | List of rule identifiers | --disable-rules |
| rule-configurations | Dictionary of threshold key and value pairs | --rule-configurations |
| report-type | Reporter identifier | --report-type |
| output-path | Path to the file | --outputpath, -o |
| severity-thresholds | Dictionary of severity level label and threshold number pairs | --severity-thresholds |

As an example, a `.yanagiba` file may look like this:

```
lint:
  disable-rules:
    - dead_code
    - long_line
  rule-configurations:
    - NESTED_CODE_BLOCK_DEPTH: 6
    - CYCLOMATIC_COMPLEXITY: 15
  report-type:
    - json
  severity-thresholds:
    - minor: 50
    - cosmetic: 100
```

You may find a sample `.yanagiba` file at the root directory of this project.
