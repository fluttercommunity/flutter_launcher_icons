import 'dart:io';

import 'package:flutter_launcher_icons/abs/icon_generator.dart';
import 'package:flutter_launcher_icons/constants.dart' as constants;
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/utils.dart' as utils;
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/// A Implementation of [IconGenerator] for Linux
class LinuxIconGenerator extends IconGenerator {
  /// Creates a instance of [LinuxIconGenerator]
  LinuxIconGenerator(IconGeneratorContext context) : super(context, 'Linux');

  @override
  Future<void> createIcons() async {
    final iconPath =
        context.linuxConfig!.imagePath ?? context.config.imagePath!;

    context.logger.verbose('Using Linux icon at $iconPath...');

    // Validate that the icon path starts with assets/ (since it needs to be runtime accessible)
    if (!iconPath.startsWith('assets/')) {
      context.logger.error(
        'Linux icon path must be in assets directory (e.g., "assets/images/icon.png") to be accessible at runtime',
      );
      throw Exception('Invalid Linux icon path: $iconPath');
    }

    // Validate that pubspec.yaml includes the assets
    await _validatePubspecAssets(iconPath);

    // Update my_application.cc file with the icon path
    await _updateMyApplicationFile(iconPath);
  }

  @override
  bool validateRequirements() {
    context.logger.verbose('Validating Linux config...');
    final linuxConfig = context.linuxConfig;
    if (linuxConfig == null || !linuxConfig.generate) {
      context.logger.error(
        'Linux config is not provided or linux.generate is false. Skipped...',
      );
      return false;
    }

    if (linuxConfig.imagePath == null && context.config.imagePath == null) {
      context.logger.error(
        'Invalid config. Either provide linux.image_path or image_path',
      );
      return false;
    }

    final iconPath = linuxConfig.imagePath ?? context.config.imagePath!;

    // Check that icon path is in assets
    if (!iconPath.startsWith('assets/')) {
      context.logger.error(
        'Linux icon path must be in assets directory (e.g., "assets/images/icon.png") to be accessible at runtime',
      );
      return false;
    }

    final entitesToCheck = [
      path.join(context.prefixPath, constants.linuxDirPath),
      path.join(context.prefixPath, constants.linuxMyApplicationFile),
      path.join(context.prefixPath, iconPath),
    ];

    final failedEntityPath = utils.areFSEntiesExist(entitesToCheck);
    if (failedEntityPath != null) {
      context.logger.error(
        '$failedEntityPath this file or folder is required to generate Linux icons',
      );
      return false;
    }

    return true;
  }

  Future<void> _updateMyApplicationFile(String iconPath) async {
    final myAppFile =
        File(path.join(context.prefixPath, constants.linuxMyApplicationFile));

    if (!myAppFile.existsSync()) {
      context.logger.error(
        'my_application.cc file not found at ${constants.linuxMyApplicationFile}',
      );
      throw FileNotFoundException(constants.linuxMyApplicationFile);
    }

    final content = await myAppFile.readAsString();

    // Create the new icon line
    final iconLine =
        'gtk_window_set_icon_from_file(window, "$iconPath", NULL);';

    // Check if icon configuration already exists (handles multi-line statements)
    final existingIconRegex = RegExp(
      r'gtk_window_set_icon_from_file\s*\(\s*[^;]*;',
      multiLine: true,
      dotAll: true,
    );

    final existingIconMatch = existingIconRegex.firstMatch(content);

    if (existingIconMatch != null) {
      // Icon configuration exists - check if it needs updating
      final existingIconStatement = existingIconMatch.group(0)!;

      // Extract the current icon path from the existing statement
      final iconPathRegex = RegExp(r'"([^"]+)"');
      final iconPathMatch = iconPathRegex.firstMatch(existingIconStatement);

      if (iconPathMatch != null) {
        final currentIconPath = iconPathMatch.group(1)!;

        if (currentIconPath == iconPath) {
          context.logger.verbose(
            'Icon configuration already exists with correct path: $iconPath',
          );
          return;
        } else {
          context.logger.verbose(
            'Updating icon configuration from "$currentIconPath" to "$iconPath"',
          );

          // Replace the existing icon statement with the new one
          final updatedContent =
              content.replaceFirst(existingIconRegex, iconLine);
          await myAppFile.writeAsString(updatedContent);

          context.logger.verbose(
            'Updated my_application.cc with new icon configuration: $iconPath',
          );
          return;
        }
      }
    }

    // No existing icon configuration found - need to add it
    context.logger.verbose('Adding new icon configuration: $iconPath');

    final lines = content.split('\n');
    bool modified = false;

    // Strategy 1: Find gtk_window_set_default_size and insert before it
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('gtk_window_set_default_size')) {
        // Handle multi-line gtk_window_set_default_size calls
        final int insertIndex = i;

        // Find the proper indentation by looking at the current line
        final currentLine = lines[i];
        final leadingWhitespace =
            RegExp(r'^(\s*)').firstMatch(currentLine)?.group(1) ?? '  ';

        lines.insert(insertIndex, '$leadingWhitespace$iconLine');
        modified = true;
        break;
      }
    }

    // Strategy 2: Find window variable declaration and insert after it
    if (!modified) {
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('GtkWindow* window =') ||
            lines[i].contains('GtkWindow *window =')) {
          // Find the end of the window declaration (look for semicolon)
          int declarationEndIndex = i;
          while (declarationEndIndex < lines.length &&
              !lines[declarationEndIndex].contains(';')) {
            declarationEndIndex++;
          }

          // Insert after the window declaration
          final int insertIndex = declarationEndIndex + 1;

          // Find proper indentation
          final currentLine = lines[i];
          final leadingWhitespace =
              RegExp(r'^(\s*)').firstMatch(currentLine)?.group(1) ?? '  ';

          lines.insert(insertIndex, '$leadingWhitespace$iconLine');
          modified = true;
          break;
        }
      }
    }

    // Strategy 3: Find gtk_window_show and insert before it
    if (!modified) {
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('gtk_window_show') ||
            lines[i].contains('gtk_widget_show')) {
          // Find proper indentation
          final currentLine = lines[i];
          final leadingWhitespace =
              RegExp(r'^(\s*)').firstMatch(currentLine)?.group(1) ?? '  ';

          lines.insert(i, '$leadingWhitespace$iconLine');
          modified = true;
          break;
        }
      }
    }

    // Strategy 4: Find any gtk_window function call and insert nearby
    if (!modified) {
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('gtk_window_') &&
            !lines[i].contains('gtk_window_set_icon_from_file')) {
          // Find proper indentation
          final currentLine = lines[i];
          final leadingWhitespace =
              RegExp(r'^(\s*)').firstMatch(currentLine)?.group(1) ?? '  ';

          lines.insert(i + 1, '$leadingWhitespace$iconLine');
          modified = true;
          break;
        }
      }
    }

    if (modified) {
      await myAppFile.writeAsString(lines.join('\n'));
      context.logger.verbose(
        'Updated my_application.cc with icon configuration: $iconPath',
      );
    } else {
      final errorMessage =
          'Could not find appropriate location to add icon configuration in my_application.cc. '
          'Please manually add the following line after the window creation:\n'
          '  gtk_window_set_icon_from_file(window, "$iconPath", NULL);';
      context.logger.error(errorMessage);
      throw Exception('Failed to update my_application.cc. $errorMessage');
    }
  }

  Future<void> _validatePubspecAssets(String iconPath) async {
    final pubspecFile = File(path.join(context.prefixPath, 'pubspec.yaml'));

    if (!pubspecFile.existsSync()) {
      context.logger.error('pubspec.yaml not found');
      return;
    }

    final content = await pubspecFile.readAsString();
    final yamlDoc = loadYaml(content) as Map<dynamic, dynamic>?;

    if (yamlDoc == null) {
      context.logger.error('Could not parse pubspec.yaml');
      return;
    }

    final flutter = yamlDoc['flutter'] as Map<dynamic, dynamic>?;
    if (flutter == null) {
      context.logger.error(
        'No flutter section found in pubspec.yaml. Please add $iconPath to your flutter.assets section.',
      );
      return;
    }

    final assets = flutter['assets'] as List<dynamic>?;
    if (assets == null) {
      context.logger.error(
        'No assets section found in pubspec.yaml. Please add "$iconPath" to your flutter.assets section.',
      );
      return;
    }

    // Check if the icon path or its directory is included in assets
    final iconDir = path.dirname(iconPath) + '/';
    bool hasIconPath = false;

    for (final asset in assets) {
      final assetStr = asset.toString();
      if (assetStr == iconPath || assetStr == iconDir) {
        hasIconPath = true;
        break;
      }
    }

    if (!hasIconPath) {
      context.logger.error(
        'Icon path $iconPath not found in pubspec.yaml assets. Please add "$iconPath" or "$iconDir" to your flutter.assets section.',
      );
    } else {
      context.logger.verbose(
        'Icon path $iconPath is properly configured in pubspec.yaml',
      );
    }
  }
}
