# Release process for cucumber-core

## Prerequisites

To release `cucumber-core`, you'll need:

- to be a member of the core-team
- make
- docker

## Releasing cucumber-core

- Upgrade gems with `scripts/update-gemspec`
- Bump the version number in `lib/cucumber/core/version.rb`
- Update `CHANGELOG.md` with the upcoming version number and create a new `In Git` section
- Remove empty sections from `CHANGELOG.md`
- Commit the changes using a verified signature
  ```shell
  git commit --gpg-sign -am "Release X.Y.Z"
  ```
- Now release it:
  ```shell
  make release
  ```
- Check the release has been successfully pushed to [rubygems](https://rubygems.org/gems/cucumber-core)
