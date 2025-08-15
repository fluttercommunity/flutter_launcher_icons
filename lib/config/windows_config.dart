import 'package:json_annotation/json_annotation.dart';

part 'windows_config.g.dart';

/// The flutter_launcher_icons configuration set for Windows
@JsonSerializable(
  anyMap: true,
  checked: true,
)
class WindowsConfig {
  /// Specifies whether to generate icons for Windows
  final bool generate;

  /// Image path for Windows
  @JsonKey(name: 'image_path')
  final String? imagePath;

  /// DEPRECATED: kept only for backward-compat. Ignored by the generator.
  @Deprecated(
    'Ignored. Windows .ico is generated with multiple sizes by default.',
  )
  @JsonKey(name: 'icon_size')
  final int? iconSize;

  /// Creates a instance of [WindowsConfig]
  const WindowsConfig({
    this.generate = false,
    this.imagePath,
    @Deprecated(
      'Ignored. Windows .ico is generated with multiple sizes by default.',
    )
    this.iconSize,
  });

  /// Creates [WindowsConfig] from [json]
  factory WindowsConfig.fromJson(Map json) => _$WindowsConfigFromJson(json);

  /// Creates [Map] from [WindowsConfig]
  Map toJson() => _$WindowsConfigToJson(this);

  @override
  String toString() => 'WindowsConfig: ${toJson()}';
}
