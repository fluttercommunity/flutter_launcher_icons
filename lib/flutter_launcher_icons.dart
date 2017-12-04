import 'package:image/image.dart';
import 'dart:io' as Io;

const String android_res_folder = "android/app/src/main/res/";
const String android_file_name ="ic_launcher.png";

class AndroidIcons {
  final String name;
  final int size;
  AndroidIcons({this.size, this.name});
}

List<AndroidIcons> android_icons = [
  new AndroidIcons(
    name: "mipmap-mdpi",
    size: 48
  ),
  new AndroidIcons(
    name: "mipmap-hdpi",
    size: 72
  ),
  new AndroidIcons(
    name: "mipmap-xhdpi",
    size: 96
  ),
  new AndroidIcons(
    name: "mipmap-xxhdpi",
    size: 144
  ),
  new AndroidIcons(
    name: "mipmap-xxxhdpi",
    size: 192
  ),
];

convertAndroid(config) {
    String file_path = config['flutter_icons']['image_path'];
    Image image = decodeImage(new Io.File(file_path).readAsBytesSync());
    android_icons.forEach((AndroidIcons e) => saveAndroidIconWithOptions(e, image));
    print("Images Generated Successfully")
}

saveAndroidIconWithOptions(AndroidIcons e, image) {
Image newFile = copyResize(image, e.size);
    new Io.File(android_res_folder + e.name +'/'+ android_file_name)
        ..writeAsBytesSync(encodePng(newFile));
}

