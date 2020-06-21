import 'package:test/test.dart';
import 'package:flutter_launcher_icons/android.dart' as android;
import 'package:flutter_launcher_icons/constants.dart';

// unit tests for android.dart
void main() {
  test('Adaptive icon mipmap path is correct', () {
    const String path1 = 'android/app/src/main/res/';
    const String path2 = 'mipmap-anydpi-v26/';
    expect(android.isCorrectMipmapDirectoryForAdaptiveIcon(path1), false);
    expect(android.isCorrectMipmapDirectoryForAdaptiveIcon(path2), false);
    expect(
      android.isCorrectMipmapDirectoryForAdaptiveIcon(androidAdaptiveXmlFolder),
      true,
    );
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
    expect(android.getAndroidIconPath(flutterIconsNewIconConfig),
        'assets/images/icon-android.png');
  });

  test('Transforming manifest without icon must add icon', () {
    final String inputManifest = getAndroidManifestExample(
      'android:icon="@mipmap/ic_launcher"',
    );
    final String expectedManifest = getAndroidManifestExample(
      'android:icon="@mipmap/ic_other_icon_name"',
    );

    final String actual = android
        .transformAndroidManifestWithNewLauncherIcon(
          inputManifest.split('\n'),
          'ic_other_icon_name',
        )
        .join('\n');
    expect(actual, equals(expectedManifest));
  });

  test(
      'Transforming manifest with icon already in place should leave it unchanged',
      () {
    final String inputManifest = getAndroidManifestExample(
      'android:icon="@mipmap/ic_launcher"',
    );
    final String actual = android
        .transformAndroidManifestWithNewLauncherIcon(
          inputManifest.split('\n'),
          'ic_launcher',
        )
        .join('\n');
    expect(actual, equals(inputManifest));
  });
}

String getAndroidManifestExample(String iconLine) {
  return '''
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.myapplication">

    <application
        android:allowBackup="true"
        $iconLine
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/AppTheme">
        <activity
            android:name=".MainActivity"
            android:label="@string/app_name"
            android:theme="@style/AppTheme.NoActionBar">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />

                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

</manifest>
  '''
      .trim();
}
