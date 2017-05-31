# Complexity 规则

## High Cyclomatic Complexity

标识名: `high_cyclomatic_complexity`

严重级别: Major

分类: Complexity

Cyclomatic complexity is determined by the number of linearly independent paths through a program's source code. In other words, cyclomatic complexity of a method is measured by the number of decision points, like `if`, `while`, and `for` statements, plus one for the method entry.

The experiments McCabe, the author of cyclomatic complexity, conclude that methods in the 3 to 7 complexity range are quite well structured. He also suggest the cyclomatic complexity of 10 is a reasonable upper limit.



## High NPath Complexity

标识名: `high_npath_complexity`

严重级别: Major

分类: Complexity



