import 'package:flutter_launcher_icons/ios.dart' as ios;
import 'package:test/test.dart';

/// XCBuildConfiguration section of a project.pbxproj where the flavors were
/// created as described in https://docs.flutter.dev/deployment/flavors-ios,
/// i.e. by duplicating the Debug/Release/Profile configurations, so the flavor
/// configurations keep using `Debug.xcconfig` / `Release.xcconfig`.
const String _projectFile = '''
/* Begin XCBuildConfiguration section */
		249021D3217E4FDB00AE95B9 /* Profile */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
			};
			name = Profile;
		};
		249021D4217E4FDB00AE95B9 /* Profile */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = 7AFA3C8E1D35360C0083082E /* Release.xcconfig */;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
			};
			name = Profile;
		};
		97C147031CF9000F007C117D /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
			};
			name = Debug;
		};
		97C147061CF9000F007C117D /* Debug */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = 9740EEB21CF90195004384FC /* Debug.xcconfig */;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
			};
			name = Debug;
		};
		A10000000000000000000001 /* Debug-staging */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
			};
			name = "Debug-staging";
		};
		A10000000000000000000002 /* Debug-staging */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = 9740EEB21CF90195004384FC /* Debug.xcconfig */;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
			};
			name = "Debug-staging";
		};
		A10000000000000000000003 /* Release-staging */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = 7AFA3C8E1D35360C0083082E /* Release.xcconfig */;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
			};
			name = "Release-staging";
		};
		A10000000000000000000004 /* Profile-staging */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = 7AFA3C8E1D35360C0083082E /* Release.xcconfig */;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
			};
			name = "Profile-staging";
		};
		A10000000000000000000005 /* Debug-qa-staging */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = 9740EEB21CF90195004384FC /* Debug.xcconfig */;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
			};
			name = "Debug-qa-staging";
		};
/* End XCBuildConfiguration section */
''';

/// Returns the `ASSETCATALOG_*` settings of every build configuration as
/// `<configuration>: <setting>` so tests can assert on all of them at once.
List<String> _assetCatalogSettings(List<String> lines) {
  final header = RegExp(r'/\* (.+) \*/ = \{');
  String? config;
  final settings = <String>[];
  for (final line in lines) {
    final match = header.firstMatch(line);
    if (match != null) {
      config = match.group(1);
    } else if (line.contains('ASSETCATALOG')) {
      settings.add('$config: ${line.trim()}');
    }
  }
  return settings;
}

void main() {
  final lines = _projectFile.split('\n');

  group('transformIosProjectWithNewLauncherIcon', () {
    test('sets the app icon of the flavor build configurations only', () {
      final result = ios.transformIosProjectWithNewLauncherIcon(
        lines,
        'AppIcon-staging',
        'staging',
      );

      expect(_assetCatalogSettings(result), [
        'Profile: ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;',
        'Profile: ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;',
        'Debug: ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;',
        'Debug: ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;',
        'Debug-staging: ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;',
        'Debug-staging: ASSETCATALOG_COMPILER_APPICON_NAME = "AppIcon-staging";',
        'Release-staging: ASSETCATALOG_COMPILER_APPICON_NAME = "AppIcon-staging";',
        'Profile-staging: ASSETCATALOG_COMPILER_APPICON_NAME = "AppIcon-staging";',
        'Debug-qa-staging: ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;',
      ]);
    });

    test('flavor names containing another flavor name are matched exactly', () {
      final result = ios.transformIosProjectWithNewLauncherIcon(
        lines,
        'AppIcon-qa-staging',
        'qa-staging',
      );

      expect(
        _assetCatalogSettings(result).where(
          (s) => s.contains('APPICON_NAME') && !s.endsWith('= AppIcon;'),
        ),
        [
          'Debug-qa-staging: ASSETCATALOG_COMPILER_APPICON_NAME = "AppIcon-qa-staging";',
        ],
      );
    });

    test('sets the app icon of every build configuration without a flavor', () {
      final result =
          ios.transformIosProjectWithNewLauncherIcon(lines, 'MyIcon', null);

      final settings = _assetCatalogSettings(result);
      expect(
        settings.where((s) => s.contains('APPICON_NAME')),
        everyElement(endsWith('ASSETCATALOG_COMPILER_APPICON_NAME = MyIcon;')),
      );
      expect(
        settings.where((s) => s.contains('GENERATE_SWIFT_ASSET_SYMBOL')),
        everyElement(endsWith('= YES;')),
      );
    });

    test('does not change anything else', () {
      final result = ios.transformIosProjectWithNewLauncherIcon(
        lines,
        'AppIcon-staging',
        'staging',
      );

      expect(result.length, lines.length);
      for (int i = 0; i < lines.length; i++) {
        if (!lines[i].contains('ASSETCATALOG_COMPILER_APPICON_NAME')) {
          expect(result[i], lines[i]);
        }
      }
    });
  });
}
