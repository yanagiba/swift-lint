# Release Process

1. Make sure you have the latest master branch.
2. Create a release branch `release-x.y.z`.
3. Pump the version to x.y.z, and make sure `swift-ast` version is also right.
  - `Package.swift`
  - `Constant.swift`
  - `README.md`
4. Ensure your local swift version matches the one defined in `.swift-version` file.
5. `swift package update`
6. `make test`
7. `./dogFooding.sh`
8. Now commit your changes if any, and push `release-x.y.z` to your own folk.
9. Send out pull request to `yanagiba/swift-lint`.
10. Once Travis CI passes and the pull request is merged, tag `master` and release it on GitHub, the tag name is `vx.y.z` and release title is simply `x.y.z`. Write a short list of what's new as release note.

🎉

> **Warning:** all major, minor, patch versions are required, even when they might be `0`s.
