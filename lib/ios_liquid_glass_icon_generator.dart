// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter_launcher_icons/config/config.dart';
import 'package:flutter_launcher_icons/constants.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:path/path.dart' as path;

/// Generate liquid glass .icon file for iOS
Future<void> generateLiquidGlassIcon(Config config, String iconName) async {
  if (!config.hasLiquidGlassIconConfig) {
    return;
  }

  final String? liquidGlassImagePath = config.imagePathIOSLiquidGlassIcon;
  if (liquidGlassImagePath == null) {
    return;
  }

  // Validate shadow kind
  final shadowKind = config.liquidGlassShadowKindIOS.toLowerCase();
  if (shadowKind != 'neutral' && shadowKind != 'chromatic') {
    throw InvalidConfigException(
      'liquid_glass_shadow_kind_ios must be either "Neutral" or "Chromatic", got: ${config.liquidGlassShadowKindIOS}',
    );
  }

  // Check if source image exists
  final sourceImageFile = File(liquidGlassImagePath);
  if (!sourceImageFile.existsSync()) {
    throw InvalidConfigException(
      'Liquid glass icon image not found at: $liquidGlassImagePath',
    );
  }

  printStatus('Creating liquid glass .icon for $iconName');

  // Create directory structure
  final iconFolderPath = iosLiquidGlassIconPath(iconName);
  final assetsFolderPath = iosLiquidGlassAssetsPath(iconName);
  final configFilePath = iosLiquidGlassConfigPath(iconName);

  await createDirIfNotExist(iconFolderPath);
  await createDirIfNotExist(assetsFolderPath);

  // Copy image to Assets folder
  final imageFileName = path.basename(liquidGlassImagePath);
  final destinationImagePath = path.join(assetsFolderPath, imageFileName);
  await sourceImageFile.copy(destinationImagePath);

  // Generate icon.json
  final iconConfig = _generateIconConfig(config, imageFileName);
  final configFile = await createFileIfNotExist(configFilePath);
  await configFile.writeAsString(prettifyJsonEncode(iconConfig));

  printStatus('Generated liquid glass .icon at $iconFolderPath');
}

/// Generate the icon.json configuration
Map<String, dynamic> _generateIconConfig(Config config, String imageFileName) {
  // Convert background color to SRGB format
  final srgbColor = _convertHexToSrgb(config.backgroundColorIOS);
  
  // Extract image name without extension for the layer name
  final imageName = path.basenameWithoutExtension(imageFileName);

  return {
    'fill': {
      'solid': srgbColor,
    },
    'groups': [
      {
        'blur-material': config.liquidGlassBlurIOS,
        'layers': [
          {
            'glass': !config.removeLiquidGlassIOS,
            'hidden': false,
            'image-name': imageFileName,
            'name': imageName,
            'position': {
              'scale': config.liquidGlassIconScaleIOS,
              'translation-in-points': [
                config.liquidGlassOffsetXIOS ?? 0.0,
                config.liquidGlassOffsetYIOS ?? 0.0,
              ],
            },
          },
        ],
        'shadow': {
          'kind': config.liquidGlassShadowKindIOS.toLowerCase() == 'chromatic' ? 'layer-color' : config.liquidGlassShadowKindIOS.toLowerCase(),
          'opacity': config.liquidGlassShadowOpacityIOS,
        },
        'specular': config.liquidGlassSpecularIOS,
        'translucency': {
          'enabled': config.liquidGlassTranslucencyIOS != null,
          'value': config.liquidGlassTranslucencyIOS ?? 0.5,
        },
      },
    ],
    'supported-platforms': {
      'circles': ['watchOS'],
      'squares': 'shared',
    },
  };
}

/// Convert hex color to Display P3 format (as used by Apple Icon Composer)
String _convertHexToSrgb(String hexColor) {
  // Remove # if present
  final cleanHex = hexColor.startsWith('#') ? hexColor.substring(1) : hexColor;
  
  if (cleanHex.length != 6) {
    throw InvalidConfigException(
      'background_color_ios hex should be 6 characters long, got: $hexColor',
    );
  }

  try {
    final hexValue = int.parse(cleanHex, radix: 16);
    final r = ((hexValue >> 16) & 0xff) / 255.0;
    final g = ((hexValue >> 8) & 0xff) / 255.0;
    final b = (hexValue & 0xff) / 255.0;
    
    return 'display-p3:${r.toStringAsFixed(5)},${g.toStringAsFixed(5)},${b.toStringAsFixed(5)},1.00000';
  } catch (e) {
    throw InvalidConfigException(
      'Invalid hex color format for background_color_ios: $hexColor',
    );
  }
}
