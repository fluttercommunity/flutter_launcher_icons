import 'dart:io';
import 'package:flutter_launcher_icons/xml_templates.dart' as XmlTemplate;
import 'package:image/image.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/constants.dart' as Constants;

class AndroidIcon {
  final String name;
  final int size;
  AndroidIcon({this.size, this.name});
}

final List<AndroidIcon> adaptiveForegroundIcons = [
  AndroidIcon(name: "drawable-mdpi", size: 108),
  AndroidIcon(name: "drawable-hdpi", size: 162),
  AndroidIcon(name: "drawable-xhdpi", size: 216),
  AndroidIcon(name: "drawable-xxhdpi", size: 324),
  AndroidIcon(name: "drawable-xxxhdpi", size: 432),
];

List<AndroidIcon> androidIcons = [
  AndroidIcon(name: "mipmap-mdpi", size: 48),
  AndroidIcon(name: "mipmap-hdpi", size: 72),
  AndroidIcon(name: "mipmap-xhdpi", size: 96),
  AndroidIcon(name: "mipmap-xxhdpi", size: 144),
  AndroidIcon(name: "mipmap-xxxhdpi", size: 192),
];

createIcons(config) {
  print("Creating icons Android");
  String filePath = getAndroidIconPath(config);
  Image image = decodeImage(File(filePath).readAsBytesSync());
  if (isCustomAndroidFile(config)) {
    print("Adding new Android launcher icon");
    String iconName = getNewIconName(config);
    isAndroidIconNameCorrectFormat(iconName);
    String iconPath = iconName + ".png";
    androidIcons.forEach((AndroidIcon e) => saveNewIcons(e, image, iconPath));
    changeAndroidLauncherIcon(iconName);
  }
  else {
    print("Overwriting default Android launcher icon with new icon");
    androidIcons.forEach((AndroidIcon e) => overwriteExistingIcons(e, image, Constants.androidFileName));
    changeAndroidLauncherIcon(Constants.androidDefaultIconName);
  }
}

bool isAndroidIconNameCorrectFormat(String iconName) {
  if (!RegExp(r"^[a-z0-9_]+$").hasMatch(iconName)) {
    throw InvalidAndroidIconNameException('The icon name must contain only lowercase a-z, 0-9, or underscore: E.g. "ic_my_new_icon"');
  }
  return true;
}

createAdaptiveIcons(config) {
  print("Creating adaptive icons Android");

  // Read in the relevant configs
  String backgroundColor = config['adaptive_icon_background'];
  String foregroundImagePath = config['adaptive_icon_foreground'];
  Image foregroundImage = decodeImage(File(foregroundImagePath).readAsBytesSync());

  // Create foreground images
  adaptiveForegroundIcons.forEach((AndroidIcon e) => overwriteExistingIcons(e, foregroundImage, Constants.androidAdaptiveForegroundFileName));
  // Generate ic_launcher.xml
  // If is using a string for android config, generate <file_name>.xml
  // Otherwise use ic_launcher.xml
  if (isCorrectMipmapDirectoryForAdaptiveIcon(Constants.androidAdaptiveXmlFolder)) {
    if (isCustomAndroidFile(config)) {
      File(Constants.androidAdaptiveXmlFolder + getNewIconName(config)
          + '.xml').create(recursive: true).then((File adaptiveIcon) {
        adaptiveIcon.writeAsString(XmlTemplate.icLauncherXml);
      });
    } else {
      File(Constants.androidAdaptiveXmlFolder + Constants.androidDefaultIconName + '.xml')
          .create(recursive: true).then((File adaptiveIcon) {
        adaptiveIcon.writeAsString(XmlTemplate.icLauncherXml);
      });
    }
  } else {
    print("Error: Unable to generate adaptive icon");
  }

  // Check if colors.xml exists in the project
  var colorsXml = File(Constants.androidColorsFile);
  // If not copy over empty template
  colorsXml.exists().then((bool isExistingFile) {
    if (!isExistingFile) {
      createNewColorsFile(backgroundColor);
    } else {
      updateColorsFile(colorsXml, backgroundColor);
    }
  });
}

createNewColorsFile(String backgroundColor) {
  print("Copying colors.xml template to project");
  File(Constants.androidColorsFile).create(recursive: true).then((File colorsFile) {
    colorsFile.writeAsString(XmlTemplate.colorsXml).then((File file) {
      updateColorsFile(colorsFile, backgroundColor);
    });
  });
}

updateColorsFile(File colorsFile, String backgroundColor) {

  // Write foreground color
  List<String> lines = colorsFile.readAsLinesSync();
  bool foundExisting = false;
  for (var x = 0; x < lines.length; x++) {
    String line = lines[x];
    if (line.contains("name=\"ic_launcher_background\"")) {
      print("Found existing background color value");
      foundExisting = true;
      line = line.replaceAll(RegExp('>(.*)<'), ">$backgroundColor<");
      lines[x] = line;
      break;
    }
  }

  // Add new line if we didn't find an existing value
  if(!foundExisting){
    print("Adding new background color value");
    lines.insert(lines.length-1, "\t<color name=\"ic_launcher_background\">${backgroundColor}</color>");
  }

  colorsFile.writeAsStringSync(lines.join("\n"));
}

/**
 * Ensures the correct path is used for generating adaptive icons
 *
 * "Next you must create alternative drawable resources in your app for use with
 * Android 8.0 (API level 26) in res/mipmap-anydpi/ic_launcher.xml"
 * Source: https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive
 */
bool isCorrectMipmapDirectoryForAdaptiveIcon(String path) {
  if (path != "android/app/src/main/res/mipmap-anydpi-v26/") {
    return false;
  } else {
    return true;
  }
}

// Check to see if specified Android config is a string or bool
// String - Generate new launcher icon with the string specified
// bool - override the default flutter project icon
bool isCustomAndroidFile(config) {
  var androidConfig = config['android'];
  if (androidConfig is String) {
    return true;
  } else {
    return false;
  }
}

// return the new launcher icon file name
String getNewIconName(config) {
  return config['android'];
}

overwriteExistingIcons(AndroidIcon e, image, filename) {
  Image newFile;
  if (image.width >= e.size) {
    newFile = copyResize(image, e.size, -1, AVERAGE);
  } else {
    newFile = copyResize(image, e.size, -1, LINEAR);
  }

  File(Constants.androidResFolder + e.name + '/' + filename).create(recursive: true).then((File file) {
    file.writeAsBytesSync(encodePng(newFile));
  });
}

saveNewIcons(AndroidIcon e, image, String iconFilePath) {
  Image newFile;
  if (image.width >= e.size)
    newFile = copyResize(image, e.size, e.size, AVERAGE);
  else
    newFile = copyResize(image, e.size, e.size, LINEAR);

  File(Constants.androidResFolder + e.name + '/' + iconFilePath).create(recursive: true).then((File file) {
    file.writeAsBytesSync(encodePng(newFile));
  });
}

// NOTE: default = ic_launcher
changeAndroidLauncherIcon(String iconName) async {
  File androidManifestFile = File(Constants.androidManifestFile);
  List<String> lines = await androidManifestFile.readAsLines();
  for (var x = 0; x < lines.length; x++) {
    String line = lines[x];
    if (line.contains("android:icon")) {
      // Using RegExp replace the value of android:icon to point to the new icon
      line = line.replaceAll(
          RegExp('android:icon=\"([^*]|(\"+([^"/]|)))*\"'),
          'android:icon="@mipmap/' + iconName + '"');
      lines[x] = line;
      lines.add(""); // used to stop git showing a diff if the icon name hasn't changed
    }
  }
  androidManifestFile.writeAsString(lines.join("\n"));
}

minSdk() {
  File androidGradleFile = File(Constants.androidGradleFile);
  List<String> lines = androidGradleFile.readAsLinesSync();
  for (var x = 0; x < lines.length; x++) {
    String line = lines[x];
    if (line.contains("minSdkVersion")) {

      String minSdk = line.replaceAll(RegExp("[^\\d]"), "");
      print("Android minSdkVersion = $minSdk");
      return int.parse(minSdk);
    }
  }
  return 0; //Didn't find minSdk, assume the worst
}

// prioritises the image_path_android if it exists over the image_path
String getAndroidIconPath(Map config) {
  return config['image_path_android'] ?? config['image_path'];
}

