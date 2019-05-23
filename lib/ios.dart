import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart';
import 'package:flutter_launcher_icons/constants.dart';

/// File to handle the creation of icons for iOS platform
class IosIcon {
  IosIcon({this.size, this.name});
  final String name;
  final int size;
}

List<IosIcon> iosIcons = [
  IosIcon(name: '-20x20@1x', size: 20),
  IosIcon(name: '-20x20@2x', size: 40),
  IosIcon(name: '-20x20@3x', size: 60),
  IosIcon(name: '-29x29@1x', size: 29),
  IosIcon(name: '-29x29@2x', size: 58),
  IosIcon(name: '-29x29@3x', size: 87),
  IosIcon(name: '-40x40@1x', size: 40),
  IosIcon(name: '-40x40@2x', size: 80),
  IosIcon(name: '-40x40@3x', size: 120),
  IosIcon(name: '-60x60@2x', size: 120),
  IosIcon(name: '-60x60@3x', size: 180),
  IosIcon(name: '-76x76@1x', size: 76),
  IosIcon(name: '-76x76@2x', size: 152),
  IosIcon(name: '-83.5x83.5@2x', size: 167),
  IosIcon(name: '-1024x1024@1x', size: 1024),
];

void createIcons(Map config) {
  final String filePath = config['image_path_ios'] ?? config['image_path'];
  final Image image = decodeImage(File(filePath).readAsBytesSync());
  String iconName;
  dynamic iosConfig = config['ios'];
  // If the IOS configuration is a string then the user has specified a new icon to be created
  // and for the old icon file to be kept
  if (iosConfig is String) {
    final String newIconName = iosConfig;
    print('Adding new iOS launcher icon');
    iosIcons.forEach((IosIcon icon) => saveNewIcons(icon, image, newIconName));
    iconName = newIconName;
    changeIosLauncherIcon(iconName);
    modifyContentsFile(iconName);
  }
  // Otherwise the user wants the new icon to use the default icons name and
  // update config file to use it
  else {
    print('Overwriting default iOS launcher icon with new icon');
    iosIcons.forEach((IosIcon icon) => overwriteDefaultIcons(icon, image));
    iconName = iosDefaultIconName;
    changeIosLauncherIcon('AppIcon');
  }
}

void overwriteDefaultIcons(IosIcon icon, Image image) {
  Image newFile;
  newFile = copyResize(image,
      width: icon.size, height: icon.size, interpolation: Interpolation.cubic);
  File(iosDefaultIconFolder + iosDefaultIconName + icon.name + '.png')
    ..writeAsBytesSync(encodePng(newFile));
}

void saveNewIcons(IosIcon icon, Image image, String newIconName) {
  final String newIconFolder = iosAssetFolder + newIconName + '.appiconset/';
  Image newFile;
  newFile = copyResize(image,
      width: icon.size, height: icon.size, interpolation: Interpolation.cubic);
  File(newIconFolder + newIconName + icon.name + '.png')
      .create(recursive: true)
      .then((File file) {
    file.writeAsBytesSync(encodePng(newFile));
  });
}

Future<void> changeIosLauncherIcon(String iconName) async {
  File iOSConfigFile = File(iosConfigFile);
  List<String> lines = await iOSConfigFile.readAsLines();
  for (var x = 0; x < lines.length; x++) {
    String line = lines[x];
    if (line.contains('ASSETCATALOG')) {
      line = line.replaceAll(RegExp('\=(.*);'), '= ' + iconName + ';');
      lines[x] = line;
      lines[lines.length - 1] = "}\n";
    }
  }
  final String entireFile = lines.join("\n");
  iOSConfigFile.writeAsString(entireFile);
}

/// Create the Contents.json file
void modifyContentsFile(String newIconName) {
  final String newIconFolder =
      iosAssetFolder + newIconName + '.appiconset/Contents.json';
  File(newIconFolder).create(recursive: true).then((File contentsJsonFile) {
    final String contentsFileContent = generateContentsFileAsString(newIconName);
    contentsJsonFile.writeAsString(contentsFileContent);
  });
}

String generateContentsFileAsString(String newIconName) {
  Map contentJson = Map<dynamic, dynamic>();
  contentJson['images'] = createImageList(newIconName);
  contentJson['info'] =
      ContentsInfoObject(version: 1, author: 'xcode').toJson();
  return json.encode(contentJson);
}

class ContentsImageObject {
  ContentsImageObject({this.size, this.idiom, this.filename, this.scale});
  final String size;
  final String idiom;
  final String filename;
  final String scale;


  Map toJson() {
    Map map = Map<dynamic, dynamic>();
    map['size'] = size;
    map['idiom'] = idiom;
    map['filename'] = filename;
    map['scale'] = scale;
    return map;
  }
}

class ContentsInfoObject {
  ContentsInfoObject({this.version, this.author});
  final int version;
  final String author;


  Map toJson() {
    Map map = Map<dynamic, dynamic>();
    map['version'] = version;
    map['author'] = author;
    return map;
  }
}

List<Map> createImageList(String fileNamePrefix) {
  List<Map> imageList = [
    ContentsImageObject(
            size: '20x20',
            idiom: 'iphone',
            filename: fileNamePrefix + '-20x20@2x.png',
            scale: '2x')
        .toJson(),
    ContentsImageObject(
            size: '20x20',
            idiom: 'iphone',
            filename: fileNamePrefix + '-20x20@3x.png',
            scale: '3x')
        .toJson(),
    ContentsImageObject(
            size: '29x29',
            idiom: 'iphone',
            filename: fileNamePrefix + '-29x29@1x.png',
            scale: '1x')
        .toJson(),
    ContentsImageObject(
            size: '29x29',
            idiom: 'iphone',
            filename: fileNamePrefix + '-29x29@2x.png',
            scale: '2x')
        .toJson(),
    ContentsImageObject(
            size: '29x29',
            idiom: 'iphone',
            filename: fileNamePrefix + '-29x29@3x.png',
            scale: '3x')
        .toJson(),
    ContentsImageObject(
            size: '40x40',
            idiom: 'iphone',
            filename: fileNamePrefix + '-40x40@2x.png',
            scale: '2x')
        .toJson(),
    ContentsImageObject(
            size: '40x40',
            idiom: 'iphone',
            filename: fileNamePrefix + '-40x40@3x.png',
            scale: '3x')
        .toJson(),
    ContentsImageObject(
            size: '60x60',
            idiom: 'iphone',
            filename: fileNamePrefix + '-60x60@2x.png',
            scale: '2x')
        .toJson(),
    ContentsImageObject(
            size: '60x60',
            idiom: 'iphone',
            filename: fileNamePrefix + '-60x60@3x.png',
            scale: '3x')
        .toJson(),
    ContentsImageObject(
            size: '20x20',
            idiom: 'ipad',
            filename: fileNamePrefix + '-20x20@1x.png',
            scale: '1x')
        .toJson(),
    ContentsImageObject(
            size: '20x20',
            idiom: 'ipad',
            filename: fileNamePrefix + '-20x20@2x.png',
            scale: '2x')
        .toJson(),
    ContentsImageObject(
            size: '29x29',
            idiom: 'ipad',
            filename: fileNamePrefix + '-29x29@1x.png',
            scale: '1x')
        .toJson(),
    ContentsImageObject(
            size: '29x29',
            idiom: 'ipad',
            filename: fileNamePrefix + '-29x29@2x.png',
            scale: '2x')
        .toJson(),
    ContentsImageObject(
            size: '40x40',
            idiom: 'ipad',
            filename: fileNamePrefix + '-40x40@1x.png',
            scale: '1x')
        .toJson(),
    ContentsImageObject(
            size: '40x40',
            idiom: 'ipad',
            filename: fileNamePrefix + '-40x40@2x.png',
            scale: '2x')
        .toJson(),
    ContentsImageObject(
            size: '76x76',
            idiom: 'ipad',
            filename: fileNamePrefix + '-76x76@1x.png',
            scale: '1x')
        .toJson(),
    ContentsImageObject(
            size: '76x76',
            idiom: 'ipad',
            filename: fileNamePrefix + '-76x76@2x.png',
            scale: '2x')
        .toJson(),
    ContentsImageObject(
            size: '83.5x83.5',
            idiom: 'ipad',
            filename: fileNamePrefix + '-83.5x83.5@2x.png',
            scale: '2x')
        .toJson(),
    ContentsImageObject(
            size: '1024x1024',
            idiom: 'ios-marketing',
            filename: fileNamePrefix + '-83.5x83.5@2x.png',
            scale: '2x')
        .toJson()
  ];
  return imageList;
}
