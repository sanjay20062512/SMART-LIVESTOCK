// Smart Livestock — Integrated 3-Module Application
// Pashu Seva - Animal Health Surveillance System.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/farmer_data_service.dart';
import 'services/localization_service.dart';
import 'widgets/farmer_shell.dart';
import 'screens/registration_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/vet/vet_shell.dart';
import 'screens/govt/govt_shell.dart';
import 'theme/app_theme.dart';
import 'widgets/language_selector_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalizationService.instance.init();
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
      home: SplashScreen(
        dataService: widget.dataService,
        onReady: (ds) => RoleSelectionScreen(dataService: ds),
      ),
    );
  }
}

// ─── Role Selection Screen (Entry point) ──────────────────────────────────────

class RoleSelectionScreen extends StatelessWidget {
  final FarmerDataService dataService;
  const RoleSelectionScreen({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalizationService.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              // ── Top Bar with Language Selector ───────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  LanguageSelectorButton(),
                ],
              ),
              const SizedBox(height: 12),

              // ── Brand Logo & Platform Name ────────────────────────────────
              Center(
                child: Column(
                  children: [
                    // Logo container
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.agriculture_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      context.tr('app_title'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppRadius.fullRadius,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        context.tr('app_subtitle'),
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Role Selection Label ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  context.tr('select_role'),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              // ── Farmer role card ─────────────────────────────────────────
              _roleCard(
                context,
                icon: Icons.agriculture_rounded,
                title: context.tr('role_farmer_title'),
                subtitle: context.tr('role_farmer_sub'),
                accentColor: AppColors.primary,
                badgeText: context.tr('role_farmer_badge'),
                onTap: () => _goFarmer(context),
              ),

              const SizedBox(height: 12),

              // ── Veterinarian role card ────────────────────────────────────
              _roleCard(
                context,
                icon: Icons.medical_services_rounded,
                title: context.tr('role_vet_title'),
                subtitle: context.tr('role_vet_sub'),
                accentColor: const Color(0xFF1E40AF),
                badgeText: context.tr('role_vet_badge'),
                onTap: () => _goVet(context),
              ),

              const SizedBox(height: 12),

              // ── Government role card ──────────────────────────────────────
              _roleCard(
                context,
                icon: Icons.account_balance_rounded,
                title: context.tr('role_govt_title'),
                subtitle: context.tr('role_govt_sub'),
                accentColor: AppColors.govtNavy,
                badgeText: context.tr('role_govt_badge'),
                onTap: () => _goGovt(context),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _roleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
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
            color: Colors.white,
            borderRadius: AppRadius.lgRadius,
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
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
                    color: accentColor.withValues(alpha: 0.10),
                    borderRadius: AppRadius.mdRadius,
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Center(
                    child: Icon(icon, size: 26, color: accentColor),
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
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.08),
                          borderRadius: AppRadius.xsRadius,
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: AppRadius.xsRadius,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.textSecondary,
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
    return ListenableBuilder(
      listenable: LocalizationService.instance,
      builder: (context, _) {
        return _loginScaffold(
          context,
          accentColor: AppColors.vetAccent,
          headerGradient: const LinearGradient(
            colors: [Color(0xFF1E40AF), Color(0xFF1E3A8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.medical_services_rounded,
          title: context.tr('vet_login_title'),
          subtitle: context.tr('role_vet_title'),
          fields: [
            _field(context.tr('official_id'), _idCtrl, Icons.badge_outlined),
            const SizedBox(height: 14),
            _field(context.tr('password'), _passCtrl, Icons.lock_outline,
                obscure: _obscure,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )),
            const SizedBox(height: 8),
          ],
          loading: _loading,
          onLogin: _login,
        );
      },
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
  final _idCtrl = TextEditingController(text: 'GOVT001');
  final _passCtrl = TextEditingController(text: 'govt123');
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
      debugPrint('Govt backend login fallback: $e');
    }

    // Fetch live cases AND alerts as govt authority
    await Future.wait([
      widget.dataService.fetchCases(role: 'government'),
      widget.dataService.fetchAlerts(role: 'government'),
    ]);

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => GovtShell(dataService: widget.dataService)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalizationService.instance,
      builder: (context, _) {
        return _loginScaffold(
          context,
          accentColor: AppColors.govtNavy,
          headerGradient: const LinearGradient(
            colors: [Color(0xFF0B192C), Color(0xFF132743)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.account_balance_rounded,
          title: context.tr('govt_login_title'),
          subtitle: context.tr('role_govt_title'),
          fields: [
            _field(context.tr('officer_id'), _idCtrl, Icons.badge_outlined),
            const SizedBox(height: 14),
            _field(context.tr('password'), _passCtrl, Icons.lock_outline,
                obscure: _obscure,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )),
            const SizedBox(height: 8),
          ],
          loading: _loading,
          onLogin: _login,
        );
      },
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
    backgroundColor: const Color(0xFFF8FAFC),
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: LanguageSelectorButton(),
        ),
      ],
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header Card ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.lgRadius,
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.10),
                      borderRadius: AppRadius.mdRadius,
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Center(
                      child: Icon(icon, size: 32, color: accentColor),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Credentials section label ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                context.tr('credentials'),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            ...fields,
            const SizedBox(height: 24),

            // ── Login button ──────────────────────────────────────────────
            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdRadius,
                  ),
                  elevation: 1,
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
                    : Text(
                        context.tr('login_button'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
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
      color: AppColors.textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: AppRadius.mdRadius,
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdRadius,
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalizationService.instance,
      builder: (context, _) {
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: LanguageSelectorButton(),
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
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.20),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
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
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('app_title'),
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F2444),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('login_title'),
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
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
      },
    );
  }
}
