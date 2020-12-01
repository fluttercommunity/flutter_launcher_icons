import 'utils.dart';

String androidResFolder(String flavor) =>
    "android/app/src/${flavor ?? 'main'}/res/";
String androidColorsFile(String flavor) =>
    "android/app/src/${flavor ?? 'main'}/res/values/colors.xml";
const String androidManifestFile = 'android/app/src/main/AndroidManifest.xml';
const String androidGradleFile = 'android/app/build.gradle';
const String androidFileName = 'ic_launcher.png';
const String androidAdaptiveForegroundFileName = 'ic_launcher_foreground.png';
const String androidAdaptiveBackgroundFileName = 'ic_launcher_background.png';
String androidAdaptiveXmlFolder(String flavor) =>
    androidResFolder(flavor) + 'mipmap-anydpi-v26/';
const String androidDefaultIconName = 'ic_launcher';

const String iosDefaultIconFolder =
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/';
const String iosAssetFolder = 'ios/Runner/Assets.xcassets/';
const String iosConfigFile = 'ios/Runner.xcodeproj/project.pbxproj';
const String iosDefaultIconName = 'Icon-App';

const String webFaviconLocation = 'web/';
const String webIconLocation = 'web/icons/';

const String errorMissingImagePath =
    'Missing "image_path" or "image_path_android" + "image_path_ios"'
    ' + "image_path_web" within configuration';
const String errorMissingPlatform =
    'No platform specified within config to generate icons for.';
const String errorMissingRegularAndroid =
    'Adaptive icon config found but no regular Android config. '
    'Below API 26 the regular Android config is required';
const String errorIncorrectIconName =
    'The icon name must contain only lowercase a-z, 0-9, or underscore: '
    'E.g. "ic_my_new_icon"';

const String errorWebCustomLocationNotSupported =
    'Icon generation for web does not support specification of a custom '
    'icon location! Please manually save a copy of the prefered icon theme '
    '(perhaps by making a copy and renaming it). Custom locations are not '
    'supported.';

String warningPlatformDirectoryMissing(String platformName) =>
    generateWarning(' Not generating icons for $platformName.'
        ' Platform $platformName is in config, but there is no'
        ' matching directory. If you want to generate icons for'
        ' $platformName, make sure you have support for $platformName'
        ' enabled and have run `flutter create .`'
        ' in the root directory of your project.');

const String currentVersion = '0.9.0';
const String introMessage = '''
  ════════════════════════════════════════════
     FLUTTER LAUNCHER ICONS (v$currentVersion)                               
  ════════════════════════════════════════════
  ''';

const String fileOption = 'file';
const String helpFlag = 'help';
const String defaultConfigFile = 'flutter_launcher_icons.yaml';
const String flavorConfigFilePattern = r'^flutter_launcher_icons-(.*).yaml$';
