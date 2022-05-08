import 'dart:io';

import 'package:image/image.dart';

import 'custom_exceptions.dart';

Image createResizedImage(int iconSize, Image image) {
  if (image.width >= iconSize) {
    return copyResize(
      image,
      width: iconSize,
      height: iconSize,
      interpolation: Interpolation.average,
    );
  } else {
    return copyResize(
      image,
      width: iconSize,
      height: iconSize,
      interpolation: Interpolation.linear,
    );
  }
}

void printStatus(String message) {
  print('• $message');
}

String generateError(Exception e, String? error) {
  return '\n✗ ERROR: ${(e).runtimeType.toString()} \n$error';
}

String generateWarning(String warning) {
  return '\n⚠ WARNING: $warning\n';
}
