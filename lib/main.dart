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

void createIconsFromArguments(List<String> arguments) async {
  ArgParser parser = ArgParser(allowTrailingOptions: true);
  parser.addFlag(helpFlag, abbr: 'h', help: 'Usage help', negatable: false);
  // Make default null to differentiate when it is explicitly set
  parser.addOption(fileOption,
      abbr: 'f', help: 'Config file (default: $defaultConfigFile)');
  ArgResults argResults = parser.parse(arguments);

  if (argResults[helpFlag]) {
    stdout.writeln('Generates icons for iOS and Android');
    stdout.writeln(parser.usage);
    exit(0);
  }

  // Load the config file
  Map yamlConfig = loadConfigFileFromArgResults(argResults, verbose: true);
  if (yamlConfig == null || !(yamlConfig['flutter_icons'] is Map)) {
    stderr.writeln(NoConfigFoundException('Check that your config file '
        '`${argResults[fileOption] ?? defaultConfigFile}`'
        ' has a `flutter_icons` section'));
    exit(1);
  }

  // Create icons
  try {
    createIconsFromConfig(yamlConfig);
  } catch (e) {
    stderr.writeln(e);
    exit(2);
  }
}

void createIconsFromConfig(Map yamlConfig) async {
  Map config = loadFlutterIconsConfig(yamlConfig);
  if (!isImagePathInConfig(config)) {
    throw InvalidConfigException(errorMissingImagePath);
  }
  if (!hasAndroidOrIOSConfig(config)) {
    throw InvalidConfigException(errorMissingPlatform);
  }
  int minSdk = android_launcher_icons.minSdk();
  if (minSdk < 26 &&
      hasAndroidAdaptiveConfig(config) &&
      !hasAndroidConfig(config)) {
    throw InvalidConfigException(errorMissingRegularAndroid);
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

Map loadConfigFileFromArgResults(ArgResults argResults,
    {bool verbose}) {
  verbose ??= false;
  String configFile = argResults[fileOption];

  Map yamlConfig;
  // If none set try flutter_launcher_icons.yaml first then pubspec.yaml
  // for compatibility
  if (configFile == defaultConfigFile || configFile == null) {
    try {
      yamlConfig = loadConfigFile(defaultConfigFile);
    } catch (e) {
      if (configFile == null) {
        try {
          // Try pubspec.yaml for compatibility
          yamlConfig = loadConfigFile('pubspec.yaml');
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
      yamlConfig = loadConfigFile(configFile);
    } catch (e) {
      if (verbose) {
        stderr.writeln(e);
      }
    }
  }
  return yamlConfig;
}

Map loadConfigFile(String path) {
  File file = File(path);
  String yamlString = file.readAsStringSync();
  return loadYaml(yamlString);
}

Map loadFlutterIconsConfig(Map config) {
  return config['flutter_icons'];
}

bool isImagePathInConfig(Map flutterIconsConfig) {
  return flutterIconsConfig.containsKey('image_path') ||
      (flutterIconsConfig.containsKey('image_path_android') &&
          flutterIconsConfig.containsKey('image_path_ios'));
}

bool hasAndroidOrIOSConfig(Map flutterIconsConfig) {
  return flutterIconsConfig.containsKey('android') ||
      flutterIconsConfig.containsKey('ios');
}

bool hasAndroidConfig(Map flutterLauncherIcons) {
  return flutterLauncherIcons.containsKey('android');
}

bool isNeedingNewAndroidIcon(Map flutterLauncherIconsConfig) {
  return hasAndroidConfig(flutterLauncherIconsConfig) &&
      flutterLauncherIconsConfig['android'] != false;
}

bool hasAndroidAdaptiveConfig(Map flutterLauncherIconsConfig) {
  return isNeedingNewAndroidIcon(flutterLauncherIconsConfig) &&
      flutterLauncherIconsConfig.containsKey('adaptive_icon_background') &&
      flutterLauncherIconsConfig.containsKey('adaptive_icon_foreground');
}

bool hasIOSConfig(Map flutterLauncherIconsConfig) {
  return flutterLauncherIconsConfig.containsKey('ios');
}

bool isNeedingNewIOSIcon(Map flutterLauncherIconsConfig) {
  return hasIOSConfig(flutterLauncherIconsConfig) &&
      flutterLauncherIconsConfig['ios'] != false;
}
