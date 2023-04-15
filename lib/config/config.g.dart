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
          adaptiveIconForeground:
              $checkedConvert('adaptive_icon_foreground', (v) => v as String?),
          adaptiveIconBackground:
              $checkedConvert('adaptive_icon_background', (v) => v as String?),
          minSdkAndroid: $checkedConvert('min_sdk_android',
              (v) => v as int? ?? constants.androidDefaultAndroidMinSDK),
          removeAlphaIOS:
              $checkedConvert('remove_alpha_ios', (v) => v as bool? ?? false),
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
        'adaptiveIconForeground': 'adaptive_icon_foreground',
        'adaptiveIconBackground': 'adaptive_icon_background',
        'minSdkAndroid': 'min_sdk_android',
        'removeAlphaIOS': 'remove_alpha_ios',
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
      'adaptive_icon_foreground': instance.adaptiveIconForeground,
      'adaptive_icon_background': instance.adaptiveIconBackground,
      'min_sdk_android': instance.minSdkAndroid,
      'remove_alpha_ios': instance.removeAlphaIOS,
      'web': instance.webConfig,
      'windows': instance.windowsConfig,
      'macos': instance.macOSConfig,
    };
