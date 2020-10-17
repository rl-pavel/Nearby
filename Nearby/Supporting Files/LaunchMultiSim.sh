#!/bin/bash

# Source: https://buildingvts.com/launch-multiple-ios-simulators-on-a-single-compile-985fd2ad5eb1

xcrun simctl shutdown all

path=$(find ~/Library/Developer/Xcode/DerivedData/Nearby-*/Build/Products/Debug-iphonesimulator -name "Nearby.app" | head -n 1)
echo "${path}"


cd "./Nearby/Supporting Files/"
filename="MultiSimConfig.txt"
grep -v '^#' $filename | while read -r line
do
  echo "🔴 $line"
  xcrun instruments -w "$line"
  xcrun simctl install booted $path
  xcrun simctl launch booted com.op.Nearby
done
