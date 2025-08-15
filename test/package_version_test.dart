import 'dart:io';

import 'package:flutter_launcher_icons/pubspec_parser.dart';
import 'package:flutter_launcher_icons/src/version.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  /// This helps avoid an issue where the pubspec version has been increased but
  /// build runner has not been run to up the version which is displayed
  /// when flutter_launcher_icons is run.
  ///
  /// Note: We locate `pubspec.yaml` robustly (CWD can vary in CI/Windows).
  test('package version is correct', () {
    final pubspecPath = _locatePubspec();
    final yamlMap = PubspecParser.fromPathToMap(pubspecPath);
    final yamlVersion = yamlMap['version'] as String;
    expect(
      yamlVersion,
      packageVersion,
      reason: 'Versions are not matching. Solution: Run build runner to '
          'updated generated version value.',
    );
  });
}

/// Locate the repo's pubspec regardless of current working dir.
/// Tries from CWD, then from this test file's directory, walking up.
String _locatePubspec() {
  String? searchFrom(Directory start) {
    var dir = start;
    for (var i = 0; i < 25; i++) {
      final candidate = p.join(dir.path, 'pubspec.yaml');
      if (File(candidate).existsSync()) {
        return candidate;
      }
      final parent = dir.parent;
      if (parent.path == dir.path) {
        break;
      }
      dir = parent;
    }
    return null;
  }

  final fromCwd = searchFrom(Directory.current);
  if (fromCwd != null) {
    return fromCwd;
  }

  final scriptDir = File.fromUri(Platform.script).parent;
  final fromScript = searchFrom(scriptDir);
  if (fromScript != null) {
    return fromScript;
  }

  throw StateError(
    'Could not find pubspec.yaml. Tried starting from: '
        '${Directory.current.path} and ${scriptDir.path}',
  );
}
