# Bad Practice ルール

## No Force Cast

<dl>
<dt>識別子</dt>
<dd>no_force_cast</dd>
<dt>ファイル名</dt>
<dd>NoForceCastRule.swift</dd>
<dt>激しさ</dt>
<dd>Minor</dd>
<dt>分類</dt>
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
<dt>識別子</dt>
<dd>no_forced_try</dd>
<dt>ファイル名</dt>
<dd>NoForcedTryRule.swift</dd>
<dt>激しさ</dt>
<dd>Minor</dd>
<dt>分類</dt>
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
<dt>識別子</dt>
<dd>remove_get_for_readonly_computed_property</dd>
<dt>ファイル名</dt>
<dd>RemoveGetForReadOnlyComputedPropertyRule.swift</dd>
<dt>激しさ</dt>
<dd>Minor</dd>
<dt>分類</dt>
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
<dt>識別子</dt>
<dd>redundant_initialization_to_nil</dd>
<dt>ファイル名</dt>
<dd>RedundantInitializationtoNilRule.swift</dd>
<dt>激しさ</dt>
<dd>Minor</dd>
<dt>分類</dt>
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
