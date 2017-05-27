#!/bin/bash

set -e

make

for f in $(find . -regex "\.\/Sources.*\.swift")
do
  echo $f
  .build/debug/swift-lint $@ $f
done

for f in $(find . -regex "\.\/Tests.*\.swift")
do
  echo $f
  .build/debug/swift-lint $@ $f
done

echo "Package.swift"
.build/debug/swift-lint $@ Package.swift
