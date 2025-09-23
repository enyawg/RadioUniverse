import 'package:flutter/material.dart';
import '../services/firebase_setup.dart';
import '../services/data_service.dart';

class FirebaseSetupScreen extends StatefulWidget {
  const FirebaseSetupScreen({super.key});

  @override
  State<FirebaseSetupScreen> createState() => _FirebaseSetupScreenState();
}

class _FirebaseSetupScreenState extends State<FirebaseSetupScreen> {
  bool _isLoading = false;
  String _status = 'Ready to setup Firebase';
  bool _setupComplete = false;

  Future<void> _runFirebaseSetup() async {
    setState(() {
      _isLoading = true;
      _status = 'Setting up Firebase...';
    });

    try {
      await FirebaseSetup.completeSetup();
      setState(() {
        _status = 'Firebase setup completed successfully!';
        _setupComplete = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Setup failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testFirebaseData() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing Firebase data...';
    });

    try {
      final dataService = DataService();
      final stations = await dataService.getAllStations();
      
      setState(() {
        _status = 'Found ${stations.length} stations in Firebase!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Data test failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Setup'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Firebase Setup Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Setup Steps:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('1. Make sure Firestore is enabled in Firebase Console'),
            const Text('2. Set Firestore rules to allow read/write'),
            const Text('3. Run Firebase setup to populate initial data'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _runFirebaseSetup,
              child: Text(_setupComplete ? 'Setup Complete ✓' : 'Run Firebase Setup'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _isLoading ? null : _testFirebaseData,
              child: const Text('Test Firebase Data'),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Firestore Rules',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '''rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}''',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Copy the rules above to Firebase Console → Firestore → Rules',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}