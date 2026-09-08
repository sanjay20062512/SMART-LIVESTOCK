// OTP Screen — demo OTP verification.
// DEMO NOTE: OTP is hardcoded as 123456 for prototype purposes only.
// Real SMS OTP service is NOT connected.

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../models/farmer_profile.dart';
import 'create_password_screen.dart';

class OtpScreen extends StatefulWidget {
  final FarmerDataService dataService;
  final FarmerProfile profile;
  final String mobileNumber;

  const OtpScreen({
    super.key,
    required this.dataService,
    required this.profile,
    required this.mobileNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpCtrl = TextEditingController();
  String? _error;
  bool _loading = false;

  static const String _demoOtp = '123456';

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  void _verify() {
    final entered = _otpCtrl.text.trim();
    if (entered.length != 6) {
      setState(() => _error = 'Please enter a 6-digit OTP.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _loading = false);

      if (entered == _demoOtp) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CreatePasswordScreen(
              dataService: widget.dataService,
              profile: widget.profile,
            ),
          ),
        );
      } else {
        setState(() => _error = 'Incorrect OTP. Use 123456 for demo.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verify Mobile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.sms, size: 56, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Enter OTP',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'A 6-digit OTP was sent to ${widget.mobileNumber}.',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // DEMO NOTICE
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.amber, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🔧 Demo Mode: Use OTP 123456. '
                      'Real SMS is not connected in this prototype.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, letterSpacing: 10),
              decoration: InputDecoration(
                hintText: '------',
                errorText: _error,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                counterText: '',
              ),
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _verify,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Verify OTP',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            Center(
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Demo mode: OTP resend not available. Use 123456.'),
                    ),
                  );
                },
                child: const Text('Resend OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
