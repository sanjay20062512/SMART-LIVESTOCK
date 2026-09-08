// Language Selection Screen — First screen before login.
// Large, accessible language cards designed for farmers.

import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../services/farmer_data_service.dart';
import '../main.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final FarmerDataService dataService;

  const LanguageSelectionScreen({super.key, required this.dataService});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  AppLanguage _selected = LocalizationService.instance.currentLanguage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // Logo & App Name
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.agriculture_rounded,
                        size: 54,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Smart Livestock',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'கால்நடை பராமரிப்பு · पशुधन सेवा',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Choose your language\nஉங்கள் மொழியைத் தேர்ந்தெடுக்கவும்\nअपनी भाषा चुनें',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              // Language Cards
              _buildLanguageCard(
                language: AppLanguage.english,
                nativeName: 'English',
                subText: 'Select English to continue',
                iconEmoji: '🇬🇧',
              ),
              const SizedBox(height: 12),

              _buildLanguageCard(
                language: AppLanguage.tamil,
                nativeName: 'தமிழ்',
                subText: 'தமிழில் தொடர இதை அழுத்தவும்',
                iconEmoji: '🌾',
              ),
              const SizedBox(height: 12),

              _buildLanguageCard(
                language: AppLanguage.hindi,
                nativeName: 'हिन्दी',
                subText: 'हिंदी में जारी रखने के लिए चुनें',
                iconEmoji: '🇮🇳',
              ),

              const SizedBox(height: 28),

              // Continue Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    LocalizationService.instance.setLanguage(_selected);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            LoginScreen(dataService: widget.dataService),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _selected == AppLanguage.tamil
                            ? 'தொடர்க'
                            : (_selected == AppLanguage.hindi
                                ? 'आगे बढ़ें'
                                : 'CONTINUE'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 22),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required AppLanguage language,
    required String nativeName,
    required String subText,
    required String iconEmoji,
  }) {
    final isSelected = _selected == language;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? primaryColor : Colors.grey.shade300,
          width: isSelected ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() => _selected = language);
            LocalizationService.instance.setLanguage(language);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Text(iconEmoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nativeName,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? primaryColor : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subText,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isSelected ? primaryColor : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? primaryColor : Colors.grey.shade400,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
