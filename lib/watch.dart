import 'dart:convert';
import 'dart:io';

import 'package:flutter_launcher_icons/abs/icon_generator.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/utils.dart' as utils;
import 'package:image/image.dart';
import 'package:path/path.dart' as path;

/// Generates icons for an Apple Watch app target.
class WatchIconGenerator extends IconGenerator {
  /// Creates an instance of [WatchIconGenerator].
  WatchIconGenerator(IconGeneratorContext context)
      : super(context, 'Apple Watch');

  @override
  bool validateRequirements() {
    final imagePath = context.config.watchImagePath;
    if (imagePath == null) {
      context.logger.verbose('watch_image_path is not configured. Skipped...');
      return false;
    }

    final imageFilePath = path.join(context.prefixPath, imagePath);
    if (!File(imageFilePath).existsSync()) {
      context.logger.error(
        'Watch icon image not found at the given path $imageFilePath.',
      );
      return false;
    }

    final iosDirectory = Directory(path.join(context.prefixPath, 'ios'));
    if (!iosDirectory.existsSync()) {
      context.logger.error(
        '${iosDirectory.path} is required to generate Apple Watch icons.',
      );
      return false;
    }

    return true;
  }

  @override
  Future<void> createIcons() async {
    final imagePath = path.join(
      context.prefixPath,
      context.config.watchImagePath!,
    );
    context.logger.verbose('Decoding and loading image file at $imagePath...');
    final image = await utils.decodeImageFile(imagePath);
    if (image == null) {
      throw FileNotFoundException(imagePath);
    }

    final iosDirectory = Directory(path.join(context.prefixPath, 'ios'));
    final assetsCatalog = await _findWatchAssetsCatalog(iosDirectory);
    final iconSetName =
        context.flavor != null && context.config.isNeedingNewIOSIcon
            ? 'AppIcon-${context.flavor}'
            : 'AppIcon';
    final iconSetDirectory = Directory(
      path.join(assetsCatalog.path, '$iconSetName.appiconset'),
    );
    await iconSetDirectory.create(recursive: true);

    final contentsFile = File(
      path.join(iconSetDirectory.path, 'Contents.json'),
    );
    final contents = contentsFile.existsSync()
        ? jsonDecode(await contentsFile.readAsString()) as Map<String, dynamic>
        : <String, dynamic>{};
    final existingImages = contents['images'];
    final images = <dynamic>[
      if (existingImages is List)
        ...existingImages.where((entry) => !_isWatchIcon(entry)),
    ];

    for (final template in _watchIconTemplates) {
      final filename = 'AppIcon-${template.size}@${template.scale}.png';
      final resizedImage = utils.createResizedImage(template.pixelSize, image);
      final iconFile = File(path.join(iconSetDirectory.path, filename));
      await iconFile.writeAsBytes(encodePng(resizedImage));
      images.add(template.toJson(filename));
    }

    contents
      ..['images'] = images
      ..putIfAbsent(
        'info',
        () => <String, dynamic>{'version': 1, 'author': 'xcode'},
      );
    await contentsFile.writeAsString(utils.prettifyJsonEncode(contents));

    final assetCatalogContents = File(
      path.join(assetsCatalog.path, 'Contents.json'),
    );
    if (!assetCatalogContents.existsSync()) {
      await assetCatalogContents.writeAsString(
        utils.prettifyJsonEncode(<String, dynamic>{
          'info': <String, dynamic>{'version': 1, 'author': 'xcode'},
        }),
      );
    }
  }
}

class _WatchIconTemplate {
  const _WatchIconTemplate({
    required this.size,
    required this.pixelSize,
    required this.scale,
    this.role,
    this.subtype,
    this.idiom = 'watch',
  });

  final String size;
  final int pixelSize;
  final String scale;
  final String? role;
  final String? subtype;
  final String idiom;

  Map<String, dynamic> toJson(String filename) => <String, dynamic>{
        'filename': filename,
        'idiom': idiom,
        if (role != null) 'role': role,
        'scale': scale,
        'size': size,
        if (subtype != null) 'subtype': subtype,
      };
}

const _watchIconTemplates = <_WatchIconTemplate>[
  _WatchIconTemplate(
    size: '24x24',
    pixelSize: 48,
    scale: '2x',
    role: 'notificationCenter',
    subtype: '38mm',
  ),
  _WatchIconTemplate(
    size: '27.5x27.5',
    pixelSize: 55,
    scale: '2x',
    role: 'notificationCenter',
    subtype: '42mm',
  ),
  _WatchIconTemplate(
    size: '29x29',
    pixelSize: 58,
    scale: '2x',
    role: 'companionSettings',
  ),
  _WatchIconTemplate(
    size: '29x29',
    pixelSize: 87,
    scale: '3x',
    role: 'companionSettings',
  ),
  _WatchIconTemplate(
    size: '33x33',
    pixelSize: 66,
    scale: '2x',
    role: 'notificationCenter',
    subtype: '45mm',
  ),
  _WatchIconTemplate(
    size: '40x40',
    pixelSize: 80,
    scale: '2x',
    role: 'appLauncher',
    subtype: '38mm',
  ),
  _WatchIconTemplate(
    size: '44x44',
    pixelSize: 88,
    scale: '2x',
    role: 'appLauncher',
    subtype: '40mm',
  ),
  _WatchIconTemplate(
    size: '46x46',
    pixelSize: 92,
    scale: '2x',
    role: 'appLauncher',
    subtype: '41mm',
  ),
  _WatchIconTemplate(
    size: '50x50',
    pixelSize: 100,
    scale: '2x',
    role: 'appLauncher',
    subtype: '44mm',
  ),
  _WatchIconTemplate(
    size: '51x51',
    pixelSize: 102,
    scale: '2x',
    role: 'appLauncher',
    subtype: '45mm',
  ),
  _WatchIconTemplate(
    size: '54x54',
    pixelSize: 108,
    scale: '2x',
    role: 'appLauncher',
    subtype: '49mm',
  ),
  _WatchIconTemplate(
    size: '86x86',
    pixelSize: 172,
    scale: '2x',
    role: 'quickLook',
    subtype: '38mm',
  ),
  _WatchIconTemplate(
    size: '98x98',
    pixelSize: 196,
    scale: '2x',
    role: 'quickLook',
    subtype: '42mm',
  ),
  _WatchIconTemplate(
    size: '108x108',
    pixelSize: 216,
    scale: '2x',
    role: 'quickLook',
    subtype: '44mm',
  ),
  _WatchIconTemplate(
    size: '117x117',
    pixelSize: 234,
    scale: '2x',
    role: 'quickLook',
    subtype: '45mm',
  ),
  _WatchIconTemplate(
    size: '129x129',
    pixelSize: 258,
    scale: '2x',
    role: 'quickLook',
    subtype: '49mm',
  ),
  _WatchIconTemplate(
    size: '1024x1024',
    pixelSize: 1024,
    scale: '1x',
    idiom: 'watch-marketing',
  ),
];

Future<Directory> _findWatchAssetsCatalog(Directory iosDirectory) async {
  final assetCatalogs = <Directory>[];
  final watchAppDirectories = <Directory>[];
  final pendingDirectories = <Directory>[iosDirectory];
  const ignoredDirectoryNames = <String>{
    '.git',
    '.symlinks',
    'build',
    'flutter',
    'pods',
  };

  while (pendingDirectories.isNotEmpty) {
    final directory = pendingDirectories.removeLast();
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is! Directory) {
        continue;
      }

      final name = path.basename(entity.path);
      final normalizedName = _normalize(name);
      if (_isWatchAppName(normalizedName)) {
        watchAppDirectories.add(entity);
      }

      if (name.toLowerCase() == 'assets.xcassets') {
        final relativePath = path.relative(
          entity.path,
          from: iosDirectory.path,
        );
        if (!_isWatchExtensionPath(relativePath) &&
            (_hasWatchPathSegment(relativePath) ||
                await _hasWatchIconSet(entity))) {
          assetCatalogs.add(entity);
        }
        continue;
      }

      if (ignoredDirectoryNames.contains(name.toLowerCase()) ||
          name.endsWith('.xcodeproj') ||
          name.endsWith('.xcworkspace')) {
        continue;
      }
      pendingDirectories.add(entity);
    }
  }

  if (assetCatalogs.length == 1) {
    return assetCatalogs.single;
  }

  if (assetCatalogs.length > 1) {
    final watchAppCatalogs = assetCatalogs.where((catalog) {
      final relativePath = path.relative(catalog.path, from: iosDirectory.path);
      return _isWatchAppName(_normalize(relativePath)) &&
          !_isWatchExtensionPath(relativePath);
    }).toList();
    if (watchAppCatalogs.length == 1) {
      return watchAppCatalogs.single;
    }

    throw InvalidConfigException(
      'Found multiple Apple Watch asset catalogs under ${iosDirectory.path}. '
      'Keep one Watch App Assets.xcassets catalog or remove the ambiguity.',
    );
  }

  if (watchAppDirectories.length == 1) {
    return Directory(
      path.join(watchAppDirectories.single.path, 'Assets.xcassets'),
    );
  }

  throw InvalidConfigException(
    'No Apple Watch Assets.xcassets catalog found under ${iosDirectory.path}. '
    'Add a Watch App target before generating its icons.',
  );
}

Future<bool> _hasWatchIconSet(Directory assetsCatalog) async {
  final contentsFile = File(
    path.join(assetsCatalog.path, 'AppIcon.appiconset', 'Contents.json'),
  );
  if (!contentsFile.existsSync()) {
    return false;
  }

  final contents =
      jsonDecode(await contentsFile.readAsString()) as Map<String, dynamic>;
  final images = contents['images'];
  return images is List && images.any(_isWatchIcon);
}

bool _isWatchIcon(dynamic image) =>
    image is Map &&
    (image['idiom'] == 'watch' || image['idiom'] == 'watch-marketing');

bool _hasWatchPathSegment(String value) =>
    path.split(value).any((segment) => segment.toLowerCase().contains('watch'));

bool _isWatchAppName(String normalizedName) =>
    normalizedName.contains('watchapp') ||
    normalizedName.contains('watchkitapp');

bool _isWatchExtensionPath(String value) {
  final normalizedPath = _normalize(value);
  return normalizedPath.contains('watchextension') ||
      normalizedPath.contains('watchkitextension');
}

String _normalize(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
