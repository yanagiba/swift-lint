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
