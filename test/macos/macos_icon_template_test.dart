import 'package:flutter_launcher_icons/macos/macos_icon_template.dart';
import 'package:test/test.dart';

void main() {
  group('MacOSIconTemplate', () {
    late int size;
    late int scale;
    late MacOSIconTemplate template;

    setUp(() {
      size = 16;
      scale = 1;
      template = MacOSIconTemplate(size, scale);
    });

    test('should pass', () {
      expect(template.size, equals(size));
      expect(template.scale, equals(scale));
      expect(template.scaledSize, equals(size * scale));
      expect(template.iconFile, equals('app_icon_${template.scaledSize}.png'));
      expect(
        template.iconContent,
        equals(
          {
            'size': '${size}x$size',
            'idiom': 'mac',
            'filename': 'app_icon_${template.scaledSize}.png',
            'scale': '1x',
          },
        ),
      );
    });
  });
}
