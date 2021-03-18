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
  final errorOutput = error == null ? '' : ' \n$error';
  return '\n✗ ERROR: ${(e).runtimeType.toString()}$errorOutput';
}

Image? decodeImageFile(String filePath) {
  final image = decodeImage(File(filePath).readAsBytesSync());
  if (image == null) {
    throw NoDecoderForImageFormatException(filePath);
  }
  return image;
}
