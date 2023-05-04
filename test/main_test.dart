import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_launcher_icons/android.dart' as android;
import 'package:flutter_launcher_icons/config/config.dart';
import 'package:flutter_launcher_icons/ios.dart' as ios;
import 'package:flutter_launcher_icons/main.dart' show defaultConfigFile;
import 'package:flutter_launcher_icons/main.dart' as main_dart;
import 'package:path/path.dart' show join;
import 'package:test/test.dart';

// Unit tests for main.dart
void main() {
  test('iOS icon list is correct size', () {
    expect(ios.iosIcons.length, 21);
  });

  test('Android icon list is correct size', () {
    expect(android.androidIcons.length, 5);
  });

  test(
      'iOS image list used to generate Contents.json for icon directory is correct size',
      () {
    expect(ios.createImageList('blah').length, 25);
  });

  group('config file from args', () {
    // Create mini parser with only the wanted option, mocking the real one
    final ArgParser parser = ArgParser()
      ..addOption(
        main_dart.fileOption,
        abbr: 'f',
        defaultsTo: defaultConfigFile,
      )
      ..addOption(
        main_dart.prefixOption,
        abbr: 'p',
        defaultsTo: '.',
      );
    final String testDir =
        join('.dart_tool', 'flutter_launcher_icons', 'test', 'config_file');

    late String currentDirectory;
    Future<void> setCurrentDirectory(String path) async {
      path = join(testDir, path);
      await Directory(path).create(recursive: true);
      Directory.current = path;
    }

    setUp(() {
      currentDirectory = Directory.current.path;
    });
    tearDown(() {
      Directory.current = currentDirectory;
    });

    test('default', () async {
      await setCurrentDirectory('default');
      await File('flutter_launcher_icons.yaml').writeAsString('''
flutter_launcher_icons:
  android: true
  ios: false
''');
      final ArgResults argResults = parser.parse(<String>[]);
      final Config? config = main_dart.loadConfigFileFromArgResults(argResults);
      expect(config, isNotNull);
      expect(config!.android, isTrue);
    });
    test('default_use_pubspec', () async {
      await setCurrentDirectory('pubspec_only');
      await File('pubspec.yaml').writeAsString('''
flutter_launcher_icons:
  android: true
  ios: false
''');
      ArgResults argResults = parser.parse(<String>[]);
      final Config? config = main_dart.loadConfigFileFromArgResults(argResults);
      expect(config, isNotNull);
      expect(config!.ios, isFalse);

      // read pubspec if provided file is not found
      argResults = parser.parse(<String>['-f', defaultConfigFile]);
      expect(main_dart.loadConfigFileFromArgResults(argResults), isNotNull);
    });

    test('custom', () async {
      await setCurrentDirectory('custom');
      await File('custom.yaml').writeAsString('''
flutter_launcher_icons:
  android: true
  ios: true
''');
      // if no argument set, should fail
      ArgResults argResults = parser.parse(<String>['-f', 'custom.yaml']);
      final Config? config = main_dart.loadConfigFileFromArgResults(argResults);
      expect(config, isNotNull);
      expect(config!.ios, isTrue);

      // should fail if no argument
      argResults = parser.parse(<String>[]);
      expect(main_dart.loadConfigFileFromArgResults(argResults), isNull);

      // or missing file
      argResults = parser.parse(<String>['-f', 'missing_custom.yaml']);
      expect(main_dart.loadConfigFileFromArgResults(argResults), isNull);
    });
  });

  test('image_path is in config', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': true,
      'ios': true
    };
    final config = Config.fromJson(flutterIconsConfig);
    expect(
      config.getImagePathAndroid(),
      equals('assets/images/icon-710x599.png'),
    );
    expect(config.getImagePathIOS(), equals('assets/images/icon-710x599.png'));
    final Map<String, dynamic> flutterIconsConfigAndroid = <String, dynamic>{
      'image_path_android': 'assets/images/icon-710x599.png',
      'android': true,
      'ios': true
    };
    final configAndroid = Config.fromJson(flutterIconsConfigAndroid);
    expect(
      configAndroid.getImagePathAndroid(),
      equals('assets/images/icon-710x599.png'),
    );
    expect(configAndroid.getImagePathIOS(), isNull);
    final Map<String, dynamic> flutterIconsConfigBoth = <String, dynamic>{
      'image_path_android': 'assets/images/icon-android.png',
      'image_path_ios': 'assets/images/icon-ios.png',
      'android': true,
      'ios': true
    };
    final configBoth = Config.fromJson(flutterIconsConfigBoth);
    expect(
      configBoth.getImagePathAndroid(),
      equals('assets/images/icon-android.png'),
    );
    expect(configBoth.getImagePathIOS(), equals('assets/images/icon-ios.png'));
  });

  test('At least one platform is in config file', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': true,
      'ios': true
    };
    final config = Config.fromJson(flutterIconsConfig);
    expect(config.hasPlatformConfig, isTrue);
  });

  test('No platform specified in config', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png'
    };
    final config = Config.fromJson(flutterIconsConfig);
    expect(config.hasPlatformConfig, isFalse);
  });

  test('No new Android icon needed - android: false', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': false,
      'ios': true
    };
    final config = Config.fromJson(flutterIconsConfig);
    expect(config.isNeedingNewAndroidIcon, isFalse);
  });

  test('No new Android icon needed - no Android config', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'ios': true
    };
    final config = Config.fromJson(flutterIconsConfig);
    expect(config.isNeedingNewAndroidIcon, isFalse);
  });

  test('No new iOS icon needed - ios: false', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': true,
      'ios': false
    };
    final config = Config.fromJson(flutterIconsConfig);
    expect(config.isNeedingNewIOSIcon, isFalse);
  });

  test('No new iOS icon needed - no iOS config', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': true
    };
    final config = Config.fromJson(flutterIconsConfig);
    expect(config.isNeedingNewIOSIcon, isFalse);
  });
}
