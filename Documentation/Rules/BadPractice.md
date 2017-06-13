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
