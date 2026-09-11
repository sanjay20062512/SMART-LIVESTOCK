// Smart Livestock — Integrated 3-Module Application
// Pashu Seva - Animal Health Surveillance System.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/farmer_data_service.dart';
import 'services/localization_service.dart';
import 'widgets/farmer_shell.dart';
import 'screens/registration_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/vet/vet_shell.dart';
import 'screens/govt/govt_shell.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
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
      theme: AppTheme.light(),
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
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // ── App Logo & Brand ─────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    // Logo container
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppRadius.lgRadius,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.45),
                            blurRadius: 28,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.agriculture_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Smart Livestock',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        borderRadius: AppRadius.fullRadius,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Text(
                        'Animal Health Surveillance System',
                        style: TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ── Role Selection Label ──────────────────────────────────────
              const Padding(
                padding: EdgeInsets.only(left: 2, bottom: 12),
                child: Text(
                  'SELECT YOUR ROLE',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                  ),
                ),
              ),

              // ── Farmer role card ─────────────────────────────────────────
              _roleCard(
                context,
                icon: Icons.agriculture_rounded,
                title: 'Farmer',
                subtitle: 'Report animal problems, track cases, receive advisories',
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                accentColor: AppColors.primaryLight,
                badgeText: 'Farmer Portal',
                onTap: () => _goFarmer(context),
              ),

              const SizedBox(height: 12),

              // ── Veterinarian role card ────────────────────────────────────
              _roleCard(
                context,
                icon: Icons.medical_services_rounded,
                title: 'Veterinarian',
                subtitle: 'Review cases, schedule visits, collect samples, manage treatments',
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                accentColor: const Color(0xFFBFDBFE),
                badgeText: 'Field Veterinary Services',
                onTap: () => _goVet(context),
              ),

              const SizedBox(height: 12),

              // ── Government role card ──────────────────────────────────────
              _roleCard(
                context,
                icon: Icons.account_balance_rounded,
                title: 'Government',
                subtitle: 'Surveillance dashboard, cluster detection, advisories, response',
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B192C), Color(0xFF132743)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                accentColor: const Color(0xFF93C5FD),
                badgeText: 'Animal Health Authority',
                onTap: () => _goGovt(context),
              ),

              const SizedBox(height: 24),
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
    required Gradient gradient,
    required Color accentColor,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: AppRadius.lgRadius,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.lgRadius,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: AppRadius.lgRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: AppRadius.smRadius,
                  ),
                  child: Center(
                    child: Icon(icon, size: 26, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 14),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.22),
                          borderRadius: AppRadius.xsRadius,
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: AppRadius.xsRadius,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white70,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
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
      accentColor: AppColors.vetAccent,
      headerGradient: const LinearGradient(
        colors: [Color(0xFF1E40AF), Color(0xFF1E3A8A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.medical_services_rounded,
      title: 'Veterinary Login',
      subtitle: 'Veterinary Officer',
      fields: [
        _field('Vet ID / Mobile', _idCtrl, Icons.badge_outlined),
        const SizedBox(height: 14),
        _field('Password', _passCtrl, Icons.lock_outline,
            obscure: _obscure,
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.white60,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            )),
        const SizedBox(height: 8),
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
      accentColor: AppColors.govtNavy,
      headerGradient: const LinearGradient(
        colors: [Color(0xFF0B192C), Color(0xFF132743)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.account_balance_rounded,
      title: 'Government Login',
      subtitle: 'District Animal Husbandry Officer',
      fields: [
        _field('Officer ID / Mobile', _idCtrl, Icons.badge_outlined),
        const SizedBox(height: 14),
        _field('Password', _passCtrl, Icons.lock_outline,
            obscure: _obscure,
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.white60,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            )),
        const SizedBox(height: 8),
      ],
      loading: _loading,
      onLogin: _login,
    );
  }
}

// ─── Shared login scaffold ─────────────────────────────────────────────────────

Widget _loginScaffold(
  BuildContext context, {
  required Color accentColor,
  required Gradient headerGradient,
  required IconData icon,
  required String title,
  required String subtitle,
  required List<Widget> fields,
  required bool loading,
  required VoidCallback onLogin,
}) {
  return Scaffold(
    backgroundColor: const Color(0xFF0A1628),
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: headerGradient,
                borderRadius: AppRadius.lgRadius,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: AppRadius.smRadius,
                    ),
                    child: Center(
                      child: Icon(icon, size: 34, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Credentials section label ─────────────────────────────────
            const Padding(
              padding: EdgeInsets.only(left: 2, bottom: 12),
              child: Text(
                'CREDENTIALS',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),

            ...fields,
            const SizedBox(height: 24),

            // ── Login button ──────────────────────────────────────────────
            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdRadius,
                  ),
                  elevation: 0,
                ),
                onPressed: loading ? null : onLogin,
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'SIGN IN',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
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
    style: const TextStyle(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: AppRadius.mdRadius,
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdRadius,
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdRadius,
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
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
