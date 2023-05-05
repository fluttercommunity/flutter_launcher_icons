// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'windows_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WindowsConfig _$WindowsConfigFromJson(Map json) => $checkedCreate(
      'WindowsConfig',
      json,
      ($checkedConvert) {
        final val = WindowsConfig(
          generate: $checkedConvert('generate', (v) => v as bool? ?? false),
          imagePath: $checkedConvert('image_path', (v) => v as String?),
          iconSize: $checkedConvert('icon_size', (v) => v as int?),
        );
        return val;
      },
      fieldKeyMap: const {'imagePath': 'image_path', 'iconSize': 'icon_size'},
    );

Map<String, dynamic> _$WindowsConfigToJson(WindowsConfig instance) =>
    <String, dynamic>{
      'generate': instance.generate,
      'image_path': instance.imagePath,
      'icon_size': instance.iconSize,
    };
