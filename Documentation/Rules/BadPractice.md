# Bad Practice Rules

## No Force Cast

<dl>
<dt>Identifier</dt>
<dd>no_force_cast</dd>
<dt>File name</dt>
<dd>NoForceCastRule.swift</dd>
<dt>Severity</dt>
<dd>Minor</dd>
<dt>Category</dt>
<dd>Bad Practice</dd>
</dl>

Force casting `as!` should be avoided, because it could crash the program
when the type casting fails.

Although it is arguable that, in rare cases, having crashes may help developers
identify issues easier, we recommend using a `guard` statement with optional casting
and then handle the failed castings gently.

##### Examples:

###### Example 1

```
let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! MyCustomCell

// guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as? MyCustomCell else {
//   print("Failed in casting to MyCustomCell.")
//   return UITableViewCell()
// }

return cell
```


## No Forced Try

<dl>
<dt>Identifier</dt>
<dd>no_forced_try</dd>
<dt>File name</dt>
<dd>NoForcedTryRule.swift</dd>
<dt>Severity</dt>
<dd>Minor</dd>
<dt>Category</dt>
<dd>Bad Practice</dd>
</dl>

Forced-try expression `try!` should be avoided, because it could crash the program
at the runtime when the expression throws an error.

We recommend using a `do-catch` statement with `try` operator and handle the errors
in `catch` blocks accordingly; or a `try?` operator with `nil`-checking.

##### Examples:

###### Example 1

```
let result = try! getResult()

// do {
//   let result = try getResult()
// } catch {
//   print("Failed in getting result with error: \(error).")
// }
//
// or
//
// guard let result = try? getResult() else {
//   print("Failed in getting result.")
// }
```


## Remove Get For Read-Only Computed Property

<dl>
<dt>Identifier</dt>
<dd>remove_get_for_readonly_computed_property</dd>
<dt>File name</dt>
<dd>RemoveGetForReadOnlyComputedPropertyRule.swift</dd>
<dt>Severity</dt>
<dd>Minor</dd>
<dt>Category</dt>
<dd>Bad Practice</dd>
</dl>

A computed property with a getter but no setter is known as
a *read-only computed property*.

You can simplify the declaration of a read-only computed property
by removing the get keyword and its braces.

##### Examples:

###### Example 1

```
var foo: Int {
  get {
    return 1
  }
}

// var foo: Int {
//   return 1
// }
```


## Redundant Initialization to Nil

<dl>
<dt>Identifier</dt>
<dd>redundant_initialization_to_nil</dd>
<dt>File name</dt>
<dd>RedundantInitializationtoNilRule.swift</dd>
<dt>Severity</dt>
<dd>Minor</dd>
<dt>Category</dt>
<dd>Bad Practice</dd>
</dl>

It is redundant to initialize an optional variable to `nil`,
because if you don’t provide an initial value when you declare an optional variable or property,
its value automatically defaults to `nil` by the compiler.

##### Examples:

###### Example 1

```
var foo: Int? = nil // var foo: Int?
```


## Redundant If Statement

<dl>
<dt>Identifier</dt>
<dd>redundant_if_statement</dd>
<dt>File name</dt>
<dd>RedundantIfStatementRule.swift</dd>
<dt>Severity</dt>
<dd>Minor</dd>
<dt>Category</dt>
<dd>Bad Practice</dd>
</dl>

This rule detects three types of redundant if statements:

- then-block and else-block are returning true/false or false/true respectively;
- then-block and else-block are the same constant;
- then-block and else-block are the same variable expression.

They are usually introduced by mistake, and should be simplified or removed.

##### Examples:

###### Example 1

```
if a == b {
  return true
} else {
  return false
}
// return a == b
```

###### Example 2

```
if a == b {
  return false
} else {
  return true
}
// return a != b
```

###### Example 3

```
if a == b {
  return true
} else {
  return true
}
// return true
```

###### Example 4

```
if a == b {
  return foo
} else {
  return foo
}
// return foo
```


## Redundant Conditional Operator

<dl>
<dt>Identifier</dt>
<dd>redundant_conditional_operator</dd>
<dt>File name</dt>
<dd>RedundantConditionalOperatorRule.swift</dd>
<dt>Severity</dt>
<dd>Minor</dd>
<dt>Category</dt>
<dd>Bad Practice</dd>
</dl>

This rule detects three types of redundant conditional operators:

- true-expression and false-expression are returning true/false or false/true respectively;
- true-expression and false-expression are the same constant;
- true-expression and false-expression are the same variable expression.

They are usually introduced by mistake, and should be simplified or removed.

##### Examples:

###### Example 1

```
return a > b ? true : false // return a > b
```

###### Example 2

```
return a == b ? false : true // return a != b
```

###### Example 3

```
return a > b ? true : true // return true
```

###### Example 4

```
return a < b ? "foo" : "foo" // return "foo"
```

###### Example 5

```
return a != b ? c : c // return c
```


## Constant If Statement Condition

<dl>
<dt>Identifier</dt>
<dd>constant_if_statement_condition</dd>
<dt>File name</dt>
<dd>ConstantIfStatementConditionRule.swift</dd>
<dt>Severity</dt>
<dd>Minor</dd>
<dt>Category</dt>
<dd>Bad Practice</dd>
</dl>

##### Examples:

###### Example 1

```
if true { // always true
  return true
}
```

###### Example 2

```
if 1 == 0 { // always false
  return false
}
```

###### Example 3

```
if 1 != 0, true { // always true
  return true
}
```


## Constant Guard Statement Condition

<dl>
<dt>Identifier</dt>
<dd>constant_guard_statement_condition</dd>
<dt>File name</dt>
<dd>ConstantGuardStatementConditionRule.swift</dd>
<dt>Severity</dt>
<dd>Minor</dd>
<dt>Category</dt>
<dd>Bad Practice</dd>
</dl>

##### Examples:

###### Example 1

```
guard true else { // always true
  return true
}
```

###### Example 2

```
guard 1 == 0 else { // always false
  return false
}
```

###### Example 3

```
guard 1 != 0, true else { // always true
  return true
}
```
