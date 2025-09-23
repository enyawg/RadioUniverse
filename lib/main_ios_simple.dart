import 'package:flutter/material.dart';

void main() {
  print('🚀 iOS App Starting...');
  runApp(const SimpleRadioApp());
}

class SimpleRadioApp extends StatelessWidget {
  const SimpleRadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('📱 Building MaterialApp...');
    return MaterialApp(
      title: 'Radio Universe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('🏠 Building HomeScreen...');
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Radio Universe - iOS Working!'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.radio,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'iOS App Works!',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}