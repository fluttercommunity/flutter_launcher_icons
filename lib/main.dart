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
      throw InvalidConfigException(errorMissingImagePath);
    }
    if (!hasAndroidOrIOSConfig(config)) {
      throw InvalidConfigException(errorMissingPlatform);
    }
    var minSdk = AndroidLauncherIcons.minSdk();
    if (minSdk < 26 && hasAndroidAdaptiveConfig(config) &&
        !hasAndroidConfig(config)) {
      throw InvalidConfigException(errorMissingRegularAndroid);
    }

    if (isNeedingNewAndroidIcon(config)) {
      AndroidLauncherIcons.createIcons(config);
    }
    if (hasAndroidAdaptiveConfig(config)) {
      AndroidLauncherIcons.createAdaptiveIcons(config);
    }
    if (isNeedingNewIOSIcon(config)) {
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

bool isImagePathInConfig(Map flutterIconsConfig) {
  return flutterIconsConfig.containsKey("image_path") || (flutterIconsConfig.containsKey("image_path_android") && flutterIconsConfig.containsKey("image_path_ios"));
}

bool hasAndroidOrIOSConfig(Map flutterIconsConfig) {
  return flutterIconsConfig.containsKey("android") || flutterIconsConfig.containsKey("ios");
}

bool hasAndroidConfig(Map flutterIconsConfig) {
  return flutterIconsConfig.containsKey("android");
}

bool isNeedingNewAndroidIcon(Map flutterIconsConfig) {
  if (hasAndroidConfig(flutterIconsConfig)) {
    if (flutterIconsConfig['android'] != false) {
      return true;
    }
  }
  return false;
}

bool hasAndroidAdaptiveConfig(Map flutterIconsConfig) {
  return isNeedingNewAndroidIcon(flutterIconsConfig) &&
      flutterIconsConfig.containsKey("adaptive_icon_background") &&
      flutterIconsConfig.containsKey("adaptive_icon_foreground");
}

bool hasIOSConfig(Map flutterIconsConfig) {
  return flutterIconsConfig.containsKey("ios");
}

bool isNeedingNewIOSIcon(Map flutterIconsConfig) {
  if (hasIOSConfig(flutterIconsConfig)) {
    if (flutterIconsConfig["ios"] != false) {
      return true;
    }
  }
  return false;
}
