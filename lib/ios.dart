import 'package:image/image.dart';
import 'dart:io';

/**
 * File to handle the creation of icons for iOS platform
 *
 * Notes:
 * 1. Config file containing icon setting: config_file_path (for Flutter projects)
 * 2. iOS launcher icon setting (perhaps) - 'ASSETCATALOG_COMPILER_APPICON_NAME = <IconFolder>;'
 * 3. IconFolder - <IconFolder>.appiconset
 */
const String default_icon_folder = "ios/Runner/Assets.xcassets/AppIcon.appiconset/";
const String asset_folder = "ios/Runner/Assets.xcassets/";
const String config_file = "ios/Runner.xcodeproj/project.pbxproj";

class IosIcon {
  final String name;
  final int size;
  IosIcon({this.size, this.name});
}

List<IosIcon> ios_icons = [
  new IosIcon(
    name: "Icon-App-20x20@1x",
    size: 20
  ),
  new IosIcon(
    name: "Icon-App-20x20@2x",
    size: 40
  ),
  new IosIcon(
    name: "Icon-App-20x20@3x",
    size: 60
  ),
  new IosIcon(
    name: "Icon-App-29x29@1x",
    size: 29
  ),
  new IosIcon(
    name: "Icon-App-29x29@2x",
    size: 58
  ),
  new IosIcon(
    name: "Icon-App-29x29@3x",
    size: 87
  ),
  new IosIcon(
    name: "Icon-App-40x40@1x",
    size: 40
  ),
  new IosIcon(
    name: "Icon-App-40x40@2x",
    size: 80
  ),
  new IosIcon(
    name: "Icon-App-40x40@3x",
    size: 120
  ),
  new IosIcon(
    name: "Icon-App-60x60@1x",
    size: 60
  ),
  new IosIcon(
    name: "Icon-App-60x60@2x",
    size: 120
  ),
  new IosIcon(
    name: "Icon-App-60x60@3x",
    size: 180
  ),
  new IosIcon(
    name: "Icon-App-76x76@1x",
    size: 76
  ),
  new IosIcon(
    name: "Icon-App-76x76@2x",
    size: 152
  ),
  new IosIcon(
    name: "Icon-App-83.5x83.5@2x",
    size: 167
  ),
];

convertIos(config) {
    String file_path = config['flutter_icons']['image_path'];
    Image image = decodeImage(new File(file_path).readAsBytesSync());
    if (config['flutter_icons']['ios']) {
      print("Saving new icon to ic_launcher.png and switching Android launcher icon to it");
    }
    ios_icons.forEach((IosIcon e) => saveIcons(e, image));
    print("IOS Launcher Icons Generated Successfully");
}

overwriteDefaultIcons(IosIcon icon, image) {
  Image newFile = copyResize(image, icon.size);
    new File(default_icon_folder + icon.name + ".png")
      ..writeAsBytesSync(encodePng(newFile));
}

saveIcons(IosIcon e, image) {
Image newFile = copyResize(image, e.size);
    new File(default_icon_folder + e.name+ ".png")
        ..writeAsBytesSync(encodePng(newFile));
}

changeIosLauncherIcon(String icon_name) async {
  File iOSConfigFile = new File(config_file);
  List<String> lines = await iOSConfigFile.readAsLines();
  for (var x = 0; x < lines.length; x++) {
    String line = lines[x];
    if (line.contains("ASSETCATALOG")) {
      print("*** Original line ***");
      print(line);
      line = line.replaceAll(new RegExp('\=(.*);'), "= " + icon_name + ";");
      print("*** New line ***");
      print(line);
    }
  }
}

