# Complexity ルール

## High Cyclomatic Complexity

識別子: `high_cyclomatic_complexity`

激しさ: Major

分類: Complexity

Cyclomatic complexity is determined by the number of linearly independent paths through a program's source code. In other words, cyclomatic complexity of a method is measured by the number of decision points, like `if`, `while`, and `for` statements, plus one for the method entry.

The experiments McCabe, the author of cyclomatic complexity, conclude that methods in the 3 to 7 complexity range are quite well structured. He also suggest the cyclomatic complexity of 10 is a reasonable upper limit.



## High NPath Complexity

識別子: `high_npath_complexity`

激しさ: Major

分類: Complexity



