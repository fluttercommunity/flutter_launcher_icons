import 'package:flutter_launcher_icons/utils.dart';

class InvalidAndroidIconNameException implements Exception {
  const InvalidAndroidIconNameException([this.message]);
  final String? message;

  @override
  String toString() {
    return generateError(this, message);
  }
}

class InvalidConfigException implements Exception {
  const InvalidConfigException([this.message]);
  final String? message;

  @override
  String toString() {
    return generateError(this, message);
  }
}

class NoConfigFoundException implements Exception {
  const NoConfigFoundException([this.message]);
  final String? message;

  @override
  String toString() {
    return generateError(this, message);
  }
}

class NoDecoderForImageFormatException implements Exception {
  const NoDecoderForImageFormatException([this.message]);
  final String? message;

  @override
  String toString() {
    return generateError(this, message);
  }
}

class FileNotFoundException implements Exception {
  const FileNotFoundException(this.fileName);

  final String fileName;
  @override
  String toString() {
    return generateError(this, '$fileName file not found');
  }
}
