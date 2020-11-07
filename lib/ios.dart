import 'dart:convert';
import 'dart:io';

import 'package:flutter_launcher_icons/utils.dart';
import 'package:flutter_launcher_icons/icon_template.dart';
import 'package:flutter_launcher_icons/constants.dart';
import 'package:flutter_launcher_icons/abstract_platform.dart';

import 'package:image/image.dart';

final IconTemplateGenerator templateGenerator = IconTemplateGenerator(
    defaultLocation: iosDefaultIconFolder, defaultSuffix: '.png');

List<IconTemplate> iosIcons = <IconTemplate>[
  templateGenerator.get(name: '-20x20@1x', size: 20),
  templateGenerator.get(name: '-20x20@2x', size: 40),
  templateGenerator.get(name: '-20x20@3x', size: 60),
  templateGenerator.get(name: '-29x29@1x', size: 29),
  templateGenerator.get(name: '-29x29@2x', size: 58),
  templateGenerator.get(name: '-29x29@3x', size: 87),
  templateGenerator.get(name: '-40x40@1x', size: 40),
  templateGenerator.get(name: '-40x40@2x', size: 80),
  templateGenerator.get(name: '-40x40@3x', size: 120),
  templateGenerator.get(name: '-60x60@2x', size: 120),
  templateGenerator.get(name: '-60x60@3x', size: 180),
  templateGenerator.get(name: '-76x76@1x', size: 76),
  templateGenerator.get(name: '-76x76@2x', size: 152),
  templateGenerator.get(name: '-83.5x83.5@2x', size: 167),
  templateGenerator.get(name: '-1024x1024@1x', size: 1024),
];

class ContentsImageObject {
  ContentsImageObject({this.size, this.idiom, this.filename, this.scale});

  final String size;
  final String idiom;
  final String filename;
  final String scale;

  Map<String, String> toJson() {
    return <String, String>{
      'size': size,
      'idiom': idiom,
      'filename': filename,
      'scale': scale
    };
  }
}

class ContentsInfoObject {
  ContentsInfoObject({this.version, this.author});

  final int version;
  final String author;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': version,
      'author': author,
    };
  }
}

List<Map<String, String>> createImageList(String fileNamePrefix) {
  final List<Map<String, String>> imageList = <Map<String, String>>[
    ContentsImageObject(
            size: '20x20',
            idiom: 'iphone',
            filename: '$fileNamePrefix-20x20@2x.png',
            scale: '2x')
        .toJson(),
    ContentsImageObject(
            size: '20x20',
            idiom: 'iphone',
            filename: '$fileNamePrefix-20x20@3x.png',
            scale: '3x')
        .toJson(),
    ContentsImageObject(
            size: '29x29',
            idiom: 'iphone',
            filename: '$fileNamePrefix-29x29@1x.png',
            scale: '1x')
        .toJson(),
    ContentsImageObject(
            size: '29x29',
            idiom: 'iphone',
            filename: '$fileNamePrefix-29x29@2x.png',
            scale: '2x')
        .toJson(),
    ContentsImageObject(
            size: '29x29',
            idiom: 'iphone',
            filename: '$fileNamePrefix-29x29@3x.png',
            scale: '3x')
        .toJson(),
    ContentsImageObject(
            size: '40x40',
            idiom: 'iphone',
            filename: '$fileNamePrefix-40x40@2x.png',
            scale: '2x')
        .toJson(),
    ContentsImageObject(
            size: '40x40',
            idiom: 'iphone',
            filename: '$fileNamePrefix-40x40@3x.png',
            scale: '3x')
        .toJson(),
    ContentsImageObject(
            size: '60x60',
            idiom: 'iphone',
            filename: '$fileNamePrefix-60x60@2x.png',
            scale: '2x')
        .toJson(),
    ContentsImageObject(
            size: '60x60',
            idiom: 'iphone',
            filename: '$fileNamePrefix-60x60@3x.png',
            scale: '3x')
        .toJson(),
    ContentsImageObject(
            size: '20x20',
            idiom: 'ipad',
            filename: '$fileNamePrefix-20x20@1x.png',
            scale: '1x')
        .toJson(),
    ContentsImageObject(
            size: '20x20',
            idiom: 'ipad',
            filename: '$fileNamePrefix-20x20@2x.png',
            scale: '2x')
        .toJson(),
    ContentsImageObject(
            size: '29x29',
            idiom: 'ipad',
            filename: '$fileNamePrefix-29x29@1x.png',
            scale: '1x')
        .toJson(),
    ContentsImageObject(
            size: '29x29',
            idiom: 'ipad',
            filename: '$fileNamePrefix-29x29@2x.png',
            scale: '2x')
        .toJson(),
    ContentsImageObject(
            size: '40x40',
            idiom: 'ipad',
            filename: '$fileNamePrefix-40x40@1x.png',
            scale: '1x')
        .toJson(),
    ContentsImageObject(
            size: '40x40',
            idiom: 'ipad',
            filename: '$fileNamePrefix-40x40@2x.png',
            scale: '2x')
        .toJson(),
    ContentsImageObject(
            size: '76x76',
            idiom: 'ipad',
            filename: '$fileNamePrefix-76x76@1x.png',
            scale: '1x')
        .toJson(),
    ContentsImageObject(
            size: '76x76',
            idiom: 'ipad',
            filename: '$fileNamePrefix-76x76@2x.png',
            scale: '2x')
        .toJson(),
    ContentsImageObject(
            size: '83.5x83.5',
            idiom: 'ipad',
            filename: '$fileNamePrefix-83.5x83.5@2x.png',
            scale: '2x')
        .toJson(),
    ContentsImageObject(
            size: '1024x1024',
            idiom: 'ios-marketing',
            filename: '$fileNamePrefix-1024x1024@1x.png',
            scale: '1x')
        .toJson()
  ];
  return imageList;
}

class IOSIconGenerator extends AbstractPlatform {
  const IOSIconGenerator() : super('ios');

  @override
  void createIcons(Map<String, dynamic> config, String flavor) {
    final String filePath = config['image_path_ios'] ?? config['image_path'];
    final Image image = decodeImage(File(filePath).readAsBytesSync());
    String iconName;
    final dynamic iosConfig = config['ios'];
    if (flavor != null) {
      final String catalogName = 'AppIcon-$flavor';
      printStatus('Building iOS launcher icon for $flavor');
      for (IconTemplate template in iosIcons) {
        _saveNewIcons(template, image, catalogName);
      }
      iconName = iosDefaultIconName;
      _changeIosLauncherIcon(catalogName, flavor);
      _modifyContentsFile(catalogName);
    } else if (iosConfig is String) {
      // If the IOS configuration is a string then the user has specified a new icon to be created
      // and for the old icon file to be kept
      final String newIconName = iosConfig;
      printStatus('Adding new iOS launcher icon');
      for (IconTemplate template in iosIcons) {
        _saveNewIcons(template, image, newIconName);
      }
      iconName = newIconName;
      _changeIosLauncherIcon(iconName, flavor);
      _modifyContentsFile(iconName);
    }
    // Otherwise the user wants the new icon to use the default icons name and
    // update config file to use it
    else {
      printStatus('Overwriting default iOS launcher icon with new icon');
      for (IconTemplate template in iosIcons) {
        _overwriteDefaultIcons(template, image);
      }
      iconName = iosDefaultIconName;
      _changeIosLauncherIcon('AppIcon', flavor);
    }
  }

  void _overwriteDefaultIcons(IconTemplate template, Image image) {
    template.updateFile(image, prefix: iosDefaultIconName);
  }

  void _saveNewIcons(IconTemplate template, Image image, String newIconName) {
    final String newIconFolder = iosAssetFolder + newIconName + '.appiconset/';

    template.updateFile(image, location: newIconFolder, prefix: newIconName);
  }

  Future<void> _changeIosLauncherIcon(String iconName, String flavor) async {
    final File iOSConfigFile = File(iosConfigFile);
    final List<String> lines = await iOSConfigFile.readAsLines();

    bool onConfigurationSection = false;
    String currentConfig;

    for (int x = 0; x < lines.length; x++) {
      final String line = lines[x];
      if (line.contains('/* Begin XCBuildConfiguration section */')) {
        onConfigurationSection = true;
      }
      if (line.contains('/* End XCBuildConfiguration section */')) {
        onConfigurationSection = false;
      }
      if (onConfigurationSection) {
        final RegExpMatch match =
            RegExp('.*/\\* (.*)\.xcconfig \\*/;').firstMatch(line);

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
    await iOSConfigFile.writeAsString(entireFile);
  }

  /// Create the Contents.json file
  void _modifyContentsFile(String newIconName) {
    final String newIconFolder =
        iosAssetFolder + newIconName + '.appiconset/Contents.json';
    File(newIconFolder).create(recursive: true).then((File contentsJsonFile) {
      final String contentsFileContent =
          _generateContentsFileAsString(newIconName);
      contentsJsonFile.writeAsString(contentsFileContent);
    });
  }

  String _generateContentsFileAsString(String newIconName) {
    final Map<String, dynamic> contentJson = <String, dynamic>{
      'images': createImageList(newIconName),
      'info': ContentsInfoObject(version: 1, author: 'xcode').toJson()
    };
    return json.encode(contentJson);
  }
}
