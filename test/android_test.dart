import 'package:test/test.dart';
import 'package:flutter_launcher_icons/android.dart' as Android;
import 'package:flutter_launcher_icons/constants.dart';

// unit tests for android.dart
void main() {
  test('Adaptive icon mipmap path is correct', () {
    String path1 = 'android/app/src/main/res/';
    String path2 = 'mipmap-anydpi-v26/';
    expect(Android.isCorrectMipmapDirectoryForAdaptiveIcon(path1), false);
    expect(Android.isCorrectMipmapDirectoryForAdaptiveIcon(path2), false);
    expect(
        Android.isCorrectMipmapDirectoryForAdaptiveIcon(
            androidAdaptiveXmlFolder),
        true);
  });

  test('Correct number of adaptive foreground icons', () {
    expect(Android.adaptiveForegroundIcons.length, 5);
  });

  test('Correct number of android launcher icons', () {
    expect(Android.androidIcons.length, 5);
  });

  test('Config contains string for generating new launcher icons', () {
    final Map flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': true,
      'ios': true
    };
    expect(Android.isCustomAndroidFile(flutterIconsConfig), false);

    final Map flutterIconsNewIconConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': 'New Icon',
      'ios': true
    };
    expect(Android.isCustomAndroidFile(flutterIconsNewIconConfig), true);
  });

  test('Prioritise image_path_android over image_path', () {
    final Map flutterIconsNewIconConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'image_path_android': 'assets/images/icon-android.png',
      'android': 'New Icon',
      'ios': true
    };
    expect(Android.getAndroidIconPath(flutterIconsNewIconConfig),
        'assets/images/icon-android.png');
  });
}
