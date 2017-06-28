# Select Rules

Swift Lint is a rule based code analysis tool. Rules are designed to be very extensible and easy to be customized in many ways. In this article, we will show you two approaches to load particular rules, through [command line options](#command-line) and [configuration file](#configuration-file).

> **Warning:** Before we dive into the details, please be advised that command line options have higher precedence than the ones in configuration files.

> **See Also:** To enable and disable rules, you need to know the rule identifiers.
You can browse the [Rule Index](Rules),
and look for `Identifier` under each rule's title.

## Command Line

Through command line, you have two options that control the rules you want to enable or disable.

`enable-rules` explicit provides a list of identifiers of the rules to be used during inspection.
It is default to all rules that Swift Lint bundles with.

`disable-rules`, on the other hands, allows you to disable rules you don't want to include. By default, it is none.

The identifiers are separated by comma, and with no space in between.

So when no custom values are given to the tool, it analyzes with all rules loaded.
When any of the options are provided with value, the tool will take the enabled rule set, subtract it with disabled one, and then load the remaining rules accordingly.

For example, assume we have three rules in the system, namely A, B, and C.
You can then find the loaded rules with the table below.

| --enable-rules | --disable-rules | loaded rules |
| :---: | :---: | :---: |
| - | - | A, B, C |
| - | A | B, C |
| - | A,D | B, C |
| A,B | - | A, B |
| A,D | - | A |
| A,B | B,C | A |
| D | E | - |

* `-` means no value is provided or resulted in

> **Warning:** Invalid rule identifiers are ignored by the tool regardless of their presence. So when the rule set is not loaded correctly, first thing you want to double check is the correctness of the rule identifiers you provided.

## Configuration File

The rule selection can be done with `.yanagiba` file as well. It basically follows the same logic, but instead of comma separated, in configuration file, they are listed as an array in YAML format (hyphen+space to begin a rule identifier in the list).

As an example, the following configuration file will instruct Swift Lint to load rules A, B, and C:

```
enable-rules:
  - A
  - B
  - C
  - D
  - E
disable-rules:
  - D
  - E
```

> **See Also:** Check out [Configuration File](DotYanagibaFile.md) for additional documentation.
