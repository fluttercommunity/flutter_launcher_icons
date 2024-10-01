// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map json) => $checkedCreate(
      'Config',
      json,
      ($checkedConvert) {
        final val = Config(
          imagePath: $checkedConvert('image_path', (v) => v as String?),
          android: $checkedConvert('android', (v) => v ?? false),
          ios: $checkedConvert('ios', (v) => v ?? false),
          imagePathAndroid:
              $checkedConvert('image_path_android', (v) => v as String?),
          imagePathIOS: $checkedConvert('image_path_ios', (v) => v as String?),
          imagePathIOSDarkTransparent: $checkedConvert(
              'image_path_ios_dark_transparent', (v) => v as String?),
          imagePathIOSTintedGrayscale: $checkedConvert(
              'image_path_ios_tinted_grayscale', (v) => v as String?),
          adaptiveIconForeground:
              $checkedConvert('adaptive_icon_foreground', (v) => v as String?),
          adaptiveIconForegroundInset: $checkedConvert(
              'adaptive_icon_foreground_inset',
              (v) => (v as num?)?.toInt() ?? 16),
          adaptiveIconBackground:
              $checkedConvert('adaptive_icon_background', (v) => v as String?),
          adaptiveIconMonochrome:
              $checkedConvert('adaptive_icon_monochrome', (v) => v as String?),
          minSdkAndroid: $checkedConvert(
              'min_sdk_android',
              (v) =>
                  (v as num?)?.toInt() ??
                  constants.androidDefaultAndroidMinSDK),
          removeAlphaIOS:
              $checkedConvert('remove_alpha_ios', (v) => v as bool? ?? false),
          desaturateTintedToGrayscaleIOS: $checkedConvert(
              'desaturate_tinted_to_grayscale_ios', (v) => v as bool? ?? false),
          backgroundColorIOS: $checkedConvert(
              'background_color_ios', (v) => v as String? ?? '#ffffff'),
          webConfig: $checkedConvert(
              'web', (v) => v == null ? null : WebConfig.fromJson(v as Map)),
          windowsConfig: $checkedConvert('windows',
              (v) => v == null ? null : WindowsConfig.fromJson(v as Map)),
          macOSConfig: $checkedConvert('macos',
              (v) => v == null ? null : MacOSConfig.fromJson(v as Map)),
        );
        return val;
      },
      fieldKeyMap: const {
        'imagePath': 'image_path',
        'imagePathAndroid': 'image_path_android',
        'imagePathIOS': 'image_path_ios',
        'imagePathIOSDarkTransparent': 'image_path_ios_dark_transparent',
        'imagePathIOSTintedGrayscale': 'image_path_ios_tinted_grayscale',
        'adaptiveIconForeground': 'adaptive_icon_foreground',
        'adaptiveIconForegroundInset': 'adaptive_icon_foreground_inset',
        'adaptiveIconBackground': 'adaptive_icon_background',
        'adaptiveIconMonochrome': 'adaptive_icon_monochrome',
        'minSdkAndroid': 'min_sdk_android',
        'removeAlphaIOS': 'remove_alpha_ios',
        'desaturateTintedToGrayscaleIOS': 'desaturate_tinted_to_grayscale_ios',
        'backgroundColorIOS': 'background_color_ios',
        'webConfig': 'web',
        'windowsConfig': 'windows',
        'macOSConfig': 'macos'
      },
    );

Map<String, dynamic> _$ConfigToJson(Config instance) => <String, dynamic>{
      'image_path': instance.imagePath,
      'android': instance.android,
      'ios': instance.ios,
      'image_path_android': instance.imagePathAndroid,
      'image_path_ios': instance.imagePathIOS,
      'image_path_ios_dark_transparent': instance.imagePathIOSDarkTransparent,
      'image_path_ios_tinted_grayscale': instance.imagePathIOSTintedGrayscale,
      'adaptive_icon_foreground': instance.adaptiveIconForeground,
      'adaptive_icon_foreground_inset': instance.adaptiveIconForegroundInset,
      'adaptive_icon_background': instance.adaptiveIconBackground,
      'adaptive_icon_monochrome': instance.adaptiveIconMonochrome,
      'min_sdk_android': instance.minSdkAndroid,
      'remove_alpha_ios': instance.removeAlphaIOS,
      'desaturate_tinted_to_grayscale_ios':
          instance.desaturateTintedToGrayscaleIOS,
      'background_color_ios': instance.backgroundColorIOS,
      'web': instance.webConfig,
      'windows': instance.windowsConfig,
      'macos': instance.macOSConfig,
    };
