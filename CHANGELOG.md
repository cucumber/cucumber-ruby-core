# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org).

This document is formatted according to the principles of [Keep A CHANGELOG](http://keepachangelog.com).

Please visit [cucumber/CONTRIBUTING.md](https://github.com/cucumber/cucumber/blob/master/CONTRIBUTING.md) for more info on how to contribute to Cucumber.

## [Unreleased]
### Changed
- Now using a 2-tiered changelog to avoid any bugs when using polyglot-release
- More refactoring of the repo by fixing up a bunch of manual rubocop offenses (See PR for details)
  ([#259](https://github.com/cucumber/cucumber-ruby-core/pull/259) [#262](https://github.com/cucumber/cucumber-ruby-core/pull/262))
- In all `Summary` and `Result` classes, changed the `strict` argument into a keyword argument.
  See upgrading notes for [13.0.0.md](upgrading_notes/13.0.0.md#upgrading-to-1300)
  ([#261](https://github.com/cucumber/cucumber-ruby-core/pull/261))
- Permit usage of gherkin v27
- Fixed retried scenarios which are run after another scenario with a passed result are still counted as failed ([#250](https://github.com/cucumber/cucumber-ruby-core/pull/250)

## [12.0.0] - 2023-09-06
### Changed
- Update gherkin and messages minimum dependencies
- Added in new rubocop sub-gems for testing, pinning versions where appropriate
- Removed all redundant / incorrect rubocop config overrides (Placed in TODO file)
- Began to refactor the repo by initially fixing up a bunch of rubocop auto-fix offenses (See PRs for details)
  ([#257](https://github.com/cucumber/cucumber-ruby-core/pull/257) [#258](https://github.com/cucumber/cucumber-ruby-core/pull/258))

### Removed
- Remove support for ruby 2.4 and below. 2.5 or higher is required now

## [11.1.0] - 2022-12-22
### Changed
- Update gherkin and messages dependencies

### Fixed
- Restore support for matching a scenario by tag and step line numbers. ([#237](https://github.com/cucumber/cucumber-ruby-core/pull/237), [#238](https://github.com/cucumber/cucumber-ruby-core/pull/238), [#239](https://github.com/cucumber/cucumber-ruby-core/pull/239))

## [11.0.0] - 2022-05-18
### Changed
- Updated `cucumber-gherkin` and `cucumber-messages`

[Unreleased]: https://github.com/cucumber/cucumber-ruby-core/compare/v12.0.0...main
[12.0.0]: https://github.com/cucumber/cucumber-ruby-core/compare/v11.1.0...v12.0.0
[11.1.0]: https://github.com/cucumber/cucumber-ruby-core/compare/v11.0.0...v11.1.0
[11.0.0]: https://github.com/cucumber/cucumber-ruby-core/compare/v10.1.1...v11.0.0
