import 'package:test/test.dart';
import 'package:flutter_launcher_icons/ios.dart';
import 'package:flutter_launcher_icons/android.dart';

void main() {
  test('iOS icon list is correct size', () {
    expect(ios_icons.length, 15);
  });

  test('Android icon list is correct size', () {
    expect(android_icons.length, 5);
  });

  test('iOS image list used to generate Contents.json for icon directory is correct size', () {
    expect(createImageList("blah").length, 19);
  });
}