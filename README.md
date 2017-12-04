# Flutter Launcher Icons

This command-line app will take a launcher image specified and export it to iOS & Android sizes.
- !This will replace any icons in the project folder.
- The project is is progress so not all features are available

# Current Features:
 - Convert icon to android version images and store them in res folder.

# Features in Progress
 - Convert icon to iOS Version images and set the icons.
 - Metadata to set icon attributes like. 
    - Round images
    - Padding
    - Shadow


# How to use. 

- Add dependency to pubspec.yaml 

```yaml
dependencies: 
  flutter_launcher_icons: "^0.0.1"
```

- Add flutter_icons config section to pubspec file

```yaml
flutter_icons:
  image_path: "icon/icon.png" 
  android: true
  ios: false

#### Attributes: 
image_path: The location of the squared image file to convert

android/ios: Whether to generate the icons or not. 
```


- Run the command to generate the images.

```
flutter pub pub run flutter_launcher_icons:main
```

### Special thanks

Thanks to Brendan Duncan for the underlying image package to transform the pics. 