import 'dart:io';

import 'package:image/image.dart';

import 'constants.dart';
import 'utils.dart';

/// File to handle the creation of icons for Windows platform
class WindowsIconTemplate {
  WindowsIconTemplate({
    required this.size,
    required this.name,
  });

  final String name;
  final int size;
}

List<WindowsIconTemplate> windowsIcons = <WindowsIconTemplate>[
  WindowsIconTemplate(name: '', size: 32),
  WindowsIconTemplate(name: '_32', size: 32),
  WindowsIconTemplate(name: '_64', size: 64),
  WindowsIconTemplate(name: '_128', size: 128),
  WindowsIconTemplate(name: '_256', size: 256),
  WindowsIconTemplate(name: '_512', size: 256),
  WindowsIconTemplate(name: '_1024', size: 256),
];

void createIcons(Map<String, dynamic> config, String? flavor) {
  final String filePath = config['image_path_windows'] ?? config['image_path'];
  final Image? image = decodeImage(File(filePath).readAsBytesSync());
  if (image == null) {
    return;
  }
  String iconName;
  final dynamic windowsConfig = config['windows'];
  // If the Windows configuration is a string then the user has specified a new icon to be created
  // and for the old icon file to be kept
  if (flavor != null) {
    final String catalogName = 'AppIcon-$flavor';
    printStatus('Building windows launcher icon for $flavor');
    for (WindowsIconTemplate template in windowsIcons) {
      saveNewIcons(template, image, catalogName);
    }
    iconName = windowsDefaultIconName;
    changeWindowsLauncherIcon(catalogName, flavor);
    //modifyContentsFile(catalogName);
  } else if (windowsConfig is String) {
    final String newIconName = windowsConfig;
    printStatus('Adding new Windows launcher icon');
    for (WindowsIconTemplate template in windowsIcons) {
      saveNewIcons(template, image, newIconName);
    }
    iconName = newIconName;
    changeWindowsLauncherIcon(iconName, flavor);
    //modifyContentsFile(iconName);
  }
  // Otherwise the user wants the new icon to use the default icons name and
  // update config file to use it
  else {
    printStatus('Overwriting default windows launcher icon with new icon');
    for (WindowsIconTemplate template in windowsIcons) {
      overwriteDefaultIcons(template, image);
    }
    iconName = windowsDefaultIconName;
    changeWindowsLauncherIcon('AppIcon', flavor);
  }
}

/// Note: Do not change interpolation unless you end up with better results (see issue for result when using cubic
/// interpolation)
/// https://github.com/fluttercommunity/flutter_launcher_icons/issues/101#issuecomment-495528733
void overwriteDefaultIcons(WindowsIconTemplate template, Image image) {
  final Image newFile = createResizedImage(template.size, image);
  File(windowsAssetFolder + windowsDefaultIconName + template.name + '.ico')
    ..writeAsBytesSync(encodeIco(newFile));
}

/// Note: Do not change interpolation unless you end up with better results (see issue for result when using cubic
/// interpolation)
/// https://github.com/fluttercommunity/flutter_launcher_icons/issues/101#issuecomment-495528733
void saveNewIcons(WindowsIconTemplate template, Image image, String newIconName) {
  final String newIconFolder = windowsDefaultIconName + newIconName;
  final Image newFile = createResizedImage(template.size, image);
  File(newIconFolder + newIconName + template.name + '.ico')
      .create(recursive: true)
      .then((File file) {
    file.writeAsBytesSync(encodeIco(newFile));
  });
}

Future<void> changeWindowsLauncherIcon(String iconName, String? flavor) async {
  // ToDo: Make changes to resources.h:
  //#define IDI_APP_ICON                    101
  //#define IDI_APP_ICON_64                 102
  //#define IDI_APP_ICON_128                103
  //#define IDI_APP_ICON_256                104

  // ToDo: make changes to runner.rc
  // // Icon with lowest ID value placed first to ensure application icon
  // // remains consistent on all systems.
  // IDI_APP_ICON              ICON                    "resources\\app_icon.ico"
  // IDI_APP_ICON_64           ICON                    "resources\\app_icon_64.ico"
  // IDI_APP_ICON_128          ICON                    "resources\\app_icon_128.ico"
  // IDI_APP_ICON_256          ICON                    "resources\\app_icon_256.ico"
}

// /// Create the Contents.json file
// void modifyContentsFile(String newIconName) {
//   final String newIconFolder =
//       windowsAssetFolder + newIconName + '.appiconset/Contents.json';
//   File(newIconFolder).create(recursive: true).then((File contentsJsonFile) {
//     final String contentsFileContent =
//         generateContentsFileAsString(newIconName);
//     contentsJsonFile.writeAsString(contentsFileContent);
//   });
// }

// String generateContentsFileAsString(String newIconName) {
//   final Map<String, dynamic> contentJson = <String, dynamic>{
//     'images': createImageList(newIconName),
//     'info': ContentsInfoObject(version: 1, author: 'xcode').toJson()
//   };
//   return json.encode(contentJson);
// }

// class ContentsImageObject {
//   ContentsImageObject({
//     required this.size,
//     required this.idiom,
//     required this.filename,
//     required this.scale,
//   });
//
//   final String size;
//   final String idiom;
//   final String filename;
//   final String scale;
//
//   Map<String, String> toJson() {
//     return <String, String>{
//       'size': size,
//       'idiom': idiom,
//       'filename': filename,
//       'scale': scale
//     };
//   }
// }

// class ContentsInfoObject {
//   ContentsInfoObject({
//     required this.version,
//     required this.author
//   });
//
//   final int version;
//   final String author;
//
//   Map<String, dynamic> toJson() {
//     return <String, dynamic>{
//       'version': version,
//       'author': author,
//     };
//   }
// }

// List<Map<String, String>> createImageList(String fileNamePrefix) {
//   final List<Map<String, String>> imageList = <Map<String, String>>[
//     // So far only one version seems to be supported
//     ContentsImageObject(
//             size: '48x48',
//             idiom: 'windows',
//             filename: '$fileNamePrefix.ico',
//             scale: '1x')
//         .toJson(),
//   ];
//   return imageList;
// }
