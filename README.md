# Flutter Launcher Icons

A command-line tool to quickly generate launcher icons for both iOS and Android platforms within any Flutter project.

**Note:** The tool will replace the existing default launcher icons for Flutter projects and so if you wish to keep them, please make a backup before running this tool.


## :sparkles: What's New

##### Version 0.2.1 (25th April 2018)
 * Added extra iOS icon size (1024x1024)
 * Fixed iOS default icon name (Thanks to PR #25 - Thank you!)
 * Fixed issue #10 where the creation of the icons was failing due to the target folder not existing

## :mag: Guide

1. Add dependency to your Flutter project's pubspec.yaml below any existing dependencies

```yaml
dev_dependencies: 
  flutter_test:
    sdk: flutter
    
  flutter_launcher_icons: "^0.2.1"
```

2. Within the same pubspec.yaml file, add flutter_icons config section

```
dev_dependencies: 
  flutter_test:
    sdk: flutter
    
  flutter_launcher_icons: "^0.2.1"
  
flutter_icons:
  image_path: "icon/icon.png" 
  android: true
  ios: "Example-Icon"
```
```
#### Attributes: 
image_path: The location of the icon image file which you want to use as the app launcher icon

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

Thanks to Brendan Duncan for the underlying image package to transform the pics. 
