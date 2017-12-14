# Flutter Launcher Icons

A command-line tool to quickly generate launcher icons for both iOS and Android platforms within any Flutter project.

Note: The tool will replace the existing default launcher icons for Flutter projects and so if you wish to keep them, please make a backup before running this tool.


# Planned Features
 - Metadata to set icon attributes like. 
    - Round images
    - Padding
    - Shadow

# Guide

- Add dependency to your Flutter project's pubspec.yaml below any existing dependencies

```yaml
dev_dependencies: 
  flutter_test:
    sdk: flutter
    
  flutter_launcher_icons: "^0.0.1"
```

- Within the same pubspec.yaml file, add flutter_icons config section

```
dev_dependencies: 
  flutter_test:
    sdk: flutter
    
  flutter_launcher_icons: "^0.0.1"
  
flutter_icons:
  image_path: "icon/icon.png" 
  android: true
  ios: false
```
```
#### Attributes: 
image_path: The location of the icon image file which you want to use as the app launcher icon

android/ios: True / False - Set as true if you want the icons generated for that platform
```

- Run the command to generate the icons

```
flutter pub get
flutter pub pub run flutter_launcher_icons:main
```

# Example

[![Video Example](https://img.youtube.com/vi/RjNAxwcP3Tc/0.jpg)](https://www.youtube.com/watch?v=RjNAxwcP3Tc)

### Special thanks

Thanks to Brendan Duncan for the underlying image package to transform the pics. 
