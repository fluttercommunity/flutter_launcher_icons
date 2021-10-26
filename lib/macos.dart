import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart';

import 'abstract_platform.dart';
import 'constants.dart';
import 'contents_image_object.dart';
import 'icon_template.dart';
import 'utils.dart';

/// File to handle the creation of icons for macos platform

final IconTemplateGenerator templateGenerator = IconTemplateGenerator(
    defaultLocation: macosDefaultIconFolder, defaultSuffix: '.png');

List<IconTemplate> macosIcons = <IconTemplate>[
  templateGenerator.get(name: '_16', size: 16),
  templateGenerator.get(name: '_32', size: 32),
  templateGenerator.get(name: '_64', size: 64),
  templateGenerator.get(name: '_128', size: 128),
  templateGenerator.get(name: '_256', size: 256),
  templateGenerator.get(name: '_512', size: 512),
  templateGenerator.get(name: '_1024', size: 1024),
];

List<Map<String, String>> _createImageList(String fileNamePrefix) {
  final List<Map<String, String>> imageList = <Map<String, String>>[
    ContentsImageObject(
        size: '16x16',
        idiom: 'mac',
        filename: '${fileNamePrefix}_16.png',
        scale: '1x')
        .toJson(),
    ContentsImageObject(
        size: '16x16',
        idiom: 'mac',
        filename: '${fileNamePrefix}_32.png',
        scale: '2x')
        .toJson(),
    ContentsImageObject(
        size: '32x32',
        idiom: 'mac',
        filename: '${fileNamePrefix}_32.png',
        scale: '1x')
        .toJson(),
    ContentsImageObject(
        size: '32x32',
        idiom: 'mac',
        filename: '${fileNamePrefix}_64.png',
        scale: '2x')
        .toJson(),
    ContentsImageObject(
        size: '128x128',
        idiom: 'mac',
        filename: '${fileNamePrefix}_128.png',
        scale: '1x')
        .toJson(),
    ContentsImageObject(
        size: '128x128',
        idiom: 'mac',
        filename: '${fileNamePrefix}_256.png',
        scale: '2x')
        .toJson(),
    ContentsImageObject(
        size: '256x256',
        idiom: 'mac',
        filename: '${fileNamePrefix}_256.png',
        scale: '1x')
        .toJson(),
    ContentsImageObject(
        size: '256x256',
        idiom: 'mac',
        filename: '${fileNamePrefix}_512.png',
        scale: '2x')
        .toJson(),
    ContentsImageObject(
        size: '512x512',
        idiom: 'mac',
        filename: '${fileNamePrefix}_512.png',
        scale: '1x')
        .toJson(),
    ContentsImageObject(
        size: '512x512',
        idiom: 'mac',
        filename: '${fileNamePrefix}_1024.png',
        scale: '2x')
        .toJson(),
  ];
  return imageList;
}


class MacOSIconGenerator extends AbstractPlatform {
  const MacOSIconGenerator() : super('macos');

  @override
  void createIcons(Map<String, dynamic> config, String? flavor) {
    final String filePath = config['image_path_macos'] ?? config['image_path'];
    final Image? image = decodeImage(File(filePath).readAsBytesSync());
    if (image == null)
      return;

    String iconName;
    final dynamic macosConfig = config['macos'];
    // If the MacOS configuration is a string then the user has specified a new icon to be created
    // and for the old icon file to be kept
    if (flavor != null) {
      final String catalogName = 'AppIcon-$flavor';
      printStatus('Building macOs launcher icon for $flavor');
      for (IconTemplate template in macosIcons) {
        _saveNewIcons(template, image, catalogName);
      }
      iconName = windowsDefaultIconName;
      _changeMacosLauncherIcon(catalogName, flavor);
      _modifyContentsFile(catalogName);
    } else if (macosConfig is String) {
      final String newIconName = macosConfig;
      printStatus('Adding new macOS launcher icon');
      for (IconTemplate template in macosIcons) {
        _saveNewIcons(template, image, newIconName);
      }
      iconName = newIconName;
      _changeMacosLauncherIcon(iconName, flavor);
      _modifyContentsFile(iconName);
    }
    // Otherwise the user wants the new icon to use the default icons name and
    // update config file to use it
    else {
      printStatus('Overwriting default macOS launcher icon with new icon');
      for (IconTemplate template in macosIcons) {
        _overwriteDefaultIcons(template, image);
      }
      iconName = windowsDefaultIconName;
      _changeMacosLauncherIcon('AppIcon', flavor);
    }
  }

  void _overwriteDefaultIcons(IconTemplate template, Image image) {
    template.updateFile(image, prefix: macosDefaultIconName);
  }

  void _saveNewIcons(IconTemplate template, Image image, String newIconName) {
    final String newIconFolder = macosAssetFolder + newIconName + '.appiconset/';
    template.updateFile(image, location: newIconFolder, prefix: newIconName);
  }

  Future<void> _changeMacosLauncherIcon(String iconName, String? flavor) async {
    final File macOSConfigFile = File(macosConfigFile);
    final List<String> lines = await macOSConfigFile.readAsLines();

    bool onConfigurationSection = false;
    String? currentConfig;

    for (int x = 0; x < lines.length; x++) {
      final String line = lines[x];
      if (line.contains('/* Begin XCBuildConfiguration section */')) {
        onConfigurationSection = true;
      }
      if (line.contains('/* End XCBuildConfiguration section */')) {
        onConfigurationSection = false;
      }
      if (onConfigurationSection) {
        final match = RegExp('.*/\\* (.*)\.xcconfig \\*/;').firstMatch(line);
        if (match != null) {
          currentConfig = match.group(1);
        }

        if (currentConfig != null &&
            (flavor == null || currentConfig.contains('-$flavor')) &&
            line.contains('ASSETCATALOG')) {
          lines[x] = line.replaceAll(RegExp('\=(.*);'), '= $iconName;');
        }
      }
    }

    final String entireFile = lines.join('\n');
    await macOSConfigFile.writeAsString(entireFile);
  }

  /// Create the Contents.json file
  void _modifyContentsFile(String newIconName) {
    final String newIconFolder =
        macosAssetFolder + newIconName + '.appiconset/Contents.json';

    File(newIconFolder).create(recursive: true).then((File contentsJsonFile) {
      final String contentsFileContent =
        _generateContentsFileAsString(newIconName);
      contentsJsonFile.writeAsString(contentsFileContent);
    });
  }

  String _generateContentsFileAsString(String newIconName) {
    final Map<String, dynamic> contentJson = <String, dynamic>{
      'images': _createImageList(newIconName),
      'info': ContentsInfoObject(version: 1, author: 'xcode').toJson()
    };
    return json.encode(contentJson);
  }
}

