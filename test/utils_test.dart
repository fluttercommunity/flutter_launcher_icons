import 'package:flutter_launcher_icons/utils.dart' as utils;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  group('#areFSEntitesExist', () {
    late String prefixPath;
    setUp(() async {
      prefixPath = path.join(d.sandbox, 'fli_test');
      await d.dir('fli_test', [
        d.file('file1.txt', 'contents1'),
        d.dir('dir1'),
      ]).create();
    });

    test('should return null when entites exists', () async {
      expect(
        utils.areFSEntiesExist([
          path.join(prefixPath, 'file1.txt'),
          path.join(prefixPath, 'dir1'),
        ]),
        isNull,
      );
    });

    test('should return the file path that does not exist', () {
      final result = utils.areFSEntiesExist([
        path.join(prefixPath, 'dir1'),
        path.join(prefixPath, 'file_that_does_not_exist.txt'),
      ]);
      expect(result, isNotNull);
      expect(
        result,
        equals(path.join(prefixPath, 'file_that_does_not_exist.txt')),
      );
    });

    test('should return the dir path that does not exist', () {
      final result = utils.areFSEntiesExist([
        path.join(prefixPath, 'dir_that_does_not_exist'),
        path.join(prefixPath, 'file.txt'),
      ]);
      expect(result, isNotNull);
      expect(result, equals(path.join(prefixPath, 'dir_that_does_not_exist')));
    });

    test('should return the first entity path that does not exist', () {
      final result = utils.areFSEntiesExist([
        path.join(prefixPath, 'dir_that_does_not_exist'),
        path.join(prefixPath, 'file_that_dodes_not_exist.txt'),
      ]);
      expect(result, isNotNull);
      expect(result, equals(path.join(prefixPath, 'dir_that_does_not_exist')));
    });
  });

  group('#createDirIfNotExist', () {
    setUpAll(() async {
      await d.dir('fli_test', [
        d.dir('dir_exists'),
      ]).create();
    });
    test('should create directory if it does not exist', () async {
      await expectLater(
        d.dir('fli_test', [d.dir('dir_that_does_not_exist')]).validate(),
        throwsException,
      );
      final result = utils.createDirIfNotExist(
        path.join(d.sandbox, 'fli_test', 'dir_that_does_not_exist'),
      );
      expect(result.existsSync(), isTrue);
      await expectLater(
        d.dir('fli_test', [d.dir('dir_that_does_not_exist')]).validate(),
        completes,
      );
    });
    test('should return dir if it exist', () async {
      await expectLater(
        d.dir('fli_test', [d.dir('dir_exists')]).validate(),
        completes,
      );
      final result = utils
          .createDirIfNotExist(path.join(d.sandbox, 'fli_test', 'dir_exists'));
      expect(result.existsSync(), isTrue);
      await expectLater(
        d.dir('fli_test', [d.dir('dir_exists')]).validate(),
        completes,
      );
    });
  });

  group('#createFileIfNotExist', () {
    setUpAll(() async {
      await d.dir('fli_test', [
        d.file('file_exists.txt'),
      ]).create();
    });
    test('should create file if it does not exist', () async {
      await expectLater(
        d.dir('fli_test', [d.file('file_that_does_not_exist.txt')]).validate(),
        throwsException,
      );
      final result = utils.createFileIfNotExist(
        path.join(d.sandbox, 'fli_test', 'file_that_does_not_exist.txt'),
      );
      expect(result.existsSync(), isTrue);
      await expectLater(
        d.dir('fli_test', [d.file('file_that_does_not_exist.txt')]).validate(),
        completes,
      );
    });
    test('should return file if it exist', () async {
      await expectLater(
        d.dir('fli_test', [d.file('file_exists.txt')]).validate(),
        completes,
      );
      final result = utils.createFileIfNotExist(
        path.join(d.sandbox, 'fli_test', 'file_exists.txt'),
      );
      expect(result.existsSync(), isTrue);
      await expectLater(
        d.dir('fli_test', [d.file('file_exists.txt')]).validate(),
        completes,
      );
    });
  });

  group('#prettifyJsonEncode', () {
    test('should return prettiffed json string 4 indents', () {
      const expectedValue = r'''
{
    "key1": "value1",
    "key2": "value2"
}''';
      final result = utils.prettifyJsonEncode({
        'key1': 'value1',
        'key2': 'value2',
      });
      expect(result, equals(expectedValue));
    });
  });
}
