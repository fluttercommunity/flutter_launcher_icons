import 'package:image/image.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_launcher_icons/constants.dart';

/**
 * File to handle the creation of icons for iOS platform
 */
class IosIcon {
  final String name;
  final int size;
  IosIcon({this.size, this.name});
}

List<IosIcon> iosIcons = [
  IosIcon(name: "-20x20@1x", size: 20),
  IosIcon(name: "-20x20@2x", size: 40),
  IosIcon(name: "-20x20@3x", size: 60),
  IosIcon(name: "-29x29@1x", size: 29),
  IosIcon(name: "-29x29@2x", size: 58),
  IosIcon(name: "-29x29@3x", size: 87),
  IosIcon(name: "-40x40@1x", size: 40),
  IosIcon(name: "-40x40@2x", size: 80),
  IosIcon(name: "-40x40@3x", size: 120),
  IosIcon(name: "-60x60@2x", size: 120),
  IosIcon(name: "-60x60@3x", size: 180),
  IosIcon(name: "-76x76@1x", size: 76),
  IosIcon(name: "-76x76@2x", size: 152),
  IosIcon(name: "-83.5x83.5@2x", size: 167),
  IosIcon(name: "-1024x1024@1x", size: 1024),
];

createIcons(config, String flavor) {
  String filePath = config['image_path_ios'] ?? config['image_path'];
  Image image = decodeImage(File(filePath).readAsBytesSync());
  String iconName;
  var iosConfig = config['ios'];
  if (flavor != null) {
    String catalogName = "AppIcon-$flavor";
    print("Building iOS launcher icon for $flavor");
    iosIcons.forEach((IosIcon icon) => saveNewIcons(icon, image, catalogName, iosDefaultIconName));
    iconName = iosDefaultIconName;
    changeIosLauncherIcon(catalogName, flavor);
    modifyContentsFile(catalogName, iconName);
  }
  // If the IOS configuration is a string then the user has specified a new icon to be created
  // and for the old icon file to be kept
  else if (iosConfig is String) {
    String newIconName = iosConfig;
    print("Adding new iOS launcher icon");
    iosIcons.forEach((IosIcon icon) => saveNewIcons(icon, image, newIconName, newIconName));
    iconName = newIconName;
    changeIosLauncherIcon(iconName, flavor);
    modifyContentsFile(iconName, iconName);
  }
  // Otherwise the user wants the new icon to use the default icons name and
  // update config file to use it
  else {
    print("Overwriting default iOS launcher icon with new icon");
    iosIcons.forEach((IosIcon icon) => overwriteDefaultIcons(icon, image));
    iconName = iosDefaultIconName;
    changeIosLauncherIcon("AppIcon", flavor);
  }
}

overwriteDefaultIcons(IosIcon icon, Image image) {
  Image newFile;
  if (image.width >= icon.size)
    newFile = copyResize(image, icon.size, icon.size, AVERAGE);
  else
    newFile = copyResize(image, icon.size, icon.size, LINEAR);

  File(iosDefaultIconFolder + iosDefaultIconName + icon.name + ".png")
    ..writeAsBytesSync(encodePng(newFile));
}

saveNewIcons(IosIcon icon, Image image, String newCatalogName, String newIconName) {
  String newIconFolder = iosAssetFolder + newCatalogName + ".appiconset/";
  Image newFile;
  if (image.width >= icon.size)
    newFile = copyResize(image, icon.size, icon.size, AVERAGE);
  else
    newFile = copyResize(image, icon.size, icon.size, LINEAR);

  File(newIconFolder + newIconName + icon.name + ".png")
      .create(recursive: true)
      .then((File file) {
    file.writeAsBytesSync(encodePng(newFile));
  });
}

changeIosLauncherIcon(String iconName, String flavor) async {
  File iOSConfigFile = File(iosConfigFile);
  List<String> lines = await iOSConfigFile.readAsLines();

  bool onConfigurationSection = false;
  String currentConfig;
  for (var x = 0; x < lines.length; x++) {
    String line = lines[x];

    if (line.contains("/* Begin XCBuildConfiguration section */")) {
      onConfigurationSection = true;
    }
    if (line.contains("/* End XCBuildConfiguration section */")) {
      onConfigurationSection = false;
    }
    if (onConfigurationSection) {
      var match = RegExp(".*/\\* (.*)\.xcconfig \\*/;").firstMatch(line);
      if (match != null) {
        currentConfig = match.group(1);
      }

      if (currentConfig != null
          && (flavor == null || currentConfig.contains("-$flavor"))
          && line.contains("ASSETCATALOG")) {
        lines[x] = line.replaceAll(RegExp('\=(.*);'), "= $iconName;");
      }
    }
  }

  String entireFile = lines.join("\n");
  iOSConfigFile.writeAsString("$entireFile\n");
}

// Create the Contents.json file
modifyContentsFile(String catalogName, String newIconName) {
  String newIconFolder =
      iosAssetFolder + catalogName + ".appiconset/Contents.json";
  File(newIconFolder).create(recursive: true).then((File contentsJsonFile) {
    String contentsFileContent = generateContentsFileAsString(newIconName);
    contentsJsonFile.writeAsString(contentsFileContent);
  });
}

String generateContentsFileAsString(String newIconName) {
  var contentJson = Map();
  contentJson["images"] = createImageList(newIconName);
  contentJson["info"] =
      ContentsInfoObject(version: 1, author: "xcode").toJson();
  return json.encode(contentJson);
}

class ContentsImageObject {
  final String size;
  final String idiom;
  final String filename;
  final String scale;

  ContentsImageObject({this.size, this.idiom, this.filename, this.scale});

  Map toJson() {
    Map map = Map();
    map["size"] = size;
    map["idiom"] = idiom;
    map["filename"] = filename;
    map["scale"] = scale;
    return map;
  }
}

class ContentsInfoObject {
  final int version;
  final String author;

  ContentsInfoObject({this.version, this.author});

  Map toJson() {
    Map map = Map();
    map["version"] = version;
    map["author"] = author;
    return map;
  }
}

List<Map> createImageList(String fileNamePrefix) {
  List<Map> imageList = [
    ContentsImageObject(
            size: "20x20",
            idiom: "iphone",
            filename: fileNamePrefix + "-20x20@2x.png",
            scale: "2x")
        .toJson(),
    ContentsImageObject(
            size: "20x20",
            idiom: "iphone",
            filename: fileNamePrefix + "-20x20@3x.png",
            scale: "3x")
        .toJson(),
    ContentsImageObject(
            size: "29x29",
            idiom: "iphone",
            filename: fileNamePrefix + "-29x29@1x.png",
            scale: "1x")
        .toJson(),
    ContentsImageObject(
            size: "29x29",
            idiom: "iphone",
            filename: fileNamePrefix + "-29x29@2x.png",
            scale: "2x")
        .toJson(),
    ContentsImageObject(
            size: "29x29",
            idiom: "iphone",
            filename: fileNamePrefix + "-29x29@3x.png",
            scale: "3x")
        .toJson(),
    ContentsImageObject(
            size: "40x40",
            idiom: "iphone",
            filename: fileNamePrefix + "-40x40@2x.png",
            scale: "2x")
        .toJson(),
    ContentsImageObject(
            size: "40x40",
            idiom: "iphone",
            filename: fileNamePrefix + "-40x40@3x.png",
            scale: "3x")
        .toJson(),
    ContentsImageObject(
            size: "60x60",
            idiom: "iphone",
            filename: fileNamePrefix + "-60x60@2x.png",
            scale: "2x")
        .toJson(),
    ContentsImageObject(
            size: "60x60",
            idiom: "iphone",
            filename: fileNamePrefix + "-60x60@3x.png",
            scale: "3x")
        .toJson(),
    ContentsImageObject(
            size: "20x20",
            idiom: "ipad",
            filename: fileNamePrefix + "-20x20@1x.png",
            scale: "1x")
        .toJson(),
    ContentsImageObject(
            size: "20x20",
            idiom: "ipad",
            filename: fileNamePrefix + "-20x20@2x.png",
            scale: "2x")
        .toJson(),
    ContentsImageObject(
            size: "29x29",
            idiom: "ipad",
            filename: fileNamePrefix + "-29x29@1x.png",
            scale: "1x")
        .toJson(),
    ContentsImageObject(
            size: "29x29",
            idiom: "ipad",
            filename: fileNamePrefix + "-29x29@2x.png",
            scale: "2x")
        .toJson(),
    ContentsImageObject(
            size: "40x40",
            idiom: "ipad",
            filename: fileNamePrefix + "-40x40@1x.png",
            scale: "1x")
        .toJson(),
    ContentsImageObject(
            size: "40x40",
            idiom: "ipad",
            filename: fileNamePrefix + "-40x40@2x.png",
            scale: "2x")
        .toJson(),
    ContentsImageObject(
            size: "76x76",
            idiom: "ipad",
            filename: fileNamePrefix + "-76x76@1x.png",
            scale: "1x")
        .toJson(),
    ContentsImageObject(
            size: "76x76",
            idiom: "ipad",
            filename: fileNamePrefix + "-76x76@2x.png",
            scale: "2x")
        .toJson(),
    ContentsImageObject(
            size: "83.5x83.5",
            idiom: "ipad",
            filename: fileNamePrefix + "-83.5x83.5@2x.png",
            scale: "2x")
        .toJson(),
    ContentsImageObject(
            size: "1024x1024",
            idiom: "ios-marketing",
            filename: fileNamePrefix + "-83.5x83.5@2x.png",
            scale: "2x")
        .toJson()
  ];
  return imageList;
}
