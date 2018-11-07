import 'package:args/args.dart';
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

  test('iOS image list used to generate Contents.json for icon directory is correct size', () {
    expect(IOS.createImageList("blah").length, 19);
  });

  test('pubspec.yaml file exists', () async {
    String path = "test/config/test_pubspec.yaml";
    var config = await Main.loadConfigFile(path);
    expect(config.length, isNotNull);
  });

  test('load config file from arg results', () async {
    String path = "test/config/test_pubspec.yaml";
    var parser = ArgParser();
    parser.addOption(Main.fileOption,
        abbr: "f", help: "Config file");
    var argResults = parser.parse(['-f', path]);
    var config = await Main.loadConfigFileFromArgResults(argResults);
    expect(config.length, isNotNull);

    argResults = parser.parse(['-f', 'dummy_path_to_pubspec.yaml']);
    config = await Main.loadConfigFileFromArgResults(argResults);
    expect(config, isNull);
  });

  test('Incorrect pubspec.yaml path throws correct error message', () async {
    String incorrectPath = "test/config/test_pubspec.yam";
    var config = Main.loadConfigFile(incorrectPath);
    expect(config, throwsA(incorrectPath + " does not exist"));
  });

  test ('image_path is in config', () {
    Map flutterIconsConfig = {"image_path": "assets/images/icon-710x599.png",
      "android": true, "ios": true};
    expect(Main.isImagePathInConfig(flutterIconsConfig), true);
    Map flutterIconsConfigAndroid = {"image_path_android": "assets/images/icon-710x599.png",
      "android": true, "ios": true};
    expect(Main.isImagePathInConfig(flutterIconsConfigAndroid), false);
    Map flutterIconsConfigBoth = {"image_path_android": "assets/images/icon-710x599.png",
      "image_path_ios": "assets/images/icon-710x599.png",
      "android": true, "ios": true};
    expect(Main.isImagePathInConfig(flutterIconsConfigBoth), true);
  });

  test('At least one platform is in config file', () {
    Map flutterIconsConfig = {"image_path": "assets/images/icon-710x599.png",
        "android": true, "ios": true};
    expect(Main.hasAndroidOrIOSConfig(flutterIconsConfig), true);
  });

  test('No platform specified in config', () {
    Map flutterIconsConfig = {"image_path": "assets/images/icon-710x599.png"};
    expect(Main.hasAndroidOrIOSConfig(flutterIconsConfig), false);
  });

  test('No new Android icon needed - android: false', () {
    Map flutterIconsConfig = {"image_path": "assets/images/icon-710x599.png",
    "android": false, "ios": true};
    expect(Main.isNeedingNewAndroidIcon(flutterIconsConfig), false);
  });

  test('No new Android icon needed - no Android config', () {
    Map flutterIconsConfig = {"image_path": "assets/images/icon-710x599.png", "ios": true};
    expect(Main.isNeedingNewAndroidIcon(flutterIconsConfig), false);
  });

  test('No new iOS icon needed - ios: false', () {
    Map flutterIconsConfig = {"image_path": "assets/images/icon-710x599.png",
      "android": true, "ios": false};
    expect(Main.isNeedingNewIOSIcon(flutterIconsConfig), false);
  });

  test('No new iOS icon needed - no iOS config', () {
    Map flutterIconsConfig = {"image_path": "assets/images/icon-710x599.png",
      "android": true};
    expect(Main.isNeedingNewIOSIcon(flutterIconsConfig), false);
  });
}
