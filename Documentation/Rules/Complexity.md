# Complexity Rules

## High Cyclomatic Complexity

<dl>
<dt>Identifier</dt>
<dd>high_cyclomatic_complexity</dd>
<dt>File name</dt>
<dd>CyclomaticComplexityRule.swift</dd>
<dt>Severity</dt>
<dd>Major</dd>
<dt>Category</dt>
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
<dt>Identifier</dt>
<dd>high_npath_complexity</dd>
<dt>File name</dt>
<dd>NPathComplexityRule.swift</dd>
<dt>Severity</dt>
<dd>Major</dd>
<dt>Category</dt>
<dd>Complexity</dd>
</dl>

NPath complexity is determined by the number of execution paths through that method.
Compared to cyclomatic complexity, NPath complexity has two outstanding characteristics:
first, it distinguishes between different kinds of control flow structures;
second, it takes the various type of acyclic paths in a flow graph into consideration.

Based on studies done by the original author in AT&T Bell Lab,
an NPath threshold value of 200 has been established for a method.

##### Thresholds:

<dl>
<dt>NPATH_COMPLEXITY</dt>
<dd>The NPath complexity reporting threshold, default value is 200.</dd>
</dl>

##### References:

Brian A. Nejmeh  (1988).
["NPATH: a measure of execution path complexity and its applications"](http://dl.acm.org/citation.cfm?id=42379).
*Communications of the ACM 31 (2) p. 188-200*
