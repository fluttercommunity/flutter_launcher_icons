import 'dart:io';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:image/image.dart';
import 'package:flutter_launcher_icons/constants.dart';

/// File to handle the creation of icons for WINDOWS platform
class WindowsIconTemplate {
  WindowsIconTemplate({required this.size, required this.name});

  final String name;
  final int size;
}

List<WindowsIconTemplate> windowsIcons = <WindowsIconTemplate>[
  WindowsIconTemplate(name: '', size: 128),
];

Image createResizedImage(WindowsIconTemplate template, Image image) {
  if (image.width >= template.size) {
    return copyResize(image,
        width: template.size,
        height: template.size,
        interpolation: Interpolation.average);
  } else {
    return copyResize(image,
        width: template.size,
        height: template.size,
        interpolation: Interpolation.linear);
  }
}

void overwriteDefaultIcons(WindowsIconTemplate template, Image image) {
  final Image newFile = createResizedImage(template, image);
  File(windowsDefaultIconFolder +
      windowsDefaultIconName +
      template.name +
      '.ico')
    ..writeAsBytesSync(encodeIco(newFile));
}

void saveNewIcons(
    WindowsIconTemplate template, Image image, String newIconName) {
  final String newIconFolder = windowsDefaultIconFolder + newIconName;
  final Image newFile = createResizedImage(template, image);
  File(newIconFolder + newIconName + template.name + '.ico')
      .create(recursive: true)
      .then((File file) {
    file.writeAsBytesSync(encodeIco(newFile));
  });
}

void createIcons(Map<String, dynamic> config, String? flavor) {
  final String filePath = config['image_path_windows'] ?? config['image_path'];
  // decodeImageFile shows error message if null
  // so can return here if image is null
  final Image? image = decodeImage(File(filePath).readAsBytesSync());
  if (image == null) {
    return;
  }
  if (config['remove_alpha_windows'] is bool &&
      config['remove_alpha_windows']) {
    image.channels = Channels.rgb;
  }
  if (image.channels == Channels.rgba) {
    print(
        '\nWARNING: Icons with alpha channel are not allowed in the Apple App Store.\nSet "remove_alpha_windows: true" to remove it.\n');
  }

  final dynamic windowsConfig = config['windows'];
  if (flavor != null) {
    final String catalogName = 'AppIcon-$flavor';
    printStatus('Building WINDOWS launcher icon for $flavor');
    for (WindowsIconTemplate template in windowsIcons) {
      saveNewIcons(template, image, catalogName);
    }
  } else if (windowsConfig is String) {
    // If the WINDOWS configuration is a string then the user has specified a new icon to be created
    // and for the old icon file to be kept
    final String newIconName = windowsConfig;
    printStatus('Adding new WINDOWS launcher icon');
    for (WindowsIconTemplate template in windowsIcons) {
      saveNewIcons(template, image, newIconName);
    }
  }
  // Otherwise the user wants the new icon to use the default icons name and
  // update config file to use it
  else {
    printStatus('Overwriting default WINDOWS launcher icon with new icon');
    for (WindowsIconTemplate template in windowsIcons) {
      overwriteDefaultIcons(template, image);
    }
  }
}
