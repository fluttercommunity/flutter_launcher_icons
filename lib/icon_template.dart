import 'dart:io';
import 'package:image/image.dart';
import 'utils.dart';

class IconTemplate {
  IconTemplate({ this.size, this.name, this.location });

  final String name;
  final int size;
  final String location;

  Image createFrom(Image image) {
    return createResizedImage(size, image);
  }

  void updateFile(Image image, { String location = '', String prefix = '' }) {
    final Image newLauncher = createFrom(image);
    location = location ?? this.location;

    File(location + prefix + name)
        .create(recursive: true)
        .then((File file) {
      file.writeAsBytesSync(encodePng(newLauncher));
    });
  }
}

class IconTemplateGenerator {
  IconTemplateGenerator({ this.defaultLocation, this.defaultSuffix = '' });

  final String defaultLocation;
  final String defaultSuffix;

  IconTemplate get({ int size, String name, String location, String suffix }) {
    location = location ?? defaultLocation;
    suffix = suffix ?? defaultSuffix;

    return IconTemplate(size: size, name: name + suffix, location: location);
  }
}