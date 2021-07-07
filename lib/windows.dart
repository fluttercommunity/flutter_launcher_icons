import 'dart:io';

import 'package:image/image.dart';

import 'abstract_platform.dart';
import 'constants.dart';
import 'icon_template.dart';
import 'utils.dart';

/// File to handle the creation of icons for Windows platform
final IconTemplateGenerator templateGenerator = IconTemplateGenerator(
    defaultLocation: windowsDefaultIconFolder, defaultSuffix: '.ico');

List<IconTemplate> windowsIcons = <IconTemplate>[
  templateGenerator.get(name: '', size: 32),
  templateGenerator.get(name: '_32', size: 32),
  templateGenerator.get(name: '_64', size: 64),
  templateGenerator.get(name: '_128', size: 128),
  templateGenerator.get(name: '_256', size: 256),
  templateGenerator.get(name: '_512', size: 256),
  templateGenerator.get(name: '_1024', size: 256),
];

class WindowsIconGenerator extends AbstractPlatform {
  const WindowsIconGenerator() : super('windows');

  @override
  void createIcons(Map<String, dynamic> config, String? flavor) {
    final String filePath =
        config['image_path_windows'] ?? config['image_path'];
    final Image? image = decodeImage(File(filePath).readAsBytesSync());
    if (image == null) {
      return;
    }
    String iconName;
    final dynamic windowsConfig = config['windows'];
    // If the Windows configuration is a string then the user has specified a new icon to be created
    // and for the old icon file to be kept
    if (flavor != null) {
      final String catalogName = 'app_icon_$flavor';
      printStatus('Building windows launcher icon for $flavor');
      for (IconTemplate template in windowsIcons) {
        _saveNewIcons(template, image, catalogName);
      }
      iconName = windowsDefaultIconName;
      _updateResources(catalogName, flavor);
    } else if (windowsConfig is String) {
      final String newIconName = windowsConfig;
      printStatus('Adding new Windows launcher icon');
      for (IconTemplate template in windowsIcons) {
        _saveNewIcons(template, image, newIconName);
      }
      iconName = newIconName;
      //modifyContentsFile(iconName);
      _updateResources(iconName, flavor);
    }
    // Otherwise the user wants the new icon to use the default icons name and
    // update config file to use it
    else {
      printStatus('Overwriting default windows launcher icon with new icon');
      for (IconTemplate template in windowsIcons) {
        _overwriteDefaultIcons(template, image);
      }
      iconName = windowsDefaultIconName;
      _updateResources('app_icon', flavor);
    }
  }

  /// Note: Do not change interpolation unless you end up with better results (see issue for result when using cubic
  /// interpolation)
  /// https://github.com/fluttercommunity/flutter_launcher_icons/issues/101#issuecomment-495528733
  void _overwriteDefaultIcons(IconTemplate template, Image image) {
    final Image newFile = createResizedImage(template.size, image);
    File(_getIconPath(template, windowsDefaultIconName))
      ..writeAsBytesSync(encodeIco(newFile));
  }

  /// Note: Do not change interpolation unless you end up with better results (see issue for result when using cubic
  /// interpolation)
  /// https://github.com/fluttercommunity/flutter_launcher_icons/issues/101#issuecomment-495528733
  void _saveNewIcons(IconTemplate template, Image image, String newIconName) {
    final Image newFile = createResizedImage(template.size, image);

    File(_getIconPath(template, newIconName))
        .create(recursive: true)
        .then((File file) {
      file.writeAsBytesSync(encodeIco(newFile));
    });
  }

  String _getIconPath(IconTemplate template, String newIconName) {
    return windowsDefaultIconFolder + newIconName + template.name;
  }

  Future<void> _updateResources(String iconName, String? flavor) async {
    final String filePathOriginalH = windowsRunnerFolder + 'resource.h';
    final String filePathOriginalRC = windowsRunnerFolder + 'runner.rc';
    final String filePathOriginalCPP = windowsRunnerFolder + 'win32_window.cpp';

    final String? flavorName = flavor != null ? '-' + flavor : '';

    final File originalResourcesH = File(filePathOriginalH);
    final File originalResourcesRC = File(filePathOriginalRC);
    final File originalResourcesCPP = File(filePathOriginalCPP);
    if (!originalResourcesH.existsSync()) {
      print("resource.h doesn't exist at $filePathOriginalH");
      return;
    }
    if (!originalResourcesRC.existsSync()) {
      print("Runner.rc doesn't exist at $filePathOriginalRC");
      return;
    }
    if (!originalResourcesCPP.existsSync()) {
      print("win32_window.cpp doesn't exist at $filePathOriginalCPP");
      return;
    }
    // If any of the files does not exist, abort - no windows configuration

    final List<String> newAppIconsSectionH = [];
    final List<String> newAppIconsSectionRC = [];
    int idiNumber = 101;
    windowsIcons.forEach((iconType) {
      final String idi =
          'IDI_${iconName.toUpperCase()}$flavorName${iconType.baseName}';

      newAppIconsSectionH.add('#define $idi  $idiNumber');
      newAppIconsSectionRC.add(
          '$idi              ICON                    \"$windowsAssetFolder/$iconName${iconType.name}\"');

      idiNumber += 1;
    });

    // Write new resource.h in buffer
    final bufferNewResourcesH = StringBuffer();
    final linesInH = await originalResourcesH.readAsLines();
    bool doKeep = true;
    for (String line in linesInH) {
      if (line.startsWith('#define IDI')) {
        // Stop copying when receiving idis
        if (doKeep) {
          doKeep = false;
          newAppIconsSectionH.forEach((line) {
            bufferNewResourcesH.writeln(line);
          });
          // Insert newly created idis
        }
      }
      if (line == '')
        doKeep = true; // Start copying again with the first blank line
      if (doKeep) bufferNewResourcesH.writeln(line);
    }

    // write new header from buffer to file
    final File newResourcesH = File(filePathOriginalH);
    await newResourcesH.writeAsString(bufferNewResourcesH.toString(),
        mode: FileMode.write);

    // Create new version in Buffer
    final bufferNewResourcesRC = StringBuffer();
    final linesInRC = await originalResourcesRC.readAsLines();
    doKeep = true;
    for (String line in linesInRC) {
      if (line.startsWith('IDI_')) {
        // Stop copying when receiving idis
        if (doKeep) {
          doKeep = false;
          newAppIconsSectionRC.forEach((line) {
            bufferNewResourcesRC.writeln(line);
          });
          // Insert newly created resources
        }
      }
      if (line == '')
        doKeep = true; // Start copying again with the first blank line
      if (doKeep) bufferNewResourcesRC.writeln(line);
    }
    final File newResourcesRC = File(filePathOriginalRC);
    await newResourcesRC.writeAsString(bufferNewResourcesRC.toString(),
        mode: FileMode.write);

    // Create new version in Buffer
    final bufferNewResourcesCPP = StringBuffer();
    final String baseIdi = 'IDI_${iconName.toUpperCase()}$flavorName';
    bool needRewriteCPP = false;
    final linesInCPP = await originalResourcesCPP.readAsLines();
    for (String line in linesInCPP) {
      if (line.contains('LoadIcon(')) {
        // Build new, when contains LoadIcon(
        String newLoadIcon = line.substring(0, line.indexOf('LoadIcon('));
        newLoadIcon +=
            'LoadIcon(window_class.hInstance, MAKEINTRESOURCE($baseIdi));';
        bufferNewResourcesCPP.writeln(newLoadIcon);
        if (line != newLoadIcon)
          needRewriteCPP = true;
        // Insert newly created resources
      } else
        bufferNewResourcesCPP.writeln(line);
    }

    // write to file
    if (needRewriteCPP) {
      // Only rewrite if changed
      final File newResourcesCPP = File(filePathOriginalCPP);
      await newResourcesCPP.writeAsString(bufferNewResourcesCPP.toString(),
          mode: FileMode.write);
      // write new win32_window.cpp
    }
  }
}
