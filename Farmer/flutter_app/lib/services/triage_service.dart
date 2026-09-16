// Triage Service — Rule-based health risk assessment prototype with complete multilingual generation.
//
// Generates clinical triage recommendations directly in English, हिन्दी (Hindi), or मराठी (Marathi).
// Supports offline instant assessment and backend response mapping.

import '../models/health_report.dart';
import 'localization_service.dart';

/// Result returned by the triage engine.
class TriageResult {
  final RiskLevel riskLevel;
  final String title;
  final String advice;
  final String recommendedAction;
  final List<String> suspectedConditions;

  const TriageResult({
    required this.riskLevel,
    required this.title,
    required this.advice,
    required this.recommendedAction,
    this.suspectedConditions = const [],
  });
}

/// Critical symptoms in farmer-friendly terminology (supports multilingual symptom tokens)
const List<String> _criticalSymptoms = [
  'breathing problem',
  'breathing difficulty',
  'excessive salivation',
  'salivation',
  'weakness',
  'skin lesions',
  'bleeding',
  'श्वास',
  'सांस',
  'लाळ',
  'लार',
  'अशक्त',
  'कमजोरी',
  'फोड',
  'छाले',
  'रक्त',
  'खून',
];

class TriageService {
  TriageService._();

  /// Assess symptoms and parameters reported by the farmer in the selected language.
  static TriageResult assess({
    required List<String> symptoms,
    String? affectedCount,
    bool isMortalityRelated = false,
    bool notEating = false,
    bool notDrinking = false,
    AppLanguage? language,
  }) {
    final lang = language ?? LocalizationService.instance.currentLanguage;

    // 1. Mortality Emergency check
    if (isMortalityRelated) {
      return _generateMortalityResult(lang);
    }

    if (symptoms.isEmpty) {
      return _generateLowRiskEmpty(lang);
    }

    // Check critical symptom matches (support icon labels, Marathi, and Hindi names)
    final criticalMatches = symptoms.where((s) {
      final clean = s.replaceAll(RegExp(r'^[^\w\u0900-\u097F]+'), '').trim().toLowerCase();
      return _criticalSymptoms.any((cs) =>
          clean.contains(cs.toLowerCase()) || cs.toLowerCase().contains(clean));
    }).length;

    final isMultipleAffected = affectedCount != null &&
        (affectedCount.contains('2–5') ||
         affectedCount.contains('6–10') ||
         affectedCount.contains('More than 10') ||
         affectedCount.contains('2-5') ||
         affectedCount.contains('6-10') ||
         affectedCount.contains('10') ||
         affectedCount.contains('२–५') ||
         affectedCount.contains('६–१०') ||
         affectedCount.contains('१०'));

    // Tier 1: CRITICAL
    if (criticalMatches >= 2 || (criticalMatches >= 1 && isMultipleAffected)) {
      return _generateCriticalResult(lang);
    }

    // Tier 2: HIGH
    if (criticalMatches >= 1 || symptoms.length >= 3 || isMultipleAffected || (notEating && notDrinking)) {
      return _generateHighResult(lang);
    }

    // Tier 3: MEDIUM
    if (symptoms.length >= 2 || notEating || notDrinking) {
      return _generateMediumResult(lang);
    }

    // Tier 4: LOW
    return _generateLowResult(lang);
  }

  static TriageResult _generateMortalityResult(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.marathi:
        return const TriageResult(
          riskLevel: RiskLevel.critical,
          title: 'गंभीर आरोग्य जोखीम — जनावराचा मृत्यू',
          advice: 'जनावराचा मृत्यू नोंदवला गेला आहे. कृपया बाधित भागातून इतर जनावरांना हलवू नका.',
          recommendedAction:
              'उर्वरित जनावरांचे काटेकोर विलगीकरण करा. तपासणी व शवविच्छेदनासाठी स्थानिक पशुवैद्यकीय दवाखान्याशी त्वरित संपर्क साधा.',
          suspectedConditions: ['ॲन्थ्रॅक्स (Anthrax)', 'घटसर्प (HS)', 'तीव्र विषबाधा'],
        );
      case AppLanguage.hindi:
        return const TriageResult(
          riskLevel: RiskLevel.critical,
          title: 'गंभीर स्वास्थ्य जोखिम — पशु मृत्यु दर्ज',
          advice: 'पशु मृत्यु की सूचना मिली है। कृपया प्रभावित क्षेत्र से अन्य पशुओं को न हटाएं।',
          recommendedAction:
              'शेष पशुओं का सख्त संगरोध (क्वारंटीन) करें। जांच के लिए तुरंत स्थानीय पशु चिकित्सालय से संपर्क करें।',
          suspectedConditions: ['एंथ्रेक्स (Anthrax)', 'गलघोंटू (HS)', 'तीव्र विषाक्तता'],
        );
      case AppLanguage.english:
        return const TriageResult(
          riskLevel: RiskLevel.critical,
          title: 'CRITICAL HEALTH RISK — MORTALITY REPORTED',
          advice: 'Animal death reported. Please avoid moving animals from the affected area.',
          recommendedAction:
              'Keep other animals strictly isolated. Contact local veterinary hospital immediately for autopsy and investigation.',
          suspectedConditions: ['Anthrax', 'Hemorrhagic Septicemia (HS)', 'Acute Toxicosis'],
        );
    }
  }

  static TriageResult _generateCriticalResult(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.marathi:
        return const TriageResult(
          riskLevel: RiskLevel.critical,
          title: 'गंभीर आरोग्य जोखीम',
          advice: 'त्वरित पशुवैद्यकीय मदत आवश्यक आहे. बाधित जनावराला आत्ताच वेगळे करा.',
          recommendedAction:
              'बाधित जनावराला कळपापासून पूर्णपणे वेगळे ठेवा. तातडीने स्थानिक पशुवैद्यकास बोलवा व इतर जनावरांची तपासणी करा.',
          suspectedConditions: ['लाळ्या खुरकूत (FMD)', 'घटसर्प (HS)', 'एकटांग्या / फऱ्या (BQ)'],
        );
      case AppLanguage.hindi:
        return const TriageResult(
          riskLevel: RiskLevel.critical,
          title: 'गंभीर स्वास्थ्य जोखिम',
          advice: 'तत्काल पशु चिकित्सक की आवश्यकता है। पशु को तुरंत अलग करें।',
          recommendedAction:
              'संक्रमण रोकने के लिए प्रभावित पशु को झुंड से अलग रखें। तत्काल डॉक्टर की सलाह लें और आवागमन रोकें।',
          suspectedConditions: ['खुरपका-मुंहपका (FMD)', 'गलघोंटू (HS)', 'लंगड़ा बुखार (BQ)'],
        );
      case AppLanguage.english:
        return const TriageResult(
          riskLevel: RiskLevel.critical,
          title: 'CRITICAL HEALTH RISK',
          advice: 'Immediate veterinary attention is required. Isolate the animal now.',
          recommendedAction:
              'Please keep the affected animal completely separated from the herd and contact a veterinarian urgently.',
          suspectedConditions: ['Foot-and-Mouth Disease (FMD)', 'Hemorrhagic Septicemia (HS)', 'Black Quarter (BQ)'],
        );
    }
  }

  static TriageResult _generateHighResult(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.marathi:
        return const TriageResult(
          riskLevel: RiskLevel.high,
          title: 'उच्च आरोग्य जोखीम',
          advice: 'कृपया बाधित जनावराला इतर जनावरांपासून वेगळे करा आणि पशुवैद्यकास बोलवा.',
          recommendedAction:
              'रोग प्रसार रोखण्यासाठी हे जनावर वेगळे ठेवा. पशुवैद्यकीय तपासणीची विनंती करा आणि स्वच्छ पिण्याचे पाणी द्या.',
          suspectedConditions: ['लाळ्या खुरकूत (FMD)', 'तीव्र श्वसन विकार', 'संसर्गजन्य ताप'],
        );
      case AppLanguage.hindi:
        return const TriageResult(
          riskLevel: RiskLevel.high,
          title: 'उच्च स्वास्थ्य जोखिम',
          advice: 'कृपया प्रभावित पशु को अलग करें और पशु चिकित्सक से जांच का अनुरोध करें।',
          recommendedAction:
              'रोग प्रसार रोकने के लिए पशु को अलग करें। नजदीकी पशु चिकित्सक से संपर्क करें और स्वच्छ पानी दें।',
          suspectedConditions: ['खुरपका-मुंहपका (FMD)', 'श्वसन संक्रमण', 'तीव्र ज्वर'],
        );
      case AppLanguage.english:
        return const TriageResult(
          riskLevel: RiskLevel.high,
          title: 'HIGH HEALTH RISK',
          advice: 'Please isolate the affected animal and request veterinarian review.',
          recommendedAction:
              'Separate this animal to prevent disease spread. Request veterinarian assistance and provide clean drinking water.',
          suspectedConditions: ['Foot-and-Mouth Disease (FMD)', 'Acute Respiratory Illness', 'Infectious Bovine Fever'],
        );
    }
  }

  static TriageResult _generateMediumResult(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.marathi:
        return const TriageResult(
          riskLevel: RiskLevel.medium,
          title: 'मध्यम आरोग्य जोखीम',
          advice: 'जनावराचे बारकाईने निरीक्षण करा आणि लक्षणे कायम राहिल्यास डॉक्टरांशी संपर्क साधा.',
          recommendedAction:
              'दिवसातून दोनदा जनावराची तपासणी करा. पुरेसा चारा, स्वच्छ पाणी आणि सावली द्या.',
          suspectedConditions: ['किरकोळ पचन बिघाड', 'सामान्य संसर्ग'],
        );
      case AppLanguage.hindi:
        return const TriageResult(
          riskLevel: RiskLevel.medium,
          title: 'मध्यम स्वास्थ्य जोखिम',
          advice: 'पशु की बारीकी से निगरानी करें और लक्षण बने रहने पर पशु चिकित्सक से संपर्क करें।',
          recommendedAction:
              'दिन में दो बार पशु की जांच करें। पर्याप्त स्वच्छ पानी, सुपाच्य चारा और shelter प्रदान करें।',
          suspectedConditions: ['पाचन विकार', 'सामान्य संक्रमण'],
        );
      case AppLanguage.english:
        return const TriageResult(
          riskLevel: RiskLevel.medium,
          title: 'MEDIUM HEALTH RISK',
          advice: 'Monitor the animal closely and prepare to contact a veterinarian if needed.',
          recommendedAction:
              'Check the animal twice daily. Provide adequate feed, clean electrolytes/water, and shelter.',
          suspectedConditions: ['Mild Digestive Upset', 'General Infection'],
        );
    }
  }

  static TriageResult _generateLowResult(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.marathi:
        return const TriageResult(
          riskLevel: RiskLevel.low,
          title: 'कमी आरोग्य जोखीम',
          advice: 'जनावराचे नियमित निरीक्षण सुरू ठेवा.',
          recommendedAction:
              'कोणतीही तातडीची गरज नाही. जनावराचे निरीक्षण चालू ठेवा आणि स्वच्छ पाणी व आहार द्या.',
          suspectedConditions: ['सामान्य आरोग्य स्थिती'],
        );
      case AppLanguage.hindi:
        return const TriageResult(
          riskLevel: RiskLevel.low,
          title: 'कम स्वास्थ्य जोखिम',
          advice: 'पशु की सामान्य निगरानी जारी रखें।',
          recommendedAction:
              'किसी आपातकालीन कदम की आवश्यकता नहीं है। सामान्य देखभाल और निगरानी जारी रखें।',
          suspectedConditions: ['सामान्य स्वास्थ्य'],
        );
      case AppLanguage.english:
        return const TriageResult(
          riskLevel: RiskLevel.low,
          title: 'LOW HEALTH RISK',
          advice: 'Continue regular monitoring of the animal.',
          recommendedAction:
              'No immediate emergency action needed. Keep observing the animal and ensure clean feed and water.',
          suspectedConditions: ['General Health Normal'],
        );
    }
  }

  static TriageResult _generateLowRiskEmpty(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.marathi:
        return const TriageResult(
          riskLevel: RiskLevel.low,
          title: 'कमी आरोग्य जोखीम',
          advice: 'कोणतीही धोक्याची लक्षणे नोंदवलेली नाहीत.',
          recommendedAction: 'नेहमीप्रमाणे जनावराची काळजी घ्या.',
        );
      case AppLanguage.hindi:
        return const TriageResult(
          riskLevel: RiskLevel.low,
          title: 'कम स्वास्थ्य जोखिम',
          advice: 'कोई चिंताजनक लक्षण नहीं मिला।',
          recommendedAction: 'सामान्य देखभाल जारी रखें।',
        );
      case AppLanguage.english:
        return const TriageResult(
          riskLevel: RiskLevel.low,
          title: 'LOW HEALTH RISK',
          advice: 'No critical symptoms reported.',
          recommendedAction: 'Continue standard herd observation.',
        );
    }
  }
}
