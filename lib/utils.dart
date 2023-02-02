import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart';
import 'package:path/path.dart' as path;

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

/// Creates [File] in the given [filePath] if not exists
File createFileIfNotExist(String filePath) {
  final file = File(path.joinAll(path.split(filePath)));
  if (!file.existsSync()) {
    file.createSync(recursive: true);
  }
  return file;
}

/// Creates [Directory] in the given [dirPath] if not exists
Directory createDirIfNotExist(String dirPath) {
  final dir = Directory(path.joinAll(path.split(dirPath)));
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  return dir;
}

/// Returns a prettified json string
String prettifyJsonEncode(Object? map) =>
    JsonEncoder.withIndent(' ' * 4).convert(map);

/// Check if give [File] or [Directory] exists at the give [paths],
/// if not returns the failed [FileSystemEntity] path
String? areFSEntiesExist(List<String> paths) {
  for (final path in paths) {
    final fsType = FileSystemEntity.typeSync(path);
    if (![FileSystemEntityType.directory, FileSystemEntityType.file]
        .contains(fsType)) {
      return path;
    }
  }
  return null;
}

String flavorConfigFile(String flavor) => 'flutter_launcher_icons-$flavor.yaml';
