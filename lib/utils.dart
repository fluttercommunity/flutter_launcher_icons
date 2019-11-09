

import 'package:flutter_launcher_icons/constants.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';

/// Returns true if the file ends in .png to indicate PNG image
bool isPngImage(String backgroundFile) {
  return backgroundFile.endsWith('.png');
}

/// Returns true if the file ends in .svg to indicate SVG image
bool isSvgImage(String backgroundFile) {
  return backgroundFile.endsWith('.svg');
}

/// Converts SVG file name to PNG file name
/// e.g. ../assets/images/icon.svg -> ../assets/images/icon.png
///
/// Recommended to check if file path indicates svg before using this function
/// otherwise InvalidImageFormatException will be thrown (unless png image)
String generateSvgToPngFileName(String originalFilePath) {
  if (isPngImage(originalFilePath)) {
    print(warningAlreadyPng);
    return originalFilePath;
  } else if (!isSvgImage(originalFilePath)) {
    throw const InvalidImageFormatException(errorInvalidImageFormat);
  }

  return originalFilePath.replaceRange(originalFilePath.length - 4, originalFilePath.length , '.png');
}


