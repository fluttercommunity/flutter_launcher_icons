import 'package:flutter/material.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Example with flavors'),
        ),
        body: const Center(
          child: Text('Example with flavors'),
        ),
      ),
    );
  }
}
