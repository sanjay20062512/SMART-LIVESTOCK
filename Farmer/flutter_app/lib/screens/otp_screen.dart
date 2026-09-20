// OTP Screen — mobile OTP verification.

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../services/localization_service.dart';
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

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  void _verify() {
    final entered = _otpCtrl.text.trim();
    if (entered.length != 6) {
      setState(() => _error = context.tr('please_enter_6_digit_otp'));
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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CreatePasswordScreen(
            dataService: widget.dataService,
            profile: widget.profile,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('verify_mobile'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.sms, size: 56, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              context.tr('enter_otp'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${context.tr('otp_sent_to')} ${widget.mobileNumber}.',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('enter_verification_code'),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green),
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
                    : Text(
                        context.tr('verify_otp'),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            Center(
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.tr('otp_resent_success')),
                    ),
                  );
                },
                child: Text(context.tr('resend_otp')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
