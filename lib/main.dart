import 'package:flutter/material.dart';
import 'widgets/listScreen.dart';

void main() {
  runApp(const WasteagramApp());
}

class WasteagramApp extends StatelessWidget {
  const WasteagramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wasteagram',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const ListScreen(),
    );
  }
}
