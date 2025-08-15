import 'package:flutter_launcher_icons/abs/icon_generator.dart';
import 'package:flutter_launcher_icons/constants.dart' as constants;
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/utils.dart' as utils;
import 'package:image/image.dart';
import 'package:path/path.dart' as path;

/// A Implementation of [IconGenerator] for Windows
class WindowsIconGenerator extends IconGenerator {
  /// Creates a instance of [WindowsIconGenerator]
  WindowsIconGenerator(IconGeneratorContext context)
      : super(context, 'Windows');

  // Minimal, sensible defaults for Windows ICOs.
  static const List<int> _icoSizes = [16, 24, 32, 48, 256];

  @override
  Future<void> createIcons() async {
    final imgFilePath = path.join(
      context.prefixPath,
      context.windowsConfig!.imagePath ?? context.config.imagePath,
    );

    context.logger
        .verbose('Decoding and loading image file from $imgFilePath...');
    final imgFile = await utils.decodeImageFile(imgFilePath);
    // TODO(RatakondalaArun): remove null check
    // #utils.decodeImageFile never returns null instead it throws Exception
    if (imgFile == null) {
      context.logger
          .error('Image File not found at given path $imgFilePath...');
      throw FileNotFoundException(imgFilePath);
    }

    context.logger.verbose('Generating icon from $imgFilePath...');
    await _generateIcon(imgFile);
  }

  @override
  bool validateRequirements() {
    context.logger.verbose('Validating windows config...');
    final windowsConfig = context.windowsConfig;
    if (windowsConfig == null || !windowsConfig.generate) {
      context.logger.error(
        'Windows config is not provided or windows.generate is false. Skipped...',
      );
      return false;
    }

    if (windowsConfig.imagePath == null && context.config.imagePath == null) {
      context.logger.error(
        'Invalid config. Either provide windows.image_path or image_path',
      );
      return false;
    }

    // DEPRECATED: read only to warn, then ignored.
    // ignore: deprecated_member_use_from_same_package
    if (windowsConfig.iconSize != null) {
      context.logger.verbose(
        'DEPRECATED: `windows.icon_size` is ignored. The generator now '
            'produces a multi-size .ico (16, 24, 32, 48, 256).',
      );
    }
    final entitesToCheck = [
      path.join(context.prefixPath, constants.windowsDirPath),
      path.join(
        context.prefixPath,
        windowsConfig.imagePath ?? context.config.imagePath,
      ),
    ];

    final failedEntityPath = utils.areFSEntiesExist(entitesToCheck);
    if (failedEntityPath != null) {
      context.logger.error(
        '$failedEntityPath this file or folder is required to generate web icons',
      );
      return false;
    }

    return true;
  }

  Future<void> _generateIcon(Image image) async {
    // Build a multi-frame ICO: one frame per target size.
    Image? multi;
    for (final sz in _icoSizes) {
      final resized = utils.createResizedImage(sz, image);
      if (multi == null) {
        multi = resized;
      } else {
        multi.addFrame(resized);
      }
    }
    final favIconFile = await utils.createFileIfNotExist(
      path.join(context.prefixPath, constants.windowsIconFilePath),
    );
    await favIconFile.writeAsBytes(encodeIco(multi!));
  }
}
