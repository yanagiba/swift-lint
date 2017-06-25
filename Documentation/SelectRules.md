# Select Rules

Swift Lint is a rule based code analysis tool. Rule system is designed to be very extensible and flexible. So it's easy to customize rules in many ways. In this article, we will show you two approaches to load particular rules, through [command line options](#command-line) and [configuration file](#configuration-file).

Before we dive into the details, please be advised that command line options have high precedence than the ones in configuration files.

## Command Line

Through command line, you have two options that control the rules you want to enable or disable.

`enable-rules` explicit provides a list of identifiers of the rules you want to use during inspection.
It is default to all rules that Swift Lint bundles with.

`disable-rules`, on the other hands, allows you to disable rules you don't want to include. By default, it is none.

The identifiers are separated by comma, no space in between.

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

* `-` means no value is provided or resulted

Maybe you already noticed, invalid rule identifiers are ignored by the tool regardless of their presence.

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
