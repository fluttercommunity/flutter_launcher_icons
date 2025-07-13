// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linux_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinuxConfig _$LinuxConfigFromJson(Map json) => $checkedCreate(
      'LinuxConfig',
      json,
      ($checkedConvert) {
        final val = LinuxConfig(
          generate: $checkedConvert('generate', (v) => v as bool? ?? false),
          imagePath: $checkedConvert('image_path', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {'imagePath': 'image_path'},
    );

Map<String, dynamic> _$LinuxConfigToJson(LinuxConfig instance) =>
    <String, dynamic>{
      'generate': instance.generate,
      'image_path': instance.imagePath,
    };
