import 'package:flutter_launcher_icons/android.dart' as android;
import 'package:flutter_launcher_icons/constants.dart';
import 'package:test/test.dart';

// unit tests for android.dart
void main() {
  test('Adaptive icon mipmap path is correct', () {
    const String path1 = 'android/app/src/main/res/';
    const String path2 = 'mipmap-anydpi-v26/';
    expect(android.isCorrectMipmapDirectoryForAdaptiveIcon(path1), false);
    expect(android.isCorrectMipmapDirectoryForAdaptiveIcon(path2), false);
    expect(android.isCorrectMipmapDirectoryForAdaptiveIcon(androidAdaptiveXmlFolder), true);
  });

  test('Correct number of adaptive foreground icons', () {
    expect(android.adaptiveForegroundIcons.length, 5);
  });

  test('Correct number of android launcher icons', () {
    expect(android.androidIcons.length, 5);
  });

  test('Config contains string for generating new launcher icons', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': true,
      'ios': true
    };
    expect(android.isCustomAndroidFile(flutterIconsConfig), false);

    final Map<String, dynamic> flutterIconsNewIconConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': 'New Icon',
      'ios': true
    };
    expect(android.isCustomAndroidFile(flutterIconsNewIconConfig), true);
  });

  test('Prioritise image_path_android over image_path', () {
    final Map<String, dynamic> flutterIconsNewIconConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'image_path_android': 'assets/images/icon-android.png',
      'android': 'New Icon',
      'ios': true
    };
    expect(android.getAndroidIconPath(flutterIconsNewIconConfig), 'assets/images/icon-android.png');
  });
}
