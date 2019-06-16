import 'dart:io';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart';
import 'package:flutter_launcher_icons/android.dart' as android_launcher_icons;
import 'package:flutter_launcher_icons/ios.dart' as ios_launcher_icons;
import 'package:flutter_launcher_icons/constants.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';

const String fileOption = 'file';
const String helpFlag = 'help';
const String defaultConfigFile = 'flutter_launcher_icons.yaml';

Future<void> createIconsFromArguments(List<String> arguments) async {
  final ArgParser parser = ArgParser(allowTrailingOptions: true);
  parser.addFlag(helpFlag, abbr: 'h', help: 'Usage help', negatable: false);
  // Make default null to differentiate when it is explicitly set
  parser.addOption(fileOption,
      abbr: 'f', help: 'Config file (default: $defaultConfigFile)');
  final ArgResults argResults = parser.parse(arguments);

  if (argResults[helpFlag]) {
    stdout.writeln('Generates icons for iOS and Android');
    stdout.writeln(parser.usage);
    exit(0);
  }

  // Load the config file
  final Map<String, dynamic> yamlConfig = loadConfigFileFromArgResults(argResults, verbose: true);

  // Create icons
  try {
    createIconsFromConfig(yamlConfig);
  } catch (e) {
    stderr.writeln(e);
    exit(2);
  }
}

Future<void> createIconsFromConfig(Map<String, dynamic> config) async {
  if (!isImagePathInConfig(config)) {
    throw const InvalidConfigException(errorMissingImagePath);
  }
  if (!hasAndroidOrIOSConfig(config)) {
    throw const InvalidConfigException(errorMissingPlatform);
  }
  final int minSdk = android_launcher_icons.minSdk();
  if (minSdk < 26 &&
      hasAndroidAdaptiveConfig(config) &&
      !hasAndroidConfig(config)) {
    throw const InvalidConfigException(errorMissingRegularAndroid);
  }

  if (isNeedingNewAndroidIcon(config)) {
    android_launcher_icons.createDefaultIcons(config);
  }
  if (hasAndroidAdaptiveConfig(config)) {
    android_launcher_icons.createAdaptiveIcons(config);
  }
  if (isNeedingNewIOSIcon(config)) {
    ios_launcher_icons.createIcons(config);
  }
}

Map<String, dynamic> loadConfigFileFromArgResults(ArgResults argResults,
    {bool verbose}) {
  verbose ??= false;
  final String configFile = argResults[fileOption];
  final String fileOptionResult = argResults[fileOption];

  Map<String, dynamic> yamlConfig;
  // If none set try flutter_launcher_icons.yaml first then pubspec.yaml
  // for compatibility
  if (configFile == defaultConfigFile || configFile == null) {
    try {
      yamlConfig = loadConfigFile(defaultConfigFile, fileOptionResult);
    } catch (e) {
      if (configFile == null) {
        try {
          // Try pubspec.yaml for compatibility
          yamlConfig = loadConfigFile('pubspec.yaml', fileOptionResult);
        } catch (_) {
          if (verbose) {
            stderr.writeln(e);
          }
        }
      } else {
        if (verbose) {
          stderr.writeln(e);
        }
      }
    }
  } else {
    try {
      yamlConfig = loadConfigFile(configFile, fileOptionResult);
    } catch (e) {
      if (verbose) {
        stderr.writeln(e);
      }
    }
  }
  return yamlConfig;
}

Map<String, dynamic> loadConfigFile(String path, String fileOptionResult) {
  final File file = File(path);
  final String yamlString = file.readAsStringSync();
  final Map yamlMap = loadYaml(yamlString);

  if (yamlMap == null || !(yamlMap['flutter_icons'] is Map)) {
    stderr.writeln(NoConfigFoundException('Check that your config file '
        '`${fileOptionResult ?? defaultConfigFile}`'
        ' has a `flutter_icons` section'));
    exit(1);
  }
  Map yamlConfig = yamlMap['flutter_icons'];

  // the YamlMap object this uses has several unwanted sideefects
  final Map<String, dynamic> config = <String, dynamic>{};
  for (String key in yamlConfig.keys) {
    config[key] = yamlConfig[key];
  }

  return config;
}

bool isImagePathInConfig(Map<String, dynamic> flutterIconsConfig) {
  return flutterIconsConfig.containsKey('image_path') ||
      (flutterIconsConfig.containsKey('image_path_android') &&
          flutterIconsConfig.containsKey('image_path_ios'));
}

bool hasAndroidOrIOSConfig(Map<String, dynamic> flutterIconsConfig) {
  return flutterIconsConfig.containsKey('android') ||
      flutterIconsConfig.containsKey('ios');
}

bool hasAndroidConfig(Map<String, dynamic> flutterLauncherIcons) {
  return flutterLauncherIcons.containsKey('android');
}

bool isNeedingNewAndroidIcon(Map<String, dynamic> flutterLauncherIconsConfig) {
  return hasAndroidConfig(flutterLauncherIconsConfig) &&
      flutterLauncherIconsConfig['android'] != false;
}

bool hasAndroidAdaptiveConfig(Map<String, dynamic> flutterLauncherIconsConfig) {
  return isNeedingNewAndroidIcon(flutterLauncherIconsConfig) &&
      flutterLauncherIconsConfig.containsKey('adaptive_icon_background') &&
      flutterLauncherIconsConfig.containsKey('adaptive_icon_foreground');
}

bool hasIOSConfig(Map<String, dynamic> flutterLauncherIconsConfig) {
  return flutterLauncherIconsConfig.containsKey('ios');
}

bool isNeedingNewIOSIcon(Map<String, dynamic> flutterLauncherIconsConfig) {
  return hasIOSConfig(flutterLauncherIconsConfig) &&
      flutterLauncherIconsConfig['ios'] != false;
}
