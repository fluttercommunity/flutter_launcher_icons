import 'dart:convert';
import 'dart:io';

import 'package:flutter_launcher_icons/constants.dart';
import 'package:image/image.dart';
import 'package:path/path.dart' as p;

/// File to handle the creation of icons for iOS platform
class IosIconTemplate {
  IosIconTemplate({this.size, this.name});

  final String name;
  final int size;
}

List<IosIconTemplate> iosIcons = <IosIconTemplate>[
  IosIconTemplate(name: '-20x20@1x', size: 20),
  IosIconTemplate(name: '-20x20@2x', size: 40),
  IosIconTemplate(name: '-20x20@3x', size: 60),
  IosIconTemplate(name: '-29x29@1x', size: 29),
  IosIconTemplate(name: '-29x29@2x', size: 58),
  IosIconTemplate(name: '-29x29@3x', size: 87),
  IosIconTemplate(name: '-40x40@1x', size: 40),
  IosIconTemplate(name: '-40x40@2x', size: 80),
  IosIconTemplate(name: '-40x40@3x', size: 120),
  IosIconTemplate(name: '-50x50@1x', size: 50),
  IosIconTemplate(name: '-50x50@2x', size: 100),
  IosIconTemplate(name: '-57x57@1x', size: 57),
  IosIconTemplate(name: '-57x57@2x', size: 114),
  IosIconTemplate(name: '-60x60@2x', size: 120),
  IosIconTemplate(name: '-60x60@3x', size: 180),
  IosIconTemplate(name: '-72x72@1x', size: 72),
  IosIconTemplate(name: '-72x72@2x', size: 144),
  IosIconTemplate(name: '-76x76@1x', size: 76),
  IosIconTemplate(name: '-76x76@2x', size: 152),
  IosIconTemplate(name: '-83.5x83.5@2x', size: 167),
  IosIconTemplate(name: '-1024x1024@1x', size: 1024),
];

void createIcons(Map<String, dynamic> config) {
  final String filePath = config['image_path_ios'] ?? config['image_path'];
  final Image image = decodeImage(File(filePath).readAsBytesSync());
  String iconName;
  final dynamic iosConfig = config['ios'];
  // If the IOS configuration is a string then the user has specified a new icon to be created
  // and for the old icon file to be kept
  if (iosConfig is String) {
    final String newIconName = iosConfig;
    print('Adding new iOS launcher icon');
    for (IosIconTemplate template in iosIcons) {
      saveNewIcons(template, image, newIconName);
    }
    iconName = newIconName;
    changeIosLauncherIcon(iconName);
    modifyContentsFile(iconName);
  }
  // Otherwise the user wants the new icon to use the default icons name and
  // update config file to use it
  else {
    print('Overwriting default iOS launcher icon with new icon');
    for (IosIconTemplate template in iosIcons) {
      overwriteDefaultIcons(template, image);
    }
    iconName = iosDefaultIconName;
    changeIosLauncherIcon('AppIcon');
  }
}

/// Note: Do not change interpolation unless you end up with better results (see issue for result when using cubic
/// interpolation)
/// https://github.com/fluttercommunity/flutter_launcher_icons/issues/101#issuecomment-495528733
void overwriteDefaultIcons(IosIconTemplate template, Image image) {
  final Image newImage = createResizedImage(template, image);
  final File newIconFile = File(p.join(iosDefaultIconFolder, iosDefaultIconName + template.name + '.png'));
  newIconFile.writeAsBytesSync(encodePng(newImage));
}

/// Note: Do not change interpolation unless you end up with better results (see issue for result when using cubic
/// interpolation)
/// https://github.com/fluttercommunity/flutter_launcher_icons/issues/101#issuecomment-495528733
Future<void> saveNewIcons(IosIconTemplate template, Image image, String newIconName) async {
  final String newIconFolder = p.join(iosAssetFolder, newIconName + '.appiconset');
  final Image newImage = createResizedImage(template, image);
  final String newIconPath = p.join(newIconFolder, newIconName + template.name + '.png');
  final File newIconFile = await File(newIconPath).create(recursive: true);
  newIconFile.writeAsBytesSync(encodePng(newImage));
}

Image createResizedImage(IosIconTemplate template, Image image) {
  if (image.width >= template.size) {
    return copyResize(image, width: template.size, height: template.size, interpolation: Interpolation.average);
  } else {
    return copyResize(image, width: template.size, height: template.size, interpolation: Interpolation.linear);
  }
}

Future<void> changeIosLauncherIcon(String iconName) async {
  final File iOSConfigFile = File(iosConfigFile);
  final List<String> lines = await iOSConfigFile.readAsLines();
  for (int x = 0; x < lines.length; x++) {
    String line = lines[x];
    if (line.contains('ASSETCATALOG')) {
      line = line.replaceAll(RegExp(r'=.*;'), '= $iconName;');
      lines[x] = line;
      lines[lines.length - 1] = '}\n';
    }
  }
  final String entireFile = lines.join('\n');
  await iOSConfigFile.writeAsString(entireFile);
}

/// Create the Contents.json file
Future<void> modifyContentsFile(String newIconName) async {
  final String newIconFolder = p.join(iosAssetFolder, newIconName + '.appiconset', 'Contents.json');
  final File contentsJsonFile = await File(newIconFolder).create(recursive: true);
  final String contentsFileContent = generateContentsFileAsString(newIconName);
  contentsJsonFile.writeAsString(contentsFileContent);
}

String generateContentsFileAsString(String newIconName) {
  return json.encode(<String, dynamic>{
    'images': createImageList(newIconName),
    'info': ContentsInfoObject(version: 1, author: 'xcode'),
  });
}

class ContentsImageObject {
  ContentsImageObject({this.size, this.idiom, this.filename, this.scale});

  final String size;
  final String idiom;
  final String filename;
  final String scale;

  Map<String, String> toJson() {
    return <String, String>{'size': size, 'idiom': idiom, 'filename': filename, 'scale': scale};
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

List<ContentsImageObject> createImageList(String fileNamePrefix) {
  return <ContentsImageObject>[
    ContentsImageObject(size: '20x20', idiom: 'iphone', filename: '$fileNamePrefix-20x20@2x.png', scale: '2x'),
    ContentsImageObject(size: '20x20', idiom: 'iphone', filename: '$fileNamePrefix-20x20@3x.png', scale: '3x'),
    ContentsImageObject(size: '29x29', idiom: 'iphone', filename: '$fileNamePrefix-29x29@1x.png', scale: '1x'),
    ContentsImageObject(size: '29x29', idiom: 'iphone', filename: '$fileNamePrefix-29x29@2x.png', scale: '2x'),
    ContentsImageObject(size: '29x29', idiom: 'iphone', filename: '$fileNamePrefix-29x29@3x.png', scale: '3x'),
    ContentsImageObject(size: '40x40', idiom: 'iphone', filename: '$fileNamePrefix-40x40@2x.png', scale: '2x'),
    ContentsImageObject(size: '40x40', idiom: 'iphone', filename: '$fileNamePrefix-40x40@3x.png', scale: '3x'),
    ContentsImageObject(size: '60x60', idiom: 'iphone', filename: '$fileNamePrefix-60x60@2x.png', scale: '2x'),
    ContentsImageObject(size: '60x60', idiom: 'iphone', filename: '$fileNamePrefix-60x60@3x.png', scale: '3x'),
    ContentsImageObject(size: '20x20', idiom: 'ipad', filename: '$fileNamePrefix-20x20@1x.png', scale: '1x'),
    ContentsImageObject(size: '20x20', idiom: 'ipad', filename: '$fileNamePrefix-20x20@2x.png', scale: '2x'),
    ContentsImageObject(size: '29x29', idiom: 'ipad', filename: '$fileNamePrefix-29x29@1x.png', scale: '1x'),
    ContentsImageObject(size: '29x29', idiom: 'ipad', filename: '$fileNamePrefix-29x29@2x.png', scale: '2x'),
    ContentsImageObject(size: '40x40', idiom: 'ipad', filename: '$fileNamePrefix-40x40@1x.png', scale: '1x'),
    ContentsImageObject(size: '40x40', idiom: 'ipad', filename: '$fileNamePrefix-40x40@2x.png', scale: '2x'),
    ContentsImageObject(size: '76x76', idiom: 'ipad', filename: '$fileNamePrefix-76x76@1x.png', scale: '1x'),
    ContentsImageObject(size: '76x76', idiom: 'ipad', filename: '$fileNamePrefix-76x76@2x.png', scale: '2x'),
    ContentsImageObject(size: '83.5x83.5', idiom: 'ipad', filename: '$fileNamePrefix-83.5x83.5@2x.png', scale: '2x'),
    ContentsImageObject(
        size: '1024x1024', idiom: 'ios-marketing', filename: fileNamePrefix + '-1024x1024@1x.png', scale: '1x'),
  ];
}
