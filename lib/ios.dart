// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:io';

import 'package:flutter_launcher_icons/config/config.dart';
import 'package:flutter_launcher_icons/constants.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:image/image.dart';

/// File to handle the creation of icons for iOS platform
class IosIconTemplate {
  /// constructs an instance of [IosIconTemplate]
  IosIconTemplate({required this.size, required this.name});

  /// suffix of the icon name
  final String name;

  /// the size of the icon
  final int size;
}

/// details of the ios icons which need to be generated
List<IosIconTemplate> iosIcons = <IosIconTemplate>[
  IosIconTemplate(name: '-20x20@2x', size: 40),
  IosIconTemplate(name: '-20x20@3x', size: 60),
  IosIconTemplate(name: '-29x29@2x', size: 58),
  IosIconTemplate(name: '-29x29@3x', size: 87),
  IosIconTemplate(name: '-38x38@2x', size: 76),
  IosIconTemplate(name: '-38x38@3x', size: 114),
  IosIconTemplate(name: '-40x40@2x', size: 80),
  IosIconTemplate(name: '-40x40@3x', size: 120),
  IosIconTemplate(name: '-57x57@2x', size: 114),
  IosIconTemplate(name: '-60x60@2x', size: 120),
  IosIconTemplate(name: '-60x60@3x', size: 180),
  IosIconTemplate(name: '-64x64@2x', size: 128),
  IosIconTemplate(name: '-64x64@3x', size: 192),
  IosIconTemplate(name: '-68x68@2x', size: 136),
  IosIconTemplate(name: '-76x76@2x', size: 152),
  IosIconTemplate(name: '-83.5x83.5@2x', size: 167),
  IosIconTemplate(name: '-1024x1024@1x', size: 1024),
];

/// create the ios icons
void createIcons(Config config, String? flavor) {
  // TODO(p-mazhnik): support prefixPath
  final String? filePath = config.getImagePathIOS();
  if (filePath == null) {
    throw const InvalidConfigException(errorMissingImagePath);
  }
  // decodeImageFile shows error message if null
  // so can return here if image is null
  Image? image = decodeImage(File(filePath).readAsBytesSync());
  if (image == null) {
    return;
  }
  if (config.removeAlphaIOS && image.hasAlpha) {
    final backgroundColor = _getBackgroundColor(config);
    final pixel = image.getPixel(0, 0);
    do {
      pixel.set(_alphaBlend(pixel, backgroundColor));
    } while (pixel.moveNext());

    image = image.convert(numChannels: 3);
  }
  if (image.hasAlpha) {
    print(
      '\nWARNING: Icons with alpha channel are not allowed in the Apple App Store.\nSet "remove_alpha_ios: true" to remove it.\n',
    );
  }
  String iconName;
  final dynamic iosConfig = config.ios;
  if (flavor != null) {
    final String catalogName = 'AppIcon-$flavor';
    printStatus('Building iOS launcher icon for $flavor');
    for (IosIconTemplate template in iosIcons) {
      saveNewIcons(template, image, catalogName);
    }
    iconName = iosDefaultIconName;
    changeIosLauncherIcon(catalogName, flavor);
    modifyContentsFile(catalogName);
  } else if (iosConfig is String) {
    // If the IOS configuration is a string then the user has specified a new icon to be created
    // and for the old icon file to be kept
    final String newIconName = iosConfig;
    printStatus('Adding new iOS launcher icon');
    for (IosIconTemplate template in iosIcons) {
      saveNewIcons(template, image, newIconName);
    }
    iconName = newIconName;
    changeIosLauncherIcon(iconName, flavor);
    modifyContentsFile(iconName);
  }
  // Otherwise the user wants the new icon to use the default icons name and
  // update config file to use it
  else {
    printStatus('Overwriting default iOS launcher icon with new icon');
    for (IosIconTemplate template in iosIcons) {
      overwriteDefaultIcons(template, image);
    }
    iconName = iosDefaultIconName;
    changeIosLauncherIcon('AppIcon', flavor);
  }
}

/// Note: Do not change interpolation unless you end up with better results (see issue for result when using cubic
/// interpolation)
/// https://github.com/fluttercommunity/flutter_launcher_icons/issues/101#issuecomment-495528733
void overwriteDefaultIcons(IosIconTemplate template, Image image) {
  final Image newFile = createResizedImage(template, image);
  File(iosDefaultIconFolder + iosDefaultIconName + template.name + '.png')
    ..writeAsBytesSync(encodePng(newFile));
}

/// Note: Do not change interpolation unless you end up with better results (see issue for result when using cubic
/// interpolation)
/// https://github.com/fluttercommunity/flutter_launcher_icons/issues/101#issuecomment-495528733
void saveNewIcons(IosIconTemplate template, Image image, String newIconName) {
  final String newIconFolder = iosAssetFolder + newIconName + '.appiconset/';
  final Image newFile = createResizedImage(template, image);
  File(newIconFolder + newIconName + template.name + '.png')
      .create(recursive: true)
      .then((File file) {
    file.writeAsBytesSync(encodePng(newFile));
  });
}

/// create resized icon image
Image createResizedImage(IosIconTemplate template, Image image) {
  if (image.width >= template.size) {
    return copyResize(
      image,
      width: template.size,
      height: template.size,
      interpolation: Interpolation.average,
    );
  } else {
    return copyResize(
      image,
      width: template.size,
      height: template.size,
      interpolation: Interpolation.linear,
    );
  }
}

/// Change the iOS launcher icon
Future<void> changeIosLauncherIcon(String iconName, String? flavor) async {
  final File iOSConfigFile = File(iosConfigFile);
  final List<String> lines = await iOSConfigFile.readAsLines();

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

  final String entireFile = '${lines.join('\n')}\n';
  await iOSConfigFile.writeAsString(entireFile);
}

/// Create the Contents.json file
void modifyContentsFile(String newIconName) {
  final String newIconFolder =
      iosAssetFolder + newIconName + '.appiconset/Contents.json';
  File(newIconFolder).create(recursive: true).then((File contentsJsonFile) {
    final String contentsFileContent =
        generateContentsFileAsString(newIconName);
    contentsJsonFile.writeAsString(contentsFileContent);
  });
}

String generateContentsFileAsString(String newIconName) {
  final Map<String, dynamic> contentJson = <String, dynamic>{
    'images': createImageList(newIconName),
    'info': ContentsInfoObject(version: 1, author: 'xcode').toJson(),
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
      'scale': scale,
    };
  }
}

class ContentsInfoObject {
  ContentsInfoObject({required this.version, required this.author});

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
      scale: '2x',
    ).toJson(),
    ContentsImageObject(
      size: '20x20',
      idiom: 'iphone',
      filename: '$fileNamePrefix-20x20@3x.png',
      scale: '3x',
    ).toJson(),
    ContentsImageObject(
      size: '29x29',
      idiom: 'iphone',
      filename: '$fileNamePrefix-29x29@2x.png',
      scale: '2x',
    ).toJson(),
    ContentsImageObject(
      size: '29x29',
      idiom: 'iphone',
      filename: '$fileNamePrefix-29x29@3x.png',
      scale: '3x',
    ).toJson(),
    ContentsImageObject(
      size: '38x38',
      idiom: 'iphone',
      filename: '$fileNamePrefix-38x38@2x.png',
      scale: '2x',
    ).toJson(),
    ContentsImageObject(
      size: '38x38',
      idiom: 'iphone',
      filename: '$fileNamePrefix-38x38@3x.png',
      scale: '3x',
    ).toJson(),    ContentsImageObject(
      size: '40x40',
      idiom: 'iphone',
      filename: '$fileNamePrefix-40x40@2x.png',
      scale: '2x',
    ).toJson(),
    ContentsImageObject(
      size: '40x40',
      idiom: 'iphone',
      filename: '$fileNamePrefix-40x40@3x.png',
      scale: '3x',
    ).toJson(),
    ContentsImageObject(
      size: '57x57',
      idiom: 'iphone',
      filename: '$fileNamePrefix-57x57@2x.png',
      scale: '2x',
    ).toJson(),
    ContentsImageObject(
      size: '60x60',
      idiom: 'iphone',
      filename: '$fileNamePrefix-60x60@2x.png',
      scale: '2x',
    ).toJson(),
    ContentsImageObject(
      size: '60x60',
      idiom: 'iphone',
      filename: '$fileNamePrefix-60x60@3x.png',
      scale: '3x',
    ).toJson(),
    ContentsImageObject(
      size: '20x20',
      idiom: 'ipad',
      filename: '$fileNamePrefix-20x20@1x.png',
      scale: '1x',
    ).toJson(),
    ContentsImageObject(
      size: '57x57',
      idiom: 'ipad',
      filename: '$fileNamePrefix-57x57@2x.png',
      scale: '2x',
    ).toJson(),
    ContentsImageObject(
      size: '60x60',
      idiom: 'ipad',
      filename: '$fileNamePrefix-60x60@2x.png',
      scale: '2x',
    ).toJson(),
    ContentsImageObject(
      size: '60x60',
      idiom: 'ipad',
      filename: '$fileNamePrefix-60x60@3x.png',
      scale: '3x',
    ).toJson(),
    ContentsImageObject(
      size: '64x64',
      idiom: 'ipad',
      filename: '$fileNamePrefix-64x64@2x.png',
      scale: '2x',
    ).toJson(),
    ContentsImageObject(
      size: '64x64',
      idiom: 'ipad',
      filename: '$fileNamePrefix-64x64@3x.png',
      scale: '3x',
    ).toJson(),
    ContentsImageObject(
      size: '68x68',
      idiom: 'ipad',
      filename: '$fileNamePrefix-68x68@2x.png',
      scale: '2x',
    ).toJson(),
    ContentsImageObject(
      size: '76x76',
      idiom: 'ipad',
      filename: '$fileNamePrefix-76x76@1x.png',
      scale: '1x',
    ).toJson(),
    ContentsImageObject(
      size: '76x76',
      idiom: 'ipad',
      filename: '$fileNamePrefix-76x76@2x.png',
      scale: '2x',
    ).toJson(),
    ContentsImageObject(
      size: '83.5x83.5',
      idiom: 'ipad',
      filename: '$fileNamePrefix-83.5x83.5@2x.png',
      scale: '2x',
    ).toJson(),
    ContentsImageObject(
      size: '1024x1024',
      idiom: 'ios-marketing',
      filename: '$fileNamePrefix-1024x1024@1x.png',
      scale: '1x',
    ).toJson(),
  ];
  return imageList;
}

ColorUint8 _getBackgroundColor(Config config) {
  final backgroundColorHex = config.backgroundColorIOS.startsWith('#')
      ? config.backgroundColorIOS.substring(1)
      : config.backgroundColorIOS;
  if (backgroundColorHex.length != 6) {
    throw Exception('background_color_ios hex should be 6 characters long');
  }

  final backgroundByte = int.parse(backgroundColorHex, radix: 16);
  return ColorUint8.rgba(
    (backgroundByte >> 16) & 0xff,
    (backgroundByte >> 8) & 0xff,
    (backgroundByte >> 0) & 0xff,
    0xff,
  );
}

Color _alphaBlend(Color fg, ColorUint8 bg) {
  if (fg.format != Format.uint8) {
    fg = fg.convert(format: Format.uint8);
  }
  if (fg.a == 0) {
    return bg;
  } else {
    final invAlpha = 0xff - fg.a;
    return ColorUint8.rgba(
      (fg.a * fg.r + invAlpha * bg.g) ~/ 0xff,
      (fg.a * fg.g + invAlpha * bg.a) ~/ 0xff,
      (fg.a * fg.b + invAlpha * bg.b) ~/ 0xff,
      0xff,
    );
  }
}
