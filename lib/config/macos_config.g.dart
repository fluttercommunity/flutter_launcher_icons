// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'macos_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MacOSConfig _$MacOSConfigFromJson(Map json) => $checkedCreate(
      'MacOSConfig',
      json,
      ($checkedConvert) {
        final val = MacOSConfig(
          generate: $checkedConvert('generate', (v) => v as bool? ?? false),
          imagePath: $checkedConvert('image_path', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {'imagePath': 'image_path'},
    );

Map<String, dynamic> _$MacOSConfigToJson(MacOSConfig instance) =>
    <String, dynamic>{
      'generate': instance.generate,
      'image_path': instance.imagePath,
    };
