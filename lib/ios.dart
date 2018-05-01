import 'package:image/image.dart';
import 'dart:io';
import 'dart:convert';

/**
 * File to handle the creation of icons for iOS platform
 */
const String default_icon_folder =
    "ios/Runner/Assets.xcassets/AppIcon.appiconset/";
const String asset_folder = "ios/Runner/Assets.xcassets/";
const String config_file = "ios/Runner.xcodeproj/project.pbxproj";
const String default_icon_name = "Icon-App";

class IosIcon {
  final String name;
  final int size;
  IosIcon({this.size, this.name});
}

List<IosIcon> ios_icons = [
  new IosIcon(name: "-20x20@1x", size: 20),
  new IosIcon(name: "-20x20@2x", size: 40),
  new IosIcon(name: "-20x20@3x", size: 60),
  new IosIcon(name: "-29x29@1x", size: 29),
  new IosIcon(name: "-29x29@2x", size: 58),
  new IosIcon(name: "-29x29@3x", size: 87),
  new IosIcon(name: "-40x40@1x", size: 40),
  new IosIcon(name: "-40x40@2x", size: 80),
  new IosIcon(name: "-40x40@3x", size: 120),
  new IosIcon(name: "-60x60@2x", size: 120),
  new IosIcon(name: "-60x60@3x", size: 180),
  new IosIcon(name: "-76x76@1x", size: 76),
  new IosIcon(name: "-76x76@2x", size: 152),
  new IosIcon(name: "-83.5x83.5@2x", size: 167),
  new IosIcon(name: "-1024x1024@1x", size: 1024),
];

convertIos(config) {
  String file_path = config['flutter_icons']['image_path'];
  Image image = decodeImage(new File(file_path).readAsBytesSync());
  String iconName;
  var iosConfig = config['flutter_icons']['ios'];
  // If the IOS configuration is a string then the user has specified a new icon to be created
  // and for the old icon file to be kept
  if (iosConfig is String) {
    String newIconName = iosConfig;
    print("Adding new iOS launcher icon");
    ios_icons.forEach((IosIcon icon) => saveNewIcons(icon, image, newIconName));
    iconName = newIconName;
    changeIosLauncherIcon(iconName);
    modifyContentsFile(iconName);
  }
  // Otherwise the user wants the new icon to use the default icons name and
  // update config file to use it
  else {
    print("Overwriting default iOS launcher icon with new icon");
    ios_icons.forEach((IosIcon icon) => overwriteDefaultIcons(icon, image));
    iconName = default_icon_name;
  }
}

overwriteDefaultIcons(IosIcon icon, Image image) {
  Image newFile;
  if (image.width >= icon.size)
    newFile = copyResize(image, icon.size, icon.size, AVERAGE);
  else
    newFile = copyResize(image, icon.size, icon.size, LINEAR);

  new File(default_icon_folder + default_icon_name + icon.name + ".png")
    ..writeAsBytesSync(encodePng(newFile));
}

saveNewIcons(IosIcon icon, Image image, String newIconName) {
  String newIconFolder = asset_folder + newIconName + ".appiconset/";

  Image newFile;
  if (image.width >= icon.size)
    newFile = copyResize(image, icon.size, -1, AVERAGE);
  else
    newFile = copyResize(image, icon.size, -1, LINEAR);

  new File(newIconFolder + newIconName + icon.name + ".png")
      .create(recursive: true)
      .then((File file) {
    file.writeAsBytesSync(encodePng(newFile));
  });
}

changeIosLauncherIcon(String iconName) async {
  File iOSConfigFile = new File(config_file);
  List<String> lines = await iOSConfigFile.readAsLines();
  for (var x = 0; x < lines.length; x++) {
    String line = lines[x];
    if (line.contains("ASSETCATALOG")) {
      line = line.replaceAll(new RegExp('\=(.*);'), "= " + iconName + ";");
      lines[x] = line;
    }
  }
  iOSConfigFile.writeAsString(lines.join("\n"));
}

// Create the Contents.json file
modifyContentsFile(String newIconName) {
  String newIconFolder =
      asset_folder + newIconName + ".appiconset/Contents.json";
  new File(newIconFolder).create(recursive: true).then((File contentsJsonFile) {
    String contentsFileContent = generateContentsFileAsString(newIconName);
    contentsJsonFile.writeAsString(contentsFileContent);
  });
}

String generateContentsFileAsString(String newIconName) {
  var contentJson = new Map();
  contentJson["images"] = createImageList(newIconName);
  contentJson["info"] =
      new ContentsInfoObject(version: 1, author: "xcode").toJson();
  return JSON.encode(contentJson);
}

class ContentsImageObject {
  final String size;
  final String idiom;
  final String filename;
  final String scale;

  ContentsImageObject({this.size, this.idiom, this.filename, this.scale});

  Map toJson() {
    Map map = new Map();
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
    Map map = new Map();
    map["version"] = version;
    map["author"] = author;
    return map;
  }
}

List<Map> createImageList(String fileNamePrefix) {
  List<Map> imageList = [
    new ContentsImageObject(
            size: "20x20",
            idiom: "iphone",
            filename: fileNamePrefix + "-20x20@2x.png",
            scale: "2x")
        .toJson(),
    new ContentsImageObject(
            size: "20x20",
            idiom: "iphone",
            filename: fileNamePrefix + "-20x20@3x.png",
            scale: "3x")
        .toJson(),
    new ContentsImageObject(
            size: "29x29",
            idiom: "iphone",
            filename: fileNamePrefix + "-29x29@1x.png",
            scale: "1x")
        .toJson(),
    new ContentsImageObject(
            size: "29x29",
            idiom: "iphone",
            filename: fileNamePrefix + "-29x29@2x.png",
            scale: "2x")
        .toJson(),
    new ContentsImageObject(
            size: "29x29",
            idiom: "iphone",
            filename: fileNamePrefix + "-29x29@3x.png",
            scale: "3x")
        .toJson(),
    new ContentsImageObject(
            size: "40x40",
            idiom: "iphone",
            filename: fileNamePrefix + "-40x40@2x.png",
            scale: "2x")
        .toJson(),
    new ContentsImageObject(
            size: "40x40",
            idiom: "iphone",
            filename: fileNamePrefix + "-40x40@3x.png",
            scale: "3x")
        .toJson(),
    new ContentsImageObject(
            size: "60x60",
            idiom: "iphone",
            filename: fileNamePrefix + "-60x60@2x.png",
            scale: "2x")
        .toJson(),
    new ContentsImageObject(
            size: "60x60",
            idiom: "iphone",
            filename: fileNamePrefix + "-60x60@3x.png",
            scale: "3x")
        .toJson(),
    new ContentsImageObject(
            size: "20x20",
            idiom: "ipad",
            filename: fileNamePrefix + "-20x20@1x.png",
            scale: "1x")
        .toJson(),
    new ContentsImageObject(
            size: "20x20",
            idiom: "ipad",
            filename: fileNamePrefix + "-20x20@2x.png",
            scale: "2x")
        .toJson(),
    new ContentsImageObject(
            size: "29x29",
            idiom: "ipad",
            filename: fileNamePrefix + "-29x29@1x.png",
            scale: "1x")
        .toJson(),
    new ContentsImageObject(
            size: "29x29",
            idiom: "ipad",
            filename: fileNamePrefix + "-29x29@2x.png",
            scale: "2x")
        .toJson(),
    new ContentsImageObject(
            size: "40x40",
            idiom: "ipad",
            filename: fileNamePrefix + "-40x40@1x.png",
            scale: "1x")
        .toJson(),
    new ContentsImageObject(
            size: "40x40",
            idiom: "ipad",
            filename: fileNamePrefix + "-40x40@2x.png",
            scale: "2x")
        .toJson(),
    new ContentsImageObject(
            size: "76x76",
            idiom: "ipad",
            filename: fileNamePrefix + "-76x76@1x.png",
            scale: "1x")
        .toJson(),
    new ContentsImageObject(
            size: "76x76",
            idiom: "ipad",
            filename: fileNamePrefix + "-76x76@2x.png",
            scale: "2x")
        .toJson(),
    new ContentsImageObject(
            size: "83.5x83.5",
            idiom: "ipad",
            filename: fileNamePrefix + "-83.5x83.5@2x.png",
            scale: "2x")
        .toJson(),
    new ContentsImageObject(
            size: "1024x1024",
            idiom: "ios-marketing",
            filename: fileNamePrefix + "-83.5x83.5@2x.png",
            scale: "2x")
        .toJson()
  ];
  return imageList;
}
