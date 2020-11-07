import 'dart:io';

import 'package:args/args.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as pathlib;
import 'package:flutter_launcher_icons/ios.dart' as ios;
import 'package:flutter_launcher_icons/android.dart' as android;
import 'package:flutter_launcher_icons/main.dart' as main_dart;
import 'package:flutter_launcher_icons/constants.dart' as constants;

// Unit tests for main.dart
void main() {
  test('iOS icon list is correct size', () {
    expect(ios.iosIcons.length, 15);
  });

  test('Android icon list is correct size', () {
    expect(android.androidIcons.length, 5);
  });

  test(
      'iOS image list used to generate Contents.json for icon directory is correct size',
      () {
    expect(ios.createImageList('blah').length, 19);
  });

  test('pubspec.yaml file exists', () async {
    const String path = 'test/config/test_pubspec.yaml';
    final Map<String, dynamic> config = main_dart.loadConfigFile(path, null);
    expect(config.length, isNotNull);
  });

  group('config file from args', () {
    // Create mini parser with only the wanted option, mocking the real one
    final ArgParser parser = ArgParser()
      ..addOption(constants.fileOption, abbr: 'f');
    final String testDir = pathlib.join(
        '.dart_tool', 'flutter_launcher_icons', 'test', 'config_file');

    String currentDirectory = testDir;
    Future<void> setCurrentDirectory(String path) async {
      currentDirectory = pathlib.join(testDir, path);
      await Directory(currentDirectory).create(recursive: true);
    }

    File getFile(String filename) {
      final String path = pathlib.join(currentDirectory, filename);

      return File(path);
    }

    Map<String, dynamic> loadConfig(ArgResults args) {
      return main_dart.loadConfigFileFromArgResults(args,
          cwd: currentDirectory);
    }

    test('default', () async {
      await setCurrentDirectory('default');
      await getFile('flutter_launcher_icons.yaml').writeAsString('''
flutter_icons:
  android: true
  ios: false
''');
      final ArgResults argResults = parser.parse(<String>[]);
      final Map<String, dynamic> config = loadConfig(argResults);
      expect(config['android'], true);
    });

    test('default_use_pubspec', () async {
      await setCurrentDirectory('pubspec_only');
      await getFile('pubspec.yaml').writeAsString('''
flutter_icons:
  android: true
  ios: false
''');
      ArgResults argResults = parser.parse(<String>[]);
      final Map<String, dynamic> config = loadConfig(argResults);
      expect(config['ios'], false);

      // fails if forcing default file
      argResults = parser.parse(<String>['-f', constants.defaultConfigFile]);
      expect(loadConfig(argResults), isNull);
    });

    test('custom', () async {
      await setCurrentDirectory('custom');
      await getFile('custom.yaml').writeAsString('''
flutter_icons:
  android: true
  ios: true
''');
      // if no argument set, should fail
      ArgResults argResults = parser.parse(<String>['-f', 'custom.yaml']);
      final Map<String, dynamic> config = loadConfig(argResults);
      expect(config['ios'], true);

      // should fail if no argument
      argResults = parser.parse(<String>[]);
      expect(loadConfig(argResults), isNull);

      // or missing file
      argResults = parser.parse(<String>['-f', 'missing_custom.yaml']);
      expect(loadConfig(argResults), isNull);
    });
  });

  test('Incorrect pubspec.yaml path throws correct error message', () async {
    const String incorrectPath = 'test/config/test_pubspec.yam';
    expect(() => main_dart.loadConfigFile(incorrectPath, null),
        throwsA(const TypeMatcher<FileSystemException>()));
  });

  test(
      'image_path is in config -- All platforms set to true & image_path given.',
      () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': true,
      'ios': true,
      'web': true,
    };
    expect(main_dart.isConfigValid(flutterIconsConfig), true);
  });

  test(
      'image_path is in config -- android & ios requested, but only android given',
      () {
    final Map<String, dynamic> flutterIconsConfigAndroid = <String, dynamic>{
      'image_path_android': 'assets/images/icon-710x599.png',
      'android': true,
      'ios': true
    };
    expect(main_dart.isConfigValid(flutterIconsConfigAndroid), false);
  });

  test(
      'image_path is in config -- Android and iOS both active and icons given for both',
      () {
    final Map<String, dynamic> flutterIconsConfigIOSAndroid = <String, dynamic>{
      'image_path_android': 'assets/images/icon-710x599.png',
      'image_path_ios': 'assets/images/icon-710x599.png',
      'android': true,
      'ios': true
    };
    expect(main_dart.isConfigValid(flutterIconsConfigIOSAndroid), true);
  });

  test('image_path is in config -- Icons for all systems given.', () {
    final Map<String, dynamic> flutterIconsConfigAll = <String, dynamic>{
      'image_path_android': 'assets/images/icon-710x599.png',
      'image_path_ios': 'assets/images/icon-710x599.png',
      'image_path_web': 'assets/images/icon-710x599.png',
      'android': true,
      'ios': true,
      'web': true,
    };
    expect(main_dart.isConfigValid(flutterIconsConfigAll), true);
  });

  test(
      'image_path is in config -- only image_path for ios given & does not match target (web).',
      () {
    final Map<String, dynamic> flutterIconsConfigWeb = <String, dynamic>{
      'image_path_ios': 'assets/images/icon-710x599.png',
      'web': true,
    };
    expect(main_dart.isConfigValid(flutterIconsConfigWeb), false);
  });

  test('At least one platform is in config file', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': true,
      'ios': true,
      'web': true,
    };
    expect(main_dart.hasPlatformConfig(flutterIconsConfig), true);
  });

  test('No platform specified in config', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png'
    };
    expect(main_dart.hasPlatformConfig(flutterIconsConfig), false);
  });

  test('No new Android icon needed - android: false', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': false,
      'ios': true
    };
    expect(main_dart.platforms['android'].inConfig(flutterIconsConfig), false);
  });

  test('No new Android icon needed - no Android config', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'ios': true
    };
    expect(main_dart.platforms['android'].inConfig(flutterIconsConfig), false);
  });

  test('No new iOS icon needed - ios: false', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': true,
      'ios': false
    };
    expect(main_dart.platforms['ios'].inConfig(flutterIconsConfig), false);
  });

  test('New iOS icon needed - ios: true, android: true', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': true,
      'ios': true
    };
    expect(main_dart.platforms['ios'].inConfig(flutterIconsConfig), true);
  });

  test('New iOS icon needed - ios: true', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'ios': true,
    };
    expect(main_dart.platforms['ios'].inConfig(flutterIconsConfig), true);
  });

  test('No new iOS icon needed -- only Android and web configs', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': true,
      'web': true,
    };
    expect(main_dart.platforms['ios'].inConfig(flutterIconsConfig), false);
  });

  test('No new web icon needed -- web: false', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'web': false,
      'ios': true
    };
    expect(main_dart.platforms['web'].inConfig(flutterIconsConfig), false);
  });

  final RegExp versionCodeExp =
      RegExp(r'\s?[#]{2,4}\s+(?:Version\s+)?(\d+\.\d+\.\d+)\s+\(.*\)\s*');

  test('Version code regexp works.', () {
    expect(versionCodeExp.firstMatch('#### 0.0.1 (3rd Oct 2020)'), isNotNull);
    expect(versionCodeExp.firstMatch('Not a version code.'), isNull);
    expect(versionCodeExp.firstMatch('## Not a version code'), isNull);
    expect(versionCodeExp.firstMatch('## 4.4 is not a .0 version'), isNull);
    expect(
        versionCodeExp.firstMatch('## 102.23.44 (3rd Never 2020)'), isNotNull);
    expect(versionCodeExp.firstMatch('\n## 102.23.44 (3rd Never 2020)'),
        isNotNull);
    expect(versionCodeExp.firstMatch('## 102.23.44 (3rd Never 2020)\n'),
        isNotNull);
    expect(
        versionCodeExp
            .firstMatch('\n\n456\n## 102.23.44 (3rd Never 2020)\n123'),
        isNotNull);
  });

  test('Built-in version code matches that in CHANGELOG.md', () async {
    final File changelog = File('CHANGELOG.md');
    final String changelogContent = await changelog.readAsString();

    // Search for & extract the first version code in the changelog.

    final RegExpMatch firstVersionMatch =
        versionCodeExp.firstMatch(changelogContent);

    expect(firstVersionMatch, isNotNull);

    // firstVersion is the first found in the file, (not the oldest version).
    final String firstVersion = firstVersionMatch.group(1);
    expect(firstVersion, equals(constants.currentVersion));
  });

  test('Built-in version code matches that in README.md', () async {
    final File readme = File('README.md');
    final String readmeContent = await readme.readAsString();

    final RegExpMatch firstVersionMatch =
        versionCodeExp.firstMatch(readmeContent);

    // Eventually, versions might not be present in README.md...
    if (firstVersionMatch != null) {
      final String readmeVersion = firstVersionMatch.group(1);

      expect(readmeVersion, equals(constants.currentVersion));
    }
  });
}
