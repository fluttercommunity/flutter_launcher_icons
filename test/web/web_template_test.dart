import 'package:flutter_launcher_icons/web/web_template.dart';
import 'package:test/test.dart';

void main() {
  group('WebTemplate', () {
    late WebIconTemplate icTemplate;
    late WebIconTemplate icMaskableTemplate;

    setUp(() {
      icTemplate = const WebIconTemplate(size: 512);
      icMaskableTemplate = const WebIconTemplate(size: 512, maskable: true);
    });

    test('.iconFile should return valid file name', () async {
      expect(icTemplate.iconFile, equals('Icon-512.png'));
      expect(icMaskableTemplate.iconFile, equals('Icon-maskable-512.png'));
    });

    test('.iconManifest should return valid manifest config', () {
      expect(
        icTemplate.iconManifest,
        equals({
          'src': 'icons/Icon-512.png',
          'sizes': '512x512',
          'type': 'image/png'
        }),
      );
      expect(
        icMaskableTemplate.iconManifest,
        equals({
          'src': 'icons/Icon-maskable-512.png',
          'sizes': '512x512',
          'type': 'image/png',
          'purpose': 'maskable'
        }),
      );
    });
  });
}
