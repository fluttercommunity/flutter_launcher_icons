import 'dart:io';
import 'package:image/image.dart';
import 'utils.dart';

class IconTemplate {
  IconTemplate({required this.size, required this.baseName, required this.suffix, required this.location});

  final String baseName;
  final String suffix;
  final int size;
  final String location;

  String get name {
    return baseName + suffix;
  }

  Image createFrom(Image image) {
    return createResizedImage(size, image);
  }

  /// Write to a file based on the provided image, optionally overriding
  /// [this.location] with [location] and [this.name] with either [prefix + this.name]
  /// or [prefix + name].
  void updateFile(Image image,
      {String? location, String? name, String prefix = ''}) {
    final Image newLauncher = createFrom(image);
    location = location ?? this.location;
    name = name ?? this.name;

    File(location + prefix + name).create(recursive: true).then((File file) {
      file.writeAsBytesSync(encodePng(newLauncher));
    });
  }
}

class IconTemplateGenerator {
  IconTemplateGenerator({required this.defaultLocation, this.defaultSuffix = ''});

  final String defaultLocation;
  final String defaultSuffix;

  IconTemplate get({required int size, required String name, String? location, String? suffix}) {
    location = location ?? defaultLocation;
    suffix = suffix ?? defaultSuffix;

    return IconTemplate(size: size, baseName: name, suffix: suffix, location: location);
  }
}
