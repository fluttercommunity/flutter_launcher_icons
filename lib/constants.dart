String androidResFolder(String? flavor) =>
    "android/app/src/${flavor ?? 'main'}/res/";
String androidColorsFile(String? flavor) =>
    "android/app/src/${flavor ?? 'main'}/res/values/colors.xml";
const String androidManifestFile = 'android/app/src/main/AndroidManifest.xml';
const String androidGradleFile = 'android/app/build.gradle';
const String androidLocalPropertiesFile = 'android/local.properties';
const String androidFileName = 'ic_launcher.png';
const String androidAdaptiveForegroundFileName = 'ic_launcher_foreground.png';
const String androidAdaptiveBackgroundFileName = 'ic_launcher_background.png';
String androidAdaptiveXmlFolder(String? flavor) =>
    androidResFolder(flavor) + 'mipmap-anydpi-v26/';
const String androidDefaultIconName = 'ic_launcher';

const String iosDefaultIconFolder =
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/';
const String iosAssetFolder = 'ios/Runner/Assets.xcassets/';
const String iosConfigFile = 'ios/Runner.xcodeproj/project.pbxproj';
const String iosDefaultIconName = 'Icon-App';

const String errorMissingImagePath =
    'Missing "image_path" or "image_path_android" + "image_path_ios" within configuration';
const String errorMissingPlatform =
    'No platform specified within config to generate icons for.';
const String errorMissingRegularAndroid =
    'Adaptive icon config found but no regular Android config. '
    'Below API 26 the regular Android config is required';
const String errorMissingMinSdk = '''
Cannot find minSdk in android/app/build.gradle or android/local.properties.
Cannot find min_sdk in pubspec.yaml or flutter_launcher_icons.yaml
Specify minSdk in android/app/build.gradle or android/local.properties
-- or --
Specify min_sdk in pubspec.yaml or flutter_launcher_icons.yaml
''';
const String errorIncorrectIconName =
    'The icon name must contain only lowercase a-z, 0-9, or underscore: '
    'E.g. "ic_my_new_icon"';

String introMessage(String currentVersion) => '''
  ════════════════════════════════════════════
     FLUTTER LAUNCHER ICONS (v$currentVersion)                               
  ════════════════════════════════════════════
  ''';
