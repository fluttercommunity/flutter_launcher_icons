[![Flutter Community: flutter_launcher_icons](https://fluttercommunity.dev/_github/header/flutter_launcher_icons)](https://github.com/fluttercommunity/community)

[![Build Status](https://travis-ci.org/fluttercommunity/flutter_launcher_icons.svg?branch=master)](https://travis-ci.org/MarkOSullivan94/flutter_launcher_icons) [![pub package](https://img.shields.io/pub/v/flutter_launcher_icons.svg)](https://pub.dartlang.org/packages/flutter_launcher_icons)

# Flutter Launcher Icons

A command-line tool which simplifies the task of updating your Flutter app's launcher icon. Fully flexible, allowing you to choose what platform you wish to update the launcher icon for and if you want, the option to keep your old launcher icon in case you want to revert back sometime in the future.


## :sparkles: What's New

#### Version 0.9.0 (28th Feb 2021)

- Null-safety support added (thanks to @SteveAlexander)
- Added option to remove alpha channel for iOS icons (thanks to @SimonIT)

#### Version 0.8.1 (2nd Oct 2020)

- Fixed flavor support on windows (@slightfoot)

#### Version 0.8.0 (12th Sept 2020)

- Added flavours support (thanks to @sestegra & @jorgecoca)
- Removed unassigned iOS icons (thanks to @melvinsalas)
- Fixing formatting (thanks to @mreichelt)

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

- `android`/`ios`
  - `true`: Override the default existing Flutter launcher icon for the platform specified
  - `false`: Ignore making launcher icons for this platform
  - `icon/path/here.png`: This will generate a new launcher icons for the platform with the name you specify, without removing the old default existing Flutter launcher icon.

- `image_path`: The location of the icon image file which you want to use as the app launcher icon

- `image_path_android`: The location of the icon image file specific for Android platform (optional - if not defined then the image_path is used)

- `image_path_ios`: The location of the icon image file specific for iOS platform (optional - if not defined then the image_path is used)

_Note: iOS icons should [fill the entire image](https://stackoverflow.com/questions/26014461/black-border-on-my-ios-icon) and not contain transparent borders._

The next two attributes are only used when generating Android launcher icon

- `adaptive_icon_background`: The color (E.g. `"#ffffff"`) or image asset (E.g. `"assets/images/christmas-background.png"`) which will
be used to fill out the background of the adaptive icon.

- `adaptive_icon_foreground`: The image asset which will be used for the icon foreground of the adaptive icon

## Flavor support

Create a Flutter Launcher Icons configuration file for your flavor. The config file is called `flutter_launcher_icons-<flavor>.yaml` by replacing `<flavor>` by the name of your desired flavor.

The configuration file format is the same.

An example project with flavor support enabled [has been added to the examples](https://github.com/fluttercommunity/flutter_launcher_icons/tree/master/example/flavors).

## :question: Troubleshooting

Listed a couple common issues with solutions for them


#### Generated icon color is different from the original icon

Caused by an update to the image dependency which is used by Flutter Launcher Icons.

```
Use #AARRGGBB for colors instead of ##AABBGGRR, to be compatible with Flutter image class.
```

[Related issue](https://github.com/fluttercommunity/flutter_launcher_icons/issues/98)


#### Image foreground is too big / too small

For best results try and use a foreground image which has padding much like [the one in the example](https://github.com/fluttercommunity/flutter_launcher_icons/blob/master/example/assets/images/icon-foreground-432x432.png).

[Related issue](https://github.com/fluttercommunity/flutter_launcher_icons/issues/96)

## :eyes: Example

[![Video Example](https://i.imgur.com/R28hqdz.png)](https://www.youtube.com/watch?v=RjNAxwcP3Tc)

Note: This is showing a very old version (v0.0.5)

### Special thanks

- Thanks to Brendan Duncan for the underlying [image package](https://pub.dev/packages/image) to transform the icons.
- Big thank you to all the contributors to the project. Every PR / reported issue is greatly appreciated!
