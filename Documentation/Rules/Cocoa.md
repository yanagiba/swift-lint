# Cocoa Rules

## Must Call Super

<dl>
<dt>Identifier</dt>
<dd>must_call_super</dd>
<dt>File name</dt>
<dd>MustCallSuperRule.swift</dd>
<dt>Severity</dt>
<dd>Major</dd>
<dt>Category</dt>
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
