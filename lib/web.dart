import 'dart:io';
import 'package:flutter_launcher_icons/abstract_platform.dart';
import 'package:flutter_launcher_icons/icon_template.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:image/image.dart';
import 'package:flutter_launcher_icons/constants.dart' as constants;

final IconTemplateGenerator iconGenerator =
    IconTemplateGenerator(defaultLocation: constants.webIconLocation);

List<IconTemplate> webIcons = <IconTemplate>[
  iconGenerator.get(name: 'Icon-192.png', size: 192),
  iconGenerator.get(name: 'Icon-512.png', size: 512),
  iconGenerator.get(
      name: 'favicon.png', size: 16, location: constants.webFaviconLocation),
];

class WebIconGenerator extends AbstractPlatform {
  const WebIconGenerator() : super('web');

  @override
  void createIcons(Map<String, dynamic> config, String flavor) {
    final String filePath = config['image_path_web'] ?? config['image_path'];
    final Image image = decodeImage(File(filePath).readAsBytesSync());
    final dynamic webConfig = config['web'];

    // If a String is given, the user wants to be able to revert
    //to the previous icon set. Back up the previous set.
    if (webConfig is String) {
      // As there is only one favicon, fail. Request that the user
      //manually backup requested icons.
      print(constants.errorWebCustomLocationNotSupported);
    } else {
      printStatus('Overwriting web favicon and launcher icons...');

      for (IconTemplate template in webIcons) {
        _overwriteDefaultIcon(template, image);
      }
    }
  }

  void _overwriteDefaultIcon(IconTemplate template, Image image) {
    template.updateFile(image);
  }
}
