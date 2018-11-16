

final String androidResFolder = "android/app/src/main/res/";
final String androidColorsFile = "android/app/src/main/res/values/colors.xml";
final String androidManifestFile = "android/app/src/main/AndroidManifest.xml";
final String androidGradleFile = "android/app/build.gradle";
final String androidFileName = "ic_launcher.png";
final String androidAdaptiveForegroundFileName = "ic_launcher_foreground.png";
final String androidAdaptiveBackgroundFileName = "ic_launcher_background.png";
final String androidAdaptiveXmlFolder =  androidResFolder + "mipmap-anydpi-v26/";
final String androidDefaultIconName = "ic_launcher";

final String iosDefaultIconFolder =
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/";
final String iosAssetFolder = "ios/Runner/Assets.xcassets/";
final String iosConfigFile = "ios/Runner.xcodeproj/project.pbxproj";
final String iosDefaultIconName = "Icon-App";

final String errorMissingImagePath = "Missing 'image_path' or 'image_path_android + image_path_ios' within configuration";
final String errorMissingPlatform = "No platform specified within config to generate icons for.";
final String errorMissingRegularAndroid = "Adaptive icon config found but no regular Android config. "
    "Below API 26 the regular Android config is required";