import 'package:flutter_launcher_icons/constants.dart';
import 'package:flutter_launcher_icons/main.dart' as flutter_launcher_icons;

void main(List<String> arguments) {
  print(introMessage('0.8.1'));
  flutter_launcher_icons.createIconsFromArguments(arguments);
}
