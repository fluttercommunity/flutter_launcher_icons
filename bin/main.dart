import 'dart:async';
import 'package:flutter_launcher_icons/android.dart' as FlutterIconsAndroid;
import 'package:flutter_launcher_icons/ios.dart' as FlutterIconsIos;
import 'package:dart_config/default_server.dart';

main(List<String> arguments) {
  Future<Map> conf = loadConfig("pubspec.yaml");
  conf.then((Map config) {
    if(config['flutter_icons']['image_path'] != null) {
      var androidConfig = config['flutter_icons']['android'];
      var iosConfig = config['flutter_icons']['ios'];
      if (androidConfig == true || androidConfig is String) {
        FlutterIconsAndroid.convertAndroid(config);
      }
      if (iosConfig == true || iosConfig is String) {
        FlutterIconsIos.convertIos(config);
      }
      if (((androidConfig == false) && (iosConfig == false)) || ((androidConfig == null) && (iosConfig == null))) {
        print("Error: No platform has been specified to generate launcher icons for.");
      }
    }else{
      print("flutter_icons config not found in pubspec.yaml");
    }
  });
  
}
