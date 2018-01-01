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
const String ios_icon_folder = "ios/Runner/Assets.xcassets/AppIcon.appiconset/";
const String ios_config_file = "ios/Runner.xcodeproj/project.pbxproj";

class IosIcons {
  final String name;
  final int size;
  IosIcons({this.size, this.name});
}

List<IosIcons> ios_icons = [
  new IosIcons(
    name: "Icon-App-20x20@1x",
    size: 20
  ),
  new IosIcons(
    name: "Icon-App-20x20@2x",
    size: 40
  ),
  new IosIcons(
    name: "Icon-App-20x20@3x",
    size: 60
  ),
  new IosIcons(
    name: "Icon-App-29x29@1x",
    size: 29
  ),
  new IosIcons(
    name: "Icon-App-29x29@2x",
    size: 58
  ),
  new IosIcons(
    name: "Icon-App-29x29@3x",
    size: 87
  ),
  new IosIcons(
    name: "Icon-App-40x40@1x",
    size: 40
  ),
  new IosIcons(
    name: "Icon-App-40x40@2x",
    size: 80
  ),
  new IosIcons(
    name: "Icon-App-40x40@3x",
    size: 120
  ),
  new IosIcons(
    name: "Icon-App-60x60@1x",
    size: 60
  ),
  new IosIcons(
    name: "Icon-App-60x60@2x",
    size: 120
  ),
  new IosIcons(
    name: "Icon-App-60x60@3x",
    size: 180
  ),
  new IosIcons(
    name: "Icon-App-76x76@1x",
    size: 76
  ),
  new IosIcons(
    name: "Icon-App-76x76@2x",
    size: 152
  ),
  new IosIcons(
    name: "Icon-App-83.5x83.5@2x",
    size: 167
  ),
];

convertIos(config) {
    String file_path = config['flutter_icons']['image_path'];
    Image image = decodeImage(new File(file_path).readAsBytesSync());
    ios_icons.forEach((IosIcons e) => saveIosIconWithOptions(e, image));
    print("IOS Launcher Icons Generated Successfully");
}

saveIosIconWithOptions(IosIcons e, image) {
Image newFile = copyResize(image, e.size);
    new File(ios_icon_folder + e.name+".png")
        ..writeAsBytesSync(encodePng(newFile));
}

changeIosLauncherIcon() async {
  File iOSConfigFile = new File(ios_config_file);
}

