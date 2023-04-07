import 'package:flutter_launcher_icons/utils.dart';

/// Exception to be thrown whenever we have an invalid configuration
class InvalidConfigException implements Exception {
  /// Constructs instance
  const InvalidConfigException([this.message]);

  /// Message for the exception
  final String? message;

  @override
  String toString() {
    return generateError(this, message);
  }
}

/// Exception to be thrown whenever using an invalid Android icon name
class InvalidAndroidIconNameException implements Exception {
  /// Constructs instance of this exception
  const InvalidAndroidIconNameException([this.message]);

  /// Message for the exception
  final String? message;

  @override
  String toString() {
    return generateError(this, message);
  }
}

/// Exception to be thrown whenever no config is found
class NoConfigFoundException implements Exception {
  /// Constructs instance of this exception
  const NoConfigFoundException([this.message]);

  /// Message for the exception
  final String? message;

  @override
  String toString() {
    return generateError(this, message);
  }
}

/// Exception to be thrown whenever there is no decoder for the image format
class NoDecoderForImageFormatException implements Exception {
  /// Constructs instance of this exception
  const NoDecoderForImageFormatException([this.message]);

  /// Message for the exception
  final String? message;

  @override
  String toString() {
    return generateError(this, message);
  }
}

/// A exception to throw when given [fileName] is not found
class FileNotFoundException implements Exception {
  /// Creates a instance of [FileNotFoundException].
  const FileNotFoundException(this.fileName);

  /// Name of the file
  final String fileName;

  @override
  String toString() {
    return generateError(this, '$fileName file not found');
  }
}
