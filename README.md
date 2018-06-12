[![Build Status](https://travis-ci.org/MarkOSullivan94/flutter_launcher_icons.svg?branch=master)](https://travis-ci.org/MarkOSullivan94/flutter_launcher_icons)

# Flutter Launcher Icons

A command-line tool which simplifies the task of updating your Flutter app's launcher icon. Fully flexible, allowing you to choose what platform you wish to update the launcher icon for and if you want, the option to keep your old launcher icon in case you want to revert back sometime in the future.


## :sparkles: What's New

#### Version 0.5.0 (12th June 2018)
 * [Android] Support for adaptive icons added (Thanks to PR #28 - Thank you!)


##### Version 0.4.0 (8th June 2018)
 * Now possible to generate icons for each platform with different image paths - one for iOS icon and a separate one for Android (Thanks to PR #27 - Thank you!)

## :mag: Guide

1. Add dependency to your Flutter project's pubspec.yaml below any existing dependencies

```yaml
dev_dependencies: 
  flutter_test:
    sdk: flutter
    
  flutter_launcher_icons: "^0.5.0"
```

2. Within the same pubspec.yaml file, add flutter_icons config section

```
dev_dependencies: 
  flutter_test:
    sdk: flutter
    
  flutter_launcher_icons: "^0.5.0"
  
flutter_icons:
  android: true 
  ios: "Example-Icon"
  image_path: "assets/icon/icon.png"
  image_path_android: "assets/icon/icon_android.png"
  image_path_ios: "assets/icon/icon_ios.png"
  adaptive_icon_background: "#FFFAFAFA"
  adaptive_icon_foreground: "assets/icon/icon-foreground.png"
```

### Attributes:
```
android/ios: True / False OR <Icon Name> - Specify whether or not you want to override the existing launcher icon or create a new one and switch to it (while keeping the old one there)

image_path: The location of the icon image file which you want to use as the app launcher icon

image_path_android: The location of the icon image file specific for Android platform (optional - if not defined then the image_path is used)

image_path_ios: The location of the icon image file specific for iOS platform (optional - if not defined then the image_path is used)


Note: The next two attributes are only necessary if you want to have an adaptive icon for the Android app of your Flutter project.

adaptive_icon_background: The color which will be used to fill out the background of the adaptive icon.

adaptive_icon_foreground: The image asset which will be used for the icon foreground of the adaptive icon
```

3. Run the command to generate the icons

```
flutter pub get
flutter pub pub run flutter_launcher_icons:main
```

## :eyes: Example

[![Video Example](https://img.youtube.com/vi/RjNAxwcP3Tc/0.jpg)](https://www.youtube.com/watch?v=RjNAxwcP3Tc)

Note: This is showing v0.0.5.

### Special thanks

- Thanks to Brendan Duncan for the underlying image package to transform the pics. 
- Big thank you to all the contributors to the project. Every PR / reported issue is greatly appreciated! 
