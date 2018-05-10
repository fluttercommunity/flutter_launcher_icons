import 'dart:async';

import 'package:test/test.dart';
import 'package:flutter_launcher_icons/ios.dart' as IOS;
import 'package:flutter_launcher_icons/android.dart' as Android;
import 'package:flutter_launcher_icons/main.dart' as Main;
import 'package:dart_config/default_server.dart';

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

  test('pubspec.yaml is not null', () {
    Future<Map> config = Main.loadConfigFile("test/config/test_pubspec.yaml");
    config.then((values) {
      expect(values.length != null, true);
    });
    expect(config, completes);
  });

  test('pubspec.yaml is not null', () {
    expect(Main.loadConfigFile("test/config/test_pubspec.yam"), new isInstanceOf<Future<Map>>());
  });
}