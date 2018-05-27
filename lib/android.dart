import 'package:image/image.dart';
import 'dart:io';

const String android_res_folder = "android/app/src/main/res/";
const String android_manifest_file = "android/app/src/main/AndroidManifest.xml";
const String android_file_name = "ic_launcher.png";
const String default_icon_name = "ic_launcher";

//
class AndroidIcon {
  final String name;
  final int size;
  AndroidIcon({this.size, this.name});
}

List<AndroidIcon> android_icons = [
  new AndroidIcon(name: "mipmap-mdpi", size: 48),
  new AndroidIcon(name: "mipmap-hdpi", size: 72),
  new AndroidIcon(name: "mipmap-xhdpi", size: 96),
  new AndroidIcon(name: "mipmap-xxhdpi", size: 144),
  new AndroidIcon(name: "mipmap-xxxhdpi", size: 192),
];

createIcons(config) {
  print("create icons Android");
  String file_path = config['image_path'];
  Image image = decodeImage(new File(file_path).readAsBytesSync());
  var androidConfig = config['android'];

  if (androidConfig is String) {
    print("Adding new Android launcher icon");
    String icon_name = androidConfig;
    String icon_path = icon_name + ".png";
    android_icons.forEach((AndroidIcon e) => saveNewIcons(e, image, icon_path));
    changeAndroidLauncherIcon(icon_name);
  } else {
    print("Overwriting default Android launcher icon with new icon");
    android_icons.forEach((AndroidIcon e) => overwriteExistingIcons(e, image));
    changeAndroidLauncherIcon(default_icon_name);
  }
}

overwriteExistingIcons(AndroidIcon e, image) {
  Image newFile;
  if (image.width >= e.size)
    newFile = copyResize(image, e.size, -1, AVERAGE);
  else
    newFile = copyResize(image, e.size, -1, LINEAR);

  new File(android_res_folder + e.name + '/' + android_file_name).create(recursive: true).then((File file) {
    file.writeAsBytesSync(encodePng(newFile));
  });
}

saveNewIcons(AndroidIcon e, image, String iconFilePath) {
  Image newFile;
  if (image.width >= e.size)
    newFile = copyResize(image, e.size, e.size, AVERAGE);
  else
    newFile = copyResize(image, e.size, e.size, LINEAR);

  new File(android_res_folder + e.name + '/' + iconFilePath).create(recursive: true).then((File file) {
    file.writeAsBytesSync(encodePng(newFile));
  });
}

// NOTE: default = ic_launcher
changeAndroidLauncherIcon(String icon_name) async {
  File androidManifestFile = new File(android_manifest_file);
  List<String> lines = await androidManifestFile.readAsLines();
  for (var x = 0; x < lines.length; x++) {
    String line = lines[x];
    if (line.contains("android:icon")) {
      // Using RegExp replace the value of android:icon to point to the new icon
      line = line.replaceAll(
          new RegExp('android:icon=\"([^*]|(\"+([^"/]|)))*\"'),
          'android:icon="@mipmap/' + icon_name + '"');
      lines[x] = line;
    }
  }
  androidManifestFile.writeAsString(lines.join("\n"));
}
