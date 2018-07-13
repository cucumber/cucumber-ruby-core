Please see [CONTRIBUTING.md](https://github.com/cucumber/cucumber/blob/master/CONTRIBUTING.md) on how to contribute to Cucumber.

## [3.2.0](https://github.com/cucumber/cucumber-ruby-core/compare/v3.1.0...v3.2.0)

### Added

* Add the GherkinSourceParsedEvent ([#155](https://github.com/cucumber/cucumber-ruby-core/pull/155) @brasmusson)
* Add #original_location to Cucumber::Core::Ast::Step and Cucumber::Core::Test::Step ([#150](https://github.com/cucumber/cucumber-ruby-core/pull/150), [#149](https://github.com/cucumber/cucumber-ruby-core/issues/149) @brasmusson)

### Fixed

* Set message and backtrace for undefined result also when skipping (@brasmusson)

## [3.1.0](https://github.com/cucumber/cucumber-ruby-core/compare/v3.0.0...3.1.0)

### Changed

* Upgraded to `cucumber-tag_expressions` 1.1.0
* Upgraded to `gherkin` 5.0.0

## [3.0.0](https://github.com/cucumber/cucumber-ruby-core/compare/v3.0.0.pre.2...v3.0.0) (2017-09-27)

### Changed

* Step#name renamed to #text ([#137](https://github.com/cucumber/cucumber-ruby-core/pull/137) [@olleolleolle](https://github.com/olleolleolle))
* Use past tense in event names (`xStarting` -> `xStarted`) (see [cucumber/cucumber-ruby#1166](https://github.com/cucumber/cucumber-ruby/issues/1166) @brasmusson).

### Added

* Do not create test cases for scenarios with no steps ([#144](https://github.com/cucumber/cucumber-ruby-core/pull/144) @brasmusson)
* Handle selective strict settings ([#143](https://github.com/cucumber/cucumber-ruby-core/pull/143) @brasmusson)

### Fixed

* Fix DataTable's Location to be aware of all of its lines ([#142](https://github.com/cucumber/cucumber-ruby-core/pull/142) @botandrose)

### Improved

* As per [#251](https://github.com/cucumber/cucumber/issues/251): renamed History.md to CHANGELOG.md, added contributing message at beginning, and misc formatting. ([#145](https://github.com/cucumber/cucumber-ruby-core/pull/145) [jaysonesmith](https://github.com/jaysonesmith))

## [3.0.0.pre.2](https://github.com/cucumber/cucumber-ruby-core/compare/v2.0.0...3.0.0.pre.2) (2017-07-26)

### New Features

* Add a flaky result type to be used for flaky scenarios ([#141](https://github.com/cucumber/cucumber-ruby-core/pull/141), [cucumber/cucumber-ruby#1044](https://github.com/cucumber/cucumber-ruby/issues/1044) @brasmusson)
* Make the Summary report able to say if the total result is ok ([#140](https://github.com/cucumber/cucumber-ruby-core/pull/140) @brasmusson)
* Replay previous events to new subscribers ([#136](https://github.com/cucumber/cucumber-ruby-core/pull/136) @mattwynne)
* Ruby 2.4.0 compatibility ([#120](https://github.com/cucumber/cucumber-ruby-core/pull/120) @junaruga)
* Use tag expressions ([#116](https://github.com/cucumber/cucumber-ruby-core/pull/116) @brasmusson)
* Access example table row data by param name ([#118](https://github.com/cucumber/cucumber-ruby-core/pull/118) @enkessler)

### Bugfixes

N/A

### Removed Features

N/A

### Refactoring

* Travis: jruby-9.1.10.0 ([#130](https://github.com/cucumber/cucumber-ruby-core/pull/130) @olleolleolle)
* Travis: jruby-9.1.12.0 ([#133](https://github.com/cucumber/cucumber-ruby-core/pull/132) @olleolleolle)

## [2.0.0](https://github.com/cucumber/cucumber-ruby-core/compare/v1.5.0...2.0.0)

### New Features

* Implement equality for test cases ([#111](https://github.com/cucumber/cucumber-ruby-core/pull/111) @mattwynne)
* Implement an event bus (moved from Cucumber-Ruby) ([#106](https://github.com/cucumber/cucumber-ruby-core/pull/106) @mattwynne)
* Use frozen string literals ([#105](https://github.com/cucumber/cucumber-ruby-core/pull/105) @twalpole)

### Bugfixes

* Handle incomplete examples to scenario outlines. ([109](https://github.com/cucumber/cucumber-ruby-core/pull/109) @brasmusson)
* Add with_filtered_backtrace method to unknown result ([107](https://github.com/cucumber/cucumber-ruby-core/pull/107) @danascheider)

### Removed Features

* Remove support for Ruby v1.9.3. ([112](https://github.com/cucumber/cucumber-ruby-core/pull/112) @brasmusson)

### Refactoring

N/A

## [1.5.0](https://github.com/cucumber/cucumber-ruby-core/compare/v1.4.0...v1.5.0)

### New Features

 * Update to Gherkin v4.0 (@brasmusson)

### Bugfixes

 * Use monotonic time ([#103](https://github.com/cucumber/cucumber-ruby-core/pull/103) @mikz)

## [1.4.0](https://github.com/cucumber/cucumber-ruby-core/compare/v1.3.1...v1.4.0)

### New Features

 * Update to Gherkin v3.2.0 (@brasmusson)

### Bugfixes

## [1.3.1](https://github.com/cucumber/cucumber-ruby-core/compare/v1.3.0...v1.3.1)

### New Features

### Bugfixes

 * Speed up location filtering ([#99](https://github.com/cucumber/cucumber-ruby-core/issues/99) @mattwynne @akostadinov @brasmusson)

## [1.3.0](https://github.com/cucumber/cucumber-ruby-core/compare/v1.2.0...v1.3.0)

### New Features

 * Add factory method to Cucumber::Core::Ast::Location that uses the output from Proc#source_location (@brasmusson)
 * Integrate Gherkin3 parser (@brasmusson)

### Bugfixes

 * Make sure that `after_test_step` is sent also when a test step is interrupted by (a timeout in) an around hook ([cucumber/cucumber-ruby#909](https://github.com/cucumber/cucumber-ruby/issues/909) @brasmusson)
 * Improve the check that a test_step quacks like a Cucumber::Core::Test::Step ([95](https://github.com/cucumber/cucumber-ruby-core/issues/95) @brasmusson)

## [1.2.0](https://github.com/cucumber/cucumber-ruby-core/compare/v1.1.3...v1.2.0)

### New Features

 * Enable the location of actions to be the step or hook location (@brasmusson)
 * Add the comments to the Steps, Examples tables and Examples table rows Ast classes (@brasmusson)
 * Expose name, description and examples_rows attributes of `Ast::ExamplesTable` (@mattwynne)
 * Add #to_sym to Cucumber::Core::Test::Result classes ([#89](https://github.com/cucumber/cucumber-ruby-core/pull/89) @pdswan)
 * Add #ok? to Cucumber::Core::Test::Result classes ([#92](https://github.com/cucumber/cucumber-ruby-core/pull/92) @brasmusson)

### Bugfixes

## [1.1.3](https://github.com/cucumber/cucumber-ruby-core/compare/v1.1.2...v1.1.3)

### New Features

  * Added custom `inspect` methods for AST Nodes (@tooky)

## [1.1.2](https://github.com/cucumber/cucumber-ruby-core/compare/v1.1.1...v1.1.2)

### New Features

  * Make Test Case names for Scenario Outlines language neutral [83](https://github.com/cucumber/cucumber-ruby-core/pull/83) (@brasmusson)
  * Add predicate methods for Multline arguments (@mattwynne)
  * Expose `Test::Case#feature` (@mattwynne)
  * Fail test case if around hook fails (@mattwynne, @tooky)
  * Expose `Test::Case#around_hooks` (@tooky)

## [1.1.1](https://github.com/cucumber/cucumber-ruby-core/compare/v1.1.0...v1.1.1)


### New Features

  * Calculate actual keyword for snippets (@brasmusson)

### Bugfixes

  * Remove keyword from `Test::Case#name` [82](https://github.com/cucumber/cucumber-ruby-core/pull/82) (@richarda)

## [1.1.0](https://github.com/cucumber/cucumber-ruby-core/compare/v1.0.0...v1.1.0)

### New features

  * LocationsFilter now sorts test cases as well as filtering them (@mattwynne)

## [1.0.0](https://github.com/cucumber/cucumber-ruby-core/compare/v1.0.0.beta.4...v1.0.0)

### Features Removed

  * Removed the Mapper DSL (@mattwynne, @tooky)
  * Removed Cucumber.initializer (@tooky)

### New Features

  * Added dynamic filter class constructor (@mattwynne)

## [1.0.0.beta.4](https://github.com/cucumber/cucumber-ruby-core/compare/v1.0.0.beta.3...v1.0.0.beta.4)

### New Features

 * Introduce a Duration object (#[71](https://github.com/cucumber/cucumber-ruby-core/pull/71) [@brasmusson](https://github.com/brasmusson))
 * BeforeStep hooks (#[70](https://github.com/cucumber/cucumber-ruby-core/pull/70) [@almostwhitehat](https://github.com/almostwhitehat))
 * Expose `Test::Case#test_steps` (@mattwynne)

### Bugfixes

 * Handle empty feature files (#[77](https://github.com/cucumber/cucumber-ruby-core/pull/77), [cucumber/cucumber-ruby#771](https://github.com/cucumber/cucumber-ruby/issues/771) [@brasmusson](https://github.com/brasmusson))
 * Run after hooks in reverse order (#[69](https://github.com/cucumber/cucumber-ruby-core/pull/69) [@erran](https://github.com/erran))

## [1.0.0.beta.3](https://github.com/cucumber/cucumber-ruby-core/compare/v1.0.0.beta.2...v1.0.0.beta.3)

Changes were not logged.

## [1.0.0.beta.2](https://github.com/cucumber/cucumber-ruby-core/compare/v1.0.0.beta.1...v1.0.0.beta.2)

Changes were not logged.
