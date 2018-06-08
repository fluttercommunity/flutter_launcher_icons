[![Build Status](https://travis-ci.org/MarkOSullivan94/flutter_launcher_icons.svg?branch=master)](https://travis-ci.org/MarkOSullivan94/flutter_launcher_icons)

# Flutter Launcher Icons

A command-line tool which simplifies the task of updating your Flutter app's launcher icon. Fully flexible, allowing you to choose what platform you wish to update the launcher icon for and if you want, the option to keep your old launcher icon in case you want to revert back sometime in the future.


## :sparkles: What's New

##### Version 0.4.0 (8th June 2018)
 * Now possible to generate icons for each platform with different image paths - one for iOS icon and a separate one for Android (Thanks to PR #27 - Thank you!)

## :mag: Guide

1. Add dependency to your Flutter project's pubspec.yaml below any existing dependencies

```yaml
dev_dependencies: 
  flutter_test:
    sdk: flutter
    
  flutter_launcher_icons: "^0.4.0"
```

2. Within the same pubspec.yaml file, add flutter_icons config section

```
dev_dependencies: 
  flutter_test:
    sdk: flutter
    
  flutter_launcher_icons: "^0.4.0"
  
flutter_icons:
  image_path: "icon/icon.png"
  image_path_android: "icon/icon_android.png"
  image_path_ios: "icon/icon_ios.png"
  android: true
  ios: "Example-Icon"
```

### Attributes:
```
image_path: The location of the icon image file which you want to use as the app launcher icon

image_path_android: The location of the icon image file specific for Android platform (optional - if not defined then the image_path is used)
image_path_ios: The location of the icon image file specific for iOS platform (optional - if not defined then the image_path is used)

android/ios: True / False - Set as true if you want the icons generated for that platform to replace the existing launcher icon

OR

android/ios: <icon name> - Alternatively, enter an icon name if you wish to use a new launcher icon in the project whilst keeping the old one.
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
