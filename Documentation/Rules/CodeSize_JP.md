# Code Size ルール

## Too Many Parameters

<dl>
<dt>識別子</dt>
<dd>too_many_parameters</dd>
<dt>ファイル名</dt>
<dd>TooManyParametersRule.swift</dd>
<dt>激しさ</dt>
<dd>Minor</dd>
<dt>分類</dt>
<dd>Code Size</dd>
</dl>

Methods with too many parameters are hard to understand and maintain,
and are thirsty for refactorings, like
[Replace Parameter With Method](http://www.refactoring.com/catalog/replaceParameterWithMethod.html),
[Introduce Parameter Object](http://www.refactoring.com/catalog/introduceParameterObject.html),
or
[Preserve Whole Object](http://www.refactoring.com/catalog/preserveWholeObject.html).

##### Thresholds:

<dl>
<dt>MAX_PARAMETERS_COUNT</dt>
<dd>The reporting threshold for too many parameters, default value is 10.</dd>
</dl>

##### Examples:

###### Example 1

```
func example(
  a: Int,
  b: Int,
  c: Int,
  ...
  z: Int
) {}
```

##### References:

Fowler, Martin (1999). *Refactoring: Improving the design of existing code.* Addison Wesley.


## Long Line

<dl>
<dt>識別子</dt>
<dd>long_line</dd>
<dt>ファイル名</dt>
<dd>LongLineRule.swift</dd>
<dt>激しさ</dt>
<dd>Minor</dd>
<dt>分類</dt>
<dd>Code Size</dd>
</dl>

When a line of code is very long, it largely harms the readability.
Break long lines of code into multiple lines.

##### Thresholds:

<dl>
<dt>LONG_LINE</dt>
<dd>The long line reporting threshold, default value is 100.</dd>
</dl>

##### Examples:

###### Example 1

```
let a012345678901234567890123456789...1234567890123456789012345678901234567890123456789
```
