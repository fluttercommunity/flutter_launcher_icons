import 'package:flutter_launcher_icons/constants.dart';
import 'package:flutter_launcher_icons/main.dart' as flutter_launcher_icons;
import 'package:pedantic/pedantic.dart';

void main(List<String> arguments) {
  print(introMessage('0.9.1'));
  unawaited(flutter_launcher_icons.createIconsFromArguments(arguments));
}
