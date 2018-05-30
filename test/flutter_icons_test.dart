import 'package:test/test.dart';
import 'package:flutter_launcher_icons/ios.dart' as IOS;
import 'package:flutter_launcher_icons/android.dart' as Android;
import 'package:flutter_launcher_icons/main.dart' as Main;

void main() {
  test('iOS icon list is correct size', () {
    expect(IOS.ios_icons.length, 15);
  });

  test('Android icon list is correct size', () {
    expect(Android.android_icons.length, 5);
  });

  test('iOS image list used to generate Contents.json for icon directory is correct size', () {
    expect(IOS.createImageList("blah").length, 19);
  });

  test('pubspec.yaml file exists', () async {
    String path = "test/config/test_pubspec.yaml";
    var config = await Main.loadConfigFile(path);
    print("Contains key: " + config.containsKey("flutter_icons").toString());
    expect(config.length, isNotNull);
  });

  test('Incorrect pubspec.yaml path throws correct error message', () async {
    String incorrectPath = "test/config/test_pubspec.yam";
    var config = Main.loadConfigFile(incorrectPath);
    expect(config, throwsA(incorrectPath + " does not exist"));
  });

  test ('image_path is in config', () async {
    Map flutter_icons_config = {"image_path": "assets/images/icon-710x599.png",
      "android": true, "ios": true};
    expect(Main.isImagePathInConfig(flutter_icons_config), true);
  });

  test('At least one platform is in config file', () async {
    Map flutter_icons_config = {"image_path": "assets/images/icon-710x599.png",
        "android": true, "ios": true};
    expect(Main.hasAndroidOrIOSConfig(flutter_icons_config), true);
  });

  test('No platform specified in config', () async {
    Map flutter_icons_config = {"image_path": "assets/images/icon-710x599.png"};
    expect(Main.hasAndroidOrIOSConfig(flutter_icons_config), false);
  });
}