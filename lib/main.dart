import 'dart:async';
import 'package:flutter_launcher_icons/android.dart' as AndroidLauncherIcons;
import 'package:flutter_launcher_icons/ios.dart' as IOSLauncherIcons;
import 'package:dart_config/default_server.dart';

createIcons(List<String> arguments) {
  Future<Map> conf = loadConfig("pubspec.yaml");
  conf.then((Map config) {
    if (config['flutter_icons']['image_path'] != null) {
      var androidConfig = config['flutter_icons']['android'];
      var iosConfig = config['flutter_icons']['ios'];
      if (androidConfig == true || androidConfig is String) {
        AndroidLauncherIcons.createIcons(config);
      }
      if (iosConfig == true || iosConfig is String) {
        IOSLauncherIcons.createIcons(config);
      }
      if (((androidConfig == false) && (iosConfig == false)) ||
          ((androidConfig == null) && (iosConfig == null))) {
        print(
            "Error: No platform has been specified to generate launcher icons for.");
      } else {
        print("Finished!");
      }
    } else {
      print("flutter_icons config not found in pubspec.yaml");
    }
  });
}

createIcons2(List<String> arguments) async {
  print("createIcons2");
  loadConfigFile("pubspec.yaml").then((Map pubspecConfig) {
    Map config = loadFlutterIconsConfig(pubspecConfig);
    print(config);
    if (!isImagePathInConfig(config)) {
      print(config.toString());
      print("Missing 'image_path' within configuration");
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
  return flutter_icons_config.containsKey("image_path");
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