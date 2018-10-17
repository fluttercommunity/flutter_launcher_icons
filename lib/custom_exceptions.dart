
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