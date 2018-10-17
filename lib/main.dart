import 'dart:async';

import 'package:dart_config/default_server.dart';
import 'package:flutter_launcher_icons/android.dart' as AndroidLauncherIcons;
import 'package:flutter_launcher_icons/ios.dart' as IOSLauncherIcons;
import 'package:flutter_launcher_icons/custom_exceptions.dart';

createIcons(List<String> arguments) async {
  loadConfigFile("pubspec.yaml").then((Map yamlConfig) {
    Map config = loadFlutterIconsConfig(yamlConfig);
    if (!isImagePathInConfig(config)) {
      print("Missing 'image_path' or 'image_path_android + image_path_ios' within configuration");
      return;
    }
    if (!hasAndroidOrIOSConfig(config)) {
      print("Error: No platform specified within config to generate icons for.");
      return;
    }
    var minSdk = AndroidLauncherIcons.minSdk();
    if(minSdk < 26 && hasAndroidAdaptiveConfig(config) && !hasAndroidConfig(config)){
      print("Error: Adaptive icon config found but no regular Android config. Below API 26 the regular Android config is required");
      return;
    }

    if (hasAndroidConfig(config)) {
      try {
        AndroidLauncherIcons.createIcons(config);
      } on Exception catch (e) {
        print(e.toString());
        return;
      }
    }
    if (hasAndroidAdaptiveConfig(config)) {
      AndroidLauncherIcons.createAdaptiveIcons(config);
    }
    if (hasIOSConfig(config)) {
      IOSLauncherIcons.createIcons(config);
    }
  });
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
