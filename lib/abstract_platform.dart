

abstract class AbstractPlatform {
  /// Returns whether the current platform is
  /// in the given configuration data.
  /// 
  /// For an Android implementation,
  /// inConfig might check for the presence of the
  /// "android" key in [config.]
  bool inConfig(final Map<String, dynamic> config);

  /// Check whether the given configuration is valid.
  /// If the configuration is valid, returns null.
  /// Otherwise, returns a description of the reason
  /// the configuration is invalid.
  /// This should always return null if `!inConfig(config)`.
  String isConfigValid(final Map<String, dynamic> config) {
    return null;
  }

  // TODO(personalizedrefrigerator): Document flavor usage.
  /// Create all icons for the current platform based on
  /// the contents of [config] and the [flavor].
  void createIcons(final Map<String, dynamic> config, 
      final String flavor);
}