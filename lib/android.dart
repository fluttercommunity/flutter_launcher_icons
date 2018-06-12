import 'dart:io';

import 'package:image/image.dart';

const String android_res_folder = "android/app/src/main/res/";
const String android_manifest_file = "android/app/src/main/AndroidManifest.xml";
const String android_gradle_file = "android/app/build.gradle";
const String android_file_name = "ic_launcher.png";
const String android_adaptive_foreground_file_name = "ic_launcher_foreground.png";
const String android_colors_xml_template = "../assets/colors.xml";
const String android_adaptive_xml_template = "../assets/ic_launcher.xml";
const String android_adaptive_xml_folder =  android_res_folder + "mipmap-anydpi-v26/";
const String default_icon_name = "ic_launcher";

//
class AndroidIcon {
  final String name;
  final int size;
  AndroidIcon({this.size, this.name});
}

List<AndroidIcon> adaptive_foreground_icons = [
  new AndroidIcon(name: "drawable-mdpi", size: 108),
  new AndroidIcon(name: "drawable-hdpi", size: 162),
  new AndroidIcon(name: "drawable-xhdpi", size: 216),
  new AndroidIcon(name: "drawable-xxhdpi", size: 324),
  new AndroidIcon(name: "drawable-xxxhdpi", size: 432),
];

List<AndroidIcon> android_icons = [
  new AndroidIcon(name: "mipmap-mdpi", size: 48),
  new AndroidIcon(name: "mipmap-hdpi", size: 72),
  new AndroidIcon(name: "mipmap-xhdpi", size: 96),
  new AndroidIcon(name: "mipmap-xxhdpi", size: 144),
  new AndroidIcon(name: "mipmap-xxxhdpi", size: 192),
];

createIcons(config) {
  print("Creating icons Android");
  String file_path = config['image_path_android'] ?? config['image_path'];
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
    android_icons.forEach((AndroidIcon e) => overwriteExistingIcons(e, image, android_file_name));
    changeAndroidLauncherIcon(default_icon_name);
  }
}

createAdaptiveIcons(config) {
  print("Creating adaptive icons Android");

  //Read in the relevant configs
  String background_color = config['adaptive_icon_background'];
  String foreground_image_path = config['adaptive_icon_foreground'];
  Image foreground_image = decodeImage(new File(foreground_image_path).readAsBytesSync());

  //Create foreground images
  adaptive_foreground_icons.forEach((AndroidIcon e) => overwriteExistingIcons(e, foreground_image, android_adaptive_foreground_file_name));

  //Copy xml template to ic_launcher.xml
  var adaptiveXmlLocation = android_adaptive_xml_folder + default_icon_name + '.xml';
  var template = new File(android_adaptive_xml_template);
  var adaptiveXmlFolder = new File(android_adaptive_xml_folder);
  if(!adaptiveXmlFolder.existsSync()) {
    new Directory(android_adaptive_xml_folder).createSync();
  }
  template.copySync(adaptiveXmlLocation);

  //Check if colors.xml exists in the project
  var colorsXml = new File(android_res_folder + "values/colors.xml");
  //If not copy over empty template
  if(!colorsXml.existsSync()){
      print("Copying colors.xml template to project");
      var colorTemplate = new File(android_colors_xml_template);
      colorsXml.createSync();
      colorsXml.writeAsStringSync(colorTemplate.readAsStringSync());
  }

  //Write foreground color
  List<String> lines = colorsXml.readAsLinesSync();
  bool foundExisting = false;
  for (var x = 0; x < lines.length; x++) {
    String line = lines[x];
    if (line.contains("name=\"ic_launcher_background\"")) {
      print("Found existing background color value");
      foundExisting = true;
      line = line.replaceAll(new RegExp('>(.*)<'), ">$background_color<");
      lines[x] = line;
      break;
    }
  }

  //Add new line if we didn't find an existing value
  if(!foundExisting){
    print("Adding new background color value");
    lines.insert(lines.length-1, "\t<color name=\"ic_launcher_background\">${background_color}</color>");
  }

  colorsXml.writeAsStringSync(lines.join("\n"));
}

overwriteExistingIcons(AndroidIcon e, image, filename) {
  Image newFile;
  if (image.width >= e.size)
    newFile = copyResize(image, e.size, -1, AVERAGE);
  else
    newFile = copyResize(image, e.size, -1, LINEAR);

  new File(android_res_folder + e.name + '/' + filename).create(recursive: true).then((File file) {
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

minSdk() {
  File androidGradleFile = new File(android_gradle_file);
  List<String> lines = androidGradleFile.readAsLinesSync();
  for (var x = 0; x < lines.length; x++) {
    String line = lines[x];
    if (line.contains("minSdkVersion")) {

      String minSdk = line.replaceAll(new RegExp("[^\\d]"), "");
      print("Android minSdkVersion = $minSdk");
      return int.parse(minSdk);
    }
  }
  return 0; //Didn't find minSdk, assume the worst
}

