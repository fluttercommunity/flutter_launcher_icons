import 'dart:async';
import 'package:flutter_launcher_icons/android.dart' as AndroidLauncherIcons;
import 'package:flutter_launcher_icons/ios.dart' as IOSLauncherIcons;
import 'package:dart_config/default_server.dart';

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
    } else {
      if (hasAndroidConfig(config)) {
        AndroidLauncherIcons.createIcons(config);
      }
      if (hasIOSConfig(config)) {
        IOSLauncherIcons.createIcons(config);
      }
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

// TODO
String isImagePathConfigValid(Map flutter_icons_config) {
  if (isImagePathInConfig(flutter_icons_config)) {

  } else {
    return "'image_path' missing from configuration";
  }
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

bool hasIOSConfig(Map flutter_icons_config) {
  return flutter_icons_config.containsKey("ios");
}
