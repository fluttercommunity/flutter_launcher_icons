import 'dart:io';

import 'package:flutter_launcher_icons/flutter_launcher_icons_config.dart';
import 'package:flutter_launcher_icons/logger.dart';

///A base class to generate icons
abstract class IconGenerator {
  final IconGeneratorContext context;
  final String platformName;

  IconGenerator(this.context, this.platformName);

  /// Creates icons for this platform.
  void createIcons();

  /// Should return `true` if this platform
  /// has all the requirments to create icons.
  /// This runs before to [createIcons]
  bool validateRequirments();
}

/// Provides easy access to user arguments and configuration
class IconGeneratorContext {
  /// Contains configuration from configuration file
  final FlutterLauncherIconsConfig config;
  final FLILogger logger;
  final String? flavor;
  final String prefixPath;

  IconGeneratorContext({
    required this.config,
    this.flavor,
    required this.prefixPath,
    required this.logger,
  });

  /// Shortcut for `config.webConfig`
  WebConfig? get webConfig => config.webConfig;
}

/// Generates Icon for given platforms
void generateIconsFor({
  required FlutterLauncherIconsConfig config,
  required String? flavor,
  required String prefixPath,
  required FLILogger logger,
  required List<IconGenerator> Function(IconGeneratorContext context) platforms,
}) {
  try {
    final platformList = platforms(IconGeneratorContext(
      config: config,
      logger: logger,
      prefixPath: prefixPath,
      flavor: flavor,
    ));
    if (platformList.isEmpty) {
      // ? maybe we can print help
      logger.info('No platform provided');
    }

    for (final platform in platformList) {
      final progress = logger.progress('Creating Icons for ${platform.platformName}');
      logger.verbose('Validating platform requirments for ${platform.platformName}');
      // in case a platform throws an exception it should not effect other platforms
      try {
        if (!platform.validateRequirments()) {
          logger.error('Requirments failed for platform ${platform.platformName}. Skipped');
          progress.cancel();
          continue;
        }
        platform.createIcons();
        progress.finish(message: 'done', showTiming: true);
      } catch (e, st) {
        progress.cancel();
        logger
          ..error(e.toString())
          ..verbose(st);
        continue;
      }
    }
  } catch (e, st) {
    // todo: better error handling
    // stacktrace should only print when verbose is turned on
    // else a normal help line
    logger
      ..error(e.toString())
      ..verbose(st);
    exit(1);
  }
}
