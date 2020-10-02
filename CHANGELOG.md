# Changelog

## 0.8.1 (2nd Oct 2020)

- Fixed flavor support on windows (@slightfoot)

## 0.8.0 (12th Sept 2020)

- Added flavours support (thanks to @sestegra & @jorgecoca)
- Removed unassigned iOS icons (thanks to @melvinsalas)
- Fixing formatting (thanks to @mreichelt)

## 0.7.5 (24th April 2020)

- Fixed issue where new lines were added to Android manifest (thanks to @mreichelt)
- Improvements to code quality and general tidying up (thanks to @connectety)
- Fixed Android example project not running (needed to be migrated to AndroidX)

## 0.7.4 (28th Oct 2019)

- Worked on suggestions from [pub.dev](https://pub.dev/packages/flutter_launcher_icons#-analysis-tab-)

## 0.7.3 (3rd Sept 2019)

- Lot of refactoring and improving code quality (thanks to @connectety)
- Added correct App Store icon settings (thanks to @richgoldmd)


## 0.7.2 (25th May 2019)

- Reverted back using old interpolation method


## 0.7.1 (24th May 2019)

- Fixed issue with image dependency not working on latest version of Flutter (thanks to @sboutet06)
- Fixed iOS icon sizes which were incorrect (thanks to @sestegra)
- Removed dart_config git dependency and replaced with yaml dependency
- Refactoring of code

## 0.7.0 (22nd November 2018)

 - Now ensuring that the Android file name is valid - An error will be thrown if it doesn't meet the criteria
 - Fixed issue where there was a git diff when there was no change
 - Fixed issue where iOS icon would be generated when it shouldn't be
 - Added support for drawables to be used for adaptive icon backgrounds
 - Added support for Flutter Launcher Icons to be able to run with it's own config file (no longer necessary to add to pubspec.yaml)

## 0.6.1 (26th August 2018)

- Upgraded test package
- Due to issue with dart_config not working with Dart 2.1.0, now using forked version of dart_config which contains fixes from both @v3rm0n and @SPodjasek

## 0.6.0 (8th August 2018)

- Moved the package to [Flutter Community](https://github.com/fluttercommunity/community)

## 0.5.2 (19th June 2018)

- Previous release didn't fix adaptive icons, just prevented the error message from appearing. This should hopefully fix it!

## 0.5.1 (18th June 2018)

- Fix for adaptive icons

## 0.5.0 (12th June 2018)

- [Android] Support for adaptive icons added (Suggestion #23)


## 0.4.0 (9th June 2018)

- Now possible to generate icons for each platform with different image paths (one for iOS icon and a separate one for Android)


## 0.3.3 (28th May 2018)

- Upgraded dart image package dependency to 2.0.0 (issue #26)


## 0.3.2 (2nd May 2018)

- Bug fixing


## 0.3.1 (1st May 2018)

- Bug fixing


## 0.3.0 (1st May 2018)

- Fixed issue where icons produced weren't the correct size (Due to images not with a 1:1 aspect r    ation)
- Improved quality of smaller icons produced (Thanks to PR #17 - Thank you!)
- Updated console printed messages to keep them consistent
- Added example folder to GitHub project

## 0.2.1 (25th April 2018)

- Added extra iOS icon size (1024x1024)
- Fixed iOS default icon name (Thanks to PR #15 - Thank you!)
- Fixed issue #10 where creation of the icons was failing due to the target folder not existing


## 0.2.0 (18th January 2018)

- Ability to create new launcher icons without replacing the old ones added (#6)
- Fixed issue with launcher icons for iOS not correctly being set

## 0.0.5

- Quick Fix on if statement

## 0.0.4

- Fixing strong mode error

## 0.0.3

- Adding flutter as a dependency so its listed as a flutter package.

## 0.0.2

- Fix Doc typo

## 0.0.1

- Initial version, Resizes Icon to Android sizes only.
