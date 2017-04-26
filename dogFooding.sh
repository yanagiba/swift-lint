#!/bin/bash

set -e

make
for f in $(find . -regex ".*\.swift")
do
  .build/debug/swift-lint $@ $f
done
