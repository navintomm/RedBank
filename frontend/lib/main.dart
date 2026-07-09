import 'package:flutter/material.';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Initialize Firebase
  // await Firebase.initializeApp();
  
  runApp(const ProviderScope(child: RedBankApp()));
}

class RedBankApp extends StatelessWidget {
  const RedBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Red Bank',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD32F2F)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Red Bank V1 - Bootstrapped'),
        ),
      ),
    );
  }
}
