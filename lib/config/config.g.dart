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
          imagePathIOSLiquidGlassIcon: $checkedConvert(
              'image_path_ios_liquid_glass_icon', (v) => v as String?),
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
          removeLiquidGlassIOS: $checkedConvert(
              'remove_liquid_glass_ios', (v) => v as bool? ?? false),
          desaturateTintedToGrayscaleIOS: $checkedConvert(
              'desaturate_tinted_to_grayscale_ios', (v) => v as bool? ?? false),
          backgroundColorIOS: $checkedConvert(
              'background_color_ios', (v) => v as String? ?? '#ffffff'),
          liquidGlassIconScaleIOS: $checkedConvert(
              'liquid_glass_icon_scale', (v) => (v as num?)?.toDouble() ?? 1),
          liquidGlassTranslucencyIOS: $checkedConvert(
              'liquid_glass_translucency_ios',
              (v) => (v as num?)?.toDouble() ?? 0.5),
          liquidGlassSpecularIOS: $checkedConvert(
              'liquid_glass_specular_ios', (v) => v as bool? ?? true),
          liquidGlassShadowKindIOS: $checkedConvert(
              'liquid_glass_shadow_kind_ios', (v) => v as String? ?? 'Neutral'),
          liquidGlassShadowOpacityIOS: $checkedConvert(
              'liquid_glass_shadow_opacity_ios',
              (v) => (v as num?)?.toDouble() ?? 0.5),
          liquidGlassBlurIOS: $checkedConvert(
              'liquid_glass_blur_ios', (v) => (v as num?)?.toDouble() ?? 0.5),
          liquidGlassOffsetXIOS: $checkedConvert('liquid_glass_offset_x_ios',
              (v) => (v as num?)?.toDouble() ?? 0.0),
          liquidGlassOffsetYIOS: $checkedConvert('liquid_glass_offset_y_ios',
              (v) => (v as num?)?.toDouble() ?? 0.0),
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
        'imagePathIOSLiquidGlassIcon': 'image_path_ios_liquid_glass_icon',
        'adaptiveIconForeground': 'adaptive_icon_foreground',
        'adaptiveIconForegroundInset': 'adaptive_icon_foreground_inset',
        'adaptiveIconBackground': 'adaptive_icon_background',
        'adaptiveIconMonochrome': 'adaptive_icon_monochrome',
        'minSdkAndroid': 'min_sdk_android',
        'removeAlphaIOS': 'remove_alpha_ios',
        'removeLiquidGlassIOS': 'remove_liquid_glass_ios',
        'desaturateTintedToGrayscaleIOS': 'desaturate_tinted_to_grayscale_ios',
        'backgroundColorIOS': 'background_color_ios',
        'liquidGlassIconScaleIOS': 'liquid_glass_icon_scale',
        'liquidGlassTranslucencyIOS': 'liquid_glass_translucency_ios',
        'liquidGlassSpecularIOS': 'liquid_glass_specular_ios',
        'liquidGlassShadowKindIOS': 'liquid_glass_shadow_kind_ios',
        'liquidGlassShadowOpacityIOS': 'liquid_glass_shadow_opacity_ios',
        'liquidGlassBlurIOS': 'liquid_glass_blur_ios',
        'liquidGlassOffsetXIOS': 'liquid_glass_offset_x_ios',
        'liquidGlassOffsetYIOS': 'liquid_glass_offset_y_ios',
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
      'image_path_ios_liquid_glass_icon': instance.imagePathIOSLiquidGlassIcon,
      'adaptive_icon_foreground': instance.adaptiveIconForeground,
      'adaptive_icon_foreground_inset': instance.adaptiveIconForegroundInset,
      'adaptive_icon_background': instance.adaptiveIconBackground,
      'adaptive_icon_monochrome': instance.adaptiveIconMonochrome,
      'min_sdk_android': instance.minSdkAndroid,
      'remove_alpha_ios': instance.removeAlphaIOS,
      'remove_liquid_glass_ios': instance.removeLiquidGlassIOS,
      'desaturate_tinted_to_grayscale_ios':
          instance.desaturateTintedToGrayscaleIOS,
      'background_color_ios': instance.backgroundColorIOS,
      'liquid_glass_icon_scale': instance.liquidGlassIconScaleIOS,
      'liquid_glass_translucency_ios': instance.liquidGlassTranslucencyIOS,
      'liquid_glass_specular_ios': instance.liquidGlassSpecularIOS,
      'liquid_glass_shadow_kind_ios': instance.liquidGlassShadowKindIOS,
      'liquid_glass_shadow_opacity_ios': instance.liquidGlassShadowOpacityIOS,
      'liquid_glass_blur_ios': instance.liquidGlassBlurIOS,
      'liquid_glass_offset_x_ios': instance.liquidGlassOffsetXIOS,
      'liquid_glass_offset_y_ios': instance.liquidGlassOffsetYIOS,
      'web': instance.webConfig,
      'windows': instance.windowsConfig,
      'macos': instance.macOSConfig,
    };
