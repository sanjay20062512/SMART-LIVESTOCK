// Create Password Screen — final step of registration.

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../services/localization_service.dart';
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
      SnackBar(
        content: Text(context.tr('account_created_success')),
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
        title: Text(
          context.tr('create_password'),
          style: const TextStyle(fontWeight: FontWeight.bold),
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
              Text(
                context.tr('create_a_password'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${context.tr('welcome')}, ${widget.profile.fullName}! ${context.tr('set_password_desc')}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: '${context.tr('password')} *',
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
                    return context.tr('please_enter_password');
                  }
                  if (v.length < 6) {
                    return context.tr('password_min_length');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: '${context.tr('confirm_password')} *',
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
                    return context.tr('passwords_do_not_match');
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
                  label: Text(
                    context.tr('create_account'),
                    style: const TextStyle(
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
