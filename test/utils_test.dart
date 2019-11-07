import 'package:flutter_launcher_icons/utils.dart';
import 'package:test/test.dart';

void main() {
  test('Produces expected png file path ', () {
    const String path = 'assets/images/icon-710x599-android.svg';
    const String expectedResult = 'assets/images/icon-710x599-android.png';
    expect(
        generateSvgToPngFileName(path), expectedResult);
  });

  test('Is PNG file', (){
    const String file = 'assets/images/icon-710x599-android.png';
    expect(isPngImage(file), true);
  });

  test('Is SVG file', (){
    const String file = 'assets/images/icon-710x599-android.svg';
    expect(isSvgImage(file), true);
  });
}
