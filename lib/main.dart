import 'dart:async';

import 'package:dart_config/default_server.dart';
import 'package:flutter_launcher_icons/android.dart' as AndroidLauncherIcons;
import 'package:flutter_launcher_icons/ios.dart' as IOSLauncherIcons;
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/constants.dart';

createIcons(List<String> arguments) async {
  loadConfigFile("pubspec.yaml").then((Map flutterLauncherIconsYamlConfig) {
    Map flutterLauncherIconsConfig = loadFlutterIconsConfig(flutterLauncherIconsYamlConfig);
    if (!isImagePathInConfig(flutterLauncherIconsConfig)) {
      throw InvalidConfigException(errorMissingImagePath);
    }
    if (!hasAndroidOrIOSConfig(flutterLauncherIconsConfig)) {
      throw InvalidConfigException(errorMissingPlatform);
    }
    var minSdk = AndroidLauncherIcons.minSdk();
    if (minSdk < 26 && hasAndroidAdaptiveConfig(flutterLauncherIconsConfig) &&
        !hasAndroidConfig(flutterLauncherIconsConfig)) {
      throw InvalidConfigException(errorMissingRegularAndroid);
    }

    if (isNeedingNewAndroidIcon(flutterLauncherIconsConfig)) {
      AndroidLauncherIcons.createDefaultIcons(flutterLauncherIconsConfig);
    }
    if (hasAndroidAdaptiveConfig(flutterLauncherIconsConfig)) {
      AndroidLauncherIcons.createAdaptiveIcons(flutterLauncherIconsConfig);
    }
    if (isNeedingNewIOSIcon(flutterLauncherIconsConfig)) {
      IOSLauncherIcons.createIcons(flutterLauncherIconsConfig);
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

bool isImagePathInConfig(Map flutterLauncherIconsConfig) {
  return flutterLauncherIconsConfig.containsKey("image_path") || (flutterLauncherIconsConfig.containsKey("image_path_android") && flutterLauncherIconsConfig.containsKey("image_path_ios"));
}

bool hasAndroidOrIOSConfig(Map flutterLauncherIconsConfig) {
  return flutterLauncherIconsConfig.containsKey("android") || flutterLauncherIconsConfig.containsKey("ios");
}

bool hasAndroidConfig(Map flutterLauncherIcons) {
  return flutterLauncherIcons.containsKey("android");
}

bool isNeedingNewAndroidIcon(Map flutterLauncherIconsConfig) {
  if (hasAndroidConfig(flutterLauncherIconsConfig)) {
    if (flutterLauncherIconsConfig['android'] != false) {
      return true;
    }
  }
  return false;
}

bool hasAndroidAdaptiveConfig(Map flutterLauncherIconsConfig) {
  return isNeedingNewAndroidIcon(flutterLauncherIconsConfig) &&
      flutterLauncherIconsConfig.containsKey("adaptive_icon_background") &&
      flutterLauncherIconsConfig.containsKey("adaptive_icon_foreground");
}

bool isMissingDefaultIconConfig(Map flutterLauncherIconsConfig) {
  var minSdk = AndroidLauncherIcons.minSdk();
  if (minSdk < 26 && hasAndroidAdaptiveConfig(flutterLauncherIconsConfig) &&
      !hasAndroidConfig(flutterLauncherIconsConfig)) {
    throw InvalidConfigException(errorMissingRegularAndroid);
  }
}

bool hasIOSConfig(Map flutterLauncherIconsConfig) {
  return flutterLauncherIconsConfig.containsKey("ios");
}

bool isNeedingNewIOSIcon(Map flutterLauncherIconsConfig) {
  if (hasIOSConfig(flutterLauncherIconsConfig)) {
    if (flutterLauncherIconsConfig["ios"] != false) {
      return true;
    }
  }
  return false;
}
