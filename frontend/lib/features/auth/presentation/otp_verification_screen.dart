import 'package:flutter/material.';

class OtpVerificationScreen extends StatelessWidget {
  final String verificationId;

  const OtpVerificationScreen({super.key, required this.verificationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('Enter the 6-digit code sent to your phone.'),
            const SizedBox(height: 24),
            const TextField(
              decoration: InputDecoration(
                labelText: 'OTP Code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Verify'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
