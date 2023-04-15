import 'dart:io';

import 'package:flutter_launcher_icons/abs/icon_generator.dart';
import 'package:flutter_launcher_icons/config/config.dart';
import 'package:flutter_launcher_icons/config/macos_config.dart';
import 'package:flutter_launcher_icons/logger.dart';
import 'package:flutter_launcher_icons/macos/macos_icon_generator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../templates.dart' as templates;

@GenerateNiceMocks([
  MockSpec<Config>(),
  MockSpec<MacOSConfig>(),
  MockSpec<FLILogger>(),
])
import 'macos_icon_generator_test.mocks.dart';

void main() {
  group('MacOSIconGenerator', () {
    late IconGeneratorContext context;
    late IconGenerator generator;
    late Config mockConfig;
    late MacOSConfig mockMacOSConfig;
    late String prefixPath;
    late File testImageFile;
    late MockFLILogger mockLogger;
    final assetPath = path.join(Directory.current.path, 'test', 'assets');

    group('#validateRequirments', () {
      setUpAll(() {
        testImageFile = File(path.join(assetPath, 'app_icon.png'));
        expect(testImageFile.existsSync(), isTrue);
      });
      setUp(() {
        prefixPath = path.join(d.sandbox, 'fli_test');
        mockConfig = MockConfig();
        mockMacOSConfig = MockMacOSConfig();
        mockLogger = MockFLILogger();
        context = IconGeneratorContext(
          config: mockConfig,
          prefixPath: prefixPath,
          logger: mockLogger,
        );
        generator = MacOSIconGenerator(context);

        // initilize mock defaults
        when(mockLogger.error(argThat(anything))).thenReturn(anything);
        when(mockLogger.verbose(argThat(anything))).thenReturn(anything);
        when(mockLogger.isVerbose).thenReturn(false);
        when(mockConfig.macOSConfig).thenReturn(mockMacOSConfig);
        when(mockMacOSConfig.generate).thenReturn(true);
        when(mockMacOSConfig.imagePath)
            .thenReturn(path.join(prefixPath, 'app_icon.png'));
        when(mockConfig.imagePath)
            .thenReturn(path.join(prefixPath, 'app_icon.png'));
      });

      test('should return false when macos config is not provided', () {
        when(mockConfig.macOSConfig).thenReturn(null);
        expect(generator.validateRequirements(), isFalse);
        verify(mockConfig.macOSConfig).called(equals(1));
      });

      test(
          'should return false when macosConfig is not null but macos.generate is false',
          () {
        when(mockConfig.macOSConfig).thenReturn(mockMacOSConfig);
        when(mockMacOSConfig.generate).thenReturn(false);
        expect(generator.validateRequirements(), isFalse);
        verify(mockConfig.macOSConfig).called(equals(1));
        verify(mockMacOSConfig.generate).called(equals(1));
      });

      test('should return false when macos.image_path and imagePath is null',
          () {
        when(mockMacOSConfig.imagePath).thenReturn(null);
        when(mockConfig.imagePath).thenReturn(null);
        expect(generator.validateRequirements(), isFalse);

        verifyInOrder([
          mockMacOSConfig.imagePath,
          mockConfig.imagePath,
        ]);
      });

      test('should return false when macos dir does not exist', () async {
        await d.dir('fli_test', [
          d.file('app_icon.png', testImageFile.readAsBytesSync()),
        ]).create();
        await expectLater(
          d.dir('fli_test', [
            d.file('app_icon.png', anything),
          ]).validate(),
          completes,
        );
        expect(generator.validateRequirements(), isFalse);
      });

      test('should return false when image file does not exist', () async {
        await d.dir('fli_test', [d.dir('macos')]).create();
        await expectLater(
          d.dir('fli_test', [d.dir('macos')]).validate(),
          completes,
        );
        expect(generator.validateRequirements(), isFalse);
      });
    });
  });

  group('MacOSIconGenerator end-to-end', () {
    late IconGeneratorContext context;
    late IconGenerator generator;
    late Config config;
    late String prefixPath;
    final assetPath = path.join(Directory.current.path, 'test', 'assets');

    setUp(() async {
      final imageFile = File(path.join(assetPath, 'app_icon.png'));
      expect(imageFile.existsSync(), isTrue);
      await d.dir('fli_test', [
        d.dir('macos/Runner/Assets.xcassets/AppIcon.appiconset', [
          d.file('Contents.json', templates.macOSContentsJsonFile),
        ]),
        d.file('flutter_launcher_icons.yaml', templates.fliConfigTemplate),
        d.file('app_icon.png', imageFile.readAsBytesSync()),
      ]).create();
      prefixPath = path.join(d.sandbox, 'fli_test');
      config = Config.loadConfigFromPath(
        'flutter_launcher_icons.yaml',
        prefixPath,
      )!;
      context = IconGeneratorContext(
        config: config,
        prefixPath: prefixPath,
        logger: FLILogger(false),
      );
      generator = MacOSIconGenerator(context);
    });

    test('should generate valid icons & contents.json file', () async {
      expect(generator.validateRequirements(), isTrue);
      expect(() => generator.createIcons(), isNot(throwsException));

      await expectLater(
        d.dir('fli_test', [
          d.dir('macos/Runner/Assets.xcassets/AppIcon.appiconset', [
            d.file('app_icon_1024.png', anything),
            d.file('app_icon_16.png', anything),
            d.file('app_icon_32.png', anything),
            d.file('app_icon_64.png', anything),
            d.file('app_icon_128.png', anything),
            d.file('app_icon_256.png', anything),
            d.file('app_icon_512.png', anything),
          ]),
        ]).validate(),
        completes,
        reason: 'All icon files are not generated',
      );

      await expectLater(
        d.dir('fli_test', [
          d.dir('macos/Runner/Assets.xcassets/AppIcon.appiconset', [
            d.file('Contents.json', equals(templates.macOSContentsJsonFile)),
          ]),
        ]).validate(),
        completes,
        reason: 'Contents.json file contents are not equal',
      );
    });
  });
}
