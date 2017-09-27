Release Process
===============

* Bump the version number in `lib/cucumber/core/version.rb`
* Update `CHANGELOG.md` with the upcoming version number and create a new `In Git` section
* Now release it:

```
bundle update
bundle exec rake
git commit -m "Release X.Y.Z"
rake release
```
