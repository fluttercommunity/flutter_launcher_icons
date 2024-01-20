// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:io';

import 'package:flutter_launcher_icons/config/config.dart';
import 'package:flutter_launcher_icons/constants.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:image/image.dart';

/// File to handle the creation of icons for iOS platform
class IosIconTemplate {
  /// constructs an instance of [IosIconTemplate]
  IosIconTemplate({required this.size, required this.name});

  /// suffix of the icon name
  final String name;

  /// the size of the icon
  final int size;
}

/// details of the ios icons which need to be generated
List<IosIconTemplate> iosIconTemplates = <IosIconTemplate>[
  IosIconTemplate(name: '16', size: 16),
  IosIconTemplate(name: '20', size: 20),
  IosIconTemplate(name: '29', size: 29),
  IosIconTemplate(name: '32', size: 32),
  IosIconTemplate(name: '40', size: 40),
  IosIconTemplate(name: '48', size: 48),
  IosIconTemplate(name: '50', size: 50),
  IosIconTemplate(name: '55', size: 55),
  IosIconTemplate(name: '57', size: 57),
  IosIconTemplate(name: '58', size: 58),
  IosIconTemplate(name: '60', size: 60),
  IosIconTemplate(name: '64', size: 64),
  IosIconTemplate(name: '72', size: 72),
  IosIconTemplate(name: '76', size: 76),
  IosIconTemplate(name: '80', size: 80),
  IosIconTemplate(name: '87', size: 87),
  IosIconTemplate(name: '88', size: 88),
  IosIconTemplate(name: '100', size: 100),
  IosIconTemplate(name: '114', size: 114),
  IosIconTemplate(name: '120', size: 120),
  IosIconTemplate(name: '128', size: 128),
  IosIconTemplate(name: '144', size: 144),
  IosIconTemplate(name: '152', size: 152),
  IosIconTemplate(name: '167', size: 167),
  IosIconTemplate(name: '172', size: 172),
  IosIconTemplate(name: '180', size: 180),
  IosIconTemplate(name: '196', size: 196),
  IosIconTemplate(name: '216', size: 216),
  IosIconTemplate(name: '256', size: 256),
  IosIconTemplate(name: '512', size: 512),
  IosIconTemplate(name: '1024', size: 1024),
];

List<IosIconTemplate> launchImageIconTemplates = <IosIconTemplate>[
  IosIconTemplate(name: 'LaunchImage@1x', size: 150),
  IosIconTemplate(name: 'LaunchImage@2x', size: 300),
  IosIconTemplate(name: 'LaunchImage@3x', size: 600),
];

/// create the ios icons
void createIcons(Config config, String? flavor) {
  // TODO(p-mazhnik): support prefixPath
  final String? filePath = config.getImagePathIOS();
  if (filePath == null) {
    throw const InvalidConfigException(errorMissingImagePath);
  }
  // decodeImageFile shows error message if null
  // so can return here if image is null
  Image? image = decodeImage(File(filePath).readAsBytesSync());
  if (image == null) {
    return;
  }
  if (config.removeAlphaIOS && image.hasAlpha) {
    final backgroundColor = _getBackgroundColor(config);
    final pixel = image.getPixel(0, 0);
    do {
      pixel.set(_alphaBlend(pixel, backgroundColor));
    } while (pixel.moveNext());

    image = image.convert(numChannels: 3);
  }
  if (image.hasAlpha) {
    print(
      '\nWARNING: Icons with alpha channel are not allowed in the Apple App Store.\nSet "remove_alpha_ios: true" to remove it.\n',
    );
  }
  String iconName;
  final dynamic iosConfig = config.ios;
  if (flavor != null) {
    final String catalogName = 'AppIcon-$flavor';
    printStatus('Building iOS launcher icon for $flavor');
    for (IosIconTemplate template in iosIconTemplates) {
      saveNewIcons(
        template,
        image,
        catalogName,
      );
    }
    iconName = iosDefaultIconName;
    changeIosLauncherIcon(catalogName, flavor);
    modifyContentsFile(catalogName);
  } else if (iosConfig is String) {
    // If the IOS configuration is a string then the user has specified a new icon to be created
    // and for the old icon file to be kept
    final String newIconName = iosConfig;
    printStatus('Adding new iOS launcher icon');
    for (IosIconTemplate template in iosIconTemplates) {
      saveNewIcons(
        template,
        image,
        newIconName,
      );
    }
    iconName = newIconName;
    changeIosLauncherIcon(iconName, flavor);
    modifyContentsFile(iconName);
  }
  // Otherwise the user wants the new icon to use the default icons name and
  // update config file to use it
  else {
    printStatus('Overwriting default iOS launcher icon with new icon');
    for (IosIconTemplate template in iosIconTemplates) {
      overwriteDefaultIcons(template, image, '');
    }
    changeIosLauncherIcon('AppIcon', flavor);
  }

  if (config.launchImageIOS != null) {
    printStatus('Generating iOS Launcher Icons');
    final launchImage = decodeImage(
      File(config.launchImageIOS!).readAsBytesSync(),
    );
    if (launchImage != null) {
      for (final template in launchImageIconTemplates) {
        saveNewLaunchImage(template, launchImage);
      }
    }
  }
}

/// Note: Do not change interpolation unless you end up with better results (see issue for result when using cubic
/// interpolation)
/// https://github.com/fluttercommunity/flutter_launcher_icons/issues/101#issuecomment-495528733
void overwriteDefaultIcons(
  IosIconTemplate template,
  Image image,
  String iconName,
) {
  final Image newFile = createResizedImage(template, image);
  File(iosDefaultIconFolder + iconName + template.name + '.png')
    ..writeAsBytesSync(encodePng(newFile));
}

/// Note: Do not change interpolation unless you end up with better results (see issue for result when using cubic
/// interpolation)
/// https://github.com/fluttercommunity/flutter_launcher_icons/issues/101#issuecomment-495528733
void saveNewIcons(
  IosIconTemplate template,
  Image image,
  String newIconName,
) {
  final String newIconFolder = iosAssetFolder + newIconName + '.appiconset/';
  final Image newFile = createResizedImage(template, image);
  File(newIconFolder + template.name + '.png')
      .create(recursive: true)
      .then((File file) {
    file.writeAsBytesSync(encodePng(newFile));
  });
}

void saveNewLaunchImage(
  IosIconTemplate template,
  Image image,
) {
  const String newIconFolder = iosAssetFolder + 'LaunchImage.imageset/';
  final Image newFile = createResizedImage(template, image);
  File(newIconFolder + template.name + '.png')
      .create(recursive: true)
      .then((File file) {
    file.writeAsBytesSync(encodePng(newFile));
  });
}

/// create resized icon image
Image createResizedImage(IosIconTemplate template, Image image) {
  if (image.width >= template.size) {
    return copyResize(
      image,
      width: template.size,
      height: template.size,
      interpolation: Interpolation.average,
    );
  } else {
    return copyResize(
      image,
      width: template.size,
      height: template.size,
      interpolation: Interpolation.linear,
    );
  }
}

/// Change the iOS launcher icon
Future<void> changeIosLauncherIcon(String iconName, String? flavor) async {
  // final File iOSConfigFile = File(iosConfigFile);
  // final List<String> lines = await iOSConfigFile.readAsLines();

  // bool onConfigurationSection = false;
  // String? currentConfig;

  // for (int x = 0; x < lines.length; x++) {
  //   final String line = lines[x];
  //   if (line.contains('/* Begin XCBuildConfiguration section */')) {
  //     onConfigurationSection = true;
  //   }
  //   if (line.contains('/* End XCBuildConfiguration section */')) {
  //     onConfigurationSection = false;
  //   }
  //   if (onConfigurationSection) {
  //     final match = RegExp('.*/\\* (.*)\.xcconfig \\*/;').firstMatch(line);
  //     if (match != null) {
  //       currentConfig = match.group(1);
  //     }

  //     if (currentConfig != null &&
  //         (flavor == null || currentConfig.contains('-$flavor')) &&
  //         line.contains('ASSETCATALOG')) {
  //       lines[x] = line.replaceAll(RegExp('\=(.*);'), '= $iconName;');
  //     }
  //   }
  // }

  // final String entireFile = '${lines.join('\n')}\n';
  // await iOSConfigFile.writeAsString(entireFile);
}

/// Create the Contents.json file
void modifyContentsFile(String newIconName) {
  // final String newIconFolder =
  //     iosAssetFolder + newIconName + '.appiconset/Contents.json';
  // File(newIconFolder).create(recursive: true).then((File contentsJsonFile) {
  //   final String contentsFileContent =
  //       generateContentsFileAsString(newIconName);
  //   contentsJsonFile.writeAsString(contentsFileContent);
  // });
}

String generateContentsFileAsString(String newIconName) {
  final Map<String, dynamic> contentJson = <String, dynamic>{
    'images': createImageList(),
    'info': ContentsInfoObject(version: 1, author: 'xcode').toJson(),
  };
  return json.encode(contentJson);
}

class ContentsImageObject {
  ContentsImageObject({
    required this.size,
    required this.idiom,
    required this.filename,
    required this.scale,
  });

  final String size;
  final String idiom;
  final String filename;
  final String scale;

  Map<String, String> toJson() {
    return <String, String>{
      'size': size,
      'idiom': idiom,
      'filename': filename,
      'scale': scale,
    };
  }
}

class ContentsInfoObject {
  ContentsInfoObject({required this.version, required this.author});

  final int version;
  final String author;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': version,
      'author': author,
    };
  }
}

List<Map<String, String>> createImageList() {
  final List<Map<String, String>> imageList = <Map<String, String>>[
    {'filename': '40.png', 'idiom': 'iphone', 'scale': '2x', 'size': '20x20'},
    {'filename': '60.png', 'idiom': 'iphone', 'scale': '3x', 'size': '20x20'},
    {'filename': '29.png', 'idiom': 'iphone', 'scale': '1x', 'size': '29x29'},
    {'filename': '58.png', 'idiom': 'iphone', 'scale': '2x', 'size': '29x29'},
    {'filename': '87.png', 'idiom': 'iphone', 'scale': '3x', 'size': '29x29'},
    {'filename': '80.png', 'idiom': 'iphone', 'scale': '2x', 'size': '40x40'},
    {'filename': '120.png', 'idiom': 'iphone', 'scale': '3x', 'size': '40x40'},
    {'filename': '57.png', 'idiom': 'iphone', 'scale': '1x', 'size': '57x57'},
    {'filename': '114.png', 'idiom': 'iphone', 'scale': '2x', 'size': '57x57'},
    {'filename': '120.png', 'idiom': 'iphone', 'scale': '2x', 'size': '60x60'},
    {'filename': '180.png', 'idiom': 'iphone', 'scale': '3x', 'size': '60x60'},
    {'filename': '20.png', 'idiom': 'ipad', 'scale': '1x', 'size': '20x20'},
    {'filename': '40.png', 'idiom': 'ipad', 'scale': '2x', 'size': '20x20'},
    {'filename': '29.png', 'idiom': 'ipad', 'scale': '1x', 'size': '29x29'},
    {'filename': '58.png', 'idiom': 'ipad', 'scale': '2x', 'size': '29x29'},
    {'filename': '40.png', 'idiom': 'ipad', 'scale': '1x', 'size': '40x40'},
    {'filename': '80.png', 'idiom': 'ipad', 'scale': '2x', 'size': '40x40'},
    {'filename': '50.png', 'idiom': 'ipad', 'scale': '1x', 'size': '50x50'},
    {'filename': '100.png', 'idiom': 'ipad', 'scale': '2x', 'size': '50x50'},
    {'filename': '72.png', 'idiom': 'ipad', 'scale': '1x', 'size': '72x72'},
    {'filename': '144.png', 'idiom': 'ipad', 'scale': '2x', 'size': '72x72'},
    {'filename': '76.png', 'idiom': 'ipad', 'scale': '1x', 'size': '76x76'},
    {'filename': '152.png', 'idiom': 'ipad', 'scale': '2x', 'size': '76x76'},
    {
      'filename': '167.png',
      'idiom': 'ipad',
      'scale': '2x',
      'size': '83.5x83.5',
    },
    {
      'filename': '1024.png',
      'idiom': 'ios-marketing',
      'scale': '1x',
      'size': '1024x1024',
    },
    {
      'filename': '48.png',
      'idiom': 'watch',
      'role': 'notificationCenter',
      'scale': '2x',
      'size': '24x24',
      'subtype': '38mm',
    },
    {
      'filename': '55.png',
      'idiom': 'watch',
      'role': 'notificationCenter',
      'scale': '2x',
      'size': '27.5x27.5',
      'subtype': '42mm',
    },
    {
      'filename': '58.png',
      'idiom': 'watch',
      'role': 'companionSettings',
      'scale': '2x',
      'size': '29x29',
    },
    {
      'filename': '87.png',
      'idiom': 'watch',
      'role': 'companionSettings',
      'scale': '3x',
      'size': '29x29',
    },
    {
      'idiom': 'watch',
      'role': 'notificationCenter',
      'scale': '2x',
      'size': '33x33',
      'subtype': '45mm',
    },
    {
      'filename': '80.png',
      'idiom': 'watch',
      'role': 'appLauncher',
      'scale': '2x',
      'size': '40x40',
      'subtype': '38mm',
    },
    {
      'filename': '88.png',
      'idiom': 'watch',
      'role': 'appLauncher',
      'scale': '2x',
      'size': '44x44',
      'subtype': '40mm',
    },
    {
      'idiom': 'watch',
      'role': 'appLauncher',
      'scale': '2x',
      'size': '46x46',
      'subtype': '41mm',
    },
    {
      'filename': '100.png',
      'idiom': 'watch',
      'role': 'appLauncher',
      'scale': '2x',
      'size': '50x50',
      'subtype': '44mm',
    },
    {
      'idiom': 'watch',
      'role': 'appLauncher',
      'scale': '2x',
      'size': '51x51',
      'subtype': '45mm',
    },
    {
      'filename': '172.png',
      'idiom': 'watch',
      'role': 'quickLook',
      'scale': '2x',
      'size': '86x86',
      'subtype': '38mm',
    },
    {
      'filename': '196.png',
      'idiom': 'watch',
      'role': 'quickLook',
      'scale': '2x',
      'size': '98x98',
      'subtype': '42mm',
    },
    {
      'filename': '216.png',
      'idiom': 'watch',
      'role': 'quickLook',
      'scale': '2x',
      'size': '108x108',
      'subtype': '44mm',
    },
    {
      'idiom': 'watch',
      'role': 'quickLook',
      'scale': '2x',
      'size': '117x117',
      'subtype': '45mm',
    },
    {
      'filename': '1024.png',
      'idiom': 'watch-marketing',
      'scale': '1x',
      'size': '1024x1024',
    },
    {'filename': '16.png', 'idiom': 'mac', 'scale': '1x', 'size': '16x16'},
    {'filename': '32.png', 'idiom': 'mac', 'scale': '2x', 'size': '16x16'},
    {'filename': '32.png', 'idiom': 'mac', 'scale': '1x', 'size': '32x32'},
    {'filename': '64.png', 'idiom': 'mac', 'scale': '2x', 'size': '32x32'},
    {'filename': '128.png', 'idiom': 'mac', 'scale': '1x', 'size': '128x128'},
    {'filename': '256.png', 'idiom': 'mac', 'scale': '2x', 'size': '128x128'},
    {'filename': '256.png', 'idiom': 'mac', 'scale': '1x', 'size': '256x256'},
    {'filename': '512.png', 'idiom': 'mac', 'scale': '2x', 'size': '256x256'},
    {'filename': '512.png', 'idiom': 'mac', 'scale': '1x', 'size': '512x512'},
    {'filename': '1024.png', 'idiom': 'mac', 'scale': '2x', 'size': '512x512'},
  ];
  return imageList;
}

ColorUint8 _getBackgroundColor(Config config) {
  final backgroundColorHex = config.backgroundColorIOS.startsWith('#')
      ? config.backgroundColorIOS.substring(1)
      : config.backgroundColorIOS;
  if (backgroundColorHex.length != 6) {
    throw Exception('background_color_ios hex should be 6 characters long');
  }

  final backgroundByte = int.parse(backgroundColorHex, radix: 16);
  return ColorUint8.rgba(
    (backgroundByte >> 16) & 0xff,
    (backgroundByte >> 8) & 0xff,
    (backgroundByte >> 0) & 0xff,
    0xff,
  );
}

Color _alphaBlend(Color fg, ColorUint8 bg) {
  if (fg.format != Format.uint8) {
    fg = fg.convert(format: Format.uint8);
  }
  if (fg.a == 0) {
    return bg;
  } else {
    final invAlpha = 0xff - fg.a;
    return ColorUint8.rgba(
      (fg.a * fg.r + invAlpha * bg.g) ~/ 0xff,
      (fg.a * fg.g + invAlpha * bg.a) ~/ 0xff,
      (fg.a * fg.b + invAlpha * bg.b) ~/ 0xff,
      0xff,
    );
  }
}
