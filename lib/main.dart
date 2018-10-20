import 'dart:async';

import 'package:dart_config/default_server.dart';
import 'package:flutter_launcher_icons/android.dart' as AndroidLauncherIcons;
import 'package:flutter_launcher_icons/ios.dart' as IOSLauncherIcons;
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/constants.dart';

createIcons(List<String> arguments) async {
  loadConfigFile("pubspec.yaml").then((Map yamlConfig) {
    Map config = loadFlutterIconsConfig(yamlConfig);
    if (!isImagePathInConfig(config)) {
      throw new InvalidConfigException(errorMissingImagePath);
    }
    if (!hasAndroidOrIOSConfig(config)) {
      throw new InvalidConfigException(errorMissingPlatform);
    }
    var minSdk = AndroidLauncherIcons.minSdk();
    if (minSdk < 26 && hasAndroidAdaptiveConfig(config) &&
        !hasAndroidConfig(config)) {
      throw new InvalidConfigException(errorMissingRegularAndroid);
    }

    if (hasAndroidConfig(config)) {
      AndroidLauncherIcons.createIcons(config);
    }
    if (hasAndroidAdaptiveConfig(config)) {
      AndroidLauncherIcons.createAdaptiveIcons(config);
    }
    if (hasIOSConfig(config)) {
      IOSLauncherIcons.createIcons(config);
    }
  }).catchError((e) => print(e.toString()));
}

Future<Map> loadConfigFile(String path) async {
  var config = await loadConfig(path);
  return config;
}

Map loadFlutterIconsConfig(Map config) {
  return config["flutter_icons"];
}

bool isImagePathInConfig(Map flutter_icons_config) {
  return flutter_icons_config.containsKey("image_path") || (flutter_icons_config.containsKey("image_path_android") && flutter_icons_config.containsKey("image_path_ios"));
}

bool hasAndroidOrIOSConfig(Map flutter_icons_config) {
  return flutter_icons_config.containsKey("android") || flutter_icons_config.containsKey("ios");
}

bool hasAndroidConfig(Map flutter_icons_config) {
  return flutter_icons_config.containsKey("android");
}

bool hasAndroidAdaptiveConfig(Map flutter_icons_config) {
  return flutter_icons_config.containsKey("android") &&
      flutter_icons_config.containsKey("adaptive_icon_background") &&
      flutter_icons_config.containsKey("adaptive_icon_foreground");
}

bool hasIOSConfig(Map flutter_icons_config) {
  return flutter_icons_config.containsKey("ios");
}
