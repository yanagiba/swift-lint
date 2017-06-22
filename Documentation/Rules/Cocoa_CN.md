# Cocoa 规则

## Must Call Super

<dl>
<dt>标识名</dt>
<dd>must_call_super</dd>
<dt>文件名</dt>
<dd>MustCallSuperRule.swift</dd>
<dt>严重级别</dt>
<dd>Major</dd>
<dt>分类</dt>
<dd>Cocoa</dd>
</dl>

By convention, these overridden cocoa methods should always call super:

- UIViewController
  - viewDidLoad()
  - viewDidAppear(_:)
  - viewDidDisappear(_:)
  - viewWillAppear(_:)
  - viewWillDisappear(_:)
  - addChildViewController(_:)
  - removeFromParentViewController()
  - didReceiveMemoryWarning()
- UIView
  - updateConstraints()
- UICollectionViewLayout
  - invalidateLayout()
  - invalidateLayout(with:)
- XCTestCase
  - setUp()
  - tearDown()

Apparently, this is not a comprehensive list.
More will be added by our contributors in the future.
The goal is to fully automate this list,
so pull request is welcomed while we address other priorities.

##### Examples:

###### Example 1

```
class MyVC : UIViewController {
  override func viewDidLoad() {
    // need to add `super.viewDidLoad()` here
    self.title = "Awesome Title"
  }
}
```

###### Example 2

```
class MyVCTest : XCTestCase {
  let myVC: MyVC!
  override func setUp() {
    // need to add `super.setUp()` here
    myVC = MyVC()
  }
}
```
