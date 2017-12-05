import 'dart:async';
import 'package:flutter_launcher_icons/android.dart' as FlutterIconsAndroid;
import 'package:flutter_launcher_icons/ios.dart' as FlutterIconsIos;
import 'package:dart_config/default_server.dart';

main(List<String> arguments) {
  Future<Map> conf = loadConfig("pubspec.yaml");
  conf.then((Map config) {
    if(config['flutter_icons']['image_path'] != null){
      if (config['flutter_icons']['android'] == true) {
        FlutterIconsAndroid.convertAndroid(config);
      }
      if (config['flutter_icons']['ios'] == true) {
        FlutterIconsIos.convertIos(config);
      }
      if (config['flutter_icons']['ios'] == false && config['flutter_icons']['android'] == false) {
        print("Error: No platform has been specified to generate launcher icons for.");
      }
    }else{
      print("flutter_icons config not found in pubspec.yaml");
    }
  });
  
}
