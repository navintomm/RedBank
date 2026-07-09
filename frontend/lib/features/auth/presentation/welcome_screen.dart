import 'package:flutter/material.';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.bloodtype, size: 80, color: Color(0xFFD32F2F)),
              const SizedBox(height: 24),
              const Text(
                'Save a Life Today',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Phone Login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Continue with Phone'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
