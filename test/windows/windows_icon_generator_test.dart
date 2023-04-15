import 'dart:io';

import 'package:flutter_launcher_icons/abs/icon_generator.dart';
import 'package:flutter_launcher_icons/config/config.dart';
import 'package:flutter_launcher_icons/config/windows_config.dart';
import 'package:flutter_launcher_icons/logger.dart';
import 'package:flutter_launcher_icons/windows/windows_icon_generator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../templates.dart' as templates;
import 'windows_icon_generator_test.mocks.dart';

@GenerateMocks([Config, WindowsConfig, FLILogger])
void main() {
  group('WindowsIconGenerator', () {
    late IconGeneratorContext context;
    late IconGenerator generator;
    late Config mockConfig;
    late WindowsConfig mockWindowsConfig;
    late String prefixPath;
    late File testImageFile;
    late MockFLILogger mockLogger;
    final assetPath = path.join(Directory.current.path, 'test', 'assets');

    group('#validateRequirments', () {
      setUpAll(() {
        // make sure test file exists before starting test
        testImageFile = File(path.join(assetPath, 'app_icon.png'));
        expect(testImageFile.existsSync(), isTrue);
      });
      setUp(() async {
        prefixPath = path.join(d.sandbox, 'fli_test');
        mockConfig = MockConfig();
        mockWindowsConfig = MockWindowsConfig();
        mockLogger = MockFLILogger();
        context = IconGeneratorContext(
          config: mockConfig,
          prefixPath: prefixPath,
          logger: mockLogger,
        );
        generator = WindowsIconGenerator(context);
        // initilize mock defaults
        when(mockLogger.error(argThat(anything))).thenReturn(anything);
        when(mockLogger.verbose(argThat(anything))).thenReturn(anything);
        when(mockLogger.isVerbose).thenReturn(false);
        when(mockConfig.windowsConfig).thenReturn(mockWindowsConfig);
        when(mockWindowsConfig.generate).thenReturn(true);
        when(mockWindowsConfig.imagePath)
            .thenReturn(path.join(prefixPath, 'app_icon.png'));
        when(mockConfig.imagePath)
            .thenReturn(path.join(prefixPath, 'app_icon.png'));
        when(mockWindowsConfig.iconSize).thenReturn(48);
      });

      test('should return false when windows config is not provided', () {
        when(mockConfig.windowsConfig).thenReturn(null);
        expect(generator.validateRequirements(), isFalse);
        verify(mockConfig.windowsConfig).called(equals(1));
      });

      test(
          'should return false when windowsConfig is not null but windows.generate is false',
          () {
        when(mockConfig.windowsConfig).thenReturn(mockWindowsConfig);
        when(mockWindowsConfig.generate).thenReturn(false);
        expect(generator.validateRequirements(), isFalse);
        verify(mockConfig.windowsConfig).called(equals(1));
        verify(mockWindowsConfig.generate).called(equals(1));
      });

      test('should return false when windows.image_path and imagePath is null',
          () {
        when(mockWindowsConfig.imagePath).thenReturn(null);
        when(mockConfig.imagePath).thenReturn(null);
        expect(generator.validateRequirements(), isFalse);

        verifyInOrder([
          mockWindowsConfig.imagePath,
          mockConfig.imagePath,
        ]);
      });

      test(
          'should return false when windows.icon_size is not between 48 and 256',
          () {
        when(mockWindowsConfig.iconSize).thenReturn(40);
        expect(generator.validateRequirements(), isFalse);
        verify(mockWindowsConfig.iconSize).called(equals(3));

        when(mockWindowsConfig.iconSize).thenReturn(257);
        expect(generator.validateRequirements(), isFalse);
        verify(mockWindowsConfig.iconSize).called(equals(4));
      });

      test('should return false when windows dir does not exist', () async {
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
        await d.dir('fli_test', [d.dir('windows')]).create();
        await expectLater(
          d.dir('fli_test', [d.dir('windows')]).validate(),
          completes,
        );
        expect(generator.validateRequirements(), isFalse);
      });
    });
  });

  group('WindowsIconGenerator end-to-end', () {
    late IconGeneratorContext context;
    late IconGenerator generator;
    late Config config;
    late String prefixPath;
    final assetPath = path.join(Directory.current.path, 'test', 'assets');

    setUp(() async {
      final imageFile = File(path.join(assetPath, 'app_icon.png'));
      expect(imageFile.existsSync(), isTrue);
      await d.dir('fli_test', [
        d.dir('windows'),
        d.file('flutter_launcher_icons.yaml', templates.fliWindowsConfig),
        d.file('pubspec.yaml', templates.pubspecTemplate),
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
      generator = WindowsIconGenerator(context);
    });

    test('should generate valid icons', () async {
      expect(generator.validateRequirements(), isTrue);
      generator.createIcons();
      await expectLater(
        d.dir('fli_test', [
          d.dir('windows', [
            d.dir('runner', [
              d.dir('resources', [
                d.file('app_icon.ico', anything),
              ]),
            ]),
          ]),
        ]).validate(),
        completes,
      );
    });
  });
}
