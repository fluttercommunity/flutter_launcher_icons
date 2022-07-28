import 'package:flutter_launcher_icons/pubspec_parser.dart';
import 'package:flutter_launcher_icons/src/version.dart';
import 'package:test/test.dart';

void main() {
  /// this helps avoid an issue where the pubspec version has been increased but
  /// build runner has not been run to up the version which is displayed
  /// when flutter_launcher_icons is run
  test('package version is correct', () {
    final yamlMap = PubspecParser.fromPathToMap('pubspec.yaml');
    final yamlVersion = yamlMap['version'] as String;
    expect(
      yamlVersion,
      packageVersion,
      reason: 'Versions are not matching. Solution: Run build runner to '
          'updated generated version value.',
    );
  });
}
