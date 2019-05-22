import 'dart:io';
import 'package:flutter_launcher_icons/xml_templates.dart' as XmlTemplate;
import 'package:image/image.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/constants.dart' as Constants;

class AndroidIconTemplate {
  final String directoryName;
  final int size;
  AndroidIconTemplate({this.size, this.directoryName});
}

final List<AndroidIconTemplate> adaptiveForegroundIcons = [
  AndroidIconTemplate(directoryName: "drawable-mdpi", size: 108),
  AndroidIconTemplate(directoryName: "drawable-hdpi", size: 162),
  AndroidIconTemplate(directoryName: "drawable-xhdpi", size: 216),
  AndroidIconTemplate(directoryName: "drawable-xxhdpi", size: 324),
  AndroidIconTemplate(directoryName: "drawable-xxxhdpi", size: 432),
];

List<AndroidIconTemplate> androidIcons = [
  AndroidIconTemplate(directoryName: "mipmap-mdpi", size: 48),
  AndroidIconTemplate(directoryName: "mipmap-hdpi", size: 72),
  AndroidIconTemplate(directoryName: "mipmap-xhdpi", size: 96),
  AndroidIconTemplate(directoryName: "mipmap-xxhdpi", size: 144),
  AndroidIconTemplate(directoryName: "mipmap-xxxhdpi", size: 192),
];

createDefaultIcons(Map flutterLauncherIconsConfig) {
  print("Creating default icons Android");
  String filePath = getAndroidIconPath(flutterLauncherIconsConfig);
  Image image = decodeImage(File(filePath).readAsBytesSync());
  if (isCustomAndroidFile(flutterLauncherIconsConfig)) {
    print("Adding a new Android launcher icon");
    String iconName = getNewIconName(flutterLauncherIconsConfig);
    isAndroidIconNameCorrectFormat(iconName);
    String iconPath = iconName + ".png";
    androidIcons.forEach((AndroidIconTemplate template) => saveNewImages(template, image, iconPath));
    overwriteAndroidManifestWithNewLauncherIcon(iconName);
  }
  else {
    print("Overwriting the default Android launcher icon with a new icon");
    androidIcons.forEach((AndroidIconTemplate e) => overwriteExistingIcons(e, image, Constants.androidFileName));
    overwriteAndroidManifestWithNewLauncherIcon(Constants.androidDefaultIconName);
  }
}

/**
 * Ensures that the Android icon name is in the correct format
 */
bool isAndroidIconNameCorrectFormat(String iconName) {
  if (!RegExp(r"^[a-z0-9_]+$").hasMatch(iconName)) {
    throw InvalidAndroidIconNameException('The icon name must contain only lowercase a-z, 0-9, or underscore: E.g. "ic_my_new_icon"');
  }
  return true;
}

createAdaptiveIcons(Map flutterLauncherIconsConfig) {
  print("Creating adaptive icons Android");

  // Retrieve the necessary Flutter Launcher Icons configuration from the pubspec.yaml file
  String backgroundConfig = flutterLauncherIconsConfig['adaptive_icon_background'];
  String foregroundImagePath = flutterLauncherIconsConfig['adaptive_icon_foreground'];
  Image foregroundImage = decodeImage(File(foregroundImagePath).readAsBytesSync());

  // Create adaptive icon foreground images
  adaptiveForegroundIcons.forEach((AndroidIconTemplate androidIcon) =>
      overwriteExistingIcons(androidIcon, foregroundImage, Constants.androidAdaptiveForegroundFileName));

  // Create adaptive icon background
  if (isAdaptiveIconConfigPngFile(backgroundConfig)) {
    createAdaptiveBackgrounds(flutterLauncherIconsConfig, backgroundConfig);
  } else {
    createAdaptiveIconMipmapXmlFile(flutterLauncherIconsConfig);
    updateColorsXmlFile(backgroundConfig);
  }
}

/**
 *  Retrieves the colors.xml file for the project.
 *
 *  If the colors.xml file is found, it is updated with a new color item for the
 *  adaptive icon background.
 *
 *  If not, the colors.xml file is created and a color item for the adaptive icon
 *  background is included in the new colors.xml file.
 */
updateColorsXmlFile(String backgroundConfig) {
  var colorsXml = File(Constants.androidColorsFile);
  colorsXml.exists().then((bool isColorsXmlAlreadyInProject) {
    if (isColorsXmlAlreadyInProject) {
      print("Updating colors.xml with color for adaptive icon background");
      updateColorsFile(colorsXml, backgroundConfig);
    } else {
      print("No colors.xml file found in your Android project");
      print("Creating colors.xml file and adding it to your Android project");
      createNewColorsFile(backgroundConfig);
    }
  });
}

/**
 * Creates the xml file required for the adaptive launcher icon
 * FILE LOCATED HERE: res/mipmap-anydpi/{icon-name-from-yaml-config}.xml
 */
createAdaptiveIconMipmapXmlFile(Map flutterLauncherIconsConfig) {
  if (isCustomAndroidFile(flutterLauncherIconsConfig)) {
    File(Constants.androidAdaptiveXmlFolder + getNewIconName(flutterLauncherIconsConfig)
        + '.xml').create(recursive: true).then((File adaptiveIcon) {
      adaptiveIcon.writeAsString(XmlTemplate.icLauncherXml);
    });
  } else {
    File(Constants.androidAdaptiveXmlFolder + Constants.androidDefaultIconName + '.xml')
        .create(recursive: true).then((File adaptiveIcon) {
      adaptiveIcon.writeAsString(XmlTemplate.icLauncherXml);
    });
  }
}

// creates adaptive background using png image
createAdaptiveBackgrounds(Map yamlConfig, String adaptiveIconBackgroundImagePath) {
  String filePath = adaptiveIconBackgroundImagePath;
  Image image = decodeImage(File(filePath).readAsBytesSync());

  // creates a png image (ic_adaptive_background.png) for the adaptive icon background in each of the locations
  // it is required
  adaptiveForegroundIcons.forEach((AndroidIconTemplate androidIcon) => saveNewImages(androidIcon, image, Constants.androidAdaptiveBackgroundFileName));

  // Creates the xml file required for the adaptive launcher icon
  // FILE LOCATED HERE:  res/mipmap-anydpi/{icon-name-from-yaml-config}.xml
  if (isCustomAndroidFile(yamlConfig)) {
    File(Constants.androidAdaptiveXmlFolder + getNewIconName(yamlConfig)
        + '.xml').create(recursive: true).then((File adaptiveIcon) {
      adaptiveIcon.writeAsString(XmlTemplate.icLauncherDrawableBackgroundXml);
    });
  } else {
    File(Constants.androidAdaptiveXmlFolder + Constants.androidDefaultIconName + '.xml')
        .create(recursive: true).then((File adaptiveIcon) {
      adaptiveIcon.writeAsString(XmlTemplate.icLauncherDrawableBackgroundXml);
    });
  }
}

/**
 * Creates a colors.xml file if it was missing from android/app/src/main/res/values/colors.xml
 */
createNewColorsFile(String backgroundColor) {
  File(Constants.androidColorsFile).create(recursive: true).then((File colorsFile) {
    colorsFile.writeAsString(XmlTemplate.colorsXml).then((File file) {
      updateColorsFile(colorsFile, backgroundColor);
    });
  });
}

/**
 * Updates the colors.xml with the new adaptive launcher icon color
 */
updateColorsFile(File colorsFile, String backgroundColor) {
  // Write foreground color
  List<String> lines = colorsFile.readAsLinesSync();
  bool foundExisting = false;
  for (var x = 0; x < lines.length; x++) {
    String line = lines[x];
    if (line.contains("name=\"ic_launcher_background\"")) {
      foundExisting = true;
      line = line.replaceAll(RegExp('>(.*)<'), ">$backgroundColor<");
      lines[x] = line;
      break;
    }
  }

  // Add new line if we didn't find an existing value
  if (!foundExisting) {
    lines.insert(lines.length - 1,
        "\t<color name=\"ic_launcher_background\">${backgroundColor}</color>");
  }

  colorsFile.writeAsStringSync(lines.join("\n"));
}


/**
 * Check to see if specified Android config is a string or bool
 *
 * String - Generate new launcher icon with the string specified
 * bool - override the default flutter project icon
 */
bool isCustomAndroidFile(Map config) {
  var androidConfig = config['android'];
  if (androidConfig is String) {
    return true;
  }
  return false;
}

// return the new launcher icon file name
String getNewIconName(config) {
  return config['android'];
}

/**
 * Overrides the existing launcher icons in the project
 */
overwriteExistingIcons(AndroidIconTemplate e, image, filename) {
  Image newFile;
  if (image.width >= e.size) {
    newFile = copyResize(image, width: e.size, height: -1, interpolation: Interpolation.average);
  } else {
    newFile = copyResize(image, width: e.size, height: -1,  interpolation: Interpolation.linear);
  }

  File(Constants.androidResFolder + e.directoryName + '/' + filename).create(recursive: true).then((File file) {
    file.writeAsBytesSync(encodePng(newFile));
  });
}

/**
 * Saves new launcher icons to the project, keeping the old launcher icons.
 */
saveNewImages(AndroidIconTemplate template, image, String iconFilePath) {
  Image newFile;
  if (image.width >= template.size) {
    newFile = copyResize(image, width: template.size, height: template.size, interpolation: Interpolation.average);
  }
  else {
    newFile = copyResize(image, width: template.size, height: template.size, interpolation: Interpolation.linear);
  }
  File(Constants.androidResFolder + template.directoryName + '/' + iconFilePath).create(recursive: true).then((File file) {
    file.writeAsBytesSync(encodePng(newFile));
  });
}

/**
 * Updates the line which specifies the launcher icon within the AndroidManifest.xml
 * with the new icon name (only if it has changed)
 *
 * Note: default iconName = "ic_launcher"
 */
overwriteAndroidManifestWithNewLauncherIcon(String iconName) async {
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

/**
 * Retrieves the minSdk value from the Android build.gradle file
 */
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

/**
 * Method for the retrieval of the Android icon path
 * If image_path_android is found, this will be prioritised over the image_path
 * value.
 */
String getAndroidIconPath(Map config) {
  return config['image_path_android'] ?? config['image_path'];
}

/**
 * Returns true if the adaptive icon configuration is a PNG image
 */
bool isAdaptiveIconConfigPngFile(String backgroundFile) {
  if (backgroundFile.endsWith(".png")) {
    return true;
  }
  return false;
}

/**
 * (NOTE THIS IS JUST USED FOR UNIT TEST)
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

