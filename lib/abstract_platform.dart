abstract class AbstractPlatform {
  const AbstractPlatform(this.platformConfigKey);

  final String platformConfigKey;

  /// Returns whether the current platform is
  /// in the given configuration data.
  ///
  /// For an Android implementation,
  /// inConfig might check for the presence of the
  /// "android" key in [config.]
  bool inConfig(final Map<String, dynamic> config) {
    return config.containsKey(platformConfigKey) &&
        config[platformConfigKey] != false;
  }

  /// Check whether the given configuration is valid.
  /// If the configuration is valid, returns null.
  /// Otherwise, returns a description of the reason
  /// the configuration is invalid.
  /// This should always return null if `!inConfig(config)`.
  String isConfigValid(final Map<String, dynamic> config) {
    if (!inConfig(config)) {
      return null; // No issue if not in the configuration file.
    }

    if (!config.containsKey('image_path_' + platformConfigKey) &&
        !config.containsKey('image_path')) {
      return 'Configuration requests $platformConfigKey icons, but does not provide an image path.';
    }

    return null; // No issues.
  }

  // TODO(personalizedrefrigerator): Document flavor usage.
  /// Create all icons for the current platform based on
  /// the contents of [config] and the [flavor].
  void createIcons(final Map<String, dynamic> config, final String flavor);
}
