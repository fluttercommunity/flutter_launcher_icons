import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_launcher_icons/abs/icon_generator.dart';
import 'package:flutter_launcher_icons/android.dart' as android_launcher_icons;
import 'package:flutter_launcher_icons/constants.dart' as constants;
import 'package:flutter_launcher_icons/constants.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/flutter_launcher_icons_config.dart';
import 'package:flutter_launcher_icons/ios.dart' as ios_launcher_icons;
import 'package:flutter_launcher_icons/logger.dart';
import 'package:flutter_launcher_icons/pubspec_parser.dart';
import 'package:flutter_launcher_icons/web/web_icon_generator.dart';
import 'package:flutter_launcher_icons/windows/windows_icon_generator.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

const String fileOption = 'file';
const String helpFlag = 'help';
const String verboseFlag = 'verbose';
const String prefixOption = 'prefix';
const String defaultConfigFile = 'flutter_launcher_icons.yaml';
const String flavorConfigFilePattern = r'^flutter_launcher_icons-(.*).yaml$';

/// todo: remove this as it is moved to utils.dart
String flavorConfigFile(String flavor) => 'flutter_launcher_icons-$flavor.yaml';

List<String> getFlavors() {
  final List<String> flavors = [];
  for (var item in Directory('.').listSync()) {
    if (item is File) {
      final name = path.basename(item.path);
      final match = RegExp(flavorConfigFilePattern).firstMatch(name);
      if (match != null) {
        flavors.add(match.group(1)!);
      }
    }
  }
  return flavors;
}

Future<void> createIconsFromArguments(List<String> arguments) async {
  final ArgParser parser = ArgParser(allowTrailingOptions: true);
  parser
    ..addFlag(helpFlag, abbr: 'h', help: 'Usage help', negatable: false)
    // Make default null to differentiate when it is explicitly set
    ..addOption(fileOption, abbr: 'f', help: 'Path to config file', defaultsTo: defaultConfigFile)
    ..addFlag(verboseFlag, abbr: 'v', help: 'Verbose output', defaultsTo: false)
    ..addOption(
      prefixOption,
      abbr: 'p',
      help: 'Generates config in the given path. Only Supports web platform',
      defaultsTo: '.',
    );

  final ArgResults argResults = parser.parse(arguments);
  // creating logger based on -v flag
  final logger = FLILogger(argResults[verboseFlag]);

  logger.verbose('Received args ${argResults.arguments}');

  if (argResults[helpFlag]) {
    stdout.writeln('Generates icons for iOS and Android');
    stdout.writeln(parser.usage);
    exit(0);
  }

  // Flavors management
  final flavors = getFlavors();
  final hasFlavors = flavors.isNotEmpty;

  // Load the config file
  final Map<String, dynamic>? yamlConfig = loadConfigFileFromArgResults(argResults, verbose: true);
  final String prefixPath = argResults[prefixOption];

  // Load configs from given file(defaults to ./flutter_launcher_icons.yaml) or from ./pubspec.yaml

  final flutterLauncherIconsConfigs =
      FlutterLauncherIconsConfig.loadConfigFromPath(argResults[fileOption], prefixPath) ??
          FlutterLauncherIconsConfig.loadConfigFromPubSpec(prefixPath);
  if (yamlConfig == null || flutterLauncherIconsConfigs == null) {
    throw NoConfigFoundException(
      'No configuration found in $defaultConfigFile or in ${constants.pubspecFilePath}. '
      'In case file exists in different directory use --file option',
    );
  }

  // Create icons
  if (!hasFlavors) {
    try {
      await createIconsFromConfig(yamlConfig, flutterLauncherIconsConfigs, logger, prefixPath);
      print('\n✓ Successfully generated launcher icons');
    } catch (e) {
      stderr.writeln('\n✕ Could not generate launcher icons');
      stderr.writeln(e);
      exit(2);
    }
  } else {
    try {
      for (String flavor in flavors) {
        print('\nFlavor: $flavor');
        final Map<String, dynamic> yamlConfig = loadConfigFile(flavorConfigFile(flavor), flavorConfigFile(flavor));
        await createIconsFromConfig(yamlConfig, flutterLauncherIconsConfigs, logger, prefixPath, flavor);
      }
      print('\n✓ Successfully generated launcher icons for flavors');
    } catch (e) {
      stderr.writeln('\n✕ Could not generate launcher icons for flavors');
      stderr.writeln(e);
      exit(2);
    }
  }
}

Future<void> createIconsFromConfig(
  Map<String, dynamic> config,
  FlutterLauncherIconsConfig flutterConfigs,
  FLILogger logger,
  String prefixPath, [
  String? flavor,
]) async {
  if (!isImagePathInConfig(config)) {
    throw const InvalidConfigException(errorMissingImagePath);
  }
  if (!hasPlatformConfig(config)) {
    throw const InvalidConfigException(errorMissingPlatform);
  }

  if (isNeedingNewAndroidIcon(config) || hasAndroidAdaptiveConfig(config)) {
    final int minSdk = android_launcher_icons.minSdk();
    if (minSdk == 0) {
      throw const InvalidConfigException(errorMissingMinSdk);
    }
    if (minSdk < 26 && hasAndroidAdaptiveConfig(config) && !hasAndroidConfig(config)) {
      throw const InvalidConfigException(errorMissingRegularAndroid);
    }
  }

  if (isNeedingNewAndroidIcon(config)) {
    android_launcher_icons.createDefaultIcons(config, flavor);
  }
  if (hasAndroidAdaptiveConfig(config)) {
    android_launcher_icons.createAdaptiveIcons(config, flavor);
  }
  if (isNeedingNewIOSIcon(config)) {
    ios_launcher_icons.createIcons(config, flavor);
  }

  // Generates Icons for given platform
  generateIconsFor(
    config: flutterConfigs,
    logger: logger,
    prefixPath: prefixPath,
    flavor: flavor,
    platforms: (context) => [
      WebIconGenerator(context),
      WindowsIconGenerator(context),
      // todo: add other platforms
    ],
  );
}

Map<String, dynamic>? loadConfigFileFromArgResults(ArgResults argResults, {bool verbose = false}) {
  final String? configFile = argResults[fileOption];
  final String? fileOptionResult = argResults[fileOption];

  // if icon is given, try to load icon
  if (configFile != null && configFile != defaultConfigFile) {
    try {
      return loadConfigFile(configFile, fileOptionResult);
    } catch (e) {
      if (verbose) {
        stderr.writeln(e);
      }

      return null;
    }
  }

  // If none set try flutter_launcher_icons.yaml first then pubspec.yaml
  // for compatibility
  try {
    return loadConfigFile(defaultConfigFile, fileOptionResult);
  } catch (e) {
    // Try pubspec.yaml for compatibility
    if (configFile == null) {
      try {
        return loadConfigFile('pubspec.yaml', fileOptionResult);
      } catch (_) {}
    }

    // if nothing got returned, print error
    if (verbose) {
      stderr.writeln(e);
    }
  }

  return null;
}

Map<String, dynamic> loadConfigFile(String path, String? fileOptionResult) {
  final yamlMap = PubspecParser.toMap(path);

  if (!(yamlMap['flutter_icons'] is Map)) {
    stderr.writeln(NoConfigFoundException('Check that your config file '
        '`${fileOptionResult ?? defaultConfigFile}`'
        ' has a `flutter_icons` section'));
    exit(1);
  }

  // yamlMap has the type YamlMap, which has several unwanted sideeffects
  final Map<String, dynamic> config = <String, dynamic>{};
  for (MapEntry<dynamic, dynamic> entry in yamlMap['flutter_icons'].entries) {
    config[entry.key] = entry.value;
  }

  return config;
}

bool isImagePathInConfig(Map<String, dynamic> flutterIconsConfig) {
  return flutterIconsConfig.containsKey('image_path') ||
      (flutterIconsConfig.containsKey('image_path_android') && flutterIconsConfig.containsKey('image_path_ios')) ||
      flutterIconsConfig.containsKey('web');
}

bool hasPlatformConfig(Map<String, dynamic> flutterIconsConfig) {
  return hasAndroidConfig(flutterIconsConfig) || hasIOSConfig(flutterIconsConfig) || hasWebConfig(flutterIconsConfig);
}

bool hasAndroidConfig(Map<String, dynamic> flutterLauncherIcons) {
  return flutterLauncherIcons.containsKey('android');
}

bool isNeedingNewAndroidIcon(Map<String, dynamic> flutterLauncherIconsConfig) {
  return hasAndroidConfig(flutterLauncherIconsConfig) && flutterLauncherIconsConfig['android'] != false;
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
  return hasIOSConfig(flutterLauncherIconsConfig) && flutterLauncherIconsConfig['ios'] != false;
}

/// Checks if the [flutterLauncherIconsConfig] contains web configs
bool hasWebConfig(Map<String, dynamic> flutterLauncherIconsConfig) {
  return flutterLauncherIconsConfig.containsKey('web');
}

/// Checks if we should generate icons for web platform
bool isNeddingNewWebIcons(Map<String, dynamic> flutterLauncherIconsConfig) {
  return hasWebConfig(flutterLauncherIconsConfig) && flutterLauncherIconsConfig['web'] != false;
}
