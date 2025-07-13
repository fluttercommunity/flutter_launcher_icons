import 'dart:io';

import 'package:flutter_launcher_icons/abs/icon_generator.dart';
import 'package:flutter_launcher_icons/config/config.dart';
import 'package:flutter_launcher_icons/config/linux_config.dart';
import 'package:flutter_launcher_icons/linux/linux_icon_generator.dart';
import 'package:flutter_launcher_icons/logger.dart';
import 'package:test/test.dart';

void main() {
  group('LinuxIconGenerator', () {
    late IconGeneratorContext context;
    late LinuxIconGenerator generator;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('linux_icon_test');

      const config = Config(
        imagePath: 'assets/images/icon.png',
        linuxConfig: LinuxConfig(generate: true),
      );

      context = IconGeneratorContext(
        config: config,
        logger: FLILogger(false),
        prefixPath: tempDir.path,
      );

      generator = LinuxIconGenerator(context);
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('validateRequirements returns false when generate is false', () {
      const config = Config(
        imagePath: 'assets/images/icon.png',
        linuxConfig: LinuxConfig(generate: false),
      );

      final testContext = IconGeneratorContext(
        config: config,
        logger: FLILogger(false),
        prefixPath: tempDir.path,
      );

      final testGenerator = LinuxIconGenerator(testContext);

      expect(testGenerator.validateRequirements(), isFalse);
    });

    test('validateRequirements returns false when no image path provided', () {
      const config = Config(
        linuxConfig: LinuxConfig(generate: true),
      );

      final testContext = IconGeneratorContext(
        config: config,
        logger: FLILogger(false),
        prefixPath: tempDir.path,
      );

      final testGenerator = LinuxIconGenerator(testContext);

      expect(testGenerator.validateRequirements(), isFalse);
    });

    test('validateRequirements returns false when image path is not in assets',
        () {
      const config = Config(
        imagePath: 'images/icon.png', // Not in assets/
        linuxConfig: LinuxConfig(generate: true),
      );

      final testContext = IconGeneratorContext(
        config: config,
        logger: FLILogger(false),
        prefixPath: tempDir.path,
      );

      final testGenerator = LinuxIconGenerator(testContext);

      expect(testGenerator.validateRequirements(), isFalse);
    });

    test(
        'validateRequirements returns false when linux directory does not exist',
        () {
      expect(generator.validateRequirements(), isFalse);
    });

    test('validateRequirements returns true when all requirements are met',
        () async {
      // Create linux directory structure
      final linuxDir = Directory('${tempDir.path}/linux');
      await linuxDir.create();
      final runnerDir = Directory('${tempDir.path}/linux/runner');
      await runnerDir.create();

      // Create my_application.cc file
      final myAppFile = File('${tempDir.path}/linux/runner/my_application.cc');
      await myAppFile.create();

      // Create test icon file in assets
      final assetsDir = Directory('${tempDir.path}/assets/images');
      await assetsDir.create(recursive: true);
      final iconFile = File('${tempDir.path}/assets/images/icon.png');
      await iconFile.writeAsBytes([0]); // dummy data

      expect(generator.validateRequirements(), isTrue);
    });

    test('platform name is Linux', () {
      expect(generator.platformName, equals('Linux'));
    });

    test('createIcons throws exception when icon path is not in assets',
        () async {
      const config = Config(
        imagePath: 'images/icon.png', // Not in assets/
        linuxConfig: LinuxConfig(generate: true),
      );

      final testContext = IconGeneratorContext(
        config: config,
        logger: FLILogger(false),
        prefixPath: tempDir.path,
      );

      final testGenerator = LinuxIconGenerator(testContext);

      expect(
        () => testGenerator.createIcons(),
        throwsA(isA<Exception>()),
      );
    });

    group('my_application.cc modifications', () {
      late File myAppFile;
      late Directory assetsDir;
      late File iconFile;

      setUp(() async {
        // Create linux directory structure
        final linuxDir = Directory('${tempDir.path}/linux');
        await linuxDir.create();
        final runnerDir = Directory('${tempDir.path}/linux/runner');
        await runnerDir.create();

        // Create my_application.cc file
        myAppFile = File('${tempDir.path}/linux/runner/my_application.cc');

        // Create test icon file in assets
        assetsDir = Directory('${tempDir.path}/assets/images');
        await assetsDir.create(recursive: true);
        iconFile = File('${tempDir.path}/assets/images/icon.png');
        await iconFile.writeAsBytes([0]); // dummy data
      });

      test('adds icon line before gtk_window_set_default_size', () async {
        const originalContent = '''
#include "my_application.h"

static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
  
  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));
}
''';

        await myAppFile.writeAsString(originalContent);
        await generator.createIcons();

        final modifiedContent = await myAppFile.readAsString();
        expect(
          modifiedContent,
          contains(
            'gtk_window_set_icon_from_file(window, "assets/images/icon.png", NULL);',
          ),
        );
        expect(
          modifiedContent,
          contains(
            'gtk_window_set_icon_from_file(window, "assets/images/icon.png", NULL);\n  gtk_window_set_default_size(window, 1280, 720);',
          ),
        );
      });

      test('uses fallback location after window declaration for single line',
          () async {
        const originalContent = '''
#include "my_application.h"

static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
  gtk_widget_show(GTK_WIDGET(window));
}
''';

        await myAppFile.writeAsString(originalContent);
        await generator.createIcons();

        final modifiedContent = await myAppFile.readAsString();
        expect(
          modifiedContent,
          contains(
            'gtk_window_set_icon_from_file(window, "assets/images/icon.png", NULL);',
          ),
        );
        // Should be inserted after the window declaration line
        final lines = modifiedContent.split('\n');
        final windowLineIndex =
            lines.indexWhere((line) => line.contains('GtkWindow* window ='));
        final iconLineIndex = lines.indexWhere(
          (line) => line.contains('gtk_window_set_icon_from_file'),
        );
        expect(iconLineIndex, greaterThan(windowLineIndex));
      });

      test('handles multiline window declaration', () async {
        const originalContent = '''
#include "my_application.h"

static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(
          GTK_APPLICATION(application)));
  gtk_widget_show(GTK_WIDGET(window));
}
''';

        await myAppFile.writeAsString(originalContent);
        await generator.createIcons();

        final modifiedContent = await myAppFile.readAsString();
        expect(
          modifiedContent,
          contains(
            'gtk_window_set_icon_from_file(window, "assets/images/icon.png", NULL);',
          ),
        );
        // Should be inserted after the multiline window declaration
        final lines = modifiedContent.split('\n');
        final windowLineIndex =
            lines.indexWhere((line) => line.contains('GtkWindow* window ='));
        final iconLineIndex = lines.indexWhere(
          (line) => line.contains('gtk_window_set_icon_from_file'),
        );
        expect(iconLineIndex, greaterThan(windowLineIndex));
      });

      test('uses custom icon path from linux config', () async {
        const config = Config(
          imagePath: 'assets/images/default.png',
          linuxConfig: LinuxConfig(
            generate: true,
            imagePath: 'assets/icons/custom.png',
          ),
        );

        final testContext = IconGeneratorContext(
          config: config,
          logger: FLILogger(false),
          prefixPath: tempDir.path,
        );

        final testGenerator = LinuxIconGenerator(testContext);

        // Create custom icon file
        final iconsDir = Directory('${tempDir.path}/assets/icons');
        await iconsDir.create(recursive: true);
        final customIconFile = File('${tempDir.path}/assets/icons/custom.png');
        await customIconFile.writeAsBytes([0]);

        const originalContent = '''
#include "my_application.h"

static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));
}
''';

        await myAppFile.writeAsString(originalContent);
        await testGenerator.createIcons();

        final modifiedContent = await myAppFile.readAsString();
        expect(
          modifiedContent,
          contains(
            'gtk_window_set_icon_from_file(window, "assets/icons/custom.png", NULL);',
          ),
        );
      });

      test(
          'does not add duplicate icon line when already present with same path',
          () async {
        const originalContent = '''
#include "my_application.h"

static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
  gtk_window_set_icon_from_file(window, "assets/images/icon.png", NULL);
  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));
}
''';

        await myAppFile.writeAsString(originalContent);
        await generator.createIcons();

        final modifiedContent = await myAppFile.readAsString();
        // Should not add a new icon line
        final iconLines = modifiedContent
            .split('\n')
            .where((line) => line.contains('gtk_window_set_icon_from_file'))
            .toList();
        expect(iconLines.length, equals(1));
        // Should keep the existing icon line unchanged
        expect(
          modifiedContent,
          contains(
            'gtk_window_set_icon_from_file(window, "assets/images/icon.png", NULL);',
          ),
        );
      });

      test('updates existing icon line when path is different', () async {
        const originalContent = '''
#include "my_application.h"

static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
  gtk_window_set_icon_from_file(window, "assets/images/old_icon.png", NULL);
  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));
}
''';

        await myAppFile.writeAsString(originalContent);
        await generator.createIcons();

        final modifiedContent = await myAppFile.readAsString();
        // Should update the existing icon line
        final iconLines = modifiedContent
            .split('\n')
            .where((line) => line.contains('gtk_window_set_icon_from_file'))
            .toList();
        expect(iconLines.length, equals(1));
        // Should have the new icon path
        expect(
          modifiedContent,
          contains(
            'gtk_window_set_icon_from_file(window, "assets/images/icon.png", NULL);',
          ),
        );
        // Should not contain the old icon path
        expect(modifiedContent, isNot(contains('old_icon.png')));
      });

      test('handles multi-line icon configuration with weird formatting',
          () async {
        const originalContent = '''
#include "my_application.h"

static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
  gtk_window_set_icon_from_file(window,
                               "assets/images/old_icon.png",
                               NULL);
  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));
}
''';

        await myAppFile.writeAsString(originalContent);
        await generator.createIcons();

        final modifiedContent = await myAppFile.readAsString();
        // Should update the multi-line icon configuration
        final iconLines = modifiedContent
            .split('\n')
            .where((line) => line.contains('gtk_window_set_icon_from_file'))
            .toList();
        expect(iconLines.length, equals(1));
        // Should have the new icon path in a clean single line
        expect(
          modifiedContent,
          contains(
            'gtk_window_set_icon_from_file(window, "assets/images/icon.png", NULL);',
          ),
        );
        // Should not contain the old icon path
        expect(modifiedContent, isNot(contains('old_icon.png')));
      });

      test('handles icon configuration with extra whitespace and formatting',
          () async {
        const originalContent = '''
#include "my_application.h"

static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
    gtk_window_set_icon_from_file(  window  ,  "assets/images/old_icon.png"  ,  NULL  );
  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));
}
''';

        await myAppFile.writeAsString(originalContent);
        await generator.createIcons();

        final modifiedContent = await myAppFile.readAsString();
        // Should update the icon configuration regardless of whitespace
        final iconLines = modifiedContent
            .split('\n')
            .where((line) => line.contains('gtk_window_set_icon_from_file'))
            .toList();
        expect(iconLines.length, equals(1));
        // Should have the new icon path
        expect(
          modifiedContent,
          contains(
            'gtk_window_set_icon_from_file(window, "assets/images/icon.png", NULL);',
          ),
        );
        // Should not contain the old icon path
        expect(modifiedContent, isNot(contains('old_icon.png')));
      });

      test('uses fallback strategy 3: inserts before gtk_window_show',
          () async {
        const originalContent = '''
#include "my_application.h"

static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
  gtk_window_show(window);
}
''';

        await myAppFile.writeAsString(originalContent);
        await generator.createIcons();

        final modifiedContent = await myAppFile.readAsString();
        expect(
          modifiedContent,
          contains(
            'gtk_window_set_icon_from_file(window, "assets/images/icon.png", NULL);',
          ),
        );
        // Should be inserted before gtk_window_show
        final lines = modifiedContent.split('\n');
        final iconLineIndex = lines.indexWhere(
          (line) => line.contains('gtk_window_set_icon_from_file'),
        );
        final showLineIndex =
            lines.indexWhere((line) => line.contains('gtk_window_show'));
        expect(iconLineIndex, lessThan(showLineIndex));
      });

      test('uses fallback strategy 3: inserts before gtk_widget_show',
          () async {
        const originalContent = '''
#include "my_application.h"

static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
  gtk_widget_show(GTK_WIDGET(window));
}
''';

        await myAppFile.writeAsString(originalContent);
        await generator.createIcons();

        final modifiedContent = await myAppFile.readAsString();
        expect(
          modifiedContent,
          contains(
            'gtk_window_set_icon_from_file(window, "assets/images/icon.png", NULL);',
          ),
        );
        // Should be inserted before gtk_widget_show
        final lines = modifiedContent.split('\n');
        final iconLineIndex = lines.indexWhere(
          (line) => line.contains('gtk_window_set_icon_from_file'),
        );
        final showLineIndex =
            lines.indexWhere((line) => line.contains('gtk_widget_show'));
        expect(iconLineIndex, lessThan(showLineIndex));
      });

      test('uses fallback strategy 4: inserts after any gtk_window function',
          () async {
        const originalContent = '''
#include "my_application.h"

static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  // window is passed as parameter, so no window declaration to trigger strategy 2
  gtk_window_set_title(window, "My App");
  // No other gtk_window functions that would trigger earlier strategies
}
''';

        await myAppFile.writeAsString(originalContent);
        await generator.createIcons();

        final modifiedContent = await myAppFile.readAsString();
        expect(
          modifiedContent,
          contains(
            'gtk_window_set_icon_from_file(window, "assets/images/icon.png", NULL);',
          ),
        );
        // Should be inserted after gtk_window_set_title
        final lines = modifiedContent.split('\n');
        final titleLineIndex =
            lines.indexWhere((line) => line.contains('gtk_window_set_title'));
        final iconLineIndex = lines.indexWhere(
          (line) => line.contains('gtk_window_set_icon_from_file'),
        );
        expect(iconLineIndex, greaterThan(titleLineIndex));
      });

      test('preserves indentation from surrounding code', () async {
        const originalContent = '''
#include "my_application.h"

static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
    GtkWindow* window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
    gtk_window_set_default_size(window, 1280, 720);
    gtk_widget_show(GTK_WIDGET(window));
}
''';

        await myAppFile.writeAsString(originalContent);
        await generator.createIcons();

        final modifiedContent = await myAppFile.readAsString();
        // Should preserve the 4-space indentation from the surrounding code
        expect(
          modifiedContent,
          contains(
            '    gtk_window_set_icon_from_file(window, "assets/images/icon.png", NULL);',
          ),
        );
      });

      test('handles window declaration with different pointer syntax',
          () async {
        const originalContent = '''
#include "my_application.h"

static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow *window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
  gtk_widget_show(GTK_WIDGET(window));
}
''';

        await myAppFile.writeAsString(originalContent);
        await generator.createIcons();

        final modifiedContent = await myAppFile.readAsString();
        expect(
          modifiedContent,
          contains(
            'gtk_window_set_icon_from_file(window, "assets/images/icon.png", NULL);',
          ),
        );
        // Should be inserted after the window declaration
        final lines = modifiedContent.split('\n');
        final windowLineIndex =
            lines.indexWhere((line) => line.contains('GtkWindow *window ='));
        final iconLineIndex = lines.indexWhere(
          (line) => line.contains('gtk_window_set_icon_from_file'),
        );
        expect(iconLineIndex, greaterThan(windowLineIndex));
      });

      test(
          'handles complex multi-line window declaration with multiple GTK calls',
          () async {
        const originalContent = '''
#include "my_application.h"

static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(
          gtk_application_window_new(
              GTK_APPLICATION(application)));
  gtk_widget_show(GTK_WIDGET(window));
}
''';

        await myAppFile.writeAsString(originalContent);
        await generator.createIcons();

        final modifiedContent = await myAppFile.readAsString();
        expect(
          modifiedContent,
          contains(
            'gtk_window_set_icon_from_file(window, "assets/images/icon.png", NULL);',
          ),
        );
        // Should be inserted after the complete window declaration
        final lines = modifiedContent.split('\n');
        final windowLineIndex =
            lines.indexWhere((line) => line.contains('GtkWindow* window ='));
        final iconLineIndex = lines.indexWhere(
          (line) => line.contains('gtk_window_set_icon_from_file'),
        );
        expect(iconLineIndex, greaterThan(windowLineIndex));
        // Should be before the show call
        final showLineIndex =
            lines.indexWhere((line) => line.contains('gtk_widget_show'));
        expect(iconLineIndex, lessThan(showLineIndex));
      });

      test('provides helpful error message when no insertion point found',
          () async {
        const originalContent = '''
#include "my_application.h"

static void my_application_activate(GApplication* application) {
  // Some other content without the expected patterns
  g_print("Hello World\\n");
}
''';

        await myAppFile.writeAsString(originalContent);

        try {
          await generator.createIcons();
          fail('Expected an exception to be thrown');
        } catch (e) {
          expect(e.toString(), contains('Failed to update my_application.cc'));
          // The error message should contain the manual instruction
          expect(
            e.toString(),
            contains(
              'gtk_window_set_icon_from_file(window, "assets/images/icon.png", NULL);',
            ),
          );
        }
      });

      test('handles deeply nested statements with proper detection', () async {
        const originalContent = '''
#include "my_application.h"

static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
  
  if (some_condition) {
    gtk_window_set_icon_from_file(
        window,
        "assets/images/nested_icon.png",
        NULL
    );
  }
  
  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));
}
''';

        await myAppFile.writeAsString(originalContent);
        await generator.createIcons();

        final modifiedContent = await myAppFile.readAsString();
        // Should update the nested icon configuration
        final iconLines = modifiedContent
            .split('\n')
            .where((line) => line.contains('gtk_window_set_icon_from_file'))
            .toList();
        expect(iconLines.length, equals(1));
        // Should have the new icon path
        expect(
          modifiedContent,
          contains(
            'gtk_window_set_icon_from_file(window, "assets/images/icon.png", NULL);',
          ),
        );
        // Should not contain the old icon path
        expect(modifiedContent, isNot(contains('nested_icon.png')));
      });
    });
  });
}
