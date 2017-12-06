# Flutter Launcher Icons

A command-line tool to quickly generate launcher icons for both iOS and Android platforms within any Flutter project.

Note: The tool will replace the existing default launcher icons for Flutter projects and so if you wish to keep them, please make a backup before running this tool.


# Planned Features
 - Metadata to set icon attributes like. 
    - Round images
    - Padding
    - Shadow

# Guide

- Add dependency to pubspec.yaml below any existing dependencies

```yaml
dev_dependencies: 
  flutter_test:
    sdk: flutter
    
  flutter_launcher_icons: "^0.0.1"
```

- Add flutter_icons config section to pubspec file

```yaml
flutter_icons:
  image_path: "icon/icon.png" 
  android: true
  ios: false

#### Attributes: 
image_path: The location of the icon image file which you want to use as the app launcher icon

android/ios: True / False - Set as true if you want the icons generated for that platform
```

- Run the command to generate the icons

```
flutter pub get
flutter pub pub run flutter_launcher_icons:main
```

### Special thanks

Thanks to Brendan Duncan for the underlying image package to transform the pics. 
