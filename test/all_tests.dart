import 'package:test/test.dart';

import 'abs/icon_generator_test.dart' as icon_generator_test;
import 'android_test.dart' as android_test;
import 'config_test.dart' as fli_config;
import 'macos/macos_icon_generator_test.dart' as macos_icons_gen_test;
import 'macos/macos_icon_template_test.dart' as macos_template_test;
import 'main_test.dart' as main_test;
import 'utils_test.dart' as utils_test;
import 'web/web_icon_generator_test.dart' as web_icon_gen_test;
import 'web/web_template_test.dart' as web_template_test;
import 'windows/windows_icon_generator_test.dart' as windows_icon_gen_test;

void main() {
  group('Flutter launcher icons', () {
    // others
    utils_test.main();
    fli_config.main();
    icon_generator_test.main();

    main_test.main();
    // android
    android_test.main();
    // web
    web_template_test.main();
    web_icon_gen_test.main();
    // windows
    windows_icon_gen_test.main();
    // macos
    macos_template_test.main();
    macos_icons_gen_test.main();
  });
}
