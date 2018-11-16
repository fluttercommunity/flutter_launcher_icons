
class InvalidAndroidIconNameException implements Exception {
  final String message;
  const InvalidAndroidIconNameException([this.message]);

  @override
  String toString() {
    return '*** ERROR ***\n'
        'InvalidAndroidIconNameException\n'
        '$message';
  }
}

class InvalidConfigException implements Exception {
  final String message;
  const InvalidConfigException([this.message]);

  @override
  String toString() {
    return '*** ERROR ***\n'
        'InvalidConfigException\n'
        '$message';
  }
}

class NoConfigFoundException implements Exception {
  final String message;
  const NoConfigFoundException([this.message]);

  @override
  String toString() {
    return '*** ERROR ***\n'
        'NoConfigFoundException\n'
        '$message';
  }
}