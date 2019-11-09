import 'dart:io';

import 'package:path/path.dart' as p;

/// Can throw ConversionException
/// Example: convertSvgToPng(p.absolute('assets/tiger.svg'), p.absolute('assets/tiger.png'), 2048, 2048);
void convertSvgToPng(String svgPath, String pngPath, int width, int height) {
  final String inkscapePath = findExecutable('inkscape');
  if (inkscapePath == null) {
    throw const ConversionException('No inkscape installation found.');
  }
  final ProcessResult result = Process.runSync(
    inkscapePath,
    [svgPath, '--export-png=$pngPath', '-w=$width', '-h=$height'],
  );
  if (result.stderr != '') {
    throw ConversionException('Inkscape produced an error: ${result.stderr}');
  } else if (result.exitCode != 0) {
    throw ConversionException('Inkscape failed to work correctly: ${result.exitCode}');
  }
}

class ConversionException implements Exception {
  const ConversionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Finds the inkscape executable
String findExecutable(String name, {String orElse()}) {
  String found;
  final String filename = Platform.isWindows ? '$name.exe' : name;

  bool existsInPath(String path) {
    final String filePath = p.join(path, filename);
    if (File(filePath).existsSync()) {
      found = filePath;
      return true;
    }
    return false;
  }

  final String binPathSep = (Platform.isWindows) ? ';' : ':';
  for (final String path in Platform.environment['PATH'].split(binPathSep)) {
    if (existsInPath(path)) {
      return found;
    }
  }

  if (Platform.isWindows) {
    if (existsInPath(p.join(Platform.environment['PROGRAMFILES'], name))) {
      return found;
    }
    if (existsInPath(p.join(Platform.environment['PROGRAMFILES(X86)'], name))) {
      return found;
    }
  }

  return orElse?.call();
}
