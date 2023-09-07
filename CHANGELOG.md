# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org).

This document is formatted according to the principles of [Keep A CHANGELOG](http://keepachangelog.com).

Please visit [cucumber/CONTRIBUTING.md](https://github.com/cucumber/cucumber/blob/master/CONTRIBUTING.md) for more info on how to contribute to Cucumber.

## [Unreleased]

## [12.0.0] - 2023-09-06
### Changed
- Update gherkin and messages minimum dependencies
- Added in new rubocop sub-gems for testing, pinning versions where appropriate
- Removed all redundant / incorrect rubocop config overrides (Placed in TODO file)

### Removed
- Remove support for ruby 2.4 and below. 2.5 or higher is required now

## [11.1.0] - 2022-12-22
### Changed
- Update gherkin and messages dependencies

### Fixed
- Restore support for matching a scenario by tag and step line numbers. ([#237](https://github.com/cucumber/cucumber-ruby-core/pull/237), [#238](https://github.com/cucumber/cucumber-ruby-core/pull/238), [#239](https://github.com/cucumber/cucumber-ruby-core/pull/239))

## [11.0.0]
### Changed
- Updated `cucumber-gherkin` and `cucumber-messages`

[Unreleased]: https://github.com/cucumber/cucumber-ruby-core/compare/v10.1.1...main
[12.0.0]: https://github.com/cucumber/cucumber-ruby-core/compare/v10.1.1...main
[11.1.0]: https://github.com/cucumber/cucumber-ruby-core/compare/v10.1.1...main
[11.0.0]: https://github.com/cucumber/cucumber-ruby-core/compare/v10.1.1...v11.0.0
[10.1.1]: https://github.com/cucumber/cucumber-ruby-core/compare/v10.1.0...v10.1.1
