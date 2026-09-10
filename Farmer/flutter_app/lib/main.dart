// Smart Livestock — Integrated 3-Module Application
// Pashu Seva - Animal Health Surveillance System.

import 'package:flutter/material.dart';
import 'services/farmer_data_service.dart';
import 'services/localization_service.dart';
import 'widgets/farmer_shell.dart';
import 'screens/registration_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/vet/vet_shell.dart';
import 'screens/govt/govt_shell.dart';

void main() {
  runApp(FarmerApp());
}

class FarmerApp extends StatefulWidget {
  FarmerApp({super.key});

  final FarmerDataService dataService = FarmerDataService();

  @override
  State<FarmerApp> createState() => _FarmerAppState();
}

class _FarmerAppState extends State<FarmerApp> {
  @override
  void initState() {
    super.initState();
    LocalizationService.instance.addListener(_onLocaleChanged);
    // Fetch data from FastAPI backend 300ms after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        widget.dataService.loadInitialData();
      });
    });
  }

  @override
  void dispose() {
    LocalizationService.instance.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Livestock',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
          ),
        ),
      ),
      home: RoleSelectionScreen(dataService: widget.dataService),
    );
  }
}

// ─── Role Selection Screen (Entry point) ──────────────────────────────────────

class RoleSelectionScreen extends StatelessWidget {
  final FarmerDataService dataService;
  const RoleSelectionScreen({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Logo
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4332).withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D6A4F).withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.agriculture_rounded, size: 60, color: Color(0xFF52B788)),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'Smart Livestock',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Health Surveillance System',
                  style: TextStyle(color: Color(0xFF74B49B), fontSize: 14),
                ),
              ),

              const SizedBox(height: 36),

              const Center(
                child: Text(
                  'SELECT YOUR ROLE',
                  style: TextStyle(
                    color: Color(0xFF74B49B),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Farmer role
              _roleCard(
                context,
                icon: Icons.person_rounded,
                title: 'Farmer',
                subtitle: 'Report animal problems, track cases, receive advisories',
                color: const Color(0xFF2E7D32),
                accentColor: const Color(0xFF52B788),
                demoHint: 'Demo: Any mobile + any password',
                onTap: () => _goFarmer(context),
              ),

              const SizedBox(height: 14),

              // Veterinarian role
              _roleCard(
                context,
                icon: Icons.medical_services_rounded,
                title: 'Veterinarian',
                subtitle: 'Review cases, schedule visits, collect samples, manage treatments',
                color: const Color(0xFF1565C0),
                accentColor: const Color(0xFF42A5F5),
                demoHint: 'Demo: Dr. Rajesh Kumar · VET001',
                onTap: () => _goVet(context),
              ),

              const SizedBox(height: 14),

              // Government role
              _roleCard(
                context,
                icon: Icons.account_balance_rounded,
                title: 'Government',
                subtitle: 'Surveillance dashboard, cluster detection, advisories, response',
                color: const Color(0xFF4A148C),
                accentColor: const Color(0xFFCE93D8),
                demoHint: 'Demo: District Animal Husbandry Officer',
                onTap: () => _goGovt(context),
              ),

              const SizedBox(height: 32),

              // SIH info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: const Column(
                  children: [
                    Text(
                      '⚡ DEMO MODE',
                      style: TextStyle(
                          color: Color(0xFF52B788),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'This prototype uses in-memory demo data to demonstrate '
                      'the complete data flow: Farmer → Vet → Government → Farmer.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color accentColor,
    required String demoHint,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(18),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(demoHint,
                          style: TextStyle(color: accentColor, fontSize: 10)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _goFarmer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LanguageSelectionScreen(dataService: dataService),
      ),
    );
  }

  void _goVet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _VetLoginScreen(dataService: dataService),
      ),
    );
  }

  void _goGovt(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _GovtLoginScreen(dataService: dataService),
      ),
    );
  }
}

// ─── Simple Vet Login Screen ───────────────────────────────────────────────────

class _VetLoginScreen extends StatefulWidget {
  final FarmerDataService dataService;
  const _VetLoginScreen({required this.dataService});

  @override
  State<_VetLoginScreen> createState() => __VetLoginScreenState();
}

class __VetLoginScreenState extends State<_VetLoginScreen> {
  final _idCtrl = TextEditingController(text: 'VET001');
  final _passCtrl = TextEditingController(text: 'vet123');
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _idCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final res = await widget.dataService.apiService.post('/auth/login', {
        'phone_or_id': _idCtrl.text.trim(),
        'password': _passCtrl.text.trim(),
      });
      if (res != null && res['access_token'] != null) {
        await widget.dataService.apiService.setToken(res['access_token']);
      }
    } catch (e) {
      debugPrint('Vet backend login fallback: $e');
    }

    // Fetch live cases AND alerts as veterinarian
    await Future.wait([
      widget.dataService.fetchCases(role: 'veterinarian'),
      widget.dataService.fetchAlerts(role: 'veterinarian'),
    ]);

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => VetShell(dataService: widget.dataService)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loginScaffold(
      context,
      color: const Color(0xFF1565C0),
      emoji: '👨‍⚕️',
      title: 'Veterinary Login',
      subtitle: 'Veterinary Officer',
      fields: [
        _field('Vet ID / Mobile', _idCtrl, Icons.badge_outlined),
        const SizedBox(height: 14),
        _field('Password', _passCtrl, Icons.lock_outline,
            obscure: _obscure,
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            )),
        const SizedBox(height: 6),
        const Text('Demo credentials: VET001 / vet123',
            style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
      loading: _loading,
      onLogin: _login,
    );
  }
}

// ─── Simple Govt Login Screen ──────────────────────────────────────────────────

class _GovtLoginScreen extends StatefulWidget {
  final FarmerDataService dataService;
  const _GovtLoginScreen({required this.dataService});

  @override
  State<_GovtLoginScreen> createState() => __GovtLoginScreenState();
}

class __GovtLoginScreenState extends State<_GovtLoginScreen> {
  final _idCtrl = TextEditingController(text: 'GOV001');
  final _passCtrl = TextEditingController(text: 'gov123');
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _idCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login() {
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => GovtShell(dataService: widget.dataService)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loginScaffold(
      context,
      color: const Color(0xFF4A148C),
      emoji: '🏛️',
      title: 'Government Login',
      subtitle: 'District Animal Husbandry Officer',
      fields: [
        _field('Officer ID / Mobile', _idCtrl, Icons.badge_outlined),
        const SizedBox(height: 14),
        _field('Password', _passCtrl, Icons.lock_outline,
            obscure: _obscure,
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            )),
        const SizedBox(height: 6),
        const Text('Demo credentials: GOV001 / gov123',
            style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
      loading: _loading,
      onLogin: _login,
    );
  }
}

// ─── Shared login scaffold ─────────────────────────────────────────────────────

Widget _loginScaffold(
  BuildContext context, {
  required Color color,
  required String emoji,
  required String title,
  required String subtitle,
  required List<Widget> fields,
  required bool loading,
  required VoidCallback onLogin,
}) {
  return Scaffold(
    backgroundColor: const Color(0xFF0D1B2A),
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 52)),
                  const SizedBox(height: 12),
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.white54, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 36),
            ...fields,
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: loading ? null : onLogin,
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('LOGIN', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _field(
  String label,
  TextEditingController ctrl,
  IconData icon, {
  bool obscure = false,
  Widget? suffixIcon,
}) {
  return TextField(
    controller: ctrl,
    obscureText: obscure,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white54),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white54, width: 1.5),
      ),
    ),
  );
}

// ─── Farmer Login Screen (kept from previous version) ─────────────────────────

class LoginScreen extends StatefulWidget {
  final FarmerDataService dataService;
  const LoginScreen({super.key, required this.dataService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _mobileCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() {
    if (_mobileCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.tr('mobile_number')} & ${context.tr('password')} required.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _loading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FarmerShell(dataService: widget.dataService),
        ),
      );
    });
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr('choose_language'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...AppLanguage.values.map((lang) {
                final isSelected = LocalizationService.instance.currentLanguage == lang;
                return ListTile(
                  title: Text(
                    lang.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    LocalizationService.instance.setLanguage(lang);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentLang = LocalizationService.instance.currentLanguage;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ActionChip(
              avatar: const Icon(Icons.language_rounded, size: 18),
              label: Text(
                '🌐 ${currentLang.label}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: _showLanguagePicker,
              backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.agriculture_rounded,
                  size: 52,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('app_title'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('login_title'),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _mobileCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                style: const TextStyle(fontSize: 17),
                decoration: InputDecoration(
                  labelText: context.tr('mobile_number'),
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                style: const TextStyle(fontSize: 17),
                decoration: InputDecoration(
                  labelText: context.tr('password'),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset demo: Use any non-empty password to log in.'),
                      ),
                    );
                  },
                  child: Text(context.tr('forgot_password')),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          context.tr('login_button'),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegistrationScreen(
                          dataService: widget.dataService,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    context.tr('new_farmer_register'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
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
