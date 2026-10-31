import 'dart:io';

import 'package:flutter_launcher_icons/ios.dart' as ios;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  test('preserves quotes when updating asset catalog icon settings', () async {
    final projectPath = path.join(d.sandbox, 'ios-project');
    final projectFile = File(
      path.join(projectPath, 'ios', 'Runner.xcodeproj', 'project.pbxproj'),
    );
    await projectFile.create(recursive: true);
    await projectFile.writeAsString('''
/* Begin XCBuildConfiguration section */
  1 /* Debug-nicemag */ = {
    baseConfigurationReference = 1 /* Debug-nicemag.xcconfig */;
    buildSettings = {
      ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
      ASSETCATALOG_COMPILER_COMPLICATION_NAME = "Complication"; /* keep comment */
      ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
    };
  };
  2 /* Debug-other */ = {
    baseConfigurationReference = 2 /* Debug-other.xcconfig */;
    buildSettings = {
      ASSETCATALOG_COMPILER_APPICON_NAME = "OtherIcon";
    };
  };
/* End XCBuildConfiguration section */
''');

    await ios.changeIosLauncherIcon(
      'AppIcon-nicemag',
      'nicemag',
      prefixPath: projectPath,
    );

    final projectContents = await projectFile.readAsString();
    expect(
      projectContents,
      contains('ASSETCATALOG_COMPILER_APPICON_NAME = "AppIcon-nicemag";'),
    );
    expect(
      projectContents,
      contains(
        'ASSETCATALOG_COMPILER_COMPLICATION_NAME = "AppIcon-nicemag"; '
        '/* keep comment */',
      ),
    );
    expect(
      projectContents,
      contains(
        'ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;',
      ),
    );
    expect(
      projectContents,
      contains('ASSETCATALOG_COMPILER_APPICON_NAME = "OtherIcon";'),
    );
  });
}
