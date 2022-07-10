import 'package:flutter_launcher_icons/abs/icon_generator.dart';
import 'package:flutter_launcher_icons/flutter_launcher_icons_config.dart';
import 'package:flutter_launcher_icons/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'icon_generator_test.mocks.dart';

@GenerateMocks([FlutterLauncherIconsConfig, IconGenerator])
void main() {
  group('#generateIconsFor', () {
    late String prefixPath;
    late FLILogger logger;
    late IconGenerator mockGenerator;
    late FlutterLauncherIconsConfig mockFLIConfig;
    setUp(() async {
      prefixPath = path.join(d.sandbox, 'fli_test');
      mockFLIConfig = MockFlutterLauncherIconsConfig();
      logger = FLILogger(false);
      mockGenerator = MockIconGenerator();
      when(mockGenerator.platformName).thenReturn('Mock');
      when(mockGenerator.context).thenReturn(IconGeneratorContext(
        config: mockFLIConfig,
        prefixPath: prefixPath,
        logger: logger,
      ));
    });
    test('should execute createIcons() when validateRequiremnts() returns true', () {
      when(mockGenerator.validateRequirments()).thenReturn(true);
      generateIconsFor(
        config: mockFLIConfig,
        flavor: null,
        prefixPath: prefixPath,
        logger: logger,
        platforms: (context) => [mockGenerator],
      );
      verify(mockGenerator.validateRequirments()).called(equals(1));
      verify(mockGenerator.createIcons()).called(equals(1));
    });

    test('should not execute createIcons() when validateRequiremnts() returns false', () {
      when(mockGenerator.validateRequirments()).thenReturn(false);
      generateIconsFor(
        config: mockFLIConfig,
        flavor: null,
        prefixPath: prefixPath,
        logger: logger,
        platforms: (context) => [mockGenerator],
      );
      verify(mockGenerator.validateRequirments()).called(equals(1));
      verifyNever(mockGenerator.createIcons());
    });

    test('should skip platform if any exception occured', () {
      when(mockGenerator.validateRequirments()).thenReturn(true);
      when(mockGenerator.createIcons()).thenThrow(Exception('should-skip-platform'));
      generateIconsFor(
        config: mockFLIConfig,
        flavor: null,
        prefixPath: prefixPath,
        logger: logger,
        platforms: (context) => [mockGenerator],
      );
      verify(mockGenerator.validateRequirments()).called(equals(1));
      verify(mockGenerator.createIcons()).called(equals(1));
      expect(() => mockGenerator.createIcons(), throwsException);
    });
  });
}
