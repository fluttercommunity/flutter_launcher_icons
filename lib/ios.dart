import 'package:image/image.dart';
import 'dart:io' as Io;

const String ios_icon_folder = "ios/Runner/Assets.xcassets/AppIcon.appiconset/";

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
];

convertIos(config) {
    String file_path = config['flutter_icons']['image_path'];
    Image image = decodeImage(new Io.File(file_path).readAsBytesSync());
    ios_icons.forEach((IosIcons e) => saveIosIconWithOptions(e, image));
    print("Images Generated Successfully");
}

saveIosIconWithOptions(IosIcons e, image) {
Image newFile = copyResize(image, e.size);
    new Io.File(ios_icon_folder + e.name+".png")
        ..writeAsBytesSync(encodePng(newFile));
}

