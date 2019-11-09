
import 'package:flutter_launcher_icons/custom_exceptions.dart';
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

  test('generateSvgToPngFileName from png', () {
    const String path = 'assets/images/icon-710x599-android.svg.png';
    const String expectedResult = 'assets/images/icon-710x599-android.svg.png';
    expect(generateSvgToPngFileName(path), expectedResult);

    const String path2 = 'assets/images/icon-710x599-android.svg.txt.svg';
    const String expectedResult2 = 'assets/images/icon-710x599-android.svg.txt.png';
    expect(generateSvgToPngFileName(path2), expectedResult2);
  });
  
  test('Throws InvalidImageFormatException', () {
    const String path = 'assets/images/icon.svg.pdf';
    const String path2 = 'assets/images/icon.svg.xml';
    expect(() => generateSvgToPngFileName(path), throwsA(const TypeMatcher<InvalidImageFormatException>()));
    expect(() => generateSvgToPngFileName(path2), throwsA(const TypeMatcher<InvalidImageFormatException>()));
  });
}
