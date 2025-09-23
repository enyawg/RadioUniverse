import 'package:flutter/material.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iOS Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('iOS Test - Working!'),
          backgroundColor: Colors.blue,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green,
              ),
              SizedBox(height: 16),
              Text(
                'iOS App is Working!',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 16),
              Text('If you see this, iOS builds work fine.'),
            ],
          ),
        ),
      ),
    );
  }
}