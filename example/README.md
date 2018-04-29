This example has been produced to allow for quick testing of the package, allow contributors and anyone interested in using this package, to quickly use an example.

There are numerous icon sizes available to test and all of these icons can be found in the `assets/images` directory.

Currently this example is set to use the latest version of the Flutter Launcher Icons package. However I've listed below the steps needed to use a local modified version of the package.

### Switching to use a local version of Flutter Launcher Icons

1. Add your flutter_launcher_icons within the example directory

2. Update pubspec.yaml to point to your local version of the package.


**Old Version**
```
dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_launcher_icons: "^0.2.1"

flutter_icons:
  image_path: "assets/images/icon-128x128.png"
  android: true
  ios: "My-Test-Icon"
```

**New Version**
```
dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_launcher_icons: 
    path: flutter_launcher_icons/

flutter_icons:
  image_path: "assets/images/icon-128x128.png"
  android: true
  ios: "My-Test-Icon"
```
