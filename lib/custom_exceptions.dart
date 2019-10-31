class InvalidAndroidIconNameException implements Exception {
  const InvalidAndroidIconNameException([this.message]);

  final String message;

  @override
  String toString() {
    return '*** ERROR ***\n'
        'InvalidAndroidIconNameException\n'
        '$message';
  }
}

class InvalidConfigException implements Exception {
  const InvalidConfigException([this.message]);

  final String message;

  @override
  String toString() {
    return '*** ERROR ***\n'
        'InvalidConfigException\n'
        '$message';
  }
}

class NoConfigFoundException implements Exception {
  const NoConfigFoundException([this.message]);

  final String message;

  @override
  String toString() {
    return '*** ERROR ***\n'
        'NoConfigFoundException\n'
        '$message';
  }
}
