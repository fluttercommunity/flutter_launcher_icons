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
const String default_icon_name = "Icon-App";

class IosIcon {
  final String name;
  final int size;
  IosIcon({this.size, this.name});
}

List<IosIcon> ios_icons = [
  new IosIcon(
    name: "-20x20@1x",
    size: 20
  ),
  new IosIcon(
    name: "-20x20@2x",
    size: 40
  ),
  new IosIcon(
    name: "-20x20@3x",
    size: 60
  ),
  new IosIcon(
    name: "-29x29@1x",
    size: 29
  ),
  new IosIcon(
    name: "-29x29@2x",
    size: 58
  ),
  new IosIcon(
    name: "-29x29@3x",
    size: 87
  ),
  new IosIcon(
    name: "-40x40@1x",
    size: 40
  ),
  new IosIcon(
    name: "-40x40@2x",
    size: 80
  ),
  new IosIcon(
    name: "-40x40@3x",
    size: 120
  ),
  new IosIcon(
    name: "-60x60@1x",
    size: 60
  ),
  new IosIcon(
    name: "-60x60@2x",
    size: 120
  ),
  new IosIcon(
    name: "-60x60@3x",
    size: 180
  ),
  new IosIcon(
    name: "-76x76@1x",
    size: 76
  ),
  new IosIcon(
    name: "-76x76@2x",
    size: 152
  ),
  new IosIcon(
    name: "-83.5x83.5@2x",
    size: 167
  ),
];

convertIos(config) {
    String file_path = config['flutter_icons']['image_path'];
    Image image = decodeImage(new File(file_path).readAsBytesSync());
    var iosConfig = config['flutter_icons']['ios'];
    // If the IOS configuration is a string then the user has specified a new icon to be created
    // and for the old icon file to be kept
    if (iosConfig is String) {
      String newIconName = iosConfig;
      print("Adding new IOS launcher icon");
      ios_icons.forEach((IosIcon icon) => saveNewIcons(icon, image, newIconName));
    }
    // Otherwise the user wants the new icon to use the default icons name and
    // update config file to use it
    else {
      print("Overwriting default icon with new icon");
      ios_icons.forEach((IosIcon icon) => overwriteDefaultIcons(icon, image));
    }
}

overwriteDefaultIcons(IosIcon icon, Image image) {
  Image newFile = copyResize(image, icon.size);
    new File(default_icon_folder + default_icon_name + icon.name + ".png")
      ..writeAsBytesSync(encodePng(newFile));
}

saveNewIcons(IosIcon icon, Image image, String newIconName) {
  String newIconFolder = asset_folder + newIconName + ".appiconset/";
  Image newFile = copyResize(image, icon.size);
    new File(newIconFolder + newIconName + icon.name+ ".png")
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
      lines[x] = line;
    }
  }
  iOSConfigFile.writeAsString(lines.join("\n"));
}

