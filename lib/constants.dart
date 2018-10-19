

final String android_res_folder = "android/app/src/main/res/";
final String android_colors_file = "android/app/src/main/res/values/colors.xml";
final String android_manifest_file = "android/app/src/main/AndroidManifest.xml";
final String android_gradle_file = "android/app/build.gradle";
final String android_file_name = "ic_launcher.png";
final String android_adaptive_foreground_file_name = "ic_launcher_foreground.png";
final String android_adaptive_xml_folder =  android_res_folder + "mipmap-anydpi-v26/";
final String android_default_icon_name = "ic_launcher";

final String ios_default_icon_folder =
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/";
final String ios_asset_folder = "ios/Runner/Assets.xcassets/";
final String ios_config_file = "ios/Runner.xcodeproj/project.pbxproj";
final String ios_default_icon_name = "Icon-App";

final String errorMissingImagePath = "Missing 'image_path' or 'image_path_android + image_path_ios' within configuration";
final String errorMissingPlatform = "No platform specified within config to generate icons for.";
final String errorMissingRegularAndroid = "Adaptive icon config found but no regular Android config. "
    "Below API 26 the regular Android config is required";