import 'dart:async';
import 'package:image/image.dart';
import 'package:dart_config/default_server.dart';
import 'dart:io' as Io;

class AndroidIcons {
  final String name;
  final int size;
  String file_name = 'ic_launcher.png';
  AndroidIcons({this.size, this.file_name, this.name});
}

List<AndroidIcons> resolutions_android = [
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

convertAndroid() {
  Future<Map> conf = loadConfig("pubspec.yaml");
  conf.then((Map config) {
    String file_path = config['flutter_icons']['image_path'];
    Image image = decodeImage(new Io.File(file_path).readAsBytesSync());
    Image thumbnail = copyResize(image, 20);
    new Io.File('thumbnail.png')
        ..writeAsBytesSync(encodePng(thumbnail));
  });
}

