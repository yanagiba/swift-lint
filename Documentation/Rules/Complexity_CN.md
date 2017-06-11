# Complexity 规则

## High Cyclomatic Complexity

<dl>
<dt>标识名</dt>
<dd>`high_cyclomatic_complexity`</dd>
<dt>文件名</dt>
<dd>`CyclomaticComplexityRule.swift`</dd>
<dt>严重级别</dt>
<dd>Major</dd>
<dt>分类</dt>
<dd>Complexity</dd>
</dl>

Cyclomatic complexity is determined by the number of
linearly independent paths through a program's source code.
In other words, cyclomatic complexity of a method is measured by
the number of decision points, like `if`, `while`, and `for` statements,
plus one for the method entry.

The experiments McCabe, the author of cyclomatic complexity,
conclude that methods in the 3 to 7 complexity range are
quite well structured. He also suggest
the cyclomatic complexity of 10 is a reasonable upper limit.

##### Thresholds:

<dl>
<dt>CYCLOMATIC_COMPLEXITY</dt>
<dd>The cyclomatic complexity reporting threshold, default value is 10.</dd>
</dl>

##### Examples:

###### Example 1

```
func example(a: Int, b: Int, c: Int) // 1
{
    if (a == b)                      // 2
    {
        if (b == c)                  // 3
        {
        }
        else if (a == c)             // 3
        {
        }
        else
        {
        }
    }
    for i in 0..<c                   // 4
    {
    }
    switch(c)
    {
        case 1:                      // 5
            break
        case 2:                      // 6
            break
        default:                     // 7
            break
    }
}
```

##### References:

McCabe (December 1976). ["A Complexity Measure"](http://www.literateprogramming.com/mccabe.pdf).
*IEEE Transactions on Software Engineering: 308–320*


## High NPath Complexity

<dl>
<dt>标识名</dt>
<dd>`high_npath_complexity`</dd>
<dt>文件名</dt>
<dd>`HighNPathComplexity.swift`</dd>
<dt>严重级别</dt>
<dd>Major</dd>
<dt>分类</dt>
<dd>Complexity</dd>
</dl>
