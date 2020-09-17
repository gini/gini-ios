# Release Process

This document describes the release process for a new version of the Gini Vision Library for iOS.

1. Add new features only in separate `feature` branches and merge them into `develop`
2. Create a `release` branch from `develop`
  * Update `s.version` in `Gini.podspec` and dependencies version
  * Add entry to changelog with version and date
3. Merge `release` branch into `master` and `develop`
4. Tag `master` branch with the same version used in 2
5. Push all branches to remote including tags
6. Wait for jenkins to pass
