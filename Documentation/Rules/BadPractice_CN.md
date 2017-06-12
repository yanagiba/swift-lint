# Bad Practice 规则

## No Force Cast

<dl>
<dt>标识名</dt>
<dd>no_force_cast</dd>
<dt>文件名</dt>
<dd>NoForceCastRule.swift</dd>
<dt>严重级别</dt>
<dd>Minor</dd>
<dt>分类</dt>
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
