import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart';

import 'constants.dart';
import 'utils.dart';

/// File to handle the creation of icons for macos platform
class MacosIconTemplate {
  MacosIconTemplate({
    required this.size,
    required this.name,
  });

  final String name;
  final int size;
}

List<MacosIconTemplate> macosIcons = <MacosIconTemplate>[
  MacosIconTemplate(name: '_16', size: 16),
  MacosIconTemplate(name: '_32', size: 32),
  MacosIconTemplate(name: '_64', size: 64),
  MacosIconTemplate(name: '_128', size: 128),
  MacosIconTemplate(name: '_256', size: 256),
  MacosIconTemplate(name: '_512', size: 512),
  MacosIconTemplate(name: '_1024', size: 1024),
];

void createIcons(Map<String, dynamic> config, String? flavor) {
  final String filePath = config['image_path_macos'] ?? config['image_path'];
  final Image? image = decodeImage(File(filePath).readAsBytesSync());
  if (image == null) {
    return;
  }
  String iconName;
  final dynamic macosConfig = config['macos'];
  // If the MacOS configuration is a string then the user has specified a new icon to be created
  // and for the old icon file to be kept
  if (flavor != null) {
    final String catalogName = 'AppIcon-$flavor';
    printStatus('Building macOs launcher icon for $flavor');
    for (MacosIconTemplate template in macosIcons) {
      saveNewIcons(template, image, catalogName);
    }
    iconName = macosDefaultIconName;
    changeMacosLauncherIcon(catalogName, flavor);
    modifyContentsFile(catalogName);
  } else if (macosConfig is String) {
    final String newIconName = macosConfig;
    printStatus('Adding new macOS launcher icon');
    for (MacosIconTemplate template in macosIcons) {
      saveNewIcons(template, image, newIconName);
    }
    iconName = newIconName;
    changeMacosLauncherIcon(iconName, flavor);
    modifyContentsFile(iconName);
  }
  // Otherwise the user wants the new icon to use the default icons name and
  // update config file to use it
  else {
    printStatus('Overwriting default macOS launcher icon with new icon');
    for (MacosIconTemplate template in macosIcons) {
      overwriteDefaultIcons(template, image);
    }
    iconName = macosDefaultIconName;
    changeMacosLauncherIcon('AppIcon', flavor);
  }
}

/// Note: Do not change interpolation unless you end up with better results (see issue for result when using cubic
/// interpolation)
/// https://github.com/fluttercommunity/flutter_launcher_icons/issues/101#issuecomment-495528733
void overwriteDefaultIcons(MacosIconTemplate template, Image image) {
  final Image newFile = createResizedImage(template.size, image);
  File(macosDefaultIconFolder + macosDefaultIconName + template.name + '.png')
    ..writeAsBytesSync(encodePng(newFile));
}

/// Note: Do not change interpolation unless you end up with better results (see issue for result when using cubic
/// interpolation)
/// https://github.com/fluttercommunity/flutter_launcher_icons/issues/101#issuecomment-495528733
void saveNewIcons(MacosIconTemplate template, Image image, String newIconName) {
  final String newIconFolder = macosAssetFolder + newIconName + '.appiconset/';
  final Image newFile = createResizedImage(template.size, image);
  File(newIconFolder + newIconName + template.name + '.png')
      .create(recursive: true)
      .then((File file) {
    file.writeAsBytesSync(encodePng(newFile));
  });
}

Future<void> changeMacosLauncherIcon(String iconName, String? flavor) async {
  final File macOSConfigFile = File(macosConfigFile);
  final List<String> lines = await macOSConfigFile.readAsLines();

  bool onConfigurationSection = false;
  String? currentConfig;

  for (int x = 0; x < lines.length; x++) {
    String line = lines[x];
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
void modifyContentsFile(String newIconName) {
  final String newIconFolder =
      macosAssetFolder + newIconName + '.appiconset/Contents.json';
  File(newIconFolder).create(recursive: true).then((File contentsJsonFile) {
    final String contentsFileContent =
        generateContentsFileAsString(newIconName);
    contentsJsonFile.writeAsString(contentsFileContent);
  });
}

String generateContentsFileAsString(String newIconName) {
  final Map<String, dynamic> contentJson = <String, dynamic>{
    'images': createImageList(newIconName),
    'info': ContentsInfoObject(version: 1, author: 'xcode').toJson()
  };
  return json.encode(contentJson);
}

class ContentsImageObject {
  ContentsImageObject({
    required this.size,
    required this.idiom,
    required this.filename,
    required this.scale,
  });

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
  ContentsInfoObject({
    required this.version,
    required this.author
  });

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
