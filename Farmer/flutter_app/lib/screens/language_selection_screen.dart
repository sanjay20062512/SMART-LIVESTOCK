// Language Selection Screen — First screen before login.
// Large, accessible language cards for English, हिन्दी, and मराठी.

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
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.20),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 92,
                          height: 92,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.agriculture_rounded,
                              size: 54,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
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
                      'पशुधन सेवा · पशु आरोग्य पाळत',
                      style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Choose your language\nअपनी भाषा चुनें\nआपली भाषा निवडा',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              // Language Cards: English, Hindi, Marathi
              _buildLanguageCard(
                language: AppLanguage.english,
                nativeName: 'English',
                subText: 'Select English to continue',
                icon: Icons.language_rounded,
              ),
              const SizedBox(height: 12),

              _buildLanguageCard(
                language: AppLanguage.hindi,
                nativeName: 'हिन्दी',
                subText: 'हिन्दी में जारी रखने के लिए चुनें',
                icon: Icons.g_translate_rounded,
              ),
              const SizedBox(height: 12),

              _buildLanguageCard(
                language: AppLanguage.marathi,
                nativeName: 'मराठी',
                subText: 'मराठीत पुढे सुरू ठेवण्यासाठी निवडा',
                icon: Icons.translate_rounded,
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
                        _selected == AppLanguage.marathi
                            ? 'पुढे सुरू ठेवा'
                            : (_selected == AppLanguage.hindi
                                ? 'आगे बढ़ें'
                                : 'CONTINUE'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
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
    required IconData icon,
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
          width: isSelected ? 2.2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor.withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? primaryColor : Colors.grey.shade600,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nativeName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? primaryColor
                              : const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subText,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected
                              ? primaryColor.withValues(alpha: 0.8)
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? primaryColor : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
