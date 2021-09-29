# Release process for cucumber-core

## Prerequisites

To release `cucumber-core`, you'll need to be a member of the core team

## Releasing cucumber-core

- Upgrade gems with `scripts/update-gemspec`
- Bump the version number in `lib/cucumber/core/version.rb`
- Update `CHANGELOG.md` with the upcoming version number and create a new `In Git` section
- Remove empty sections from `CHANGELOG.md`
- Commit the changes using a verified signature, and push
  ```shell
  git commit --gpg-sign -am "Release X.Y.Z"
  git push
  ```
- To trigger the release process, `git push` to a dedicated `release/` branch:
  ```shell
  git push origin main:release/vX.Y.Z
  ```
- Monitor the [github workflow](https://github.com/cucumber/cucumber-ruby-core/actions/workflows/release.yml)
- Check the release has been successfully pushed to [rubygems](https://rubygems.org/gems/cucumber-core)
