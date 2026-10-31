import 'dart:convert';
import 'dart:io';

import 'package:flutter_launcher_icons/abs/icon_generator.dart';
import 'package:flutter_launcher_icons/config/config.dart';
import 'package:flutter_launcher_icons/logger.dart';
import 'package:flutter_launcher_icons/watch.dart';
import 'package:image/image.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  group('WatchIconGenerator', () {
    late String projectPath;
    late String iconSetPath;

    setUp(() async {
      projectPath = path.join(d.sandbox, 'watch-project');
      iconSetPath = path.join(
        projectPath,
        'ios',
        'Runner Watch App',
        'Assets.xcassets',
        'AppIcon.appiconset',
      );
      await Directory(iconSetPath).create(recursive: true);

      final sourceImage = encodePng(Image(width: 64, height: 64));
      final sourceFile = File(path.join(projectPath, 'watch.png'));
      await sourceFile.create(recursive: true);
      await sourceFile.writeAsBytes(sourceImage);

      await File(path.join(iconSetPath, 'Contents.json')).writeAsString(
        jsonEncode(<String, dynamic>{
          'images': <Map<String, dynamic>>[
            <String, dynamic>{
              'filename': 'iOS-Icon.png',
              'idiom': 'iphone',
              'scale': '2x',
              'size': '60x60',
            },
            <String, dynamic>{
              'filename': 'old-watch-icon.png',
              'idiom': 'watch',
              'scale': '2x',
              'size': '40x40',
            },
          ],
          'info': <String, dynamic>{'author': 'xcode', 'version': 1},
        }),
      );
    });

    test('generates watchOS icon sizes and preserves other idioms', () async {
      final generator = _createGenerator(projectPath);

      expect(generator.validateRequirements(), isTrue);
      await generator.createIcons();

      final contents = jsonDecode(
        await File(path.join(iconSetPath, 'Contents.json')).readAsString(),
      ) as Map<String, dynamic>;
      final images = contents['images'] as List<dynamic>;
      final watchImages = images.where(_isWatchIcon).toList();

      expect(watchImages, hasLength(17));
      expect(images.where((image) => image['idiom'] == 'iphone'), hasLength(1));
      expect(
        watchImages.where((image) => image['idiom'] == 'watch-marketing'),
        hasLength(1),
      );

      for (final image in watchImages) {
        final imageConfig = image as Map<String, dynamic>;
        final fileName = imageConfig['filename'] as String;
        final file = File(path.join(iconSetPath, fileName));
        expect(file.existsSync(), isTrue);

        final size = (imageConfig['size'] as String).split('x').first;
        final scale = (imageConfig['scale'] as String).replaceAll('x', '');
        final expectedPixels =
            (double.parse(size) * double.parse(scale)).round();
        final generatedImage = decodeImage(await file.readAsBytes());
        expect(generatedImage?.width, expectedPixels);
        expect(generatedImage?.height, expectedPixels);
      }
    });
  });
}

WatchIconGenerator _createGenerator(String prefixPath) {
  return WatchIconGenerator(
    IconGeneratorContext(
      config: const Config(watchImagePath: 'watch.png'),
      logger: FLILogger(false),
      prefixPath: prefixPath,
    ),
  );
}

bool _isWatchIcon(dynamic image) =>
    image['idiom'] == 'watch' || image['idiom'] == 'watch-marketing';
