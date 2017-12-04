import 'dart:async';
import 'package:flutter_launcher_icons/flutter_launcher_icons.dart' as FlutterIcons;
import 'package:dart_config/default_server.dart';

main(List<String> arguments) {
  Future<Map> conf = loadConfig("pubspec.yaml");
  conf.then((Map config) {
    if(config['flutter_icons']){
      FlutterIcons.convertAndroid(config);
    }else{
      print("flutter_icons config not found in pubspec.yaml");
    }
    // FlutterIcons.convertAndroid(config);
  });
  
}
