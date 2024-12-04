// lib/app.dart
import 'package:flutter/material.dart';
import 'screens/decryptor_selector_screen.dart';

class DecryptorApp extends StatelessWidget {
  const DecryptorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Config Decryptor',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const DecryptorSelectorScreen(),
    );
  }
}