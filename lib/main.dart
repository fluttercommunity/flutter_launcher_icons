import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_launcher_icons/abstract_platform.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import 'package:flutter_launcher_icons/android.dart' as android_launcher_icons;
import 'package:flutter_launcher_icons/ios.dart' as ios_launcher_icons;
import 'package:flutter_launcher_icons/web.dart' as web_launcher_icons;
import 'package:flutter_launcher_icons/constants.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';

const Map<String, AbstractPlatform> platforms = {
  'web': web_launcher_icons.WebIconGenerator(),
  'android_adaptive': android_launcher_icons.AdaptiveAndroidIconGenerator(),
  'android': android_launcher_icons.DefaultAndroidIconGenerator(),
  'ios': ios_launcher_icons.IOSIconGenerator(),
};

String flavorConfigFile(String flavor) => 'flutter_launcher_icons-$flavor.yaml';

List<String> getFlavors() {
  final List<String> flavors = [];

  for (FileSystemEntity item in Directory('.').listSync()) {
    if (item is File) {
      final String name = path.basename(item.path);
      final RegExpMatch match =
          RegExp(flavorConfigFilePattern).firstMatch(name);

      if (match != null) {
        flavors.add(match.group(1));
      }
    }
  }

  return flavors;
}

Future<void> createIconsFromArguments(List<String> arguments) async {
  final ArgParser parser = ArgParser(allowTrailingOptions: true);
  parser.addFlag(helpFlag, abbr: 'h', help: 'Usage help', negatable: false);

  // Make default null to differentiate when it is explicitly set
  parser.addOption(fileOption,
      abbr: 'f', help: 'Config file (default: $defaultConfigFile)');
  final ArgResults argResults = parser.parse(arguments);

  if (argResults[helpFlag]) {
    stdout.writeln('Generates icons for iOS, web, and Android');
    stdout.writeln(parser.usage);
    exit(0);
  }

  // Flavors manangement
  final List<String> flavors = getFlavors();
  final bool hasFlavors = flavors.isNotEmpty;

  // Create icons
  if (!hasFlavors || argResults[fileOption] != null) {
    // Load the config file
    final Map<String, dynamic> yamlConfig =
        loadConfigFileFromArgResults(argResults, verbose: true);

    try {
      createIconsFromConfig(yamlConfig);
    } catch (e) {
      stderr.writeln(e);
      exit(2);
    } finally {
      print('\n✓ Successfully generated launcher icons');
    }
  } else {
    try {
      for (String flavor in flavors) {
        print('\nFlavor: $flavor');
        final Map<String, dynamic> yamlConfig =
            loadConfigFile(flavorConfigFile(flavor), flavorConfigFile(flavor));
        await createIconsFromConfig(yamlConfig, flavor);
      }
    } catch (e) {
      stderr.writeln(e);
      exit(2);
    } finally {
      print('\n✓ Successfully generated launcher icons for flavors');
    }
  }
}

Future<void> createIconsFromConfig(Map<String, dynamic> config,
    [String flavor]) async {
  if (!hasPlatformConfig(config)) {
    throw const InvalidConfigException(errorMissingPlatform);
  }

  for (final AbstractPlatform platform in platforms.values) {
    final String complaint = platform.isConfigValid(config);

    if (complaint != null) {
      throw InvalidConfigException(complaint);
    }
  }

  for (final AbstractPlatform platform in platforms.values) {
    if (platform.inConfig(config) &&
        platform.logWarnings(config, out: stderr)) {
      platform.createIcons(config, flavor);
    }
  }
}

/// Call [loadConfigFile] with arguments inferred from [argResults].
/// 
/// If an error occurs and the (optional) [verbose] is true, log 
/// a description to stderr.
/// 
/// Treat the current working directory as [cwd] (if given), else,
/// use './' as the current working directory.
/// 
/// Note: [cwd] was added to allow tests that require different
///  working directories to run at the same time, without conflicting.
Map<String, dynamic> loadConfigFileFromArgResults(ArgResults argResults,
    {bool verbose, String cwd}) {

  verbose ??= false;
  cwd ??= './';

  String configFile = argResults[fileOption];
  final String fileOptionResult = argResults[fileOption];

  if (configFile != null) {
    configFile = path.join(cwd, configFile);
  }

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
    return loadConfigFile(path.join(cwd, defaultConfigFile), fileOptionResult);
  } catch (e) {
    // Try pubspec.yaml for compatibility
    if (configFile == null) {
      try {
        return loadConfigFile(path.join(cwd, 'pubspec.yaml'), fileOptionResult);
      } catch (_) {}
    }

    // if nothing got returned, print error
    if (verbose) {
      stderr.writeln(e);
    }
  }

  return null;
}

Map<String, dynamic> loadConfigFile(String path, String fileOptionResult) {
  final File file = File(path);
  final String yamlString = file.readAsStringSync();
  // ignore: always_specify_types
  final Map yamlMap = loadYaml(yamlString);

  if (yamlMap == null || !(yamlMap['flutter_icons'] is Map)) {
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

bool isConfigValid(Map<String, dynamic> flutterIconsConfig) {
  for (final AbstractPlatform platform in platforms.values) {
    final String complaint = platform.isConfigValid(flutterIconsConfig);

    if (complaint != null) {
      return false;
    }
  }

  return hasPlatformConfig(flutterIconsConfig);
}

bool hasPlatformConfig(Map<String, dynamic> flutterIconsConfig) {
  for (final AbstractPlatform platform in platforms.values) {
    if (platform.inConfig(flutterIconsConfig)) {
      return true;
    }
  }

  return false;
}
