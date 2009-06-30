#!/bin/sh
~/Scripts/clang/latest/scan-build --status-bugs -warn-objc-missing-dealloc xcodebuild -configuration Debug -sdk iphonesimulator3.0