import 'dart:io';

import 'package:yaml/yaml.dart';

/// Helper class for parsing the contents of pubspec file
class PubspecParser {
  /// Ensures unnamed constructor cannot be used as this class should only have
  /// static methods
  PubspecParser._();

  /// Parses the pubspec located at [path] to map
  static Map fromPathToMap(String path) {
    final File file = File(path);
    final String yamlString = file.readAsStringSync();
    final Map yamlMap = loadYaml(yamlString);
    return yamlMap;
  }
}
