import 'package:path/path.dart' as path;

/// Relative path to android resource folder
String androidResFolder(String? flavor) => "android/app/src/${flavor ?? 'main'}/res/";

/// Relative path to android colors.xml file
String androidColorsFile(String? flavor) => "android/app/src/${flavor ?? 'main'}/res/values/colors.xml";

const String androidManifestFile = 'android/app/src/main/AndroidManifest.xml';
const String androidGradleFile = 'android/app/build.gradle';
const String androidLocalPropertiesFile = 'android/local.properties';
const String androidFileName = 'ic_launcher.png';
const String androidAdaptiveForegroundFileName = 'ic_launcher_foreground.png';
const String androidAdaptiveBackgroundFileName = 'ic_launcher_background.png';
String androidAdaptiveXmlFolder(String? flavor) => androidResFolder(flavor) + 'mipmap-anydpi-v26/';
const String androidDefaultIconName = 'ic_launcher';

const String iosDefaultIconFolder = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/';
const String iosAssetFolder = 'ios/Runner/Assets.xcassets/';
const String iosConfigFile = 'ios/Runner.xcodeproj/project.pbxproj';
const String iosDefaultIconName = 'Icon-App';

// web
/// favicon.ico size
const int kFaviconSize = 16;

/// Relative web direcotry path
String webDirPath = path.join('web');

/// Relative web icons directory path
String webIconsDirPath = path.join(webDirPath, 'icons');

/// Relative web manifest.json file path
String webManifestFilePath = path.join(webDirPath, 'manifest.json');
// todo: support for other images formats
/// Relative favicon.png path
String webFaviconFilePath = path.join(webDirPath, 'favicon.png');

/// Relative index.html file path
String webIndexFilePath = path.join(webDirPath, 'index.html');

/// Relative pubspec.yaml path
String pubspecFilePath = path.join('pubspec.yaml');

const String errorMissingImagePath =
    'Missing "image_path" or "image_path_android" + "image_path_ios" within configuration';
const String errorMissingPlatform = 'No platform specified within config to generate icons for.';
const String errorMissingRegularAndroid = 'Adaptive icon config found but no regular Android config. '
    'Below API 26 the regular Android config is required';
const String errorMissingMinSdk = 'Cannot not find minSdk from android/app/build.gradle or android/local.properties'
    'Specify minSdk in either android/app/build.gradle or android/local.properties';
const String errorIncorrectIconName = 'The icon name must contain only lowercase a-z, 0-9, or underscore: '
    'E.g. "ic_my_new_icon"';

String introMessage(String currentVersion) => '''
  ════════════════════════════════════════════
     FLUTTER LAUNCHER ICONS (v$currentVersion)                               
  ════════════════════════════════════════════
  ''';
