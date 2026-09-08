// Create Password Screen — final step of registration.

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../models/farmer_profile.dart';
import '../widgets/farmer_shell.dart';

class CreatePasswordScreen extends StatefulWidget {
  final FarmerDataService dataService;
  final FarmerProfile profile;

  const CreatePasswordScreen({
    super.key,
    required this.dataService,
    required this.profile,
  });

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _create() {
    if (!_formKey.currentState!.validate()) return;

    // Save the profile to the data service.
    // In a real app, password hash would be sent to the backend here.
    widget.dataService.updateProfile(widget.profile);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully! Welcome.'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to the main app shell, removing all previous routes.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => FarmerShell(dataService: widget.dataService),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Password',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock, size: 56, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                'Create a Password',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome, ${widget.profile.fullName}! '
                'Set a secure password for your account.',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please enter a password.';
                  }
                  if (v.length < 6) {
                    return 'Password must be at least 6 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm Password *',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  if (v != _passwordCtrl.text) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _create,
                  icon: const Icon(Icons.check_circle),
                  label: const Text(
                    'Create Account',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
