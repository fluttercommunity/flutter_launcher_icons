import 'package:test/test.dart';
import 'package:flutter_launcher_icons/ios.dart';
import 'package:flutter_launcher_icons/android.dart';

void main() {
  test('iOS icon list is correct size', () {
    expect(15, ios_icons.length);
  });

  test('Android icon list is correct size', () {
    expect(5, android_icons.length);
  });
}