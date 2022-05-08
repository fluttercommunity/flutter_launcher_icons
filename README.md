[![Flutter Community: flutter_launcher_icons](https://fluttercommunity.dev/_github/header/flutter_launcher_icons)](https://github.com/fluttercommunity/community)

[![Build Status](https://travis-ci.org/fluttercommunity/flutter_launcher_icons.svg?branch=master)](https://travis-ci.org/MarkOSullivan94/flutter_launcher_icons) [![pub package](https://img.shields.io/pub/v/flutter_launcher_icons.svg)](https://pub.dartlang.org/packages/flutter_launcher_icons)

# Flutter Launcher Icons

A command-line tool which simplifies the task of updating your Flutter app's launcher icon. Fully flexible, allowing you to choose what platform you wish to update the launcher icon for and if you want, the option to keep your old launcher icon in case you want to revert back sometime in the future.


## :sparkles: What's New

## 0.9.1 (**RELEASE DATE HERE**)
 - Support for web favicons and launcher icons (thanks to @personalizedrefrigerator).
 - Bug fixes and refactoring (thanks to @personalizedrefrigerator).

#### Version 0.9.0 (28th Feb 2021)
 - Null-safety support added (thanks to @SteveAlexander)
 - Added option to remove alpha channel for iOS icons (thanks to @SimonIT)

#### Version 0.8.1 (2nd Oct 2020)

- Fixed flavor support on windows (@slightfoot)

#### Version 0.8.0 (12th Sept 2020)

- Added flavours support (thanks to @sestegra & @jorgecoca)
- Removed unassigned iOS icons (thanks to @melvinsalas)
- Fixing formatting (thanks to @mreichelt)

#### Version 0.7.5 (24th Apr 2020)

- Fixed issue where new lines were added to Android manifest (thanks to @mreichelt)
- Improvements to code quality and general tidying up (thanks to @connectety)
- Fixed Android example project not running (needed to be migrated to AndroidX)

#### Version 0.7.4 (28th Oct 2019)
 * Worked on suggestions from [pub.dev](https://pub.dev/packages/flutter_launcher_icons#-analysis-tab-)

#### Version 0.7.3 (3rd Sept 2019)
 * Lot of refactoring and improving code quality (thanks to @connectety)
 * Added correct App Store icon settings (thanks to @richgoldmd)

#### Version 0.7.2 (25th May 2019)
 * Reverted back using old interpolation method

#### Version 0.7.1 (24th May 2019)
 * Fixed issue with image dependency not working on latest version of Flutter (thanks to @sboutet06)
 * Fixed iOS icon sizes which were incorrect (thanks to @sestegra)
 * Removed dart_config git dependency and replaced with yaml dependency

#### Version 0.7.0 (22nd November 2018)
 * Added check to ensure the Android file name is valid
 * Fixed issue where there was a git diff when there was no change
 * Fixed issue where iOS icon would be generated when it shouldn't be
 * Added support for drawables to be used for adaptive icon backgrounds
 * Added support for Flutter Launcher Icons to be able to run with it's own config file (no longer necessary to add to pubspec.yaml)

Want to see older changes? Be sure to check out the [Changelog](https://github.com/fluttercommunity/flutter_launcher_icons/blob/master/CHANGELOG.md).

## :book: Guide

#### 1. Setup the config file

Add your Flutter Launcher Icons configuration to your `pubspec.yaml` or create a new config file called `flutter_launcher_icons.yaml`.
An example is shown below. More complex examples [can be found in the example projects](https://github.com/fluttercommunity/flutter_launcher_icons/tree/master/example).
```yaml
dev_dependencies:
  flutter_launcher_icons: "^0.9.0"

flutter_icons:
  android: "launcher_icon"
  ios: true
  windows: true
  macos: false
  image_path: "assets/icon/icon.png"
```
If you name your configuration file something other than `flutter_launcher_icons.yaml` or `pubspec.yaml` you will need to specify
the name of the file when running the package.

```
flutter pub get
flutter pub run flutter_launcher_icons:main -f <your config file name here>
```

Note: If you are not using the existing `pubspec.yaml` ensure that your config file is located in the same directory as it.

#### 2. Run the package

After setting up the configuration, all that is left to do is run the package.

```
flutter pub get
flutter pub run flutter_launcher_icons:main
```

If you encounter any issues [please report them here](https://github.com/fluttercommunity/flutter_launcher_icons/issues).


In the above configuration, the package is setup to replace the existing launcher icons in both the Android and iOS project
with the icon located in the image path specified above and given the name "launcher_icon" in the Android project and "Example-Icon" in the iOS project.


## :mag: Attributes

Shown below is the full list of attributes which you can specify within your Flutter Launcher Icons configuration.

- `android`/`ios`/`web`/`macos`/`windows`
  - `true`: Override the default existing Flutter launcher icon for the platform specified
  - `false`: Ignore making launcher icons for this platform

- `android`/`ios`
  - `icon/path/here.png`: This will generate a new launcher icon set for the platform with the name you specify, without removing the old default existing Flutter launcher icon.

- `image_path`: The location of the icon image file which you want to use as the app launcher icon

- `image_path_android`: The location of the icon image file specific for Android platform (optional - if not defined then the `image_path` is used).

- `image_path_ios`: The location of the icon image file specific for iOS platform (optional - if not defined then the `image_path` is used).

- `image_path_web`: The location of the image file to be used for the web favicon and launcher (optional - if not defined, `image_path` is used).

- `image_path_macos`: The location of the icon image file specific for macOS platform (optional - if not defined then the image_path is used)

- `image_path_windows`: The location of the icon image file specific for windows platform (optional - if not defined then the image_path is used)

_Note: iOS icons should [fill the entire image](https://stackoverflow.com/questions/26014461/black-border-on-my-ios-icon) and not contain transparent borders._

The next two attributes are only used when generating Android launcher icons

- `adaptive_icon_background`: The color (E.g. `"#ffffff"`) or image asset (E.g. `"assets/images/christmas-background.png"`) which will
be used to fill out the background of the adaptive icon.

- `adaptive_icon_foreground`: The image asset which will be used for the icon foreground of the adaptive icon

## Flavor support

Create a Flutter Launcher Icons configuration file for your flavor. The config file is called `flutter_launcher_icons-<flavor>.yaml` by replacing `<flavor>` by the name of your desired flavor.

The configuration file format is the same.

An example project with flavor support enabled [has been added to the examples](https://github.com/fluttercommunity/flutter_launcher_icons/tree/master/example/flavors).

## :question: Troubleshooting

Some common issues and solutions!


#### Generated icon color is different from the original icon

Caused by an update to the image dependency which is used by Flutter Launcher Icons.

```
Use #AARRGGBB for colors instead of ##AABBGGRR, to be compatible with Flutter image class.
```

[Related issue](https://github.com/fluttercommunity/flutter_launcher_icons/issues/98)


#### Image foreground is too big / too small

For best results try and use a foreground image which has padding much like [the one in the example](https://github.com/fluttercommunity/flutter_launcher_icons/blob/master/example/default/assets/images/icon-foreground-432x432.png).

[Related issue](https://github.com/fluttercommunity/flutter_launcher_icons/issues/96)

#### Can't run web example project!

Make sure that you have enabled web support!

To check whether you have, try running `flutter devices`.

You should see a line similar to the following in its output:

```
Web Server (web) • web-server • web-javascript • Flutter Tools
```

If you don't, please [enable web support!](https://flutter.dev/docs/get-started/web#set-up)

#### Launcher icons not present in debug mode

`favicon.png` may not be served with `index.html` when `flutter run -d web-server` is used. Try this!
```bash
$ flutter build web
$ cd build/web
$ python3 -m http.server
```

Favicons should now be present!

#### `flutter run --flavor` doesn't work with web!

`flutter run --flavor` is currently an [`android` and `iOS` specific feature!](https://github.com/flutter/flutter/issues/59388)

To make this work with `flutter_launcher_icons`, say that you have the following flavor-specific configuration files:

`flutter_launcher_icons-development.yaml`
```yaml
flutter_icons:
  android: true
  ios: true
  image_path: "assets/launcher_icon/demo-icon-dev.png"
```

`flutter_launcher_icons-integration.yaml`
```yaml
flutter_icons:
  android: true
  ios: true
  image_path: "assets/launcher_icon/demo-icon-int.png"
```

`flutter_launcher_icons-production.yaml`
```yaml
flutter_icons:
  android: true
  ios: true
  image_path: "assets/launcher_icon/demo-icon.png"
```

We can tell `flutter_launcher_icons` to only generate web icons for the `production` flavor:

`flutter_launcher_icons-development.yaml`
```yaml
flutter_icons:
  android: true
  ios: true
  web: false
  image_path: "assets/launcher_icon/demo-icon-dev.png"
```

`flutter_launcher_icons-integration.yaml`
```yaml
flutter_icons:
  android: true
  ios: true
  web: false
  image_path: "assets/launcher_icon/demo-icon-int.png"
```

`flutter_launcher_icons-production.yaml`
```yaml
flutter_icons:
  android: true
  ios: true
  web: true
  image_path: "assets/launcher_icon/demo-icon.png"
```

Using this, `flutter run --flavor <some flavor here>` will work for iOS and Android
and `web` will always use the production icon!

We make this change here, rather than in `pubspec.yaml` because
`flutter_launcher_icons` ignores any configuration information in
`pubspec.yaml` when flavor config files are present!

For a working example, please see [`example/flavors`](example/flavors)!

--------------------

## :eyes: Example

[![Video Example](https://i.imgur.com/R28hqdz.png)](https://www.youtube.com/watch?v=RjNAxwcP3Tc)

Note: This is showing a very old version (v0.0.5)

### Special thanks

- Thanks to Brendan Duncan for the underlying [image package](https://pub.dev/packages/image) to transform the icons.
- Big thank you to all the contributors to the project. Every PR / reported issue is greatly appreciated!
