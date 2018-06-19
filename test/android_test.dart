import 'package:test/test.dart';
import 'package:flutter_launcher_icons/android.dart' as Android;

/**
 * Unit tests for android.dart
 */

void main() {
  test('Adaptive icon mipmap path is correct', () {
    String path1 = "android/app/src/main/res/";
    String path2 = "mipmap-anydpi-v26/";
    expect(Android.isCorrectMipmapDirectoryForAdaptiveIcon(path1), false);
    expect(Android.isCorrectMipmapDirectoryForAdaptiveIcon(path2), false);
    expect(Android.isCorrectMipmapDirectoryForAdaptiveIcon(Android.android_adaptive_xml_folder), true);
  });

  test('Correct number of adaptive foreground icons', () {
    expect(Android.adaptive_foreground_icons.length, 5);
  });

  test('Correct number of android launcher icons', () {
    expect(Android.android_icons.length, 5);
  });

  test('Config contains string for generating new launcher icons', () {
    Map flutter_icons_config = {"image_path": "assets/images/icon-710x599.png",
      "android": true, "ios": true};
    expect(Android.isCustomAndroidFile(flutter_icons_config), false);

    Map flutter_icons_new_icon_config = {"image_path": "assets/images/icon-710x599.png",
      "android": "New Icon", "ios": true};
    expect(Android.isCustomAndroidFile(flutter_icons_new_icon_config), true);
  });
}