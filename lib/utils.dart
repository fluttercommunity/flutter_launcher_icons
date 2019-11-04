
import 'package:image/image.dart';

Image createResizedImage(int iconSize, Image image) {
  if (image.width >= iconSize) {
    return copyResize(image, width: iconSize, height: iconSize, interpolation: Interpolation.average);
  } else {
    return copyResize(image, width: iconSize, height: iconSize, interpolation: Interpolation.linear);
  }
}