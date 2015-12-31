/*
   Copyright 2015 Ryuichi Saito, LLC

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

import PackageDescription

let package = Package(
    name: "swift-lint",
    targets: [
        Target(
            name: "swift-lint",
            dependencies: [
                "lint",
            ]
        ),
    ],
    dependencies: [
        .Package(url: "https://github.com/ryuichis/swift-ast", Version(0, 1, 3)),
        .Package(url: "https://github.com/kylef/Commander", majorVersion: 0)
    ],
    testDependencies: [
        .Package(url: "https://github.com/kylef/Spectre.git", majorVersion: 0),
    ]
)
