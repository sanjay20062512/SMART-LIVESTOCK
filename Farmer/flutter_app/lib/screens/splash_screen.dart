// Smart Livestock — Splash Screen
// Minimal, premium white screen displayed on app launch.
// Shows the brand logo prominently, then auto-navigates to the provided destination.

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../widgets/brand_logo.dart';

class SplashScreen extends StatefulWidget {
  final FarmerDataService dataService;
  final Widget Function(FarmerDataService ds) onReady;

  const SplashScreen({
    super.key,
    required this.dataService,
    required this.onReady,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();

    // Navigate to role selection after 2.4 seconds
    Future.delayed(const Duration(milliseconds: 2400), _navigateNext);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateNext() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: widget.onReady(widget.dataService),
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Brand Logo ────────────────────────────────────────
                    const BrandLogo.large(),

                    const SizedBox(height: 32),

                    // ── Platform Name ─────────────────────────────────────
                    const Text(
                      'Smart Livestock',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F2444),
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Tagline ───────────────────────────────────────────
                    const Text(
                      'Animal Health Surveillance System',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0D9488),
                        letterSpacing: 0.3,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
