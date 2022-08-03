import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_launcher_icons/android.dart' as android;
import 'package:flutter_launcher_icons/flutter_launcher_icons_config.dart';
import 'package:flutter_launcher_icons/ios.dart' as ios;
import 'package:flutter_launcher_icons/main.dart' show defaultConfigFile;
import 'package:flutter_launcher_icons/main.dart' as main_dart;
import 'package:path/path.dart';
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
      ..addOption(main_dart.fileOption, abbr: 'f', defaultsTo: defaultConfigFile)
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
flutter_icons:
  android: true
  ios: false
''');
      final ArgResults argResults = parser.parse(<String>[]);
      final FlutterLauncherIconsConfig? config =
          main_dart.loadConfigFileFromArgResults(argResults);
      expect(config, isNotNull);
      expect(config!.android, true);
    });
    test('default_use_pubspec', () async {
      await setCurrentDirectory('pubspec_only');
      await File('pubspec.yaml').writeAsString('''
flutter_icons:
  android: true
  ios: false
''');
      ArgResults argResults = parser.parse(<String>[]);
      final FlutterLauncherIconsConfig? config =
          main_dart.loadConfigFileFromArgResults(argResults);
      expect(config, isNotNull);
      expect(config!.ios, false);

      // read pubspec if provided file is not found
      argResults = parser.parse(<String>['-f', defaultConfigFile]);
      expect(main_dart.loadConfigFileFromArgResults(argResults), isNotNull);
    });

    test('custom', () async {
      await setCurrentDirectory('custom');
      await File('custom.yaml').writeAsString('''
flutter_icons:
  android: true
  ios: true
''');
      // if no argument set, should fail
      ArgResults argResults = parser.parse(<String>['-f', 'custom.yaml']);
      final FlutterLauncherIconsConfig? config =
          main_dart.loadConfigFileFromArgResults(argResults);
      expect(config, isNotNull);
      expect(config!.ios, true);

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
    final config = FlutterLauncherIconsConfig.fromJson(flutterIconsConfig);
    expect(config.getImagePathAndroid(), 'assets/images/icon-710x599.png');
    expect(config.getImagePathIOS(), 'assets/images/icon-710x599.png');
    final Map<String, dynamic> flutterIconsConfigAndroid = <String, dynamic>{
      'image_path_android': 'assets/images/icon-710x599.png',
      'android': true,
      'ios': true
    };
    final configAndroid = FlutterLauncherIconsConfig.fromJson(flutterIconsConfigAndroid);
    expect(configAndroid.getImagePathAndroid(), 'assets/images/icon-710x599.png');
    expect(configAndroid.getImagePathIOS(), isNull);
    final Map<String, dynamic> flutterIconsConfigBoth = <String, dynamic>{
      'image_path_android': 'assets/images/icon-android.png',
      'image_path_ios': 'assets/images/icon-ios.png',
      'android': true,
      'ios': true
    };
    final configBoth = FlutterLauncherIconsConfig.fromJson(flutterIconsConfigBoth);
    expect(configBoth.getImagePathAndroid(), 'assets/images/icon-android.png');
    expect(configBoth.getImagePathIOS(), 'assets/images/icon-ios.png');
  });

  test('At least one platform is in config file', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': true,
      'ios': true
    };
    final config = FlutterLauncherIconsConfig.fromJson(flutterIconsConfig);
    expect(config.hasPlatformConfig, true);
  });

  test('No platform specified in config', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png'
    };
    final config = FlutterLauncherIconsConfig.fromJson(flutterIconsConfig);
    expect(config.hasPlatformConfig, false);
  });

  test('No new Android icon needed - android: false', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': false,
      'ios': true
    };
    final config = FlutterLauncherIconsConfig.fromJson(flutterIconsConfig);
    expect(config.isNeedingNewAndroidIcon, false);
  });

  test('No new Android icon needed - no Android config', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'ios': true
    };
    final config = FlutterLauncherIconsConfig.fromJson(flutterIconsConfig);
    expect(config.isNeedingNewAndroidIcon, false);
  });

  test('No new iOS icon needed - ios: false', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': true,
      'ios': false
    };
    final config = FlutterLauncherIconsConfig.fromJson(flutterIconsConfig);
    expect(config.isNeedingNewIOSIcon, false);
  });

  test('No new iOS icon needed - no iOS config', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': true
    };
    final config = FlutterLauncherIconsConfig.fromJson(flutterIconsConfig);
    expect(config.isNeedingNewIOSIcon, false);
  });
}
