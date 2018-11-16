import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_launcher_icons/main.dart' show defaultConfigFile;
import 'package:path/path.dart';
import 'package:test/test.dart';
import 'package:flutter_launcher_icons/ios.dart' as IOS;
import 'package:flutter_launcher_icons/android.dart' as Android;
import 'package:flutter_launcher_icons/main.dart' as Main;

/**
 * Unit tests for main.dart
 */
void main() {
  test('iOS icon list is correct size', () {
    expect(IOS.iosIcons.length, 15);
  });

  test('Android icon list is correct size', () {
    expect(Android.androidIcons.length, 5);
  });

  test(
      'iOS image list used to generate Contents.json for icon directory is correct size',
      () {
    expect(IOS.createImageList("blah").length, 19);
  });

  test('pubspec.yaml file exists', () async {
    String path = "test/config/test_pubspec.yaml";
    var config = await Main.loadConfigFile(path);
    expect(config.length, isNotNull);
  });

  group('config file from args', () {
    // Create mini parser with only the wanted option, mocking the real one
    var parser = ArgParser()..addOption(Main.fileOption, abbr: "f");
    var testDir =
        join('.dart_tool', 'flutter_launcher_icons', 'test', 'config_file');

    String currentDirectory;
    setCurrentDirectory(String path) async {
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
      await File('flutter_launcher_icons.yaml').writeAsString(
          '''
            flutter_icons:
              android: true
              ios: false
          '''
      );
      var argResults = parser.parse([]);
      var config = await Main.loadConfigFileFromArgResults(argResults);
      expect(config['flutter_icons']['android'], true);
    });
    test('default_use_pubspec', () async {
      await setCurrentDirectory('pubspec_only');
      await File('pubspec.yaml').writeAsString(
        '''
          flutter_icons:
            android: true
            ios: false
        '''
      );
      var argResults = parser.parse([]);
      var config = await Main.loadConfigFileFromArgResults(argResults);
      expect(config['flutter_icons']['ios'], false);

      // fails if forcing default file
      argResults = parser.parse(['-f', defaultConfigFile]);
      expect(await Main.loadConfigFileFromArgResults(argResults), isNull);
    });

    test('custom', () async {
      await setCurrentDirectory('custom');
      await File('custom.yaml').writeAsString(
          '''
            flutter_icons:
              android: true
              ios: true
          '''
      );
      // if no argument set, should fail
      var argResults = parser.parse(['-f', 'custom.yaml']);
      var config = await Main.loadConfigFileFromArgResults(argResults);
      expect(config['flutter_icons']['ios'], true);

      // should fail if no argument
      argResults = parser.parse([]);
      expect(await Main.loadConfigFileFromArgResults(argResults), isNull);

      // or missing file
      argResults = parser.parse(['-f', 'missing_custom.yaml']);
      expect(await Main.loadConfigFileFromArgResults(argResults), isNull);
    });
  });

  test('Incorrect pubspec.yaml path throws correct error message', () async {
    String incorrectPath = "test/config/test_pubspec.yam";
    var config = Main.loadConfigFile(incorrectPath);
    expect(config, throwsA(incorrectPath + " does not exist"));
  });

  test('image_path is in config', () {
    Map flutterIconsConfig = {
      "image_path": "assets/images/icon-710x599.png",
      "android": true,
      "ios": true
    };
    expect(Main.isImagePathInConfig(flutterIconsConfig), true);
    Map flutterIconsConfigAndroid = {
      "image_path_android": "assets/images/icon-710x599.png",
      "android": true,
      "ios": true
    };
    expect(Main.isImagePathInConfig(flutterIconsConfigAndroid), false);
    Map flutterIconsConfigBoth = {
      "image_path_android": "assets/images/icon-710x599.png",
      "image_path_ios": "assets/images/icon-710x599.png",
      "android": true,
      "ios": true
    };
    expect(Main.isImagePathInConfig(flutterIconsConfigBoth), true);
  });

  test('At least one platform is in config file', () {
    Map flutterIconsConfig = {
      "image_path": "assets/images/icon-710x599.png",
      "android": true,
      "ios": true
    };
    expect(Main.hasAndroidOrIOSConfig(flutterIconsConfig), true);
  });

  test('No platform specified in config', () {
    Map flutterIconsConfig = {"image_path": "assets/images/icon-710x599.png"};
    expect(Main.hasAndroidOrIOSConfig(flutterIconsConfig), false);
  });

  test('No new Android icon needed - android: false', () {
    Map flutterIconsConfig = {
      "image_path": "assets/images/icon-710x599.png",
      "android": false,
      "ios": true
    };
    expect(Main.isNeedingNewAndroidIcon(flutterIconsConfig), false);
  });

  test('No new Android icon needed - no Android config', () {
    Map flutterIconsConfig = {
      "image_path": "assets/images/icon-710x599.png",
      "ios": true
    };
    expect(Main.isNeedingNewAndroidIcon(flutterIconsConfig), false);
  });

  test('No new iOS icon needed - ios: false', () {
    Map flutterIconsConfig = {
      "image_path": "assets/images/icon-710x599.png",
      "android": true,
      "ios": false
    };
    expect(Main.isNeedingNewIOSIcon(flutterIconsConfig), false);
  });

  test('No new iOS icon needed - no iOS config', () {
    Map flutterIconsConfig = {
      "image_path": "assets/images/icon-710x599.png",
      "android": true
    };
    expect(Main.isNeedingNewIOSIcon(flutterIconsConfig), false);
  });
}
