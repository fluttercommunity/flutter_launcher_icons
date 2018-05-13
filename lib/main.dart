import 'dart:async';
import 'package:flutter_launcher_icons/android.dart' as FlutterIconsAndroid;
import 'package:flutter_launcher_icons/ios.dart' as FlutterIconsIos;
import 'package:dart_config/default_server.dart';

start(List<String> arguments) {
  Future<Map> conf = loadConfig("pubspec.yaml");
  conf.then((Map config) {
    if (config['flutter_icons']['image_path'] != null) {
      var androidConfig = config['flutter_icons']['android'];
      var iosConfig = config['flutter_icons']['ios'];
      if (androidConfig == true || androidConfig is String) {
        FlutterIconsAndroid.convertAndroid(config);
      }
      if (iosConfig == true || iosConfig is String) {
        FlutterIconsIos.convertIos(config);
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