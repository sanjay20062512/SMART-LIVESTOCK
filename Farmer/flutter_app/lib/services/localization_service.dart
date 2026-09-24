// LocalizationService — Centralized language and string dictionary.
// Full native multilingual support for English, हिन्दी (Hindi), and मराठी (Marathi).
// Implements JSON asset loading, SharedPreferences persistence, and Devanagari fallbacks.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english('English', 'en'),
  hindi('हिन्दी', 'hi'),
  marathi('मराठी', 'mr');

  final String label;
  final String code;
  const AppLanguage(this.label, this.code);

  String get voiceLocaleCode {
    switch (code) {
      case 'hi':
        return 'hi-IN';
      case 'mr':
        return 'mr-IN';
      case 'en':
      default:
        return 'en-IN';
    }
  }

  String get nativeDescription {
    switch (code) {
      case 'hi':
        return 'हिन्दी में जारी रखने के लिए चुनें';
      case 'mr':
        return 'मराठीत पुढे सुरू ठेवण्यासाठी निवडा';
      case 'en':
      default:
        return 'Select English to continue';
    }
  }
}

class LocalizationService extends ChangeNotifier {
  static final LocalizationService instance = LocalizationService._internal();
  LocalizationService._internal();

  static const String _prefKey = 'app_language';
  AppLanguage _currentLanguage = AppLanguage.english;
  bool _isInitialized = false;

  final Map<String, Map<String, String>> _loadedStrings = {};

  AppLanguage get currentLanguage => _currentLanguage;
  String get voiceLocaleCode => _currentLanguage.voiceLocaleCode;
  bool get isInitialized => _isInitialized;

  /// Initialize from SharedPreferences and asynchronously load JSON locale files.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKey);
      if (savedCode != null) {
        _currentLanguage = AppLanguage.values.firstWhere(
          (l) => l.code == savedCode,
          orElse: () => AppLanguage.english,
        );
      }
    } catch (e) {
      debugPrint('LocalizationService: Error loading saved language: $e');
    }

    await _loadAllJsonLocales();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadAllJsonLocales() async {
    for (final lang in AppLanguage.values) {
      try {
        final jsonString = await rootBundle.loadString('assets/locales/${lang.code}.json');
        final Map<String, dynamic> parsed = jsonDecode(jsonString);
        _loadedStrings[lang.code] = parsed.map((k, v) => MapEntry(k, v.toString()));
      } catch (e) {
        debugPrint('LocalizationService: Error loading assets/locales/${lang.code}.json: $e');
      }
    }
  }

  /// Change active language and persist to disk.
  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefKey, language.code);
      } catch (e) {
        debugPrint('LocalizationService: Error saving language to prefs: $e');
      }
    }
  }

  void setLanguageByName(String name) {
    final match = AppLanguage.values.firstWhere(
      (l) =>
          l.name.toLowerCase() == name.toLowerCase() ||
          l.label.toLowerCase() == name.toLowerCase() ||
          l.code.toLowerCase() == name.toLowerCase(),
      orElse: () => AppLanguage.english,
    );
    setLanguage(match);
  }

  /// Central string translation method.
  String tr(String key, {Map<String, String>? params}) {
    final langKey = _currentLanguage.code;

    // 1. Try loaded JSON string for active language
    String? text = _loadedStrings[langKey]?[key];

    // 2. Try embedded fallback dictionary for active language
    text ??= _embeddedFallbackStrings[langKey]?[key];

    // 3. Try common phrase dictionary for active language
    text ??= _commonPhraseTranslations[key]?[langKey];

    // 4. Try normalized key (trimmed, lowercase)
    final normalizedKey = key.trim().toLowerCase();
    text ??= _loadedStrings[langKey]?[normalizedKey];
    text ??= _embeddedFallbackStrings[langKey]?[normalizedKey];
    text ??= _commonPhraseTranslations[normalizedKey]?[langKey];

    // 5. Try loaded JSON string for English
    text ??= _loadedStrings['en']?[key];

    // 6. Try embedded fallback dictionary for English
    text ??= _embeddedFallbackStrings['en']?[key];

    // 7. Try common phrase dictionary for English
    text ??= _commonPhraseTranslations[key]?['en'];
    text ??= _commonPhraseTranslations[normalizedKey]?['en'];

    // 8. Raw key fallback
    text ??= key;

    if (params != null && params.isNotEmpty) {
      params.forEach((k, v) {
        text = text!.replaceAll('{$k}', v);
      });
    }

    return text!;
  }

  /// Translates arbitrary text or clinical terms (symptoms, breeds, species, statuses)
  /// Translates arbitrary text or clinical terms (symptoms, breeds, species, statuses, alerts, notes)
  String translateText(String? text) {
    if (text == null || text.trim().isEmpty) return '';
    final trimmed = text.trim();
    final langKey = _currentLanguage.code;

    // If active language is English and text matches English phrase, return it directly
    if (langKey == 'en') {
      final enMatch = _commonPhraseTranslations[trimmed]?['en'] ??
          _commonPhraseTranslations[trimmed.toLowerCase()]?['en'];
      if (enMatch != null) return enMatch;
    }

    // Direct lookup in phrase dictionary
    final phrase = _commonPhraseTranslations[trimmed]?[langKey] ??
        _commonPhraseTranslations[trimmed.toLowerCase()]?[langKey];
    if (phrase != null) return phrase;

    // Direct lookup in tr
    final trResult = tr(trimmed);
    if (trResult != trimmed) return trResult;

    // Check for leading emojis (e.g. "🚨 CRITICAL: 4 Buffaloes Affected", "📢 Free Vaccination Camp")
    final emojiMatch = RegExp(r'^([\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE00}-\u{FE0F}\u{1F900}-\u{1F9FF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}]+)\s*(.*)$', unicode: true).firstMatch(trimmed);
    if (emojiMatch != null) {
      final emoji = emojiMatch.group(1)!;
      final rest = emojiMatch.group(2)!.trim();
      if (rest.isNotEmpty) {
        final restTrans = translateText(rest);
        if (restTrans != rest) {
          return '$emoji $restTrans';
        }
      }
    }

    // Check for comma-separated lists (e.g. "Reduced Milk Yield, Swollen Udder" or "Uruli Kanchan, Haveli, Pune")
    if (trimmed.contains(',')) {
      final parts = trimmed.split(',').map((p) => translateText(p.trim())).toList();
      return parts.join(', ');
    }

    // Check for bullet/dash separated lists (e.g. "Cow (C001) • Jersey" or "High Risk — High Fever")
    if (trimmed.contains('—')) {
      final parts = trimmed.split('—').map((p) => translateText(p.trim())).toList();
      return parts.join(' — ');
    }
    if (trimmed.contains('•')) {
      final parts = trimmed.split('•').map((p) => translateText(p.trim())).toList();
      return parts.join(' • ');
    }

    // If target language is English, we don't need to apply the translation regexes
    // because the original input strings (mock data/backend data) are already in English.
    if (langKey == 'en') {
      return trimmed;
    }

    // Dynamic pattern: "New Case: <TAG> (<RISK>)"
    final newCaseMatch = RegExp(r'^New Case:\s*(\S+)\s*\((.*?)\)$', caseSensitive: false).firstMatch(trimmed);
    if (newCaseMatch != null) {
      final tag = translateTag(newCaseMatch.group(1));
      final risk = translateText(newCaseMatch.group(2));
      return langKey == 'mr' ? 'नवीन केस: $tag ($risk)' : 'नया मामला: $tag ($risk)';
    }

    // Dynamic pattern: "Farmer <NAME> in <VILLAGE> reported: <SYMPTOMS>."
    final farmerReportMatch = RegExp(r'^Farmer\s+(.*?)\s+in\s+(.*?)\s+reported:\s*(.*?)\.?$', caseSensitive: false).firstMatch(trimmed);
    if (farmerReportMatch != null) {
      final fName = translateText(farmerReportMatch.group(1));
      final fVillage = translateText(farmerReportMatch.group(2));
      final fSymp = translateText(farmerReportMatch.group(3));
      return langKey == 'mr'
          ? 'शेतकरी $fName ($fVillage) यांनी नोंदवले: $fSymp.'
          : 'किसान $fName ($fVillage) ने रिपोर्ट किया: $fSymp।';
    }

    // Dynamic pattern: "CRITICAL: Animal Mortality in <VILLAGE>"
    final critMortMatch = RegExp(r'^(?:CRITICAL:\s*)?Animal Mortality in\s+(.*?)$', caseSensitive: false).firstMatch(trimmed);
    if (critMortMatch != null) {
      final fVillage = translateText(critMortMatch.group(1));
      return langKey == 'mr' ? 'गंभीर: $fVillage मध्ये जनावराचा मृत्यू' : 'गंभीर: $fVillage में पशु मृत्यु';
    }

    // Dynamic pattern: "Farmer <NAME> reported death of <TAG>. Suspected cause: <CAUSE>."
    final deathReportMatch = RegExp(r'^Farmer\s+(.*?)\s+reported death of\s+(\S+)\.\s*Suspected cause:\s*(.*?)\.?$', caseSensitive: false).firstMatch(trimmed);
    if (deathReportMatch != null) {
      final fName = translateText(deathReportMatch.group(1));
      final fTag = translateTag(deathReportMatch.group(2));
      final fCause = translateText(deathReportMatch.group(3));
      return langKey == 'mr'
          ? 'शेतकरी $fName यांनी $fTag च्या मृत्यूची माहिती दिली. संशयित कारण: $fCause.'
          : 'किसान $fName ने $fTag की मृत्यु की सूचना दी। संदिग्ध कारण: $fCause।';
    }

    // Dynamic pattern: "Visit Request: <TAG>"
    final visitReqMatch = RegExp(r'^Visit Request:\s*(\S+)$', caseSensitive: false).firstMatch(trimmed);
    if (visitReqMatch != null) {
      final fTag = translateTag(visitReqMatch.group(1));
      return langKey == 'mr' ? 'भेटीची विनंती: $fTag' : 'भेंट का अनुरोध: $fTag';
    }

    // Dynamic pattern: "Farmer <NAME> requested visit for "<REASON>". Slot: <SLOT>."
    final farmerVisitMatch = RegExp(r'^Farmer\s+(.*?)\s+requested visit for\s+"(.*?)".\s*Slot:\s*(.*?)\.?$', caseSensitive: false).firstMatch(trimmed);
    if (farmerVisitMatch != null) {
      final fName = translateText(farmerVisitMatch.group(1));
      final fReason = translateText(farmerVisitMatch.group(2));
      final fSlot = translateText(farmerVisitMatch.group(3));
      return langKey == 'mr'
          ? 'शेतकरी $fName यांनी "$fReason" साठी भेटीची विनंती केली. वेळ: $fSlot.'
          : 'किसान $fName ने "$fReason" के लिए भेंट का अनुरोध किया। समय: $fSlot।';
    }

    // Dynamic pattern: "Case #<ID> Escalated to Government"
    final escMatch = RegExp(r'^Case #(\S+)\s+Escalated to Government$', caseSensitive: false).firstMatch(trimmed);
    if (escMatch != null) {
      final fId = translateTag(escMatch.group(1));
      return langKey == 'mr' ? 'केस #$fId शासनाकडे वर्ग केली' : 'केस #$fId शासन को संदर्भित किया गया';
    }

    // Dynamic pattern: "Dr. <NAME> escalated this case to regional animal health authorities..."
    final escBodyMatch = RegExp(r'^Dr\.\s+(.*?)\s+escalated this case to regional animal health authorities for emergency assistance\.?$', caseSensitive: false).firstMatch(trimmed);
    if (escBodyMatch != null) {
      final fName = translateText(escBodyMatch.group(1));
      return langKey == 'mr'
          ? 'डॉ. $fName यांनी तातडीच्या मदतीसाठी हे प्रकरण प्रादेशिक पशु आरोग्य अधिकाऱ्यांकडे वर्ग केले.'
          : 'डॉ. $fName ने आपातकालीन सहायता के लिए इस मामले को क्षेत्रीय पशु स्वास्थ्य अधिकारियों को भेजा।';
    }

    // Dynamic pattern: "Visit Scheduled: <NAME>"
    final visitSchedMatch = RegExp(r'^Visit Scheduled:\s*(.*?)$', caseSensitive: false).firstMatch(trimmed);
    if (visitSchedMatch != null) {
      final fName = translateText(visitSchedMatch.group(1));
      return langKey == 'mr' ? 'भेट नियोजित: $fName' : 'भेंट निर्धारित: $fName';
    }

    // Dynamic pattern: "<NAME> has scheduled a farm visit on <DATE> for animal <TAG>."
    final visitSchedBodyMatch = RegExp(r'^(.*?)\s+has scheduled a farm visit on\s+(\S+)\s+for animal\s+(.*?)\.?$', caseSensitive: false).firstMatch(trimmed);
    if (visitSchedBodyMatch != null) {
      final fName = translateText(visitSchedBodyMatch.group(1));
      final fDate = visitSchedBodyMatch.group(2);
      final fTag = translateTag(visitSchedBodyMatch.group(3));
      return langKey == 'mr'
          ? '$fName यांनी जनावर $fTag साठी $fDate रोजी फार्म भेट निश्चित केली आहे.'
          : '$fName ने पशु $fTag के लिए दिनांक $fDate को फार्म भेंट निर्धारित की है।';
    }

    // Check for regex patterns like "X animal(s) affected"
    final animalAffectedMatch = RegExp(r'^(\d+)\s+animal\(s\)\s+affected', caseSensitive: false).firstMatch(trimmed);
    if (animalAffectedMatch != null) {
      final count = animalAffectedMatch.group(1);
      return tr('animals_affected_count', params: {'count': count ?? '1'});
    }

    // Check for "(X) Risk"
    final riskMatch = RegExp(r'^(LOW|MEDIUM|HIGH|CRITICAL)\s*Risk', caseSensitive: false).firstMatch(trimmed);
    if (riskMatch != null) {
      final level = riskMatch.group(1)!.toUpperCase();
      final levelTrans = tr('risk_${level.toLowerCase()}');
      return levelTrans != 'risk_${level.toLowerCase()}' ? levelTrans : '$level ${tr("risk")}';
    }

    // Word-by-word fallback for names or titles
    if (trimmed.contains(' ')) {
      final words = trimmed.split(RegExp(r'\s+'));
      bool allTranslated = true;
      final translatedWords = <String>[];
      for (final w in words) {
        final tw = _commonPhraseTranslations[w]?[langKey] ?? _commonPhraseTranslations[w.toLowerCase()]?[langKey];
        if (tw != null) {
          translatedWords.add(tw);
        } else {
          allTranslated = false;
          break;
        }
      }
      if (allTranslated && translatedWords.isNotEmpty) {
        return translatedWords.join(' ');
      }
    }

    return trimmed;
  }

  /// Specialized helper to translate animal species name
  String translateSpecies(String? species) {
    if (species == null || species.trim().isEmpty) return tr('species');
    return translateText(species.trim());
  }

  /// Specialized helper to translate breed name
  String translateBreed(String? breed) {
    if (breed == null || breed.trim().isEmpty) return '';
    return translateText(breed.trim());
  }

  /// Specialized helper to translate symptom name
  String translateSymptom(String symptom) {
    return translateText(symptom);
  }

  /// Specialized helper to translate status
  String translateStatus(String status) {
    return translateText(status);
  }

  /// Specialized helper to translate ear tags (e.g. C001 -> सी००१, SMP001 -> एसएमपी००१ in Hindi/Marathi)
  String translateTag(String? tag) {
    if (tag == null || tag.trim().isEmpty) return '';
    final trimmed = tag.trim();
    final langKey = _currentLanguage.code;
    if (langKey == 'en') return trimmed;

    final devanagariDigits = {
      '0': '०', '1': '१', '2': '२', '3': '३', '4': '४',
      '5': '५', '6': '६', '7': '७', '8': '८', '9': '९'
    };

    String prefix = '';
    String numPart = trimmed;

    if (trimmed.toUpperCase().startsWith('SMP')) {
      prefix = 'एसएमपी';
      numPart = trimmed.substring(3);
    } else if (trimmed.startsWith(RegExp(r'^[Cc](?=\d)'))) {
      prefix = 'सी';
      numPart = trimmed.substring(1);
    } else if (trimmed.startsWith(RegExp(r'^[Gg](?=\d)'))) {
      prefix = 'जी';
      numPart = trimmed.substring(1);
    } else if (trimmed.startsWith(RegExp(r'^[Bb](?=\d)'))) {
      prefix = 'बी';
      numPart = trimmed.substring(1);
    } else if (trimmed.toUpperCase().startsWith('TAG-') || trimmed.toUpperCase().startsWith('TAG')) {
      prefix = tr('animal_id') == 'animal_id' ? 'टैग ' : '${tr('animal_id')} ';
      numPart = trimmed.replaceFirst(RegExp(r'TAG-?', caseSensitive: false), '');
    } else {
      final match = RegExp(r'^([A-Za-z]+)(\d.*)$').firstMatch(trimmed);
      if (match != null) {
        final letters = match.group(1)!.toUpperCase();
        if (letters == 'SMP') {
          prefix = 'एसएमपी';
        } else if (letters == 'C') {
          prefix = 'सी';
        } else if (letters == 'B') {
          prefix = 'बी';
        } else if (letters == 'G') {
          prefix = 'जी';
        } else {
          prefix = letters;
        }
        numPart = match.group(2)!;
      }
    }

    final buffer = StringBuffer(prefix);
    for (int i = 0; i < numPart.length; i++) {
      final ch = numPart[i];
      buffer.write(devanagariDigits[ch] ?? ch);
    }
    return buffer.toString();
  }


  // â”€â”€â”€ In-memory fallback dictionary â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static final Map<String, Map<String, String>> _embeddedFallbackStrings = {
    'en': {
      'app_title': 'Smart Livestock',
      'app_subtitle': 'Animal Health Surveillance System',
      'choose_language': 'Choose your language',
      'select_language_subtitle': 'Select a language to continue with the app',
      'select_role': 'SELECT YOUR ROLE',
      'continue': 'CONTINUE',
      'next': 'Next',
      'back': 'Back',
      'save': 'Save',
      'cancel': 'Cancel',
      'done': 'Done',
      'submit': 'SUBMIT',
      'edit': 'Edit',
      'edit_farm_details': 'Edit Farm Details',
      'online': 'Online',
      'offline': 'Offline',
      'loading': 'Loading...',
      'listen': 'Listen',
      'close': 'Close',
      'back_to_home': 'BACK TO HOME',
      'search': 'Search...',
      'no_data': 'No records found',
      'confirm': 'Confirm',
      'success': 'Success',
      'error': 'Error',
      'language_changed': 'Language changed successfully',

      // Roles
      'role_farmer_title': 'Farmer',
      'role_farmer_sub': 'Report animal problems, track cases, receive advisories',
      'role_farmer_badge': 'Farmer Portal',
      'role_vet_title': 'Veterinarian',
      'role_vet_sub': 'Review cases, schedule visits, collect samples, manage treatments',
      'role_vet_badge': 'Field Veterinary Services',
      'role_govt_title': 'Government',
      'role_govt_sub': 'Surveillance dashboard, cluster detection, advisories, response',
      'role_govt_badge': 'Animal Health Authority',

      // Login & Registration
      'login_title': 'Farmer Login',
      'vet_login_title': 'Veterinarian Login',
      'govt_login_title': 'Surveillance Officer Login',
      'mobile_number': 'Mobile Number',
      'enter_mobile_hint': 'Enter 10-digit mobile number',
      'password': 'Password',
      'enter_password_hint': 'Enter your password',
      'confirm_password': 'Confirm Password',
      'login_button': 'LOGIN',
      'forgot_password': 'Forgot Password?',
      'new_farmer_register': 'New Farmer? Register',
      'already_account': 'Already have an account? Login',
      'about_you': 'About You',
      'full_name': 'Full Name',
      'speak_name': 'Speak your name',
      'email_optional': 'Email (optional)',
      'where_is_farm': 'Where is your farm?',
      'state': 'State',
      'district': 'District',
      'block_taluk': 'Block / Taluk',
      'village': 'Village',
      'about_farm': 'About Your Farm',
      'farm_name_optional': 'Farm Name (optional)',
      'farm_size': 'Farm Size',
      'farm_size_unit': 'Size Unit',
      'acres': 'Acres',
      'hectares': 'Hectares',
      'cent': 'Cent',
      'farm_location': 'Farm Location',
      'use_current_location': 'Use Current Location',
      'enter_location_manually': 'Enter Location Manually',
      'livestock_type': 'Livestock Type',
      'cow': 'Cow',
      'buffalo': 'Buffalo',
      'goat': 'Goat',
      'sheep': 'Sheep',
      'pig': 'Pig',
      'poultry': 'Poultry',
      'other': 'Other',
      'language_preferences': 'Language & Preferences',
      'preferred_language': 'Preferred Language',
      'communication_preference': 'Communication Preference',
      'comm_voice': 'Voice',
      'comm_text': 'Text',
      'comm_both': 'Both Voice & Text',
      'create_farmer_profile': 'CREATE FARMER PROFILE',
      'verify_mobile': 'Verify Mobile Number',
      'demo_otp_notice': 'Enter OTP',
      'enter_otp': 'Enter OTP',
      'create_password_title': 'Create Password',
      'create_account_btn': 'Create Account',
      'account_created_success': 'Account Created Successfully!',
      'official_id': 'Veterinary Registration ID',
      'officer_id': 'Officer / Employee ID',

      // Navigation Bar
      'nav_home': 'Home',
      'nav_my_cases': 'My Cases',
      'nav_report': 'Report',
      'nav_alerts': 'Alerts',
      'nav_profile': 'Profile',

      // Dashboard
      'hello_farmer': 'Hello, {name}',
      'report_animal_problem': 'REPORT ANIMAL PROBLEM',
      'report_problem_subtitle': 'Fast 5-step triage with photo, video, and voice notes',
      'my_animals_cases': 'My Cases',
      'request_veterinarian': 'Request Veterinarian',
      'weather_livestock_health': 'Weather & Livestock Health',
      'weather_health_subtitle': 'Advisory, disease risk & farm conditions',
      'alerts': 'Alerts',
      'animals_reported': 'Animals Reported',
      'active_cases': 'Active Cases',
      'vaccination_due': 'Vaccination Due',
      'important_alerts': 'Important Alerts',
      'recent_activity': 'Recent Activity',
      'view_all': 'View All',

      // Report Wizard
      'start_assessment': 'Start Assessment',
      'step_animal': 'Animal',
      'step_symptoms': 'Symptoms',
      'step_details': 'Details',
      'step_evidence': 'Evidence',
      'step_summary': 'Summary',
      'what_animal_problem': 'What animal has a problem?',
      'tell_about_animal': 'Tell us about the animal',
      'animal_id_tag': 'Animal ID / Ear Tag (optional)',
      'select_breed': 'Select Breed',
      'gender': 'Gender',
      'male': 'Male',
      'female': 'Female',
      'age': 'Age',
      'age_below_1': 'Below 1 year',
      'age_1_2': '1–2 years',
      'age_2_5': '2–5 years',
      'age_5_10': '5–10 years',
      'age_above_10': 'Above 10 years',

      // Symptoms
      'what_is_wrong': 'What is wrong with the animal?',
      'select_all_symptoms_hint': 'Select all symptoms you observe:',
      'sym_fever': 'Fever',
      'sym_not_eating': 'Not eating',
      'sym_breathing': 'Breathing problem',
      'sym_walking': 'Difficulty walking',
      'sym_diarrhea': 'Diarrhea',
      'sym_salivation': 'Excessive salivation',
      'sym_weakness': 'Weakness',
      'sym_skin_lesions': 'Skin lesions / blisters',
      'sym_vomiting': 'Vomiting',
      'sym_nasal_discharge': 'Nasal discharge',
      'sym_eye_problem': 'Eye problem',
      'sym_bleeding': 'Bleeding',
      'sym_milk_reduced': 'Milk production reduced',
      'sym_pregnancy_problem': 'Pregnancy / birth problem',
      'sym_other': 'Other symptoms',

      // Since when
      'since_when': 'Since when?',
      'today': 'Today',
      'yesterday': 'Yesterday',
      '2_3_days': '2–3 days',
      '4_7_days': '4–7 days',
      'more_than_week': 'More than a week',
      'not_sure': 'Not sure',

      // Eating & Drinking
      'is_animal_eating': 'Is the animal eating feed?',
      'is_animal_drinking': 'Is the animal drinking water?',
      'yes': 'Yes',
      'less_than_usual': 'Less than usual',
      'no': 'No',
      'how_many_affected': 'How many animals have this problem?',
      'is_pregnant': 'Is the animal pregnant?',
      'is_lactating': 'Currently giving milk?',

      // Evidence & Voice
      'show_us_problem': 'Show us the problem',
      'voice_photo_help_diag': 'Voice and photo help the veterinarian diagnose faster.',
      'take_photo': 'Take Photo',
      'record_video': 'Record Video',
      'record_voice': 'Record Voice',
      'write_description': 'Write Description',
      'extra_notes_vet_hint': 'Any extra notes for the vet...',
      'tell_what_happened': 'Tell us what happened',
      'tap_and_speak': 'TAP AND SPEAK',
      'tap_to_speak': 'Tap to Speak',
      'speak_in_language': 'Speak in your language',
      'voice_recorded': 'Voice recorded',
      'voice_lang_tag': 'English',
      'recording': 'Listening... Speak now',
      'stop': 'Stop & Save',
      'play': 'Listen',
      'record_again': 'Record Again',
      'photo_added': 'Photo added',
      'video_added': 'Video added',

      // Location & Summary
      'where_is_animal': 'Where is the animal?',
      'confirm_animal_location_diag': 'Confirm the animal location for vet dispatch.',
      'acquiring_device_gps': 'Acquiring device GPS...',
      'use_farm_location': 'Use Farm Location',
      'report_summary': 'Report Summary',
      'submit_report': 'SUBMIT REPORT',
      'assessment_result': 'Assessment Result',
      'report_submitted_net': 'Report Submitted & Logged to Surveillance Network',
      'recommended_action': 'Recommended Action',
      'suspected_diseases': 'Suspected Conditions / Differential',
      'explanation': 'Clinical Explanation',

      // Risk Assessment
      'health_risk_assessment': 'Health Risk Assessment',
      'risk_low': 'LOW HEALTH RISK',
      'risk_medium': 'MEDIUM HEALTH RISK',
      'risk_high': 'HIGH HEALTH RISK',
      'risk_critical': 'CRITICAL HEALTH RISK',

      // Mortality Report
      'report_animal_death': 'Report Animal Death',
      'how_many_died': 'How many animals died?',
      'when_happened': 'When did it happen?',
      'problems_before_death': 'Problems before death',
      'death_reported_title': 'CRITICAL: Animal death reported',
      'death_reported_msg': 'Please avoid moving animals from the affected area. Strict quarantine is recommended.',

      // Vet Request
      'need_veterinarian': 'Need a Veterinarian?',
      'select_case': 'Select Animal / Case',
      'reason_for_vet': 'Reason for Request',
      'reason_very_sick': 'Animal is very sick',
      'reason_not_improving': 'Animal not improving',
      'reason_death': 'Animal death',
      'reason_vaccination': 'Vaccination request',
      'reason_treatment': 'Treatment follow-up',
      'reason_other': 'Other',
      'preferred_visit': 'Preferred Visit Date',
      'preferred_time': 'Preferred Time',
      'morning': 'Morning (8 AM – 12 PM)',
      'afternoon': 'Afternoon (12 PM – 4 PM)',
      'evening': 'Evening (4 PM – 7 PM)',
      'status_submitted': 'SUBMITTED',
      'status_under_review': 'UNDER REVIEW',
      'status_vet_assigned': 'VET ASSIGNED',
      'status_visit_scheduled': 'VISIT SCHEDULED',
      'status_treatment_started': 'TREATMENT STARTED',
      'status_case_closed': 'CASE CLOSED',

      'farmer_details': 'Farmer Details',
      'farm_details': 'Farm Details',
      'app_settings': 'App Settings',
      'change_language': 'Change Language',
      'smart_livestock': 'Smart Livestock',
      'veterinary_dashboard': 'Veterinary Dashboard',
      'vet_officer_title': 'Dr. Rajesh Kumar · Veterinary Officer',
      'notifications': 'Notifications',
      'logout': 'Logout',
      'logout_confirm': 'Are you sure you want to log out?',

      'step_counter': 'Step {step} of {total}',
      'basic_info_subtitle': 'Please provide your basic contact information.',
      'name_hint': 'e.g. Ramesh Patil (or speak)',
      'tap_speak_name': 'Tap to speak your name',
      'listening_tap_stop': 'Listening... Tap to Stop & Save',
      'speak_your_name': 'Speak your name',
      'stop_listening': 'Stop listening',
      'location_subtitle': 'Select your location details from dropdowns.',
      'fixed': 'Fixed',
      'taluk': 'Taluk',
      'village_hint': 'Enter your village name',
      'farm_details_subtitle': 'Enter farm size and select your livestock.',
      'select_all_apply': 'Select all that apply',
      'livestock_type_select_all': 'Livestock Type (Select all that apply)',
      'pref_subtitle': 'Choose how you want to interact with the app.',
      'verification_code_sent': 'We sent a verification code to {mobile}.',
      'autofill_demo_otp': 'Auto-fill Demo OTP ({otp})',
      'verify_and_continue': 'VERIFY & CONTINUE',
      'create_password_subtitle': 'Create a password for {name} to log in easily.',
      'welcome_ready': 'Welcome, {name}! You are ready to manage your farm.',
      'farm_health_summary': 'Farm Health Summary',
      'see_all_cases': 'See All Cases',
      'activity_animal_registered': 'Animal Registered',
      'activity_health_reported': 'Health Report',
      'activity_mortality_reported': 'Mortality Report',
      'activity_vet_requested': 'Vet Requested',
      'no_recent_activity': 'No recent reports or actions yet.',
      'use_report_button_to_start': 'Use the Report button above to get started.',
      'animals_affected_count': '{count} animal(s) affected',
      'alerts_and_advisories': 'Alerts & Advisories',
      'mark_all_read': 'Mark All Read',
      'no_alerts_yet': 'No alerts yet',
      'no_alerts_subtitle': 'Alerts will appear here when health reports, mortality events, or advisories are created.',
      'tab_health': 'Health',
      'tab_mortality': 'Mortality',
      'tab_vet_visits': 'Vet Visits',
      'report_new_problem': 'Report New Problem',
      'report_an_issue': 'Report an Issue',
      'what_to_report': 'What would you like to report?',
      'report_symptoms': 'Report Symptoms',
      'report_symptoms_desc': 'Select an animal and report health symptoms for risk assessment.',
      'report_mortality': 'Report Mortality',
      'report_mortality_desc': 'Report the death of an animal. A critical alert will be created.',
      'request_vet': 'Request Veterinarian',
      'request_vet_desc': 'Request a veterinarian visit for an animal in need.',
      'my_recent_reports': 'My Recent Reports',
      'farmer_profile': 'Farmer Profile',
      'section_farmer_details': 'SECTION 1 — FARMER DETAILS',
      'section_farm_details': 'SECTION 2 — FARM DETAILS',
      'edit_farmer_details': 'Edit Farmer Details',
      'save_farm_details': 'SAVE FARM DETAILS',
      'location_mode': 'Location Mode',
      'gender_male': 'Male',
      'gender_female': 'Female',
      'status_healthy': 'Healthy',
      'status_monitoring': 'Under Monitoring',
      'status_active_case': 'Active Case',
      'status_critical': 'Critical',
      'otp_sent_to': 'A 6-digit OTP was sent to',
      'enter_verification_code': 'Enter 6-digit verification OTP',
      'please_enter_6_digit_otp': 'Please enter a 6-digit OTP.',
      'verify_otp': 'Verify OTP',
      'resend_otp': 'Resend OTP',
      'otp_resent_success': 'OTP resent to your mobile number.',
      'create_password': 'Create Password',
      'create_a_password': 'Create a Password',
      'welcome': 'Welcome',
      'set_password_desc': 'Set a secure password for your account.',
      'please_enter_password': 'Please enter a password.',
      'password_min_length': 'Password must be at least 6 characters.',
      'passwords_do_not_match': 'Passwords do not match.',
      'create_account': 'Create Account',
      'treatment_followup': 'Treatment follow-up',
      'request_general_visit_no_animal': 'Requesting general visit for farm (No registered animals selected)',
      'describe_symptoms_notes': 'Describe symptoms / condition',
      'write_brief_notes_hint': 'Or write brief notes here...',
      'submit_vet_request': 'SUBMIT VET REQUEST',
      'request_submitted': 'Request Submitted',
      'vet_request_submitted': 'Veterinarian Request Submitted',
      'request_id': 'Request ID',
      'case_progression_timeline': 'Case Progression Timeline:',
      'timeline_submitted': 'SUBMITTED',
      'timeline_submitted_desc': 'Your request has been received.',
      'timeline_under_review': 'UNDER REVIEW',
      'timeline_under_review_desc': 'Coordinator will review the case.',
      'timeline_vet_assigned': 'VET ASSIGNED',
      'timeline_vet_assigned_desc': 'Veterinarian will be assigned.',
      'timeline_visit_scheduled': 'VISIT SCHEDULED',
      'timeline_visit_scheduled_desc': 'Visit date & time confirmed.',
      'timeline_treatment_started': 'TREATMENT STARTED',
      'timeline_treatment_started_desc': 'Vet visit & treatment administered.',
      'timeline_case_closed': 'CASE CLOSED',
      'timeline_case_closed_desc': 'Case resolved.',
      'sample_collected': 'SAMPLE COLLECTED',
      'lab_referred': 'LAB REFERRED',
      'escalated_to_govt': 'ESCALATED TO GOVT',
      'treatment_records': 'Treatment Records',
      'treatment_records_created_by_vet': 'Treatment records are created by the veterinarian through the veterinarian module.',
      'vaccination_records': 'Vaccination Records',
      'please_add_animals_first': 'Please add animals first.',
      'add_vaccination_record': 'Add Vaccination Record',
      'vaccine_name': 'Vaccine Name',
      'save_record': 'Save Record',
      'no_upcoming_vaccinations': 'No upcoming vaccinations.',
      'no_vaccination_history': 'No vaccination history.',
      'no_health_cases_reported': 'No health cases reported yet.',
      'no_mortality_cases_reported': 'No mortality cases reported.',
      'escalated_to_govt_title': 'ESCALATED TO GOVERNMENT SURVEILLANCE',
      'escalated_to_govt_desc': 'Case escalated to regional animal health authorities for emergency epidemic response.',
      'attending_vet': 'ATTENDING VET',
      'visit': 'Visit',
      'vet_findings_diagnosis': 'Veterinarian Findings & Diagnosis',
      'health_risk': 'HEALTH RISK',
      'reported_problems': 'Reported Problems',
      'advice_given': 'Advice Given',
      'voice_note_recorded': 'Voice note recorded with this case',
      'status_timeline': 'Status Timeline',
      'animals_died': 'Animals Died',
      'symptoms_before_death': 'Symptoms before death',
      'upcoming': 'Upcoming',
      'history': 'History',
      'verified': 'Verified',
      'choose_date': 'Choose date',
      'start_date': 'Start Date',
      'follow_up': 'Follow-up',
      'instructions': 'Instructions',
      'mortality': 'Mortality',
      'case': 'Case',
      'risk': 'Risk',
      'species': 'Species',
      'time': 'Time',
      'location': 'Location',
      'date': 'Date',
      'status': 'Status',
      'tomorrow': 'Tomorrow',
      'section_vet_visits': 'SECTION 3 — VET VISITS',
      'no_vet_visits': 'No vet visits recorded',
      'no_vet_visits_desc': 'When a vet visits your farm, the visit report will appear here.',
      'load_demo_records': 'Load Demo Records',
      'load_demo_records_desc': 'Populates sample animals, health reports, vet requests, and alerts.',
      'demo_data_loaded': 'Demo records loaded successfully!',
      'filter_animals': 'Filter Animals',
      'health_status': 'Health Status',
      'clear_filters': 'Clear Filters',
      'individual': 'Individual',
      'herds': 'Herds',
      'search_animals_hint': 'Search by Tag, Breed, Species...',
      'showing_animals_count': 'Showing {count} animal(s)',
      'no_animals_found': 'No animals found',
      'add_first_animal': 'Add First Animal',
      'add_animal': 'Add Animal',
      'remove_animal': 'Remove Animal',
      'remove_animal_confirm': 'Are you sure you want to remove animal {tag}?',
      'removed': 'removed',
      'view_details': 'View Details',
      'no_herds_found': 'No herd groups registered yet.',
      'edit_animal': 'Edit Animal',
      'add_new_animal': 'Add New Animal',
      'add_photo': 'Add Photo',
      'photo_upload_placeholder': 'Tap to take or pick animal photo',
      'animal_identification': 'Animal Identification',
      'please_enter_animal_id': 'Please enter animal ear tag / ID',
      'please_enter_breed': 'Please enter breed',
      'please_enter_age': 'Please enter age',
      'save_changes': 'Save Changes',
      'ear_tag_exists': 'An animal with this ear tag already exists.',
      'animal_updated': 'Animal updated successfully!',
      'added_successfully': 'added successfully!',
      'animal_details': 'Animal Details',
      'animal_not_found': 'Animal not found',
      'animal_information': 'Animal Information',
      'health_overview': 'Health Overview',
      'current_status': 'Current Status',
      'last_health_report': 'Last Health Report',
      'last_vet_visit': 'Last Vet Visit',
      'none': 'None',
      'health_records': 'Health Records',
      'no_health_records': 'No health records reported for this animal.',
      'vaccination': 'Vaccination',
      'no_vaccinations': 'No vaccination records.',
      'treatment': 'Treatment',
      'no_treatments': 'No treatment records.',
      'vet_requests': 'Veterinarian Requests',
      'no_vet_requests': 'No vet visit requests.',
      'no_reports_yet_desc': 'Start reporting health symptoms to see clinical records and case tracking here.',
      'ago': 'ago',
      'just_now': 'Just now',
      'selected': 'Selected',
      'continue_with': 'Continue with',
      'animal_id_hint': 'e.g. COW-001, TAG-1234, or speak',
      'select_all_problems': 'Select all that apply',
      'duration_subtitle': 'How long has the animal been sick?',
      'affected_count_subtitle': 'How many animals show symptoms?',
      'evidence_subtitle': 'Attach photo, video, or voice recording',
      'review_details_subtitle': 'Review reported symptoms and submit',
      'more_than_10': 'More than 10',
      'affected_2_5': '2–5 Animals',
      'affected_6_10': '6–10 Animals',
      'recorded': 'Recorded',
      'added': 'Added',
      'manual_location': 'Manual Location',
      'gps_fix': 'GPS Fix',
      'problems': 'Problems',
      'animals_affected': 'Animals Affected',
      'submit_mortality_report': 'SUBMIT MORTALITY REPORT',
      'login_subtitle': 'Livestock Health & Disease Surveillance Portal',
      'remember_me': 'Remember Me',
      'reset_password': 'Reset Password',
      'reset_password_desc': 'Enter your registered mobile number. We will send an OTP to reset your password.',
      'send_otp': 'Send OTP',
      'animal': 'Animal',
      'animal_id': 'Animal ID',
      'submitted': 'SUBMITTED',
      'breed': 'Breed',
      'details': 'Details',
      'cases': 'Cases',
      'health': 'Health',
      'vet_visits': 'Vet Visits',
      'vet_request': 'Vet Request',
      'timeline': 'Timeline',
      'preferred_date': 'Preferred Date',
      'enter_full_name': 'Please enter your full name.',
      'enter_valid_mobile': 'Please enter a valid 10-digit mobile number.',
      'enter_village': 'Please enter your village name.',
      'select_one_livestock': 'Please select at least one livestock type.',
      'incorrect_otp': 'Incorrect OTP. Use 123456 for demo.',
      'password_min_4': 'Password must be at least 4 characters.',
      'passwords_dont_match': 'Passwords do not match.',
      'listening_speak_name': 'Listening... Speak your name clearly',
      'transcribing_name': 'Transcribing spoken name...',
      'voice_captured': 'Voice captured',
      'no_speech_detected': 'No speech detected. Please speak louder or type your name.',
      'using_current_loc': 'Using current location',
      'case_id': 'Case ID'
    },

    'hi': {
      'app_title': 'स्मार्ट पशुधन',
      'app_subtitle': 'पशु स्वास्थ्य निगरानी एवं निर्णय प्रणाली',
      'choose_language': 'अपनी भाषा चुनें',
      'select_language_subtitle': 'ऐप जारी रखने के लिए अपनी भाषा का चयन करें',
      'select_role': 'अपनी भूमिका चुनें',
      'continue': 'आगे बढ़ें',
      'next': 'आगे',
      'back': 'पीछे',
      'save': 'सहेजें',
      'cancel': 'रद्द करें',
      'done': 'पूर्ण',
      'submit': 'जमा करें',
      'edit': 'संपादित करें',
      'edit_farm_details': 'फार्म विवरण बदलें',
      'online': 'ऑनलाइन',
      'offline': 'ऑफ़लाइन',
      'loading': 'लोड हो रहा है...',
      'listen': 'सुनें',
      'close': 'बंद करें',
      'back_to_home': 'होम पर वापस जाएं',
      'search': 'खोजें...',
      'no_data': 'कोई रिकॉर्ड नहीं मिला',
      'confirm': 'पुष्टि करें',
      'success': 'सफल',
      'error': 'त्रुटि',
      'language_changed': 'भाषा सफलतापूर्वक बदल दी गई है',

      'role_farmer_title': 'किसान',
      'role_farmer_sub': 'पशु समस्या दर्ज करें, केस ट्रैक करें, स्वास्थ्य परामर्श प्राप्त करें',
      'role_farmer_badge': 'किसान पोर्टल',
      'role_vet_title': 'पशु चिकित्सक',
      'role_vet_sub': 'केस समीक्षा करें, दौरा निर्धारित करें, नमूने एकत्र करें, उपचार दर्ज करें',
      'role_vet_badge': 'क्षेत्रीय पशु चिकित्सा सेवा',
      'role_govt_title': 'शासन / पशुपालन विभाग',
      'role_govt_sub': 'रोग निगरानी डैशबोर्ड, क्लस्टर पहचान, अलर्ट व त्वरित प्रतिक्रिया',
      'role_govt_badge': 'पशु स्वास्थ्य प्राधिकरण',

      'login_title': 'किसान लॉगिन',
      'vet_login_title': 'पशु चिकित्सक लॉगिन',
      'govt_login_title': 'निगरानी अधिकारी लॉगिन',
      'mobile_number': 'मोबाइल नंबर',
      'enter_mobile_hint': '10 अंकों का मोबाइल नंबर दर्ज करें',
      'password': 'पासवर्ड',
      'enter_password_hint': 'अपना पासवर्ड दर्ज करें',
      'confirm_password': 'पासवर्ड की पुष्टि करें',
      'login_button': 'लॉगिन करें',
      'forgot_password': 'पासवर्ड भूल गए?',
      'new_farmer_register': 'नए किसान? पंजीकरण करें',
      'already_account': 'पहले से खाता है? लॉगिन करें',
      'about_you': 'आपके बारे में',
      'full_name': 'पूरा नाम',
      'speak_name': 'अपना नाम बोलें',
      'email_optional': 'ईमेल (वैकल्पिक)',
      'where_is_farm': 'आपका फार्म कहाँ स्थित है?',
      'state': 'राज्य',
      'district': 'जिला',
      'block_taluk': 'ब्लॉक / तहसील',
      'village': 'गाँव',
      'about_farm': 'आपके फार्म के बारे में',
      'farm_name_optional': 'फार्म का नाम (वैकल्पिक)',
      'farm_size': 'फार्म का आकार',
      'farm_size_unit': 'माप इकाई',
      'acres': 'एकड़',
      'hectares': 'हेक्टेयर',
      'cent': 'सेंट',
      'farm_location': 'फार्म का स्थान',
      'use_current_location': 'वर्तमान स्थान का उपयोग करें',
      'enter_location_manually': 'स्थान स्वयं दर्ज करें',
      'livestock_type': 'पशुधन का प्रकार',
      'cow': 'गाय',
      'buffalo': 'भैंस',
      'goat': 'बकरी',
      'sheep': 'भेड़',
      'pig': 'सूअर',
      'poultry': 'मुर्गी पालन',
      'other': 'अन्य',
      'language_preferences': 'भाषा और प्राथमिकताएं',
      'preferred_language': 'पसंदीदा भाषा',
      'communication_preference': 'संचार माध्यम',
      'comm_voice': 'आवाज़',
      'comm_text': 'संदेश',
      'comm_both': 'आवाज़ और संदेश दोनों',
      'create_farmer_profile': 'किसान प्रोफ़ाइल बनाएं',
      'verify_mobile': 'मोबाइल नंबर सत्यापित करें',
      'demo_otp_notice': 'ओटीपी दर्ज करें',
      'enter_otp': 'ओटीपी दर्ज करें',
      'create_password_title': 'पासवर्ड बनाएं',
      'create_account_btn': 'खाता बनाएं',
      'account_created_success': 'खाता सफलतापूर्वक बन गया!',
      'official_id': 'पशु चिकित्सा पंजीकरण संख्या',
      'officer_id': 'अधिकारी / कर्मचारी संख्या',

      'nav_home': 'होम',
      'nav_my_cases': 'मेरे केस',
      'nav_report': 'रिपोर्ट',
      'nav_alerts': 'अलर्ट',
      'nav_profile': 'प्रोफ़ाइल',

      'hello_farmer': 'नमस्ते, {name}',
      'report_animal_problem': 'पशु की समस्या दर्ज करें',
      'report_problem_subtitle': 'फोटो, वीडियो और आवाज़ के साथ 5-चरणीय त्वरित आकलन',
      'my_animals_cases': 'मेरे केस',
      'request_veterinarian': 'पशु चिकित्सक बुलाएं',
      'weather_livestock_health': 'मौसम और पशु स्वास्थ्य',
      'weather_health_subtitle': 'सलाह, रोग जोखिम और खेत की स्थिति',
      'alerts': 'अलर्ट',
      'animals_reported': 'दर्ज पशु',
      'active_cases': 'सक्रिय केस',
      'vaccination_due': 'टीकाकरण बाकी',
      'important_alerts': 'महत्वपूर्ण अलर्ट',
      'recent_activity': 'हाल की गतिविधियाँ',
      'view_all': 'सभी देखें',

      'start_assessment': 'आकलन शुरू करें',
      'step_animal': 'पशु',
      'step_symptoms': 'लक्षण',
      'step_details': 'विवरण',
      'step_evidence': 'सबूत',
      'step_summary': 'सारांश',
      'what_animal_problem': 'किस पशु को समस्या है?',
      'tell_about_animal': 'पशु के बारे में बताएं',
      'animal_id_tag': 'पशु आईडी / कान का टैग (वैकल्पिक)',
      'select_breed': 'नस्ल चुनें',
      'gender': 'लिंग',
      'male': 'नर',
      'female': 'मादा',
      'age': 'उम्र',
      'age_below_1': '1 वर्ष से कम',
      'age_1_2': '1–2 वर्ष',
      'age_2_5': '2–5 वर्ष',
      'age_5_10': '5–10 वर्ष',
      'age_above_10': '10 वर्ष से अधिक',

      'what_is_wrong': 'पशु को क्या समस्या है?',
      'select_all_symptoms_hint': 'दिखाई देने वाले सभी लक्षण चुनें:',
      'sym_fever': 'बुखार',
      'sym_not_eating': 'चारा नहीं खा रहा',
      'sym_breathing': 'सांस लेने में तकलीफ',
      'sym_walking': 'चलने में कठिनाई / लंगड़ाना',
      'sym_diarrhea': 'दस्त',
      'sym_salivation': 'मुंह से अधिक लार टपकना',
      'sym_weakness': 'कमजोरी / सुस्ती',
      'sym_skin_lesions': 'त्वचा पर छाले / घाव',
      'sym_vomiting': 'उल्टी',
      'sym_nasal_discharge': 'नाक बहना',
      'sym_eye_problem': 'आंख की समस्या',
      'sym_bleeding': 'खून बहना',
      'sym_milk_reduced': 'दूध उत्पादन कम होना',
      'sym_pregnancy_problem': 'गर्भ / प्रसव समस्या',
      'sym_other': 'अन्य लक्षण',

      'since_when': 'कब से समस्या है?',
      'today': 'आज से',
      'yesterday': 'कल से',
      '2_3_days': '2–3 दिन',
      '4_7_days': '4–7 दिन',
      'more_than_week': 'एक सप्ताह से अधिक',
      'not_sure': 'पक्का नहीं पता',

      'is_animal_eating': 'क्या पशु चारा खा रहा है?',
      'is_animal_drinking': 'क्या पशु पानी पी रहा है?',
      'yes': 'हाँ',
      'less_than_usual': 'सामान्य से कम',
      'no': 'नहीं',
      'how_many_affected': 'कितने पशु प्रभावित हैं?',
      'is_pregnant': 'क्या पशु गाभिन है?',
      'is_lactating': 'क्या वर्तमान में दूध दे रहा है?',

      'show_us_problem': 'समस्या दिखाएं',
      'voice_photo_help_diag': 'आवाज़ और फोटो से पशु चिकित्सक को जल्दी निदान करने में मदद मिलती है।',
      'take_photo': 'फोटो लें',
      'record_video': 'वीडियो बनाएं',
      'record_voice': 'आवाज़ रिकॉर्ड करें',
      'write_description': 'विवरण लिखें',
      'extra_notes_vet_hint': 'पशु चिकित्सक के लिए कोई अतिरिक्त टिप्पणी...',
      'tell_what_happened': 'बताएं क्या हुआ',
      'tap_and_speak': 'दबाएं और बोलें',
      'tap_to_speak': 'बोलने के लिए टैप करें',
      'speak_in_language': 'अपनी भाषा में बोलें',
      'voice_recorded': 'आवाज़ रिकॉर्ड हो गई',
      'voice_lang_tag': 'हिन्दी',
      'recording': 'सुन रहे हैं... अब बोलें',
      'stop': 'रोकें और सहेजें',
      'play': 'सुनें',
      'record_again': 'दोबारा बोलें',
      'photo_added': 'फोटो जोड़ दी गई',
      'video_added': 'वीडियो जोड़ दिया गया',

      'where_is_animal': 'पशु कहाँ है?',
      'confirm_animal_location_diag': 'पशु चिकित्सक भेजने के लिए पशु का स्थान सुनिश्चित करें।',
      'acquiring_device_gps': 'डिवाइस जीपीएस प्राप्त किया जा रहा है...',
      'use_farm_location': 'फार्म के स्थान का उपयोग करें',
      'report_summary': 'रिपोर्ट सारांश',
      'submit_report': 'रिपोर्ट जमा करें',
      'assessment_result': 'स्वास्थ्य आकलन परिणाम',
      'report_submitted_net': 'रिपोर्ट निगरानी नेटवर्क में दर्ज हो चुकी है',
      'recommended_action': 'अनुशंसित कार्रवाई',
      'suspected_diseases': 'संभावित रोग (डिफरेंशियल डायग्नोसिस)',
      'explanation': 'चिकित्सीय विवरण',

      'health_risk_assessment': 'स्वास्थ्य जोखिम मूल्यांकन',
      'risk_low': 'कम स्वास्थ्य जोखिम',
      'risk_medium': 'मध्यम स्वास्थ्य जोखिम',
      'risk_high': 'उच्च स्वास्थ्य जोखिम',
      'risk_critical': 'गंभीर स्वास्थ्य जोखिम',

      'report_animal_death': 'पशु मृत्यु की रिपोर्ट करें',
      'how_many_died': 'कितने पशुओं की मृत्यु हुई?',
      'when_happened': 'यह कब हुआ?',
      'problems_before_death': 'मृत्यु से पहले के लक्षण',
      'death_reported_title': 'गंभीर: पशु मृत्यु की रिपोर्ट दर्ज',
      'death_reported_msg': 'कृपया प्रभावित क्षेत्र से अन्य पशुओं को न हटाएं। सख्त संगरोध आवश्यक है।',

      'need_veterinarian': 'पशु चिकित्सक चाहिए?',
      'select_case': 'पशु / केस चुनें',
      'reason_for_vet': 'बुलाने का कारण',
      'reason_very_sick': 'पशु बहुत बीमार है',
      'reason_not_improving': 'सुधार नहीं हो रहा',
      'reason_death': 'पशु की मृत्यु',
      'reason_vaccination': 'टीकाकरण का अनुरोध',
      'reason_treatment': 'उपचार फॉलो-अप',
      'reason_other': 'अन्य कारण',
      'preferred_visit': 'पसंदीदा दिन',
      'preferred_time': 'पसंदीदा समय',
      'morning': 'सुबह (8 बजे से 12 बजे)',
      'afternoon': 'दोपहर (12 बजे से 4 बजे)',
      'evening': 'शाम (4 बजे से 7 बजे)',
      'status_submitted': 'जमा किया गया',
      'status_under_review': 'समीक्षा में',
      'status_vet_assigned': 'डॉक्टर नियुक्त',
      'status_visit_scheduled': 'दौरा निर्धारित',
      'status_treatment_started': 'उपचार शुरू',
      'status_case_closed': 'केस बंद',

      'farmer_details': 'किसान विवरण',
      'farm_details': 'फार्म विवरण',
      'app_settings': 'ऐप सेटिंग्स',
      'change_language': 'भाषा बदलें',
      'smart_livestock': 'स्मार्ट पशुधन',
      'veterinary_dashboard': 'पशु चिकित्सा डैशबोर्ड',
      'vet_officer_title': 'डॉ. राजेश कुमार · पशु चिकित्सा अधिकारी',
      'notifications': 'सूचनाएं',
      'logout': 'लॉगआउट करें',
      'logout_confirm': 'क्या आप लॉगआउट करना चाहते हैं?',

      'step_counter': 'चरण {step} / {total}',
      'basic_info_subtitle': 'कृपया अपनी बुनियादी संपर्क जानकारी प्रदान करें।',
      'name_hint': 'उदा. रमेश पाटिल (या बोलें)',
      'tap_speak_name': 'अपना नाम बोलने के लिए दबाएं',
      'listening_tap_stop': 'सुन रहे हैं... रोकने और सहेजने के लिए दबाएं',
      'speak_your_name': 'अपना नाम बोलें',
      'stop_listening': 'सुनना बंद करें',
      'location_subtitle': 'ड्रॉपडाउन से अपने स्थान का विवरण चुनें।',
      'fixed': 'स्थिर',
      'taluk': 'तालुका / तहसील',
      'village_hint': 'अपने गांव का नाम दर्ज करें',
      'farm_details_subtitle': 'फ़ार्म का आकार दर्ज करें और अपने पशुधन का चयन करें।',
      'select_all_apply': 'लागू होने वाले सभी चुनें',
      'livestock_type_select_all': 'पशुधन का प्रकार (लागू होने वाले सभी चुनें)',
      'pref_subtitle': 'चुनें कि आप ऐप के साथ कैसे बातचीत करना चाहते हैं।',
      'verification_code_sent': '{mobile} पर सत्यापन कोड भेजा गया है।',
      'autofill_demo_otp': 'डेमो ओटीपी ऑटो-भरें ({otp})',
      'verify_and_continue': 'सत्यापित करें और आगे बढ़ें',
      'create_password_subtitle': '{name} के लिए आसानी से लॉगिन करने हेतु पासवर्ड बनाएं।',
      'welcome_ready': 'स्वागत है, {name}! आप अपने फ़ार्म का प्रबंधन करने के लिए तैयार हैं।',
      'farm_health_summary': 'फ़ार्म स्वास्थ्य सारांश',
      'see_all_cases': 'सभी केस देखें',
      'activity_animal_registered': 'पशु पंजीकृत',
      'activity_health_reported': 'स्वास्थ्य रिपोर्ट',
      'activity_mortality_reported': 'मृत्यु दर रिपोर्ट',
      'activity_vet_requested': 'पशु चिकित्सक अनुरोध',
      'no_recent_activity': 'अभी तक कोई हालिया गतिविधि नहीं है।',
      'use_report_button_to_start': 'शुरू करने के लिए ऊपर दिए गए रिपोर्ट बटन का उपयोग करें।',
      'animals_affected_count': '{count} पशु प्रभावित',
      'alerts_and_advisories': 'अलर्ट और सलाह',
      'mark_all_read': 'सभी पढ़े हुए मार्क करें',
      'no_alerts_yet': 'अभी कोई अलर्ट नहीं है',
      'no_alerts_subtitle': 'स्वास्थ्य रिपोर्ट, मृत्यु या सलाह जारी होने पर अलर्ट यहां दिखाई देंगे।',
      'tab_health': 'स्वास्थ्य',
      'tab_mortality': 'मृत्यु',
      'tab_vet_visits': 'पशु चिकित्सक भेंट',
      'report_new_problem': 'नई समस्या दर्ज करें',
      'report_an_issue': 'समस्या की रिपोर्ट करें',
      'what_to_report': 'आप क्या रिपोर्ट करना चाहते हैं?',
      'report_symptoms': 'लक्षण रिपोर्ट करें',
      'report_symptoms_desc': 'जोखिम आकलन के लिए पशु चुनें और स्वास्थ्य लक्षण दर्ज करें।',
      'report_mortality': 'पशु मृत्यु रिपोर्ट करें',
      'report_mortality_desc': 'पशु की मृत्यु की रिपोर्ट करें। एक महत्वपूर्ण अलर्ट बनाया जाएगा।',
      'request_vet': 'पशु चिकित्सक बुलाएं',
      'request_vet_desc': 'ज़रूरत पड़ने पर पशु चिकित्सक के दौरे का अनुरोध करें।',
      'my_recent_reports': 'मेरी हालिया रिपोर्ट',
      'farmer_profile': 'किसान प्रोफ़ाइल',
      'section_farmer_details': 'भाग 1 — किसान विवरण',
      'section_farm_details': 'भाग 2 — फ़ार्म विवरण',
      'edit_farmer_details': 'किसान विवरण संपादित करें',
      'save_farm_details': 'फ़ार्म विवरण सहेजें',
      'location_mode': 'स्थान मोड',
      'gender_male': 'नर',
      'gender_female': 'मादा',
      'status_healthy': 'स्वस्थ',
      'status_monitoring': 'निगरानी में',
      'status_active_case': 'सक्रिय केस',
      'status_critical': 'गंभीर',
      'otp_sent_to': '6 अंकों का ओटीपी भेजा गया है',
      'enter_verification_code': '6-अंकों का सत्यापन ओटीपी दर्ज करें',
      'please_enter_6_digit_otp': 'कृपया 6 अंकों का ओटीपी दर्ज करें।',
      'verify_otp': 'ओटीपी सत्यापित करें',
      'resend_otp': 'ओटीपी पुनः भेजें',
      'otp_resent_success': 'आपके मोबाइल नंबर पर ओटीपी पुनः भेजा गया।',
      'create_password': 'पासवर्ड बनाएं',
      'create_a_password': 'एक पासवर्ड बनाएं',
      'welcome': 'स्वागत है',
      'set_password_desc': 'अपने खाते के लिए एक सुरक्षित पासवर्ड सेट करें।',
      'please_enter_password': 'कृपया एक पासवर्ड दर्ज करें।',
      'password_min_length': 'पासवर्ड कम से कम 6 अक्षरों का होना चाहिए।',
      'passwords_do_not_match': 'पासवर्ड मेल नहीं खाते।',
      'create_account': 'खाता बनाएं',
      'treatment_followup': 'उपचार फॉलो-अप',
      'request_general_visit_no_animal': 'खेत के लिए सामान्य दौरे का अनुरोध (कोई पंजीकृत पशु चयनित नहीं)',
      'describe_symptoms_notes': 'लक्षणों / स्थिति का वर्णन करें',
      'write_brief_notes_hint': 'या यहाँ संक्षिप्त विवरण लिखें...',
      'submit_vet_request': 'पशु चिकित्सक अनुरोध भेजें',
      'request_submitted': 'अनुरोध भेजा गया',
      'vet_request_submitted': 'पशु चिकित्सक अनुरोध सफलतापूर्वक भेजा गया',
      'request_id': 'अनुरोध आईडी',
      'case_progression_timeline': 'प्रकरण प्रगति समयरेखा:',
      'timeline_submitted': 'दर्ज किया गया',
      'timeline_submitted_desc': 'आपका अनुरोध प्राप्त हो गया है।',
      'timeline_under_review': 'समीक्षाधीन',
      'timeline_under_review_desc': 'समन्वयक मामले की समीक्षा करेंगे।',
      'timeline_vet_assigned': 'पशु चिकित्सक नियुक्त',
      'timeline_vet_assigned_desc': 'पशु चिकित्सक नियुक्त किए जाएंगे।',
      'timeline_visit_scheduled': 'दौरा निर्धारित',
      'timeline_visit_scheduled_desc': 'दौरे की तिथि और समय की पुष्टि हुई।',
      'timeline_treatment_started': 'उपचार शुरू',
      'timeline_treatment_started_desc': 'पशु चिकित्सक का दौरा और उपचार दिया गया।',
      'timeline_case_closed': 'प्रकरण बंद',
      'timeline_case_closed_desc': 'मामला सुलझ गया।',
      'sample_collected': 'नमूना एकत्र किया गया',
      'lab_referred': 'प्रयोगशाला संदर्भित',
      'escalated_to_govt': 'सरकार को संदर्भित',
      'treatment_records': 'उपचार रिकॉर्ड',
      'treatment_records_created_by_vet': 'उपचार रिकॉर्ड पशु चिकित्सक मॉड्यूल के माध्यम से पशु चिकित्सक द्वारा बनाए जाते हैं।',
      'vaccination_records': 'टीकाकरण रिकॉर्ड',
      'please_add_animals_first': 'कृपया पहले पशु जोड़ें।',
      'add_vaccination_record': 'टीकाकरण रिकॉर्ड जोड़ें',
      'vaccine_name': 'टीके का नाम',
      'save_record': 'रिकॉर्ड सहेजें',
      'no_upcoming_vaccinations': 'कोई आगामी टीकाकरण नहीं।',
      'no_vaccination_history': 'कोई टीकाकरण इतिहास नहीं।',
      'no_health_cases_reported': 'अभी तक कोई स्वास्थ्य मामला दर्ज नहीं किया गया है।',
      'no_mortality_cases_reported': 'कोई मृत्यु मामला दर्ज नहीं किया गया है।',
      'escalated_to_govt_title': 'सरकारी निगरानी को संदर्भित',
      'escalated_to_govt_desc': 'आपातकालीन महामारी नियंत्रण के लिए मामला क्षेत्रीय पशु स्वास्थ्य अधिकारियों को भेजा गया।',
      'attending_vet': 'उपचारक चिकित्सक',
      'visit': 'दौरा',
      'vet_findings_diagnosis': 'चिकित्सक के निष्कर्ष और निदान',
      'health_risk': 'स्वास्थ्य जोखिम',
      'reported_problems': 'दर्ज की गई समस्याएं',
      'advice_given': 'दी गई सलाह',
      'voice_note_recorded': 'इस मामले के साथ वॉयस नोट रिकॉर्ड किया गया',
      'status_timeline': 'स्थिति समयरेखा',
      'animals_died': 'मृत पशु',
      'symptoms_before_death': 'मृत्यु से पहले के लक्षण',
      'upcoming': 'आगामी',
      'history': 'इतिहास',
      'verified': 'सत्यापित',
      'choose_date': 'तारीख चुनें',
      'start_date': 'प्रारंभ तिथि',
      'follow_up': 'फॉलो-अप',
      'instructions': 'निर्देश',
      'mortality': 'मृत्यु',
      'case': 'केस',
      'risk': 'जोखिम',
      'species': 'प्रजाति',
      'time': 'समय',
      'location': 'स्थान',
      'date': 'तिथि',
      'status': 'स्थिति',
      'tomorrow': 'कल',
      'section_vet_visits': 'भाग 3 — पशु चिकित्सक भेंट',
      'no_vet_visits': 'कोई पशु चिकित्सक भेंट दर्ज नहीं',
      'no_vet_visits_desc': 'जब पशु चिकित्सक आपके खेत का दौरा करेंगे, तो रिपोर्ट यहां दिखाई देगी।',
      'load_demo_records': 'डेमो रिकॉर्ड लोड करें',
      'load_demo_records_desc': 'नमूना पशु, स्वास्थ्य रिपोर्ट, पशु चिकित्सक अनुरोध और अलर्ट लोड करता है।',
      'demo_data_loaded': 'डेमो रिकॉर्ड सफलतापूर्वक लोड किए गए!',
      'filter_animals': 'पशु फ़िल्टर करें',
      'health_status': 'स्वास्थ्य स्थिति',
      'clear_filters': 'फ़िल्टर हटाएं',
      'individual': 'व्यक्तिगत पशु',
      'herds': 'झुंड',
      'search_animals_hint': 'टैग, नस्ल या प्रजाति द्वारा खोजें...',
      'showing_animals_count': '{count} पशु दिखाए जा रहे हैं',
      'no_animals_found': 'कोई पशु नहीं मिला',
      'add_first_animal': 'पहला पशु जोड़ें',
      'add_animal': 'पशु जोड़ें',
      'remove_animal': 'पशु हटाएं',
      'remove_animal_confirm': 'क्या आप वाकई पशु {tag} को हटाना चाहते हैं?',
      'removed': 'हटा दिया गया',
      'view_details': 'विवरण देखें',
      'no_herds_found': 'अभी तक कोई झुंड पंजीकृत नहीं है।',
      'edit_animal': 'पशु विवरण संपादित करें',
      'add_new_animal': 'नया पशु जोड़ें',
      'add_photo': 'फ़ोटो जोड़ें',
      'photo_upload_placeholder': 'फ़ोटो खींचने या चुनने के लिए टैप करें',
      'animal_identification': 'पशु पहचान',
      'please_enter_animal_id': 'कृपया कान का टैग / आईडी दर्ज करें',
      'please_enter_breed': 'कृपया नस्ल दर्ज करें',
      'please_enter_age': 'कृपया उम्र दर्ज करें',
      'save_changes': 'बदलाव सहेजें',
      'ear_tag_exists': 'इस कान के टैग वाला पशु पहले से मौजूद है।',
      'animal_updated': 'पशु विवरण सफलतापूर्वक अद्यतित किया गया!',
      'added_successfully': 'सफलतापूर्वक जोड़ा गया!',
      'animal_details': 'पशु विवरण',
      'animal_not_found': 'पशु नहीं मिला',
      'animal_information': 'पशु जानकारी',
      'health_overview': 'स्वास्थ्य अवलोकन',
      'current_status': 'वर्तमान स्थिति',
      'last_health_report': 'अंतिम स्वास्थ्य रिपोर्ट',
      'last_vet_visit': 'अंतिम पशु चिकित्सक दौरा',
      'none': 'कोई नहीं',
      'health_records': 'स्वास्थ्य रिकॉर्ड',
      'no_health_records': 'इस पशु के लिए कोई स्वास्थ्य रिकॉर्ड दर्ज नहीं है।',
      'vaccination': 'टीकाकरण',
      'no_vaccinations': 'कोई टीकाकरण रिकॉर्ड नहीं।',
      'treatment': 'उपचार',
      'no_treatments': 'कोई उपचार रिकॉर्ड नहीं।',
      'vet_requests': 'पशु चिकित्सक अनुरोध',
      'no_vet_requests': 'कोई पशु चिकित्सक अनुरोध नहीं।',
      'no_reports_yet_desc': 'चिकित्सीय रिकॉर्ड और केस ट्रैकिंग देखने के लिए स्वास्थ्य लक्षण रिपोर्ट करना शुरू करें।',
      'ago': 'पहले',
      'just_now': 'अभी-अभी',
      'selected': 'चयनित',
      'continue_with': 'के साथ जारी रखें',
      'animal_id_hint': 'उदा. COW-001, TAG-1234, या बोलें',
      'select_all_problems': 'लागू होने वाले सभी का चयन करें',
      'duration_subtitle': 'पशु कितने समय से बीमार है?',
      'affected_count_subtitle': 'कितने पशुओं में लक्षण दिखाई दे रहे हैं?',
      'evidence_subtitle': 'फ़ोटो, वीडियो या वॉयस रिकॉर्डिंग संलग्न करें',
      'review_details_subtitle': 'रिपोर्ट किए गए लक्षणों की समीक्षा करें और सबमिट करें',
      'more_than_10': "10 से अधिक",
      'affected_2_5': '2–5 पशु',
      'affected_6_10': '6–10 पशु',
      'recorded': 'दर्ज किया गया',
      'added': 'जोड़ा गया',
      'manual_location': 'मैन्युअल स्थान',
      'gps_fix': 'जीपीएस स्थान',
      'problems': 'समस्याएं',
      'animals_affected': 'प्रभावित पशु',
      'submit_mortality_report': 'मृत्यु रिपोर्ट सबमिट करें',
      'login_subtitle': 'पशुधन स्वास्थ्य एवं रोग निगरानी पोर्टल',
      'remember_me': 'मुझे याद रखें',
      'reset_password': 'पासवर्ड रीसेट करें',
      'reset_password_desc': 'अपना पंजीकृत मोबाइल नंबर दर्ज करें। हम आपका पासवर्ड रीसेट करने के लिए एक ओटीपी भेजेंगे।',
      'send_otp': 'ओटीपी भेजें',
      'animal': 'पशु',
      'animal_id': 'पशु आईडी',
      'submitted': 'जमा किया गया',
      'breed': 'नस्ल',
      'details': 'विवरण',
      'cases': 'केस',
      'health': 'स्वास्थ्य',
      'vet_visits': 'पशु चिकित्सक भेंट',
      'vet_request': 'पशु चिकित्सक अनुरोध',
      'timeline': 'समयरेखा',
      'preferred_date': 'पसंदीदा दिन',
      'enter_full_name': 'कृपया अपना पूरा नाम दर्ज करें।',
      'enter_valid_mobile': 'कृपया 10-अंकों का मोबाइल नंबर दर्ज करें।',
      'enter_village': 'कृपया अपने गाँव का नाम दर्ज करें।',
      'select_one_livestock': 'कृपया कम से कम एक पशुधन प्रकार चुनें।',
      'incorrect_otp': 'गलत ओटीपी। डेमो के लिए 123456 का उपयोग करें।',
      'password_min_4': 'पासवर्ड कम से कम 4 अक्षरों का होना चाहिए।',
      'passwords_dont_match': 'पासवर्ड मेल नहीं खाते।',
      'listening_speak_name': 'सुन रहे हैं... अपना नाम स्पष्ट बोलें',
      'transcribing_name': 'बोले गए नाम का रूपांतरण हो रहा है...',
      'voice_captured': 'आवाज़ दर्ज हो गई',
      'no_speech_detected': 'कोई आवाज़ नहीं मिली। कृपया ज़ोर से बोलें या अपना नाम टाइप करें।',
      'using_current_loc': 'वर्तमान स्थान का उपयोग किया जा रहा है',
      'case_id': 'केस आईडी'
    },

    'mr': {
      'app_title': 'स्मार्ट पशुधन',
      'app_subtitle': 'पशु आरोग्य पाळत व निर्णय प्रणाली',
      'choose_language': 'आपली भाषा निवडा',
      'select_language_subtitle': 'ॲप सुरू ठेवण्यासाठी आपली भाषा निवडा',
      'select_role': 'आपली भूमिका निवडा',
      'continue': 'पुढे सुरू ठेवा',
      'next': 'पुढे',
      'back': 'मागे',
      'save': 'जतन करा',
      'cancel': 'रद्द करा',
      'done': 'पूर्ण',
      'submit': 'सबमिट करा',
      'edit': 'बदल करा',
      'edit_farm_details': 'गोठ्याचा तपशील बदला',
      'online': 'ऑनलाइन',
      'offline': 'ऑफलाइन',
      'loading': 'लोड होत आहे...',
      'listen': 'ऐका',
      'close': 'बंद करा',
      'back_to_home': 'मुख्यपृष्ठावर जा',
      'search': 'शोधा...',
      'no_data': 'माहिती उपलब्ध नाही',
      'confirm': 'निश्चित करा',
      'success': 'यशस्वी',
      'error': 'त्रुटी',
      'language_changed': 'भाषा यशस्वीरित्या बदलली आहे',

      'role_farmer_title': 'शेतकरी / पशुपालक',
      'role_farmer_sub': 'जनावरांची समस्या नोंदवा, केसेस तपासा, आरोग्य सल्ला मिळवा',
      'role_farmer_badge': 'शेतकरी पोर्टल',
      'role_vet_title': 'पशुवैद्यकीय अधिकारी',
      'role_vet_sub': 'केस तपासा, भेट ठरवा, नमुने गोळा करा, उपचाराची नोंद ठेवा',
      'role_vet_badge': 'क्षेत्रीय पशुवैद्यकीय सेवा',
      'role_govt_title': 'शासकीय विभाग',
      'role_govt_sub': 'रोग पाळत डॅशबोर्ड, क्लस्टर शोध, सूचना व तात्काळ प्रतिसाद',
      'role_govt_badge': 'पशु आरोग्य प्राधिकरण',

      'login_title': 'शेतकरी लॉगिन',
      'vet_login_title': 'पशुवैद्यक लॉगिन',
      'govt_login_title': 'पाळत अधिकारी लॉगिन',
      'mobile_number': 'मोबाईल नंबर',
      'enter_mobile_hint': '१० अंकी मोबाईल नंबर टाका',
      'password': 'पासवर्ड',
      'enter_password_hint': 'आपला पासवर्ड टाका',
      'confirm_password': 'पासवर्डची खात्री करा',
      'login_button': 'लॉगिन करा',
      'forgot_password': 'पासवर्ड विसरलात?',
      'new_farmer_register': 'नवीन शेतकरी? नोंदणी करा',
      'already_account': 'आधीच खाते आहे? लॉगिन करा',
      'about_you': 'आपल्याविषयी माहिती',
      'full_name': 'पूर्ण नाव',
      'speak_name': 'आपले नाव बोला',
      'email_optional': 'ईमेल (पर्यायी)',
      'where_is_farm': 'आपला गोठा / शेत कोठे आहे?',
      'state': 'राज्य',
      'district': 'जिल्हा',
      'block_taluk': 'तालुका',
      'village': 'गाव',
      'about_farm': 'गोठ्याविषयी माहिती',
      'farm_name_optional': 'गोठ्याचे / फार्मचे नाव (पर्यायी)',
      'farm_size': 'गोठ्याचा / शेताचा आकार',
      'farm_size_unit': 'आकार एकक',
      'acres': 'एकर',
      'hectares': 'हेक्टर',
      'cent': 'गुंठा / सेंट',
      'farm_location': 'गोठ्याचे स्थान',
      'use_current_location': 'सध्याचे स्थान वापरा',
      'enter_location_manually': 'स्थान स्वतः प्रविष्ट करा',
      'livestock_type': 'पशुधनाचा प्रकार',
      'cow': 'गाय',
      'buffalo': 'म्हैस',
      'goat': 'शेळी',
      'sheep': 'मेंढी',
      'pig': 'डुक्कर',
      'poultry': 'कुक्कुटपालन',
      'other': 'इतर',
      'language_preferences': 'भाषा आणि प्राधान्ये',
      'preferred_language': 'पसंतीची भाषा',
      'communication_preference': 'संवादाचे माध्यम',
      'comm_voice': 'आवाज',
      'comm_text': 'संदेश',
      'comm_both': 'आवाज आणि संदेश दोन्ही',
      'create_farmer_profile': 'शेतकरी प्रोफाइल तयार करा',
      'verify_mobile': 'मोबाईल नंबर पडताळा',
      'demo_otp_notice': 'ओटीपी प्रविष्ट करा',
      'enter_otp': 'ओटीपी प्रविष्ट करा',
      'create_password_title': 'पासवर्ड तयार करा',
      'create_account_btn': 'खाते तयार करा',
      'account_created_success': 'खाते यशस्वीरित्या तयार झाले!',
      'official_id': 'पशुवैद्यकीय नोंदणी क्रमांक',
      'officer_id': 'अधिकारी / कर्मचारी क्रमांक',

      'nav_home': 'मुख्यपृष्ठ',
      'nav_my_cases': 'माझी प्रकरणे',
      'nav_report': 'तक्रार',
      'nav_alerts': 'सूचना',
      'nav_profile': 'प्रोफाइल',

      'hello_farmer': 'नमस्कार, {name}',
      'report_animal_problem': 'जनावरांची समस्या नोंदवा',
      'report_problem_subtitle': 'फोटो, व्हिडिओ व आवाजासह ५-टप्प्यांत तात्काळ मूल्यमापन',
      'my_animals_cases': 'माझी प्रकरणे',
      'request_veterinarian': 'पशुवैद्यक बोलवा',
      'weather_livestock_health': 'हवामान आणि पशू आरोग्य',
      'weather_health_subtitle': 'सल्ला, रोग जोखीम आणि शेताची स्थिती',
      'alerts': 'सूचना',
      'animals_reported': 'नोंदवलेली जनावरे',
      'active_cases': 'सक्रिय प्रकरणे',
      'vaccination_due': 'लसीकरण बाकी',
      'important_alerts': 'महत्त्वाच्या सूचना',
      'recent_activity': 'अलीकडील घडामोडी',
      'view_all': 'सर्व पहा',

      'start_assessment': 'मूल्यांकन सुरू करा',
      'step_animal': 'जनावर',
      'step_symptoms': 'लक्षणे',
      'step_details': 'तपशील',
      'step_evidence': 'पुरावा',
      'step_summary': 'सारांश',
      'what_animal_problem': 'कोणत्या जनावराला समस्या आहे?',
      'tell_about_animal': 'जनावराविषयी माहिती द्या',
      'animal_id_tag': 'जनावर क्रमांक / कानाचा टॅग (पर्यायी)',
      'select_breed': 'जात निवडा',
      'gender': 'लिंग',
      'male': 'नर',
      'female': 'मादी',
      'age': 'वय',
      'age_below_1': '१ वर्षाखालील',
      'age_1_2': '१–२ वर्षे',
      'age_2_5': '२–५ वर्षे',
      'age_5_10': '५–१० वर्षे',
      'age_above_10': '१० वर्षांपेक्षा जास्त',

      'what_is_wrong': 'जनावराला नक्की काय त्रास आहे?',
      'select_all_symptoms_hint': 'दिसणारी सर्व लक्षणे निवडा:',
      'sym_fever': 'ताप',
      'sym_not_eating': 'चारा खात नाही',
      'sym_breathing': 'श्वास घेण्यास त्रास',
      'sym_walking': 'चालताना त्रास / लंगडणे',
      'sym_diarrhea': 'हगवण / जुलाब',
      'sym_salivation': 'तोंडातून जास्त लाळ गळणे',
      'sym_weakness': 'अशक्तपणा / सुस्ती',
      'sym_skin_lesions': 'त्वचेवर फोड / जखमा',
      'sym_vomiting': 'उलटी',
      'sym_nasal_discharge': 'नाकातून स्राव वाहणे',
      'sym_eye_problem': 'डोळ्यांची समस्या',
      'sym_bleeding': 'रक्तस्त्राव',
      'sym_milk_reduced': 'दूध उत्पादन घटले',
      'sym_pregnancy_problem': 'गाभण / विताना समस्या',
      'sym_other': 'इतर लक्षणे',

      'since_when': 'कधीपासून त्रास आहे?',
      'today': 'आजपासून',
      'yesterday': 'कालपासून',
      '2_3_days': '२–३ दिवस',
      '4_7_days': '४–७ दिवस',
      'more_than_week': 'एका आठवड्यापेक्षा जास्त',
      'not_sure': 'खात्री नाही',

      'is_animal_eating': 'जनावर चारा खात आहे का?',
      'is_animal_drinking': 'जनावर पाणी पीत आहे का?',
      'yes': 'होय',
      'less_than_usual': 'नेहमीपेक्षा कमी',
      'no': 'नाही',
      'how_many_affected': 'किती जनावरांना हा त्रास आहे?',
      'is_pregnant': 'जनावर गाभण आहे का?',
      'is_lactating': 'सध्या दूध देत आहे का?',

      'show_us_problem': 'समस्या दाखवा',
      'voice_photo_help_diag': 'आवाज आणि फोटोमुळे पशुवैद्यकाला लवकर निदान करण्यास मदत होते.',
      'take_photo': 'फोटो काढा',
      'record_video': 'व्हिडिओ बनवा',
      'record_voice': 'आवाज रेकॉर्ड करा',
      'write_description': 'तपशील लिहा',
      'extra_notes_vet_hint': 'पशुवैद्यकासाठी काही अतिरिक्त माहिती...',
      'tell_what_happened': 'नेमके काय घडले ते सांगा',
      'tap_and_speak': 'दाबा आणि बोला',
      'tap_to_speak': 'बोलण्यासाठी टॅप करा',
      'speak_in_language': 'तुमच्या भाषेत बोला',
      'voice_recorded': 'आवाज रेकॉर्ड झाला',
      'voice_lang_tag': 'मराठी',
      'recording': 'ऐकत आहे... आता बोला',
      'stop': 'थांबवा आणि सेव्ह करा',
      'play': 'ऐका',
      'record_again': 'पुन्हा बोला',
      'photo_added': 'फोटो जोडला गेला',
      'video_added': 'व्हिडिओ जोडला गेला',

      'where_is_animal': 'जनावर कोठे आहे?',
      'confirm_animal_location_diag': 'पशुवैद्यक पाठवण्यासाठी जनावराचे ठिकाण निश्चित करा.',
      'acquiring_device_gps': 'डिव्हाइस जीपीएस मिळवत आहे...',
      'use_farm_location': 'गोठ्याचे स्थान वापरा',
      'report_summary': 'तक्रार सारांश',
      'submit_report': 'तक्रार सबमिट करा',
      'assessment_result': 'आरोग्य मूल्यमापन निकाल',
      'report_submitted_net': 'तक्रार पाळत नेटवर्कमध्ये नोंदवली गेली आहे',
      'recommended_action': 'शिफारस केलेली कृती',
      'suspected_diseases': 'संभाव्य आजार (डिफरेंशियल डायग्नोसिस)',
      'explanation': 'वैद्यकीय स्पष्टीकरण',

      'health_risk_assessment': 'आरोग्य जोखीम मूल्यमापन',
      'risk_low': 'कमी आरोग्य जोखीम',
      'risk_medium': 'मध्यम आरोग्य जोखीम',
      'risk_high': 'उच्च आरोग्य जोखीम',
      'risk_critical': 'गंभीर आरोग्य जोखीम',

      'report_animal_death': 'जनावर मृत झाल्याची नोंद करा',
      'how_many_died': 'किती जनावरांचा मृत्यू झाला?',
      'when_happened': 'हे कधी घडले?',
      'problems_before_death': 'मृत्यूआधी दिसलेली लक्षणे',
      'death_reported_title': 'गंभीर: जनावराचा मृत्यू नोंदवला गेला आहे',
      'death_reported_msg': 'कृपया बाधित भागातून इतर जनावरांना हलवू नका. काटेकोर विलगीकरण आवश्यक आहे.',

      'need_veterinarian': 'पशुवैद्यक डॉक्टर हवे आहेत का?',
      'select_case': 'जनावर / केस निवडा',
      'reason_for_vet': 'बोलवण्याचे कारण',
      'reason_very_sick': 'जनावर खूप आजारी आहे',
      'reason_not_improving': 'गुण येत नाही',
      'reason_death': 'जनावराचा मृत्यू',
      'reason_vaccination': 'लसीकरणाची विनंती',
      'reason_treatment': 'पुढील उपचार',
      'reason_other': 'इतर कारण',
      'preferred_visit': 'पसंतीचा दिवस',
      'preferred_time': 'पसंतीची वेळ',
      'morning': 'सकाळ (८ ते १२)',
      'afternoon': 'दुपार (१२ ते ४)',
      'evening': 'संध्याकाळ (४ ते ७)',
      'status_submitted': 'सबमिट झाले',
      'status_under_review': 'तपासणी सुरू',
      'status_vet_assigned': 'डॉक्टर नियुक्त',
      'status_visit_scheduled': 'भेट ठरली',
      'status_treatment_started': 'उपचार सुरू',
      'status_case_closed': 'प्रकरण बंद',

      'farmer_details': 'शेतकऱ्याचा तपशील',
      'farm_details': 'गोठ्याचा तपशील',
      'app_settings': 'ॲप सेटिंग्ज',
      'change_language': 'भाषा बदला',
      'smart_livestock': 'स्मार्ट पशुधन',
      'veterinary_dashboard': 'पशुवैद्यकीय डॅशबोर्ड',
      'vet_officer_title': 'डॉ. राजेश कुमार · पशुवैद्यकीय अधिकारी',
      'notifications': 'सूचना',
      'logout': 'लॉगआउट करा',
      'logout_confirm': 'आपण नक्की लॉगआउट करू इच्छिता का?',

      'step_counter': 'टप्पा {step} / {total}',
      'basic_info_subtitle': 'कृपया आपली मूलभूत संपर्क माहिती द्या.',
      'name_hint': 'उदा. रमेश पाटील (किंवा बोला)',
      'tap_speak_name': 'नाव बोलण्यासाठी टॅप करा',
      'listening_tap_stop': 'ऐकत आहे... थांबवण्यासाठी आणि सेव्ह करण्यासाठी टॅप करा',
      'speak_your_name': 'आपले नाव बोला',
      'stop_listening': 'ऐकणे थांबवा',
      'location_subtitle': 'ड्रॉपडाउनमधून आपल्या स्थानाचा तपशील निवडा.',
      'fixed': 'निश्चित',
      'taluk': 'तालुका',
      'village_hint': 'आपल्या गावाचे नाव प्रविष्ट करा',
      'farm_details_subtitle': 'फार्मचा आकार प्रविष्ट करा आणि आपले पशुधन निवडा.',
      'select_all_apply': 'लागू असलेले सर्व निवडा',
      'livestock_type_select_all': 'पशुधनाचा प्रकार (लागू असलेले सर्व निवडा)',
      'pref_subtitle': 'अ‍ॅपशी संवाद कसा साधायचा ते निवडा.',
      'verification_code_sent': '{mobile} वर पडताळणी कोड पाठवला आहे.',
      'autofill_demo_otp': 'डेमो ओटीपी ऑटो-भरा ({otp})',
      'verify_and_continue': 'पडताळा आणि पुढे जा',
      'create_password_subtitle': '{name} साठी सहज लॉगिन करण्यासाठी पासवर्ड तयार करा.',
      'welcome_ready': 'स्वागत आहे, {name}! आपण आपल्या फार्मचे व्यवस्थापन करण्यास तयार आहात.',
      'farm_health_summary': 'फार्म आरोग्य सारांश',
      'see_all_cases': 'सर्व केसेस पहा',
      'activity_animal_registered': 'पशू नोंदणीकृत',
      'activity_health_reported': 'आरोग्य अहवाल',
      'activity_mortality_reported': 'मृत्यू अहवाल',
      'activity_vet_requested': 'पशुवैद्यक विनंती',
      'no_recent_activity': 'अद्याप कोणतीही अलीकडील कृती नाही.',
      'use_report_button_to_start': 'सुरू करण्यासाठी वरील रिपोर्ट बटण वापरा.',
      'animals_affected_count': '{count} प्राणी बाधित',
      'alerts_and_advisories': 'अलर्ट आणि मार्गदर्शक सूचना',
      'mark_all_read': 'सर्व वाचलेले चिन्हांकित करा',
      'no_alerts_yet': 'अद्याप कोणतेही अलर्ट नाहीत',
      'no_alerts_subtitle': 'आरोग्य अहवाल किंवा सल्लागार जारी केल्यावर अलर्ट येथे दिसतील.',
      'tab_health': 'आरोग्य',
      'tab_mortality': 'मृत्यू',
      'tab_vet_visits': 'पशुवैद्यकीय भेटी',
      'report_new_problem': 'नवीन समस्या नोंदवा',
      'report_an_issue': 'समस्येची तक्रार करा',
      'what_to_report': 'आपल्याला कशाची नोंद करायची आहे?',
      'report_symptoms': 'लक्षणे नोंदवा',
      'report_symptoms_desc': 'जोखीम मूल्यांकनासाठी प्राणी निवडा आणि आरोग्य लक्षणे नोंदवा.',
      'report_mortality': 'पशू मृत्यू नोंदवा',
      'report_mortality_desc': 'प्राण्याच्या मृत्यूची नोंद करा. एक गंभीर इशारा तयार केला जाईल.',
      'request_vet': 'पशुवैद्यक बोलवा',
      'request_vet_desc': 'गरज असल्यास पशुवैद्यकीय भेटीची विनंती करा.',
      'my_recent_reports': 'माझे अलीकडील अहवाल',
      'farmer_profile': 'शेतकरी प्रोफाइल',
      'section_farmer_details': 'विभाग १ — शेतकरी तपशील',
      'section_farm_details': 'विभाग २ — फार्म तपशील',
      'edit_farmer_details': 'शेतकरी तपशील संपादित करा',
      'save_farm_details': 'फार्म तपशील जतन करा',
      'location_mode': 'स्थान मोड',
      'gender_male': 'नर',
      'gender_female': 'मादी',
      'status_healthy': 'निरोगी',
      'status_monitoring': 'निरीक्षणाखाली',
      'status_active_case': 'सक्रिय केस',
      'status_critical': 'गंभीर',
      'otp_sent_to': '६ अंकी ओटीपी पाठवला आहे',
      'enter_verification_code': '६-अंकी पडताळणी ओटीपी प्रविष्ट करा',
      'please_enter_6_digit_otp': 'कृपया ६ अंकी ओटीपी प्रविष्ट करा.',
      'verify_otp': 'ओटीपी पडताळा',
      'resend_otp': 'ओटीपी पुन्हा पाठवा',
      'otp_resent_success': 'आपल्या मोबाईल क्रमांकावर ओटीपी पुन्हा पाठवला आहे.',
      'create_password': 'पासवर्ड तयार करा',
      'create_a_password': 'एक पासवर्ड तयार करा',
      'welcome': 'स्वागत आहे',
      'set_password_desc': 'आपल्या खात्यासाठी सुरक्षित पासवर्ड सेट करा.',
      'please_enter_password': 'कृपया एक पासवर्ड प्रविष्ट करा.',
      'password_min_length': 'पासवर्ड किमान ६ अक्षरांचा असावा.',
      'passwords_do_not_match': 'पासवर्ड जुळत नाहीत.',
      'create_account': 'खाते तयार करा',
      'treatment_followup': 'उपचार फॉलो-अप',
      'request_general_visit_no_animal': 'शेतासाठी सामान्य भेटीची विनंती (नोंदणीकृत जनावर निवडलेले नाही)',
      'describe_symptoms_notes': 'लक्षणे / परिस्थितीचे वर्णन करा',
      'write_brief_notes_hint': 'किंवा येथे थोडक्यात नोंद लिहा...',
      'submit_vet_request': 'पशुवैद्यकीय भेट विनंती पाठवा',
      'request_submitted': 'विनंती पाठवली',
      'vet_request_submitted': 'पशुवैद्यकीय भेट विनंती यशस्वीरित्या पाठवली',
      'request_id': 'विनंती आयडी',
      'case_progression_timeline': 'प्रकरण प्रगती टाइमलाइन:',
      'timeline_submitted': 'दाखल केले',
      'timeline_submitted_desc': 'आपली विनंती प्राप्त झाली आहे.',
      'timeline_under_review': 'पुनरावलोकनाधीन',
      'timeline_under_review_desc': 'समन्वयक प्रकरणाचे पुनरावलोकन करतील.',
      'timeline_vet_assigned': 'पशुवैद्यक नियुक्त',
      'timeline_vet_assigned_desc': 'पशुवैद्यकांची नियुक्ती केली जाईल.',
      'timeline_visit_scheduled': 'भेट नियोजित',
      'timeline_visit_scheduled_desc': 'भेटीची तारीख आणि वेळ निश्चित झाली.',
      'timeline_treatment_started': 'उपचार सुरू',
      'timeline_treatment_started_desc': 'पशुवैद्यकांची भेट आणि उपचार दिले.',
      'timeline_case_closed': 'प्रकरण बंद',
      'timeline_case_closed_desc': 'प्रकरण निकाली निघाले.',
      'sample_collected': 'नमुना गोळा केला',
      'lab_referred': 'प्रयोगशाळेकडे पाठवले',
      'escalated_to_govt': 'शासनाला वर्ग केले',
      'treatment_records': 'उपचार नोंदी',
      'treatment_records_created_by_vet': 'उपचार नोंदी पशुवैद्यकीय मॉड्युलद्वारे पशुवैद्यकांकडून तयार केल्या जातात.',
      'vaccination_records': 'लसीकरण नोंदी',
      'please_add_animals_first': 'कृपया आधी जनावरांची नोंद करा.',
      'add_vaccination_record': 'लसीकरण नोंद जोडा',
      'vaccine_name': 'लसीचे नाव',
      'save_record': 'नोंद जतन करा',
      'no_upcoming_vaccinations': 'कोणतेही आगामी लसीकरण नाही.',
      'no_vaccination_history': 'लसीकरणाचा इतिहास नाही.',
      'no_health_cases_reported': 'अद्याप कोणतीही आरोग्य तक्रार दाखल झालेली नाही.',
      'no_mortality_cases_reported': 'कोणत्याही मृत जनावराची नोंद नाही.',
      'escalated_to_govt_title': 'शासकीय देखरेखीसाठी वर्ग करण्यात आले',
      'escalated_to_govt_desc': 'तातडीच्या साथीच्या नियंत्रणासाठी हे प्रकरण प्रादेशिक पशु आरोग्य अधिकाऱ्यांकडे वर्ग केले आहे.',
      'attending_vet': 'उपचार करणारे पशुवैद्यक',
      'visit': 'भेट',
      'vet_findings_diagnosis': 'पशुवैद्यकीय तपासणी निष्कर्ष व निदान',
      'health_risk': 'आरोग्य धोका',
      'reported_problems': 'दाखल केलेल्या समस्या',
      'advice_given': 'दिलेला सल्ला',
      'voice_note_recorded': 'या प्रकरणासोबत व्हॉईस नोट रेकॉर्ड केली आहे',
      'status_timeline': 'स्थिती टाइमलाइन',
      'animals_died': 'मृत जनावरे',
      'symptoms_before_death': 'मृत्यू आधीची लक्षणे',
      'upcoming': 'आगामी',
      'history': 'इतिहास',
      'verified': 'पडताळलेले',
      'choose_date': 'तारीख निवडा',
      'start_date': 'सुरू झालेली तारीख',
      'follow_up': 'फॉलो-अप',
      'instructions': 'सूचना',
      'mortality': 'मृत्यू',
      'case': 'केस',
      'risk': 'धोका',
      'species': 'प्रजाती',
      'time': 'वेळ',
      'location': 'स्थान',
      'date': 'तारीख',
      'status': 'स्थिती',
      'tomorrow': 'उद्या',
      'section_vet_visits': 'विभाग ३ — पशुवैद्यकीय भेटी',
      'no_vet_visits': 'कोणतीही पशुवैद्यकीय भेट नोंदवलेली नाही',
      'no_vet_visits_desc': 'जेव्हा पशुवैद्यक आपल्या शेताला भेट देतील, तेव्हा अहवाल येथे दिसेल.',
      'load_demo_records': 'डेमो नोंदी लोड करा',
      'load_demo_records_desc': 'नमुना प्राणी, आरोग्य अहवाल, पशुवैद्यक विनंत्या आणि इशारे समाविष्ट करतो.',
      'demo_data_loaded': 'डेमो नोंदी यशस्वीरित्या लोड केल्या!',
      'filter_animals': 'जनावरे फिल्टर करा',
      'health_status': 'आरोग्य स्थिती',
      'clear_filters': 'फिल्टर काढा',
      'individual': 'वैयक्तिक',
      'herds': 'कळप',
      'search_animals_hint': 'टॅग, जात, प्रजातीनुसार शोधा...',
      'showing_animals_count': '{count} जनावरे दाखवत आहे',
      'no_animals_found': 'कोणतेही जनावर आढळले नाही',
      'add_first_animal': 'पहिले जनावर जोडा',
      'add_animal': 'जनावर जोडा',
      'remove_animal': 'जनावर काढा',
      'remove_animal_confirm': 'आपण नक्की {tag} हे जनावर काढू इच्छिता का?',
      'removed': 'काढले',
      'view_details': 'तपशील पहा',
      'no_herds_found': 'अद्याप कोणताही कळप गट नोंदणीकृत नाही.',
      'edit_animal': 'जनावर तपशील संपादित करा',
      'add_new_animal': 'नवीन जनावर जोडा',
      'add_photo': 'फोटो जोडा',
      'photo_upload_placeholder': 'जनावराचा फोटो घेण्यासाठी किंवा निवडण्यासाठी टॅप करा',
      'animal_identification': 'जनावर ओळख',
      'please_enter_animal_id': 'कृपया कानाचा टॅग / आयडी प्रविष्ट करा',
      'please_enter_breed': 'कृपया जात प्रविष्ट करा',
      'please_enter_age': 'कृपया वय प्रविष्ट करा',
      'save_changes': 'बदल जतन करा',
      'ear_tag_exists': 'या कानाच्या टॅगचे जनावर आधीच नोंदणीकृत आहे.',
      'animal_updated': 'जनावराची माहिती यशस्वीरित्या अद्यतनित केली!',
      'added_successfully': 'यशस्वीरित्या जोडले गेले!',
      'animal_details': 'जनावराचा तपशील',
      'animal_not_found': 'जनावर आढळले नाही',
      'animal_information': 'जनावराची माहिती',
      'health_overview': 'आरोग्य आढावा',
      'current_status': 'सद्य स्थिती',
      'last_health_report': 'शेवटचा आरोग्य अहवाल',
      'last_vet_visit': 'शेवटची पशुवैद्यकीय भेट',
      'none': 'काही नाही',
      'health_records': 'आरोग्य नोंदी',
      'no_health_records': 'या जनावरासाठी कोणतीही आरोग्य नोंद नाही.',
      'vaccination': 'लसीकरण',
      'no_vaccinations': 'लसीकरणाच्या नोंदी नाहीत.',
      'treatment': 'उपचार',
      'no_treatments': 'उपचाराच्या नोंदी नाहीत.',
      'vet_requests': 'पशुवैद्यक विनंत्या',
      'no_vet_requests': 'पशुवैद्यकीय भेट विनंत्या नाहीत.',
      'no_reports_yet_desc': 'येथे वैद्यकीय नोंदी व केस ट्रॅकिंग पाहण्यासाठी आरोग्य लक्षणे नोंदवणे सुरू करा.',
      'ago': 'पूर्वी',
      'just_now': 'आत्ताच',
      'selected': 'निवडले',
      'continue_with': 'सह पुढे जा',
      'animal_id_hint': 'उदा. COW-001, TAG-1234, किंवा बोला',
      'select_all_problems': 'लागू असलेले सर्व निवडा',
      'duration_subtitle': 'जनावर किती दिवसांपासून आजारी आहे?',
      'affected_count_subtitle': 'किती जनावरांमध्ये लक्षणे दिसत आहेत?',
      'evidence_subtitle': 'फोटो, व्हिडिओ किंवा व्हॉईस रेकॉर्डिंग जोडा',
      'review_details_subtitle': 'नोंदवलेल्या लक्षणांचे पुनरावलोकन करा आणि सबमिट करा',
      'more_than_10': "१० पेक्षा जास्त",
      'affected_2_5': '2–5 जनावरे',
      'affected_6_10': '6–10 जनावरे',
      'recorded': 'नोंदवले',
      'added': 'जोडले',
      'manual_location': 'मॅन्युअल स्थान',
      'gps_fix': 'जीपीएस स्थान',
      'problems': 'समस्या',
      'animals_affected': 'बाधित जनावरे',
      'submit_mortality_report': 'मृत्यू अहवाल सबमिट करा',
      'login_subtitle': 'पशुधन आरोग्य आणि रोग पाळत पोर्टल',
      'remember_me': 'माझी आठवण ठेवा',
      'reset_password': 'पासवर्ड रीसेट करा',
      'reset_password_desc': 'आपला नोंदणीकृत मोबाईल क्रमांक प्रविष्ट करा. पासवर्ड रीसेट करण्यासाठी आम्ही एक ओटीपी पाठवू.',
      'send_otp': 'ओटीपी पाठवा',
      'animal': 'जनावर',
      'animal_id': 'जनावर आयडी',
      'submitted': 'सबमिट झाले',
      'breed': 'जात',
      'details': 'तपशील',
      'cases': 'प्रकरणे',
      'health': 'आरोग्य',
      'vet_visits': 'पशुवैद्यकीय भेटी',
      'vet_request': 'पशुवैद्यक विनंती',
      'timeline': 'टाइमलाइन',
      'preferred_date': 'पसंतीचा दिवस',
      'enter_full_name': 'कृपया आपले पूर्ण नाव प्रविष्ट करा.',
      'enter_valid_mobile': 'कृपया १०-अंकी मोबाईल क्रमांक प्रविष्ट करा.',
      'enter_village': 'कृपया आपल्या गावाचे नाव प्रविष्ट करा.',
      'select_one_livestock': 'कृपया किमान एक पशुधनाचा प्रकार निवडा.',
      'incorrect_otp': 'चुकीचा ओटीपी. डेमोसाठी 123456 वापरा.',
      'password_min_4': 'पासवर्ड किमान ४ अक्षरांचा असावा.',
      'passwords_dont_match': 'पासवर्ड जुळत नाहीत.',
      'listening_speak_name': 'ऐकत आहे... आपले नाव स्पष्ट बोला',
      'transcribing_name': 'बोललेले नाव रूपांतरित करत आहे...',
      'voice_captured': 'आवाज नोंदवला गेला',
      'no_speech_detected': 'आवाज ओळखता आला नाही. कृपया मोठ्याने बोला किंवा आपले नाव टाइप करा.',
      'using_current_loc': 'सध्याचे स्थान वापरत आहे',
      'case_id': 'प्रकरण आयडी'
    }
  };

  /// Common dictionary for universal translations across dynamic clinical terms, breeds, symptoms, and phrases.
  static final Map<String, Map<String, String>> _commonPhraseTranslations = {
    // ── Species ──
    'Cow': {'en': 'Cow', 'hi': 'गाय', 'mr': 'गाय'},
    'cow': {'en': 'Cow', 'hi': 'गाय', 'mr': 'गाय'},
    'Buffalo': {'en': 'Buffalo', 'hi': 'भैंस', 'mr': 'म्हैस'},
    'buffalo': {'en': 'Buffalo', 'hi': 'भैंस', 'mr': 'म्हैस'},
    'Goat': {'en': 'Goat', 'hi': 'बकरी', 'mr': 'शेळी'},
    'goat': {'en': 'Goat', 'hi': 'बकरी', 'mr': 'शेळी'},
    'Sheep': {'en': 'Sheep', 'hi': 'भेड़', 'mr': 'मेंढी'},
    'sheep': {'en': 'Sheep', 'hi': 'भेड़', 'mr': 'मेंढी'},
    'Pig': {'en': 'Pig', 'hi': 'सूअर', 'mr': 'डुक्कर'},
    'pig': {'en': 'Pig', 'hi': 'सूअर', 'mr': 'डुक्कर'},
    'Poultry': {'en': 'Poultry', 'hi': 'पोल्ट्री / मुर्गी', 'mr': 'पोल्ट्री / कोंबडी'},
    'poultry': {'en': 'Poultry', 'hi': 'पोल्ट्री / मुर्गी', 'mr': 'पोल्ट्री / कोंबडी'},
    'Other': {'en': 'Other', 'hi': 'अन्य', 'mr': 'इतर'},
    'other': {'en': 'Other', 'hi': 'अन्य', 'mr': 'इतर'},

    // ── Risk Levels ──
    'LOW Risk': {'en': 'LOW Risk', 'hi': 'कम जोखिम', 'mr': 'कमी जोखीम'},
    'Low Risk': {'en': 'Low Risk', 'hi': 'कम जोखिम', 'mr': 'कमी जोखीम'},
    'MEDIUM Risk': {'en': 'MEDIUM Risk', 'hi': 'मध्यम जोखिम', 'mr': 'मध्यम जोखीम'},
    'Medium Risk': {'en': 'Medium Risk', 'hi': 'मध्यम जोखिम', 'mr': 'मध्यम जोखीम'},
    'HIGH Risk': {'en': 'HIGH Risk', 'hi': 'उच्च जोखिम', 'mr': 'उच्च जोखीम'},
    'High Risk': {'en': 'High Risk', 'hi': 'उच्च जोखिम', 'mr': 'उच्च जोखीम'},
    'CRITICAL Risk': {'en': 'CRITICAL Risk', 'hi': 'गंभीर जोखिम', 'mr': 'गंभीर जोखीम'},
    'Critical Risk': {'en': 'Critical Risk', 'hi': 'गंभीर जोखिम', 'mr': 'गंभीर जोखीम'},

    // ── Farmer Profile, Names & Locations ──
    'Sanjay Kumar': {'en': 'Sanjay Kumar', 'hi': 'संजय कुमार', 'mr': 'संजय कुमार'},
    'sanjay kumar': {'en': 'Sanjay Kumar', 'hi': 'संजय कुमार', 'mr': 'संजय कुमार'},
    'Green Meadows Farm': {'en': 'Green Meadows Farm', 'hi': 'ग्रीन मीडोज फार्म', 'mr': 'ग्रीन मेडोज फार्म'},
    'green meadows farm': {'en': 'Green Meadows Farm', 'hi': 'ग्रीन मीडोज फार्म', 'mr': 'ग्रीन मेडोज फार्म'},
    'Ramesh Pawar': {'en': 'Ramesh Pawar', 'hi': 'रमेश पवार', 'mr': 'रमेश पवार'},
    'ramesh pawar': {'en': 'Ramesh Pawar', 'hi': 'रमेश पवार', 'mr': 'रमेश पवार'},
    'Dr. Rajesh Kumar': {'en': 'Dr. Rajesh Kumar', 'hi': 'डॉ. राजेश कुमार', 'mr': 'डॉ. राजेश कुमार'},
    'dr. rajesh kumar': {'en': 'Dr. Rajesh Kumar', 'hi': 'डॉ. राजेश कुमार', 'mr': 'डॉ. राजेश कुमार'},
    'Dr. Priya Nair': {'en': 'Dr. Priya Nair', 'hi': 'डॉ. प्रिया नायर', 'mr': 'डॉ. प्रिया नायर'},
    'dr. priya nair': {'en': 'Dr. Priya Nair', 'hi': 'डॉ. प्रिया नायर', 'mr': 'डॉ. प्रिया नायर'},
    'Uruli Kanchan': {'en': 'Uruli Kanchan', 'hi': 'उरुली कांचन', 'mr': 'उरुळी कांचन'},
    'uruli kanchan': {'en': 'Uruli Kanchan', 'hi': 'उरुली कांचन', 'mr': 'उरुळी कांचन'},
    'Maharashtra': {'en': 'Maharashtra', 'hi': 'महाराष्ट्र', 'mr': 'महाराष्ट्र'},
    'maharashtra': {'en': 'Maharashtra', 'hi': 'महाराष्ट्र', 'mr': 'महाराष्ट्र'},

    // ── Maharashtra Districts (All 36) ──
    'Ahmednagar': {'en': 'Ahmednagar', 'hi': 'अहमदनगर', 'mr': 'अहमदनगर'},
    'Akola': {'en': 'Akola', 'hi': 'अकोला', 'mr': 'अकोला'},
    'Amravati': {'en': 'Amravati', 'hi': 'अमरावती', 'mr': 'अमरावती'},
    'Aurangabad': {'en': 'Aurangabad', 'hi': 'औरंगाबाद', 'mr': 'औरंगाबाद'},
    'Beed': {'en': 'Beed', 'hi': 'बीड', 'mr': 'बीड'},
    'Bhandara': {'en': 'Bhandara', 'hi': 'भंडारा', 'mr': 'भंडारा'},
    'Buldhana': {'en': 'Buldhana', 'hi': 'बुलढाणा', 'mr': 'बुलढाणा'},
    'Chandrapur': {'en': 'Chandrapur', 'hi': 'चंद्रपुर', 'mr': 'चंद्रपूर'},
    'Dhule': {'en': 'Dhule', 'hi': 'धुले', 'mr': 'धुळे'},
    'Gadchiroli': {'en': 'Gadchiroli', 'hi': 'गढ़चिरौली', 'mr': 'गडचिरोली'},
    'Gondia': {'en': 'Gondia', 'hi': 'गोंदिया', 'mr': 'गोंदिया'},
    'Hingoli': {'en': 'Hingoli', 'hi': 'हिंगोली', 'mr': 'हिंगोली'},
    'Jalgaon': {'en': 'Jalgaon', 'hi': 'जलगांव', 'mr': 'जळगाव'},
    'Jalna': {'en': 'Jalna', 'hi': 'जालना', 'mr': 'जालना'},
    'Kolhapur': {'en': 'Kolhapur', 'hi': 'कोल्हापुर', 'mr': 'कोल्हापूर'},
    'Latur': {'en': 'Latur', 'hi': 'लातुर', 'mr': 'लातूर'},
    'Mumbai City': {'en': 'Mumbai City', 'hi': 'मुंबई शहर', 'mr': 'मुंबई शहर'},
    'Mumbai Suburban': {'en': 'Mumbai Suburban', 'hi': 'मुंबई उपनगर', 'mr': 'मुंबई उपनगर'},
    'Nagpur': {'en': 'Nagpur', 'hi': 'नागपुर', 'mr': 'नागपूर'},
    'Nanded': {'en': 'Nanded', 'hi': 'नांदेड़', 'mr': 'नांदेड'},
    'Nandurbar': {'en': 'Nandurbar', 'hi': 'नंदुरबार', 'mr': 'नंदुरबार'},
    'Nashik': {'en': 'Nashik', 'hi': 'नासिक', 'mr': 'नाशिक'},
    'Osmanabad': {'en': 'Osmanabad', 'hi': 'उस्मानाबाद', 'mr': 'उस्मानाबाद'},
    'Palghar': {'en': 'Palghar', 'hi': 'पालघर', 'mr': 'पालघर'},
    'Parbhani': {'en': 'Parbhani', 'hi': 'परभनी', 'mr': 'परभणी'},
    'Pune': {'en': 'Pune', 'hi': 'पुणे', 'mr': 'पुणे'},
    'Raigad': {'en': 'Raigad', 'hi': 'रायगढ़', 'mr': 'रायगड'},
    'Ratnagiri': {'en': 'Ratnagiri', 'hi': 'रत्नागिरी', 'mr': 'रत्नागिरी'},
    'Sangli': {'en': 'Sangli', 'hi': 'सांगली', 'mr': 'सांगली'},
    'Satara': {'en': 'Satara', 'hi': 'सतारा', 'mr': 'सातारा'},
    'Sindhudurg': {'en': 'Sindhudurg', 'hi': 'सिंधुदुर्ग', 'mr': 'सिंधुदुर्ग'},
    'Solapur': {'en': 'Solapur', 'hi': 'सोलापुर', 'mr': 'सोलापूर'},
    'Thane': {'en': 'Thane', 'hi': 'ठाणे', 'mr': 'ठाणे'},
    'Wardha': {'en': 'Wardha', 'hi': 'वर्धा', 'mr': 'वर्धा'},
    'Washim': {'en': 'Washim', 'hi': 'वाशिम', 'mr': 'वाशीम'},
    'Yavatmal': {'en': 'Yavatmal', 'hi': 'यवतमाल', 'mr': 'यवतमाळ'},

    // ── Maharashtra Talukas / Blocks ──
    'Haveli': {'en': 'Haveli', 'hi': 'हवेली', 'mr': 'हवेली'},
    'Ambegaon': {'en': 'Ambegaon', 'hi': 'आंबेगांव', 'mr': 'आंबेगाव'},
    'Baramati': {'en': 'Baramati', 'hi': 'बारामती', 'mr': 'बारामती'},
    'Bhor': {'en': 'Bhor', 'hi': 'भोर', 'mr': 'भोर'},
    'Daund': {'en': 'Daund', 'hi': 'दौंड', 'mr': 'दौंड'},
    'Indapur': {'en': 'Indapur', 'hi': 'इंदापुर', 'mr': 'इंदापूर'},
    'Junnar': {'en': 'Junnar', 'hi': 'जुन्नर', 'mr': 'जुन्नर'},
    'Khed': {'en': 'Khed', 'hi': 'खेड', 'mr': 'खेड'},
    'Mawal': {'en': 'Mawal', 'hi': 'मावल', 'mr': 'मावळ'},
    'Mulshi': {'en': 'Mulshi', 'hi': 'मुलशी', 'mr': 'मुळशी'},
    'Purandar': {'en': 'Purandar', 'hi': 'पुरंदर', 'mr': 'पुरंदर'},
    'Shirur': {'en': 'Shirur', 'hi': 'शिरुर', 'mr': 'शिरूर'},
    'Velhe': {'en': 'Velhe', 'hi': 'वेल्हे', 'mr': 'वेल्हे'},
    'Akole': {'en': 'Akole', 'hi': 'अकोले', 'mr': 'अकोले'},
    'Jamkhed': {'en': 'Jamkhed', 'hi': 'जामखेड', 'mr': 'जामखेड'},
    'Karjat': {'en': 'Karjat', 'hi': 'कर्जत', 'mr': 'कर्जत'},
    'Kopargaon': {'en': 'Kopargaon', 'hi': 'कोपरगांव', 'mr': 'कोपरगाव'},
    'Nagar': {'en': 'Nagar', 'hi': 'नगर', 'mr': 'नगर'},
    'Nevasa': {'en': 'Nevasa', 'hi': 'नेवासा', 'mr': 'नेवासा'},
    'Parner': {'en': 'Parner', 'hi': 'पारनेर', 'mr': 'पारनेर'},
    'Pathardi': {'en': 'Pathardi', 'hi': 'पाथर्डी', 'mr': 'पाथर्डी'},
    'Rahata': {'en': 'Rahata', 'hi': 'रहाता', 'mr': 'राहाता'},
    'Rahuri': {'en': 'Rahuri', 'hi': 'राहुरी', 'mr': 'राहुरी'},
    'Sangamner': {'en': 'Sangamner', 'hi': 'संगमनेर', 'mr': 'संगमनेर'},
    'Shevgaon': {'en': 'Shevgaon', 'hi': 'शेवगांव', 'mr': 'शेवगाव'},
    'Shrigonda': {'en': 'Shrigonda', 'hi': 'श्रीगोंदा', 'mr': 'श्रीगोंदा'},
    'Shrirampur': {'en': 'Shrirampur', 'hi': 'श्रीरामपुर', 'mr': 'श्रीरामपूर'},
    'Akot': {'en': 'Akot', 'hi': 'आकोट', 'mr': 'आकोट'},
    'Balapur': {'en': 'Balapur', 'hi': 'बालापुर', 'mr': 'बाळापूर'},
    'Barshitakli': {'en': 'Barshitakli', 'hi': 'बार्शीटाकली', 'mr': 'बार्शीटाकळी'},
    'Murtizapur': {'en': 'Murtizapur', 'hi': 'मुर्तिजापुर', 'mr': 'मूर्तिजापूर'},
    'Patur': {'en': 'Patur', 'hi': 'पातुर', 'mr': 'पातूर'},
    'Telhara': {'en': 'Telhara', 'hi': 'तेल्हारा', 'mr': 'तेल्हारा'},
    'Achalpur': {'en': 'Achalpur', 'hi': 'अचलपुर', 'mr': 'अचलपूर'},
    'Anjangaon Surji': {'en': 'Anjangaon Surji', 'hi': 'अंजनगांव सुर्जी', 'mr': 'अंजनगाव सुर्जी'},
    'Chandur Bazar': {'en': 'Chandur Bazar', 'hi': 'चांदुर बाजार', 'mr': 'चांदूर बाजार'},
    'Chandurbazar': {'en': 'Chandurbazar', 'hi': 'चांदुर बाजार', 'mr': 'चांदूर बाजार'},
    'Chikhaldara': {'en': 'Chikhaldara', 'hi': 'चिखलदरा', 'mr': 'चिखलदरा'},
    'Daryapur': {'en': 'Daryapur', 'hi': 'दर्यापुर', 'mr': 'दर्यापूर'},
    'Dhamangaon Rly': {'en': 'Dhamangaon Rly', 'hi': 'धामनगांव रेलवे', 'mr': 'धामणगाव रेल्वे'},
    'Morshi': {'en': 'Morshi', 'hi': 'मोर्शी', 'mr': 'मोर्शी'},
    'Nandgaon Khandeshwar': {'en': 'Nandgaon Khandeshwar', 'hi': 'नांदगांव खंडेश्वर', 'mr': 'नांदगाव खंडेश्वर'},
    'Teosa': {'en': 'Teosa', 'hi': 'तिवसा', 'mr': 'तिवसा'},
    'Warud': {'en': 'Warud', 'hi': 'वरुड', 'mr': 'वरुड'},
    'Gangapur': {'en': 'Gangapur', 'hi': 'गंगापुर', 'mr': 'गंगापूर'},
    'Kannad': {'en': 'Kannad', 'hi': 'कन्नड', 'mr': 'कन्नड'},
    'Khuldabad': {'en': 'Khuldabad', 'hi': 'खुलताबाद', 'mr': 'खुलताबाद'},
    'Paithan': {'en': 'Paithan', 'hi': 'पैठन', 'mr': 'पैठण'},
    'Phulambri': {'en': 'Phulambri', 'hi': 'फुलंब्री', 'mr': 'फुलंब्री'},
    'Silod': {'en': 'Silod', 'hi': 'सिल्लोड', 'mr': 'सिल्लोड'},
    'Soegaon': {'en': 'Soegaon', 'hi': 'सोयगांव', 'mr': 'सोयगाव'},
    'Soyegaon': {'en': 'Soyegaon', 'hi': 'सोयगांव', 'mr': 'सोयगाव'},
    'Vaijapur': {'en': 'Vaijapur', 'hi': 'वैजापुर', 'mr': 'वैजापूर'},
    'Ambajogai': {'en': 'Ambajogai', 'hi': 'अंबाजोगाई', 'mr': 'अंबाजोगाई'},
    'Ashti': {'en': 'Ashti', 'hi': 'आष्टी', 'mr': 'आष्टी'},
    'Dharur': {'en': 'Dharur', 'hi': 'धारुर', 'mr': 'धारूर'},
    'Georai': {'en': 'Georai', 'hi': 'गेवराई', 'mr': 'गेवराई'},
    'Kaij': {'en': 'Kaij', 'hi': 'केज', 'mr': 'केज'},
    'Manjlegaon': {'en': 'Manjlegaon', 'hi': 'माजलगांव', 'mr': 'माजलगाव'},
    'Parli': {'en': 'Parli', 'hi': 'परली', 'mr': 'परळी'},
    'Patoda': {'en': 'Patoda', 'hi': 'पाटोदा', 'mr': 'पाटोदा'},
    'Shirur Kasar': {'en': 'Shirur Kasar', 'hi': 'शिरुर कासार', 'mr': 'शिरूर कासार'},
    'Wadwani': {'en': 'Wadwani', 'hi': 'वडवणी', 'mr': 'वडवणी'},
    'Lakhandur': {'en': 'Lakhandur', 'hi': 'लाखांदुर', 'mr': 'लाखांदूर'},
    'Lakhani': {'en': 'Lakhani', 'hi': 'लाखनी', 'mr': 'लाखनी'},
    'Mohadi': {'en': 'Mohadi', 'hi': 'मोहाडी', 'mr': 'मोहाडी'},
    'Pauni': {'en': 'Pauni', 'hi': 'पवनी', 'mr': 'पवनी'},
    'Sakoli': {'en': 'Sakoli', 'hi': 'साकोली', 'mr': 'साकोली'},
    'Tumsar': {'en': 'Tumsar', 'hi': 'तुमसर', 'mr': 'तुमसर'},
    'Chikhli': {'en': 'Chikhli', 'hi': 'चिखली', 'mr': 'चिखली'},
    'Deolgaon Raja': {'en': 'Deolgaon Raja', 'hi': 'देवलगांव राजा', 'mr': 'देऊळगाव राजा'},
    'Jalgaon Jamod': {'en': 'Jalgaon Jamod', 'hi': 'जलगांव जामोद', 'mr': 'जळगाव जामोद'},
    'Khamgaon': {'en': 'Khamgaon', 'hi': 'खामगांव', 'mr': 'खामगाव'},
    'Lonar': {'en': 'Lonar', 'hi': 'लोणार', 'mr': 'लोणार'},
    'Malkapur': {'en': 'Malkapur', 'hi': 'मलकापुर', 'mr': 'मलकापूर'},
    'Mehkar': {'en': 'Mehkar', 'hi': 'मेहकर', 'mr': 'मेहकर'},
    'Motala': {'en': 'Motala', 'hi': 'मोताळा', 'mr': 'मोताळा'},
    'Nandura': {'en': 'Nandura', 'hi': 'नांदुरा', 'mr': 'नांदुरा'},
    'Sangrampur': {'en': 'Sangrampur', 'hi': 'संग्रामपुर', 'mr': 'संग्रामपूर'},
    'Shegaon': {'en': 'Shegaon', 'hi': 'शेगांव', 'mr': 'शेगाव'},
    'Sindkhed Raja': {'en': 'Sindkhed Raja', 'hi': 'सिंदखेड राजा', 'mr': 'सिंदखेड राजा'},
    'Ballarpur': {'en': 'Ballarpur', 'hi': 'बल्लारपुर', 'mr': 'बल्लारपूर'},
    'Bhadravati': {'en': 'Bhadravati', 'hi': 'भद्रावती', 'mr': 'भद्रावती'},
    'Brahmapuri': {'en': 'Brahmapuri', 'hi': 'ब्रह्मपुरी', 'mr': 'ब्रह्मपुरी'},
    'Chimur': {'en': 'Chimur', 'hi': 'चिमुर', 'mr': 'चिमूर'},
    'Gondpipri': {'en': 'Gondpipri', 'hi': 'गोंडपिपरी', 'mr': 'गोंडपिपरी'},
    'Jiwati': {'en': 'Jiwati', 'hi': 'जिवती', 'mr': 'जिवती'},
    'Korpana': {'en': 'Korpana', 'hi': 'कोरपना', 'mr': 'कोरपना'},
    'Mul': {'en': 'Mul', 'hi': 'मुल', 'mr': 'मूल'},
    'Nagbhid': {'en': 'Nagbhid', 'hi': 'नागभीड', 'mr': 'नागभीड'},
    'Pombhurna': {'en': 'Pombhurna', 'hi': 'पोंभूर्णा', 'mr': 'पोंभुर्णा'},
    'Rajura': {'en': 'Rajura', 'hi': 'राजुरा', 'mr': 'राजुरा'},
    'Sawali': {'en': 'Sawali', 'hi': 'सावली', 'mr': 'सावली'},
    'Sindewahi': {'en': 'Sindewahi', 'hi': 'सिंदेवाही', 'mr': 'सिंदेवाही'},
    'Warora': {'en': 'Warora', 'hi': 'वरोरा', 'mr': 'वरोरा'},
    'Sakri': {'en': 'Sakri', 'hi': 'साक्री', 'mr': 'साक्री'},
    'Shirpur': {'en': 'Shirpur', 'hi': 'शिरपुर', 'mr': 'शिरपूर'},
    'Sindkheda': {'en': 'Sindkheda', 'hi': 'शिंदखेडा', 'mr': 'शिंदखेडा'},
    'Aheri': {'en': 'Aheri', 'hi': 'अहेरी', 'mr': 'अहेरी'},
    'Armori': {'en': 'Armori', 'hi': 'आरमोरी', 'mr': 'आरमोरी'},
    'Bhamragad': {'en': 'Bhamragad', 'hi': 'भामरागड', 'mr': 'भामरागड'},
    'Chamorshi': {'en': 'Chamorshi', 'hi': 'चामोर्शी', 'mr': 'चामोर्शी'},
    'Dhanora': {'en': 'Dhanora', 'hi': 'धानोरा', 'mr': 'धानोरा'},
    'Desaiganj': {'en': 'Desaiganj', 'hi': 'देसाईगंज', 'mr': 'देसाईगंज'},
    'Etapalli': {'en': 'Etapalli', 'hi': 'एटापल्ली', 'mr': 'एटापल्ली'},
    'Korchi': {'en': 'Korchi', 'hi': 'कोरची', 'mr': 'कोरची'},
    'Kurkheda': {'en': 'Kurkheda', 'hi': 'कुरखेडा', 'mr': 'कुरखेडा'},
    'Mulchera': {'en': 'Mulchera', 'hi': 'मुलचेरा', 'mr': 'मुलचेरा'},
    'Sironcha': {'en': 'Sironcha', 'hi': 'सिरोंचा', 'mr': 'सिरोंचा'},
    'Amgaon': {'en': 'Amgaon', 'hi': 'आमगांव', 'mr': 'आमगाव'},
    'Arjuni Morgaon': {'en': 'Arjuni Morgaon', 'hi': 'अर्जुनी मोरगांव', 'mr': 'अर्जुनी मोरगाव'},
    'Deori': {'en': 'Deori', 'hi': 'देवरी', 'mr': 'देवरी'},
    'Goregaon': {'en': 'Goregaon', 'hi': 'गोरेगांव', 'mr': 'गोरेगाव'},
    'Salekasa': {'en': 'Salekasa', 'hi': 'सालेकसा', 'mr': 'सालेकसा'},
    'Sadak Arjuni': {'en': 'Sadak Arjuni', 'hi': 'सड़क अर्जुनी', 'mr': 'सडक अर्जुनी'},
    'Tirora': {'en': 'Tirora', 'hi': 'तिरोड़ा', 'mr': 'तिरोडा'},
    'Aundha Nagnath': {'en': 'Aundha Nagnath', 'hi': 'औंढा नागनाथ', 'mr': 'औंढा नागनाथ'},
    'Basmath': {'en': 'Basmath', 'hi': 'वसमत', 'mr': 'वसमत'},
    'Kalamnuri': {'en': 'Kalamnuri', 'hi': 'कळमनुरी', 'mr': 'कळमनुरी'},
    'Sengaon': {'en': 'Sengaon', 'hi': 'सेनगांव', 'mr': 'सेनगाव'},
    'Amalner': {'en': 'Amalner', 'hi': 'अमलनेर', 'mr': 'अमळनेर'},
    'Bhadgaon': {'en': 'Bhadgaon', 'hi': 'भड़गांव', 'mr': 'भडगाव'},
    'Bhusawal': {'en': 'Bhusawal', 'hi': 'भुसावल', 'mr': 'भुसावळ'},
    'Bodwad': {'en': 'Bodwad', 'hi': 'बोदवड', 'mr': 'बोधवड'},
    'Chalisgaon': {'en': 'Chalisgaon', 'hi': 'चालीसगांव', 'mr': 'चाळीसगाव'},
    'Chopda': {'en': 'Chopda', 'hi': 'चोपड़ा', 'mr': 'चोपडा'},
    'Dharangaon': {'en': 'Dharangaon', 'hi': 'धरणगांव', 'mr': 'धरणगाव'},
    'Erandol': {'en': 'Erandol', 'hi': 'एरंडोल', 'mr': 'एरंडोल'},
    'Jamner': {'en': 'Jamner', 'hi': 'जामनेर', 'mr': 'जामनेर'},
    'Muktainagar': {'en': 'Muktainagar', 'hi': 'मुक्ताईनगर', 'mr': 'मुक्ताईनगर'},
    'Pachora': {'en': 'Pachora', 'hi': 'पाचोरा', 'mr': 'पाचोरा'},
    'Parola': {'en': 'Parola', 'hi': 'पारोला', 'mr': 'पारोळा'},
    'Raver': {'en': 'Raver', 'hi': 'रावेर', 'mr': 'रावेर'},
    'Yawal': {'en': 'Yawal', 'hi': 'यावल', 'mr': 'यावल'},
    'Ambad': {'en': 'Ambad', 'hi': 'अंबड', 'mr': 'अंबड'},
    'Badnapur': {'en': 'Badnapur', 'hi': 'बदनापुर', 'mr': 'बदनापूर'},
    'Bhokardan': {'en': 'Bhokardan', 'hi': 'भोकरदन', 'mr': 'भोकरदन'},
    'Ghansawangi': {'en': 'Ghansawangi', 'hi': 'घनसावंगी', 'mr': 'घनसावंगी'},
    'Jafrabad': {'en': 'Jafrabad', 'hi': 'जाफराबाद', 'mr': 'जाफराबाद'},
    'Mantha': {'en': 'Mantha', 'hi': 'मंठा', 'mr': 'मंठा'},
    'Partur': {'en': 'Partur', 'hi': 'परतूर', 'mr': 'परतूर'},
    'Ajra': {'en': 'Ajra', 'hi': 'आजरा', 'mr': 'आजरा'},
    'Bavada': {'en': 'Bavada', 'hi': 'बावड़ा', 'mr': 'बावडा'},
    'Bhudargad': {'en': 'Bhudargad', 'hi': 'भुदरगड', 'mr': 'भुदरगड'},
    'Chandgad': {'en': 'Chandgad', 'hi': 'चंदगड', 'mr': 'चंदगड'},
    'Gadhinglaj': {'en': 'Gadhinglaj', 'hi': 'गडहिंग्लज', 'mr': 'गडहिंग्लज'},
    'Hatkanangle': {'en': 'Hatkanangle', 'hi': 'हातकणंगले', 'mr': 'हातकणंगले'},
    'Kagal': {'en': 'Kagal', 'hi': 'कागल', 'mr': 'कागल'},
    'Karvir': {'en': 'Karvir', 'hi': 'करवीर', 'mr': 'करवीर'},
    'Panhala': {'en': 'Panhala', 'hi': 'पन्हाला', 'mr': 'पन्हाळा'},
    'Radhanagari': {'en': 'Radhanagari', 'hi': 'राधानगरी', 'mr': 'राधानगरी'},
    'Shahuwadi': {'en': 'Shahuwadi', 'hi': 'शाहूवाड़ी', 'mr': 'शाहूवाडी'},
    'Shirol': {'en': 'Shirol', 'hi': 'शिरोल', 'mr': 'शिरोळ'},
    'Ahmedpur': {'en': 'Ahmedpur', 'hi': 'अहमदपुर', 'mr': 'अहमदपूर'},
    'Ausa': {'en': 'Ausa', 'hi': 'औसा', 'mr': 'औसा'},
    'Chakur': {'en': 'Chakur', 'hi': 'चाकूर', 'mr': 'चाकूर'},
    'Deoni': {'en': 'Deoni', 'hi': 'देवणी', 'mr': 'देवणी'},
    'Jalkot': {'en': 'Jalkot', 'hi': 'जलकोट', 'mr': 'जळकोट'},
    'Nilanga': {'en': 'Nilanga', 'hi': 'निलंगा', 'mr': 'निलंगा'},
    'Renapur': {'en': 'Renapur', 'hi': 'रेनापुर', 'mr': 'रेणापूर'},
    'Shirur Anantpal': {'en': 'Shirur Anantpal', 'hi': 'शिरुर अनंतपाल', 'mr': 'शिरूर अनंतपाळ'},
    'Udgir': {'en': 'Udgir', 'hi': 'उदगीर', 'mr': 'उदगीर'},
    'Andheri': {'en': 'Andheri', 'hi': 'अंधेरी', 'mr': 'अंधेरी'},
    'Borivali': {'en': 'Borivali', 'hi': 'बोरिवली', 'mr': 'बोरिवली'},
    'Kurla': {'en': 'Kurla', 'hi': 'कुर्ला', 'mr': 'कुर्ला'},
    'Bhiwapur': {'en': 'Bhiwapur', 'hi': 'भिवापुर', 'mr': 'भिवापूर'},
    'Hingna': {'en': 'Hingna', 'hi': 'हिंगणा', 'mr': 'हिंगणा'},
    'Kadpar': {'en': 'Kadpar', 'hi': 'कडपार', 'mr': 'कडपार'},
    'Kamthi': {'en': 'Kamthi', 'hi': 'कामठी', 'mr': 'कामठी'},
    'Katol': {'en': 'Katol', 'hi': 'काटोल', 'mr': 'काटोल'},
    'Kuhi': {'en': 'Kuhi', 'hi': 'कुही', 'mr': 'कुही'},
    'Mauda': {'en': 'Mauda', 'hi': 'मौदा', 'mr': 'मौदा'},
    'Nagpur Rural': {'en': 'Nagpur Rural', 'hi': 'नागपुर ग्रामीण', 'mr': 'नागपूर ग्रामीण'},
    'Nagpur Urban': {'en': 'Nagpur Urban', 'hi': 'नागपुर शहर', 'mr': 'नागपूर शहर'},
    'Narkhed': {'en': 'Narkhed', 'hi': 'नरखेड', 'mr': 'नरखेड'},
    'Parseoni': {'en': 'Parseoni', 'hi': 'पारशिवनी', 'mr': 'पारशिवनी'},
    'Ramtek': {'en': 'Ramtek', 'hi': 'रामटेक', 'mr': 'रामटेक'},
    'Savner': {'en': 'Savner', 'hi': 'सावनेर', 'mr': 'सावनेर'},
    'Umred': {'en': 'Umred', 'hi': 'उमरेड', 'mr': 'उमरेड'},
    'Ardhapur': {'en': 'Ardhapur', 'hi': 'अर्धापुर', 'mr': 'अर्धापूर'},
    'Biloli': {'en': 'Biloli', 'hi': 'बिलोली', 'mr': 'बिलोली'},
    'Bhokar': {'en': 'Bhokar', 'hi': 'भोकर', 'mr': 'भोकर'},
    'Deglur': {'en': 'Deglur', 'hi': 'देगलूर', 'mr': 'देगलूर'},
    'Dharmabad': {'en': 'Dharmabad', 'hi': 'धर्माबाद', 'mr': 'धर्माबाद'},
    'Hadgaon': {'en': 'Hadgaon', 'hi': 'हदगांव', 'mr': 'हदगाव'},
    'Himayatnagar': {'en': 'Himayatnagar', 'hi': 'हिमायतनगर', 'mr': 'हिमायतनगर'},
    'Kandhar': {'en': 'Kandhar', 'hi': 'कंधार', 'mr': 'कंधार'},
    'Kinwat': {'en': 'Kinwat', 'hi': 'किनवट', 'mr': 'किनवट'},
    'Loha': {'en': 'Loha', 'hi': 'लोहा', 'mr': 'लोहा'},
    'Mahur': {'en': 'Mahur', 'hi': 'माहूर', 'mr': 'माहूर'},
    'Mudkhed': {'en': 'Mudkhed', 'hi': 'मुदखेड', 'mr': 'मुदखेड'},
    'Mukhed': {'en': 'Mukhed', 'hi': 'मुखेड', 'mr': 'मुखेड'},
    'Naigaon': {'en': 'Naigaon', 'hi': 'नायगांव', 'mr': 'नायगाव'},
    'Umri': {'en': 'Umri', 'hi': 'उमरी', 'mr': 'उमरी'},
    'Akkalkuwa': {'en': 'Akkalkuwa', 'hi': 'अक्कलकुवा', 'mr': 'अक्कलकुवा'},
    'Akrani': {'en': 'Akrani', 'hi': 'अक्राणी', 'mr': 'अक्राणी'},
    'Nawapur': {'en': 'Nawapur', 'hi': 'नवापुर', 'mr': 'नवापूर'},
    'Shahada': {'en': 'Shahada', 'hi': 'शहादा', 'mr': 'शहादा'},
    'Talode': {'en': 'Talode', 'hi': 'तलोदा', 'mr': 'तळोदा'},
    'Malegaon': {'en': 'Malegaon', 'hi': 'मालेगांव', 'mr': 'मालेगाव'},
    'Niphad': {'en': 'Niphad', 'hi': 'निफाड', 'mr': 'निफाड'},
    'Sinnar': {'en': 'Sinnar', 'hi': 'सिन्नर', 'mr': 'सिन्नर'},
    'Yeola': {'en': 'Yeola', 'hi': 'येवला', 'mr': 'येवला'},
    'Igatpuri': {'en': 'Igatpuri', 'hi': 'इगतपुरी', 'mr': 'इगतपुरी'},
    'Dindori': {'en': 'Dindori', 'hi': 'दिंडोरी', 'mr': 'दिंडोरी'},
    'Trimbakeshwar': {'en': 'Trimbakeshwar', 'hi': 'त्र्यंबकेश्वर', 'mr': 'त्र्यंबकेश्वर'},
    'Kalwan': {'en': 'Kalwan', 'hi': 'कळवण', 'mr': 'कळवण'},
    'Baglan': {'en': 'Baglan', 'hi': 'बागलाण', 'mr': 'बागलाण'},
    'Deola': {'en': 'Deola', 'hi': 'देवळा', 'mr': 'देवळा'},
    'Surgana': {'en': 'Surgana', 'hi': 'सुरगाणा', 'mr': 'सुरगाणा'},
    'Peint': {'en': 'Peint', 'hi': 'पेठ', 'mr': 'पेठ'},
    'Nandgaon': {'en': 'Nandgaon', 'hi': 'नांदगांव', 'mr': 'नांदगाव'},
    'Chandwad': {'en': 'Chandwad', 'hi': 'चांदवड', 'mr': 'चांदवड'},
    'Bhum': {'en': 'Bhum', 'hi': 'भूम', 'mr': 'भूम'},
    'Kalamb': {'en': 'Kalamb', 'hi': 'कळंब', 'mr': 'कळंब'},
    'Lohara': {'en': 'Lohara', 'hi': 'लोहारा', 'mr': 'लोहारा'},
    'Paranda': {'en': 'Paranda', 'hi': 'परांडा', 'mr': 'परांडा'},
    'Tuljapur': {'en': 'Tuljapur', 'hi': 'तुळजापुर', 'mr': 'तुळजापूर'},
    'Umarga': {'en': 'Umarga', 'hi': 'उमरगा', 'mr': 'उमरगा'},
    'Washi': {'en': 'Washi', 'hi': 'वाशी', 'mr': 'वाशी'},
    'Dahanu': {'en': 'Dahanu', 'hi': 'डहाणू', 'mr': 'डहाणू'},
    'Jawhar': {'en': 'Jawhar', 'hi': 'जव्हार', 'mr': 'जव्हार'},
    'Mokhada': {'en': 'Mokhada', 'hi': 'मोखाडा', 'mr': 'मोखाडा'},
    'Talasari': {'en': 'Talasari', 'hi': 'तलासरी', 'mr': 'तलासरी'},
    'Vasai': {'en': 'Vasai', 'hi': 'वसई', 'mr': 'वसई'},
    'Vikramgad': {'en': 'Vikramgad', 'hi': 'विक्रमगड', 'mr': 'विक्रमगड'},
    'Wada': {'en': 'Wada', 'hi': 'वाडा', 'mr': 'वाडा'},
    'Gangakhed': {'en': 'Gangakhed', 'hi': 'गंगाखेड', 'mr': 'गंगाखेड'},
    'Jintur': {'en': 'Jintur', 'hi': 'जिंतूर', 'mr': 'जिंतूर'},
    'Manwath': {'en': 'Manwath', 'hi': 'मानवत', 'mr': 'मानवत'},
    'Palam': {'en': 'Palam', 'hi': 'पालम', 'mr': 'पालम'},
    'Pathri': {'en': 'Pathri', 'hi': 'पाथरी', 'mr': 'पाथरी'},
    'Purna': {'en': 'Purna', 'hi': 'पूर्णा', 'mr': 'पूर्णा'},
    'Selu': {'en': 'Selu', 'hi': 'सेलु', 'mr': 'सेलू'},
    'Sonpeth': {'en': 'Sonpeth', 'hi': 'सोनपेठ', 'mr': 'सोनपेठ'},
    'Alibag': {'en': 'Alibag', 'hi': 'अलिबाग', 'mr': 'अलिबाग'},
    'Khalapur': {'en': 'Khalapur', 'hi': 'खालापूर', 'mr': 'खालापूर'},
    'Mahad': {'en': 'Mahad', 'hi': 'महाड', 'mr': 'महाड'},
    'Mangaon': {'en': 'Mangaon', 'hi': 'माणगांव', 'mr': 'माणगाव'},
    'Mhasla': {'en': 'Mhasla', 'hi': 'म्हसळा', 'mr': 'म्हसळा'},
    'Murud': {'en': 'Murud', 'hi': 'मुरुड', 'mr': 'मुरुड'},
    'Panvel': {'en': 'Panvel', 'hi': 'पनवेल', 'mr': 'पनवेल'},
    'Pen': {'en': 'Pen', 'hi': 'पेण', 'mr': 'पेण'},
    'Poladpur': {'en': 'Poladpur', 'hi': 'पोलादपुर', 'mr': 'पोलादपूर'},
    'Roha': {'en': 'Roha', 'hi': 'रोहा', 'mr': 'रोहा'},
    'Shriwardhan': {'en': 'Shriwardhan', 'hi': 'श्रीवर्धन', 'mr': 'श्रीवर्धन'},
    'Sudhagad': {'en': 'Sudhagad', 'hi': 'सुधागड', 'mr': 'सुधागड'},
    'Tala': {'en': 'Tala', 'hi': 'तळा', 'mr': 'तळा'},
    'Uran': {'en': 'Uran', 'hi': 'उरण', 'mr': 'उरण'},
    'Chiplun': {'en': 'Chiplun', 'hi': 'चिपळूण', 'mr': 'चिपळूण'},
    'Dapoli': {'en': 'Dapoli', 'hi': 'दापोली', 'mr': 'दापोली'},
    'Guhagar': {'en': 'Guhagar', 'hi': 'गुहागर', 'mr': 'गुहागर'},
    'Lanja': {'en': 'Lanja', 'hi': 'लांजा', 'mr': 'लांजा'},
    'Mandangad': {'en': 'Mandangad', 'hi': 'मंडणगड', 'mr': 'मंडणगड'},
    'Rajapur': {'en': 'Rajapur', 'hi': 'राजापुर', 'mr': 'राजापूर'},
    'Sangameshwar': {'en': 'Sangameshwar', 'hi': 'संगमेश्वर', 'mr': 'संगमेश्वर'},
    'Atpadi': {'en': 'Atpadi', 'hi': 'आटपाडी', 'mr': 'आटपाडी'},
    'Jat': {'en': 'Jat', 'hi': 'जत', 'mr': 'जत'},
    'Kadegaon': {'en': 'Kadegaon', 'hi': 'कडेगांव', 'mr': 'कडेगाव'},
    'Kavathemahankal': {'en': 'Kavathemahankal', 'hi': 'कवठे महांकाळ', 'mr': 'कवठे महांकाळ'},
    'Khanapur': {'en': 'Khanapur', 'hi': 'खानापुर', 'mr': 'खानापूर'},
    'Miraj': {'en': 'Miraj', 'hi': 'मिरज', 'mr': 'मिरज'},
    'Palus': {'en': 'Palus', 'hi': 'पलूस', 'mr': 'पलूस'},
    'Shirala': {'en': 'Shirala', 'hi': 'शिराळा', 'mr': 'शिराळा'},
    'Tasgaon': {'en': 'Tasgaon', 'hi': 'तासगांव', 'mr': 'तासगाव'},
    'Valva': {'en': 'Valva', 'hi': 'वाळवा', 'mr': 'वाळवा'},
    'Waltepattan': {'en': 'Waltepattan', 'hi': 'वाळवा', 'mr': 'वाळवा'},
    'Jaoli': {'en': 'Jaoli', 'hi': 'जावली', 'mr': 'जावळी'},
    'Karad': {'en': 'Karad', 'hi': 'कराड', 'mr': 'कराड'},
    'Khandala': {'en': 'Khandala', 'hi': 'खंडाळा', 'mr': 'खंडाळा'},
    'Khatav': {'en': 'Khatav', 'hi': 'खटाव', 'mr': 'खटाव'},
    'Koregaon': {'en': 'Koregaon', 'hi': 'कोरेगांव', 'mr': 'कोरेगाव'},
    'Mahabaleshwar': {'en': 'Mahabaleshwar', 'hi': 'महाबलेश्वर', 'mr': 'महाबळेश्वर'},
    'Man': {'en': 'Man', 'hi': 'माण', 'mr': 'माण'},
    'Patan': {'en': 'Patan', 'hi': 'पाटण', 'mr': 'पाटण'},
    'Phaltan': {'en': 'Phaltan', 'hi': 'फलटन', 'mr': 'फलटण'},
    'Wai': {'en': 'Wai', 'hi': 'वाई', 'mr': 'वाई'},
    'Deogad': {'en': 'Deogad', 'hi': 'देवगड', 'mr': 'देवगड'},
    'Dodamarg': {'en': 'Dodamarg', 'hi': 'दोडामार्ग', 'mr': 'दोडामार्ग'},
    'Kankavli': {'en': 'Kankavli', 'hi': 'कणकवली', 'mr': 'कणकवली'},
    'Kudal': {'en': 'Kudal', 'hi': 'कुडाळ', 'mr': 'कुडाळ'},
    'Malvan': {'en': 'Malvan', 'hi': 'मालवण', 'mr': 'मालवण'},
    'Sawantwadi': {'en': 'Sawantwadi', 'hi': 'सावंतवाड़ी', 'mr': 'सावंतवाडी'},
    'Vaibhavvadi': {'en': 'Vaibhavvadi', 'hi': 'वैभववाडी', 'mr': 'वैभववाडी'},
    'Vengurla': {'en': 'Vengurla', 'hi': 'वेंगुर्ला', 'mr': 'वेंगुर्ला'},
    'Akkalkot': {'en': 'Akkalkot', 'hi': 'अक्कलकोट', 'mr': 'अक्कलकोट'},
    'Barshi': {'en': 'Barshi', 'hi': 'बार्शी', 'mr': 'बार्शी'},
    'Karmala': {'en': 'Karmala', 'hi': 'करमाळा', 'mr': 'करमाळा'},
    'Madha': {'en': 'Madha', 'hi': 'माढा', 'mr': 'माढा'},
    'Malshiras': {'en': 'Malshiras', 'hi': 'माळशिरस', 'mr': 'माळशिरस'},
    'Mangalvedhe': {'en': 'Mangalvedhe', 'hi': 'मंगळवेढा', 'mr': 'मंगळवेढा'},
    'Mohol': {'en': 'Mohol', 'hi': 'मोहोळ', 'mr': 'मोहोळ'},
    'Pandharpur': {'en': 'Pandharpur', 'hi': 'पंढरपुर', 'mr': 'पंढरपूर'},
    'Sangola': {'en': 'Sangola', 'hi': 'सांगोला', 'mr': 'सांगोला'},
    'Solapur North': {'en': 'Solapur North', 'hi': 'उत्तर सोलापुर', 'mr': 'उत्तर सोलापूर'},
    'Solapur South': {'en': 'Solapur South', 'hi': 'दक्षिण सोलापुर', 'mr': 'दक्षिण सोलापूर'},
    'Ambarnath': {'en': 'Ambarnath', 'hi': 'अंबरनाथ', 'mr': 'अंबरनाथ'},
    'Bhiwandi': {'en': 'Bhiwandi', 'hi': 'भिवंडी', 'mr': 'भिवंडी'},
    'Kalyan': {'en': 'Kalyan', 'hi': 'कल्याण', 'mr': 'कल्याण'},
    'Murbad': {'en': 'Murbad', 'hi': 'मुरबाड', 'mr': 'मुरबाड'},
    'Shahapur': {'en': 'Shahapur', 'hi': 'शहापुर', 'mr': 'शहापूर'},
    'Ulhasnagar': {'en': 'Ulhasnagar', 'hi': 'उल्हासनगर', 'mr': 'उल्हासनगर'},
    'Arvi': {'en': 'Arvi', 'hi': 'आर्वी', 'mr': 'आर्वी'},
    'Deoli': {'en': 'Deoli', 'hi': 'देवळी', 'mr': 'देवळी'},
    'Hinganghat': {'en': 'Hinganghat', 'hi': 'हिंगणघाट', 'mr': 'हिंगणघाट'},
    'Karanja': {'en': 'Karanja', 'hi': 'कारंजा', 'mr': 'कारंजा'},
    'Samudrapur': {'en': 'Samudrapur', 'hi': 'समुद्रपुर', 'mr': 'समुद्रपूर'},
    'Seloo': {'en': 'Seloo', 'hi': 'सेलू', 'mr': 'सेलू'},
    'Mangrulpir': {'en': 'Mangrulpir', 'hi': 'मानग्रुलपीर', 'mr': 'मंगरुळपीर'},
    'Manora': {'en': 'Manora', 'hi': 'मानोरा', 'mr': 'मानोरा'},
    'Risod': {'en': 'Risod', 'hi': 'रिसोड', 'mr': 'रिसोड'},
    'Arni': {'en': 'Arni', 'hi': 'आर्णी', 'mr': 'आर्णी'},
    'Babhulgaon': {'en': 'Babhulgaon', 'hi': 'बाभुलगांव', 'mr': 'बाभुळगाव'},
    'Darwha': {'en': 'Darwha', 'hi': 'दारव्हा', 'mr': 'दारव्हा'},
    'Digras': {'en': 'Digras', 'hi': 'दिग्रस', 'mr': 'दिग्रस'},
    'Ghatanji': {'en': 'Ghatanji', 'hi': 'घाटंजी', 'mr': 'घाटंजी'},
    'Kelapur': {'en': 'Kelapur', 'hi': 'केलापुर', 'mr': 'केळापूर'},
    'Mahagaon': {'en': 'Mahagaon', 'hi': 'महागांव', 'mr': 'महागाव'},
    'Maregaon': {'en': 'Maregaon', 'hi': 'मारेगांव', 'mr': 'मारेगाव'},
    'Ner': {'en': 'Ner', 'hi': 'नेर', 'mr': 'नेर'},
    'Pusad': {'en': 'Pusad', 'hi': 'पुसद', 'mr': 'पुसद'},
    'Ralegaon': {'en': 'Ralegaon', 'hi': 'राळेगांव', 'mr': 'राळेगाव'},
    'Umarkhed': {'en': 'Umarkhed', 'hi': 'उमरखेड', 'mr': 'उमरखेड'},
    'Wani': {'en': 'Wani', 'hi': 'वणी', 'mr': 'वणी'},
    'Zari Jamni': {'en': 'Zari Jamni', 'hi': 'झरी जामणी', 'mr': 'झरी जामणी'},

    // ── Breeds ──
    'Jersey': {'en': 'Jersey', 'hi': 'जर्सी', 'mr': 'जर्सी'},
    'Holstein Friesian (HF)': {'en': 'Holstein Friesian (HF)', 'hi': 'होलस्टीन फ्रीजियन', 'mr': 'होल्स्टिन फ्रीजियन'},
    'holstein friesian (hf)': {'en': 'Holstein Friesian (HF)', 'hi': 'होलस्टीन फ्रीजियन', 'mr': 'होल्स्टिन फ्रीजियन'},
    'Holstein Friesian': {'en': 'Holstein Friesian', 'hi': 'होलस्टीन फ्रीजियन', 'mr': 'होल्स्टिन फ्रीजियन'},
    'holstein friesian': {'en': 'Holstein Friesian', 'hi': 'होलस्टीन फ्रीजियन', 'mr': 'होल्स्टिन फ्रीजियन'},
    'HF': {'en': 'HF', 'hi': 'होलस्टीन फ्रीजियन', 'mr': 'होल्स्टिन फ्रीजियन'},
    'hf': {'en': 'HF', 'hi': 'होलस्टीन फ्रीजियन', 'mr': 'होल्स्टिन फ्रीजियन'},
    'Gir': {'en': 'Gir', 'hi': 'गीर', 'mr': 'गीर'},
    'Sahiwal': {'en': 'Sahiwal', 'hi': 'साहीवाल', 'mr': 'साहिवाल'},
    'Red Sindhi': {'en': 'Red Sindhi', 'hi': 'लाल सिंधी', 'mr': 'लाल सिंधी'},
    'Murrah': {'en': 'Murrah', 'hi': 'मुर्रा', 'mr': 'मुर्रा'},
    'Jaffarabadi': {'en': 'Jaffarabadi', 'hi': 'जाफराबादी', 'mr': 'जाफराबादी'},
    'Mehsana': {'en': 'Mehsana', 'hi': 'मेहसाणा', 'mr': 'मेहसाणा'},
    'Surti': {'en': 'Surti', 'hi': 'सुरती', 'mr': 'सुरती'},
    'Boer': {'en': 'Boer', 'hi': 'बोअर', 'mr': 'बोअर'},
    'Osmanabadi': {'en': 'Osmanabadi', 'hi': 'उस्मानाबादी', 'mr': 'उस्मानाबादी'},
    'Sirohi': {'en': 'Sirohi', 'hi': 'सिरोही', 'mr': 'सिरोही'},
    'Barbari': {'en': 'Barbari', 'hi': 'बरबरी', 'mr': 'बरबरी'},
    'Jamnapari': {'en': 'Jamnapari', 'hi': 'जमनापारी', 'mr': 'जमनापारी'},
    'Marwari': {'en': 'Marwari', 'hi': 'मारवाड़ी', 'mr': 'मारवाडी'},
    'Deccani': {'en': 'Deccani', 'hi': 'दक्कनी', 'mr': 'दख्खनी'},
    'Nellore': {'en': 'Nellore', 'hi': 'नेल्लोर', 'mr': 'नेल्लोर'},
    'Broiler': {'en': 'Broiler', 'hi': 'ब्रायलर', 'mr': 'ब्रॉयलर'},
    'Layer': {'en': 'Layer', 'hi': 'लेयर', 'mr': 'लेयर'},
    'Aseel': {'en': 'Aseel', 'hi': 'असील', 'mr': 'असील'},
    'Kadaknath': {'en': 'Kadaknath', 'hi': 'कड़कनाथ', 'mr': 'कडकनाथ'},
    'Large White Yorkshire': {'en': 'Large White Yorkshire', 'hi': 'लार्ज व्हाइट यॉर्कशायर', 'mr': 'लार्ज व्हाइट यॉर्कशायर'},
    'Landrace': {'en': 'Landrace', 'hi': 'लैंडरेस', 'mr': 'लँडरेस'},
    'Duroc': {'en': 'Duroc', 'hi': 'ड्यूरोक', 'mr': 'ड्युरॉक'},
    'Standard': {'en': 'Standard', 'hi': 'सामान्य', 'mr': 'सामान्य'},

    // ── Clinical Symptoms ──
    'Reduced Milk Yield': {'en': 'Reduced Milk Yield', 'hi': 'दूध उत्पादन कम होना', 'mr': 'दूध उत्पादन घटले'},
    'Milk production reduced': {'en': 'Milk production reduced', 'hi': 'दूध उत्पादन कम होना', 'mr': 'दूध उत्पादन घटले'},
    'Swollen Udder': {'en': 'Swollen Udder', 'hi': 'थन में सूजन', 'mr': 'कास सुजणे'},
    'Loss of Appetite': {'en': 'Loss of Appetite', 'hi': 'भूख न लगना', 'mr': 'चारा न खाणे'},
    'Not eating': {'en': 'Not eating', 'hi': 'चारा नहीं खा रहा', 'mr': 'चारा खात नाही'},
    'High Fever': {'en': 'High Fever', 'hi': 'तेज बुखार', 'mr': 'तीव्र ताप'},
    'Fever': {'en': 'Fever', 'hi': 'बुखार', 'mr': 'ताप'},
    'Blisters in Mouth': {'en': 'Blisters in Mouth', 'hi': 'मुंह में छाले', 'mr': 'तोंडात फोड'},
    'Skin lesions / blisters': {'en': 'Skin lesions / blisters', 'hi': 'त्वचा पर छाले / घाव', 'mr': 'त्वचेवर फोड / जखमा'},
    'Skin lesions / Blisters': {'en': 'Skin lesions / Blisters', 'hi': 'त्वचा पर छाले / घाव', 'mr': 'त्वचेवर फोड / जखमा'},
    'Skin lesions': {'en': 'Skin lesions', 'hi': 'त्वचा पर छाले', 'mr': 'त्वचेवर फोड'},
    'Excessive Salivation': {'en': 'Excessive Salivation', 'hi': 'अत्यधिक लार गिरना', 'mr': 'तोंडातून जास्त लाळ गळणे'},
    'Excessive salivation': {'en': 'Excessive salivation', 'hi': 'अत्यधिक लार गिरना', 'mr': 'तोंडातून जास्त लाळ गळणे'},
    'Limping': {'en': 'Limping', 'hi': 'लंगड़ाना', 'mr': 'लंगडणे'},
    'Difficulty walking': {'en': 'Difficulty walking', 'hi': 'चलने में कठिनाई / लंगड़ाना', 'mr': 'चालताना त्रास / लंगडणे'},
    'Breathing problem': {'en': 'Breathing problem', 'hi': 'सांस लेने में तकलीफ', 'mr': 'श्वास घेण्यास त्रास'},
    'Diarrhea': {'en': 'Diarrhea', 'hi': 'दस्त', 'mr': 'हगवण / जुलाब'},
    'Weakness': {'en': 'Weakness', 'hi': 'कमजोरी / सुस्ती', 'mr': 'अशक्तपणा / सुस्ती'},
    'Weakness / Collapse': {'en': 'Weakness / Collapse', 'hi': 'कमजोरी / सुस्ती', 'mr': 'अशक्तपणा / सुस्ती'},
    'Sudden Collapse': {'en': 'Sudden Collapse', 'hi': 'अचानक गिरना', 'mr': 'अचानक कोसळणे'},
    'Bloody Discharge from Nostrils': {'en': 'Bloody Discharge from Nostrils', 'hi': 'नाक से खून बहना', 'mr': 'नाकातून रक्त येणे'},
    'Vomiting': {'en': 'Vomiting', 'hi': 'उल्टी', 'mr': 'उलटी'},
    'Nasal discharge': {'en': 'Nasal discharge', 'hi': 'नाक बहना', 'mr': 'नाकातून स्राव'},
    'Eye problem': {'en': 'Eye problem', 'hi': 'आंख की समस्या', 'mr': 'डोळ्यांची समस्या'},
    'Bleeding': {'en': 'Bleeding', 'hi': 'खून बहना', 'mr': 'रक्तस्त्राव'},
    'Pregnancy / birth problem': {'en': 'Pregnancy / birth problem', 'hi': 'गर्भ / प्रसव समस्या', 'mr': 'गाभण / विताना समस्या'},
    'Pregnancy/birth problem': {'en': 'Pregnancy / birth problem', 'hi': 'गर्भ / प्रसव समस्या', 'mr': 'गाभण / विताना समस्या'},
    'Other symptoms': {'en': 'Other symptoms', 'hi': 'अन्य लक्षण', 'mr': 'इतर लक्षणे'},

    // ── Case Statuses ──
    'submitted': {'en': 'Submitted', 'hi': 'दर्ज किया गया', 'mr': 'सबमिट झाले'},
    'SUBMITTED': {'en': 'SUBMITTED', 'hi': 'दर्ज किया गया', 'mr': 'सबमिट झाले'},
    'under review': {'en': 'Under Review', 'hi': 'समीक्षाधीन', 'mr': 'पुनरावलोकनाधीन'},
    'under_review': {'en': 'Under Review', 'hi': 'समीक्षाधीन', 'mr': 'पुनरावलोकनाधीन'},
    'UNDER REVIEW': {'en': 'UNDER REVIEW', 'hi': 'समीक्षाधीन', 'mr': 'पुनरावलोकनाधीन'},
    'vet assigned': {'en': 'Vet Assigned', 'hi': 'पशु चिकित्सक नियुक्त', 'mr': 'पशुवैद्यक नियुक्त'},
    'vet_assigned': {'en': 'Vet Assigned', 'hi': 'पशु चिकित्सक नियुक्त', 'mr': 'पशुवैद्यक नियुक्त'},
    'VET ASSIGNED': {'en': 'VET ASSIGNED', 'hi': 'पशु चिकित्सक नियुक्त', 'mr': 'पशुवैद्यक नियुक्त'},
    'visit scheduled': {'en': 'Visit Scheduled', 'hi': 'दौरा निर्धारित', 'mr': 'भेट नियोजित'},
    'visit_scheduled': {'en': 'Visit Scheduled', 'hi': 'दौरा निर्धारित', 'mr': 'भेट नियोजित'},
    'VISIT SCHEDULED': {'en': 'VISIT SCHEDULED', 'hi': 'दौरा निर्धारित', 'mr': 'भेट नियोजित'},
    'treatment started': {'en': 'Treatment Started', 'hi': 'उपचार शुरू', 'mr': 'उपचार सुरू'},
    'treatment_started': {'en': 'Treatment Started', 'hi': 'उपचार शुरू', 'mr': 'उपचार सुरू'},
    'TREATMENT STARTED': {'en': 'TREATMENT STARTED', 'hi': 'उपचार शुरू', 'mr': 'उपचार सुरू'},
    'case closed': {'en': 'Case Closed', 'hi': 'केस बंद', 'mr': 'प्रकरण बंद'},
    'case_closed': {'en': 'Case Closed', 'hi': 'केस बंद', 'mr': 'प्रकरण बंद'},
    'CASE CLOSED': {'en': 'CASE CLOSED', 'hi': 'केस बंद', 'mr': 'प्रकरण बंद'},
    'open': {'en': 'Open', 'hi': 'दर्ज किया गया', 'mr': 'नोंदवले गेले'},
    'investigation': {'en': 'Investigation', 'hi': 'जांच जारी', 'mr': 'तपास सुरू'},
    'sample collected': {'en': 'Sample Collected', 'hi': 'नमूना एकत्र किया गया', 'mr': 'नमुना गोळा केला'},
    'sample_collected': {'en': 'Sample Collected', 'hi': 'नमूना एकत्र किया गया', 'mr': 'नमुना गोळा केला'},
    'lab referred': {'en': 'Lab Referred', 'hi': 'प्रयोगशाला संदर्भित', 'mr': 'प्रयोगशाळेत पाठवले'},
    'lab_referred': {'en': 'Lab Referred', 'hi': 'प्रयोगशाला संदर्भित', 'mr': 'प्रयोगशाळेत पाठवले'},
    'escalated': {'en': 'Escalated to Govt', 'hi': 'शासन को संदर्भित', 'mr': 'शासनाला वर्ग केले'},
    'closed': {'en': 'Closed', 'hi': 'केस बंद', 'mr': 'प्रकरण बंद'},

    // ── Vet Request Reasons ──
    'Animal is very sick': {'en': 'Animal is very sick', 'hi': 'पशु बहुत बीमार है', 'mr': 'जनावर खूप आजारी आहे'},
    'Animal not improving': {'en': 'Animal not improving', 'hi': 'सुधार नहीं हो रहा', 'mr': 'गुण येत नाही'},
    'Animal death': {'en': 'Animal death', 'hi': 'पशु की मृत्यु', 'mr': 'जनावराचा मृत्यू'},
    'Vaccination request': {'en': 'Vaccination request', 'hi': 'टीकाकरण का अनुरोध', 'mr': 'लसीकरणाची विनंती'},
    'Treatment follow-up': {'en': 'Treatment follow-up', 'hi': 'उपचार फॉलो-अप', 'mr': 'पुढील उपचार'},

    // ── Units, Time & Form Controls ──
    'Acres': {'en': 'Acres', 'hi': 'एकड़', 'mr': 'एकर'},
    'Hectares': {'en': 'Hectares', 'hi': 'हेक्टेयर', 'mr': 'हेक्टर'},
    'Cent': {'en': 'Cent', 'hi': 'सेंट', 'mr': 'गुंठा / सेंट'},
    'Voice': {'en': 'Voice', 'hi': 'आवाज़', 'mr': 'आवाज'},
    'Text': {'en': 'Text', 'hi': 'संदेश', 'mr': 'संदेश'},
    'Both': {'en': 'Both Voice & Text', 'hi': 'आवाज़ और संदेश दोनों', 'mr': 'आवाज आणि संदेश दोन्ही'},
    '📍 Use Farm Location': {'en': '📍 Use Farm Location', 'hi': '📍 फार्म के स्थान का उपयोग करें', 'mr': '📍 गोठ्याचे स्थान वापरा'},
    'Use Farm Location': {'en': 'Use Farm Location', 'hi': 'फार्म के स्थान का उपयोग करें', 'mr': 'गोठ्याचे स्थान वापरा'},
    '📍 Current Location': {'en': '📍 Current Location', 'hi': '📍 वर्तमान स्थान का उपयोग करें', 'mr': '📍 सध्याचे स्थान वापरा'},
    'Use Current Location': {'en': 'Use Current Location', 'hi': 'वर्तमान स्थान का उपयोग करें', 'mr': 'सध्याचे स्थान वापरा'},
    '📝 Enter Location Manually': {'en': '📝 Enter Location Manually', 'hi': '📝 स्थान स्वयं दर्ज करें', 'mr': '📝 स्थान स्वतः प्रविष्ट करा'},
    'Enter Location Manually': {'en': 'Enter Location Manually', 'hi': 'स्थान स्वयं दर्ज करें', 'mr': 'स्थान स्वतः प्रविष्ट करा'},
    'Today': {'en': 'Today', 'hi': 'आज', 'mr': 'आज'},
    'Yesterday': {'en': 'Yesterday', 'hi': 'कल', 'mr': 'काल'},
    '2–3 days': {'en': '2–3 days', 'hi': '२–३ दिन', 'mr': '२–३ दिवस'},
    '2–3 days ago': {'en': '2–3 days ago', 'hi': '२–३ दिन पहले', 'mr': '२–३ दिवसांपूर्वी'},
    '4–7 days': {'en': '4–7 days', 'hi': '४–७ दिन', 'mr': '४–७ दिवस'},
    'More than a week': {'en': 'More than a week', 'hi': 'एक सप्ताह से अधिक', 'mr': 'एका आठवड्यापेक्षा जास्त'},
    'Not sure': {'en': 'Not sure', 'hi': 'पक्का नहीं पता', 'mr': 'खात्री नाही'},
    'Yes': {'en': 'Yes', 'hi': 'हाँ', 'mr': 'होय'},
    'No': {'en': 'No', 'hi': 'नहीं', 'mr': 'नाही'},
    'Less than usual': {'en': 'Less than usual', 'hi': 'सामान्य से कम', 'mr': 'नेहमीपेक्षा कमी'},

    // ── Animal Attributes & Health Statuses ──
    'Healthy': {'en': 'Healthy', 'hi': 'स्वस्थ', 'mr': 'निरोगी'},
    'healthy': {'en': 'Healthy', 'hi': 'स्वस्थ', 'mr': 'निरोगी'},
    'Under Monitoring': {'en': 'Under Monitoring', 'hi': 'निगरानी में', 'mr': 'निरीक्षणाखाली'},
    'under monitoring': {'en': 'Under Monitoring', 'hi': 'निगरानी में', 'mr': 'निरीक्षणाखाली'},
    'Active Case': {'en': 'Active Case', 'hi': 'सक्रिय मामला', 'mr': 'सक्रिय केस'},
    'active case': {'en': 'Active Case', 'hi': 'सक्रिय मामला', 'mr': 'सक्रिय केस'},
    'Critical': {'en': 'Critical', 'hi': 'गंभीर', 'mr': 'गंभीर'},
    'critical': {'en': 'Critical', 'hi': 'गंभीर', 'mr': 'गंभीर'},
    'Male': {'en': 'Male', 'hi': 'नर', 'mr': 'नर'},
    'male': {'en': 'Male', 'hi': 'नर', 'mr': 'नर'},
    'Female': {'en': 'Female', 'hi': 'मादा', 'mr': 'मादी'},
    'female': {'en': 'Female', 'hi': 'मादा', 'mr': 'मादी'},
    'Both (Male & Female)': {'en': 'Both (Male & Female)', 'hi': 'दोनों (नर और मादा)', 'mr': 'दोन्ही (नर आणि मादी)'},
    'both (male & female)': {'en': 'Both (Male & Female)', 'hi': 'दोनों (नर और मादा)', 'mr': 'दोन्ही (नर आणि मादी)'},
    'both': {'en': 'Both (Male & Female)', 'hi': 'दोनों (नर और मादा)', 'mr': 'दोन्ही (नर आणि मादी)'},
    'both_male_female': {'en': 'Both (Male & Female)', 'hi': 'दोनों (नर और मादा)', 'mr': 'दोन्ही (नर आणि मादी)'},
    'enter_breed_name': {'en': 'Enter breed name', 'hi': 'नस्ल का नाम दर्ज करें', 'mr': 'जातीचे नाव टाका'},
    'general_mixed_breed': {'en': 'General / Mixed Breed', 'hi': 'सामान्य / मिश्रित नस्ल', 'mr': 'सामान्य / मिश्र जात'},
    'General / Mixed Breed': {'en': 'General / Mixed Breed', 'hi': 'सामान्य / मिश्रित नस्ल', 'mr': 'सामान्य / मिश्र जात'},
    'CONFIRMED': {'en': 'CONFIRMED', 'hi': 'पुष्टि की गई', 'mr': 'निश्चित केले'},
    'Confirmed': {'en': 'Confirmed', 'hi': 'पुष्टि की गई', 'mr': 'निश्चित केले'},
    'COMPLETED': {'en': 'COMPLETED', 'hi': 'पूर्ण हुआ', 'mr': 'पूर्ण झाले'},
    'Completed': {'en': 'Completed', 'hi': 'पूर्ण हुआ', 'mr': 'पूर्ण झाले'},
    'at': {'en': 'at', 'hi': 'को', 'mr': 'रोजी'},
    'doctor': {'en': 'Doctor', 'hi': 'चिकित्सक', 'mr': 'डॉक्टर'},
    'Doctor': {'en': 'Doctor', 'hi': 'चिकित्सक', 'mr': 'डॉक्टर'},
    'notes': {'en': 'Notes', 'hi': 'टिप्पणियाँ', 'mr': 'नोंदी'},
    'Notes': {'en': 'Notes', 'hi': 'टिप्पणियाँ', 'mr': 'नोंदी'},
    'prescribed': {'en': 'Prescribed', 'hi': 'परामर्श / दवा', 'mr': 'औषधोपचार / सल्ला'},
    'Prescribed': {'en': 'Prescribed', 'hi': 'परामर्श / दवा', 'mr': 'औषधोपचार / सल्ला'},
    'treatment': {'en': 'Treatment', 'hi': 'उपचार', 'mr': 'उपचार'},
    'Treatment': {'en': 'Treatment', 'hi': 'उपचार', 'mr': 'उपचार'},
    'medicine': {'en': 'Medicine', 'hi': 'दवा', 'mr': 'औषध'},
    'Medicine': {'en': 'Medicine', 'hi': 'दवा', 'mr': 'औषध'},
    'vet': {'en': 'Vet', 'hi': 'पशु चिकित्सक', 'mr': 'पशुवैद्यक'},
    'Vet': {'en': 'Vet', 'hi': 'पशु चिकित्सक', 'mr': 'पशुवैद्यक'},
    'given': {'en': 'Given', 'hi': 'दिया गया', 'mr': 'दिले'},
    'Given': {'en': 'Given', 'hi': 'दिया गया', 'mr': 'दिले'},
    'unit': {'en': 'Unit', 'hi': 'इकाई', 'mr': 'एकक'},
    'Unit': {'en': 'Unit', 'hi': 'इकाई', 'mr': 'एकक'},
    'save_changes': {'en': 'SAVE CHANGES', 'hi': 'बदलाव सहेजें', 'mr': 'बदल जतन करा'},
    'save_farm_details': {'en': 'SAVE FARM DETAILS', 'hi': 'फ़ार्म विवरण सहेजें', 'mr': 'फार्म तपशील जतन करा'},
    'edit_farmer_details': {'en': 'Edit Farmer Details', 'hi': 'किसान का विवरण बदलें', 'mr': 'शेतकऱ्याचे तपशील बदला'},
    'edit_farm_details': {'en': 'Edit Farm Details', 'hi': 'फ़ार्म का विवरण बदलें', 'mr': 'फार्म तपशील बदला'},
    'vet_visit': {'en': 'Visit', 'hi': 'भेंट', 'mr': 'भेट'},
    'vet_visits': {'en': 'Visits', 'hi': 'भेंटें', 'mr': 'भेटी'},
    'status_confirmed': {'en': 'CONFIRMED', 'hi': 'पुष्टि की गई', 'mr': 'निश्चित केले'},
    'status_completed': {'en': 'COMPLETED', 'hi': 'पूर्ण हुआ', 'mr': 'पूर्ण झाले'},

    // ── Common Demo Clinical Phrases ──
    'Routine inspection completed.': {'en': 'Routine inspection completed.', 'hi': 'नियमित निरीक्षण पूरा हुआ।', 'mr': 'नियमित तपासणी पूर्ण झाली.'},
    'Follow-up visit scheduled for next week.': {'en': 'Follow-up visit scheduled for next week.', 'hi': 'अगले सप्ताह के लिए फॉलो-अप भेंट निर्धारित।', 'mr': 'पुढील आठवड्यासाठी पुढील भेट नियोजित.'},
    'Animal is recovering well.': {'en': 'Animal is recovering well.', 'hi': 'पशु तेजी से स्वस्थ हो रहा है।', 'mr': 'जनावर वेगाने बरे होत आहे.'},
    'Oral suspension and antiseptic spray applied.': {'en': 'Oral suspension and antiseptic spray applied.', 'hi': 'मौखिक दवा और एंटीसेप्टिक स्प्रे दिया गया।', 'mr': 'तोंडावाटे औषध व जंतुनाशक फवारा दिला.'},
    'Mastitis Treatment': {'en': 'Mastitis Treatment', 'hi': 'थनैल रोग उपचार', 'mr': 'स्तनदाह उपचार'},
    'Intramammary Infusion': {'en': 'Intramammary Infusion', 'hi': 'इंट्रामैमरी इन्फ्यूजन', 'mr': 'इंट्रामॅमरी ओतणे'},
    'Amoxicillin': {'en': 'Amoxicillin', 'hi': 'एमोक्सिसिलिन', 'mr': 'अमोक्सिसिलिन'},
    'FMD Booster': {'en': 'FMD Booster', 'hi': 'एफएमडी बूस्टर', 'mr': 'लाळ्या खुरकूत बूस्टर'},
    'FMD Vaccine': {'en': 'FMD Vaccine', 'hi': 'एफएमडी टीका', 'mr': 'लाळ्या खुरकूत लस'},
    'Brucellosis Dose 1': {'en': 'Brucellosis Dose 1', 'hi': 'ब्रुसेलोसिस खुराक १', 'mr': 'ब्रुसेलोसिस डोस १'},
    'Brucella Vaccine': {'en': 'Brucella Vaccine', 'hi': 'ब्रुसेला टीका', 'mr': 'ब्रुसेला लस'},
    'Blackleg Vaccine': {'en': 'Blackleg Vaccine', 'hi': 'ब्लैकलेग टीका', 'mr': 'ब्लॅकलेग लस'},
    'HS Vaccine': {'en': 'HS Vaccine', 'hi': 'गलघोंटू टीका', 'mr': 'घटसर्प लस'},
    'Deworming': {'en': 'Deworming', 'hi': 'कृमि मुक्ति', 'mr': 'जंतनिर्मूलन'},
    'Albendazole': {'en': 'Albendazole', 'hi': 'अल्बेंडाजोल', 'mr': 'अल्बेंडाझोल'},
    'Wound Care': {'en': 'Wound Care', 'hi': 'घाव की देखभाल', 'mr': 'जखमेची काळजी'},
    'Povidone Iodine': {'en': 'Povidone Iodine', 'hi': 'पोवीडोन आयोडीन', 'mr': 'पोव्हिडोन आयोडीन'},

    // ── Names, Places & People ──
    'Sanjay': {'en': 'Sanjay', 'hi': 'संजय', 'mr': 'संजय'},
    'sanjay': {'en': 'Sanjay', 'hi': 'संजय', 'mr': 'संजय'},
    'Kumar': {'en': 'Kumar', 'hi': 'कुमार', 'mr': 'कुमार'},
    'Suresh': {'en': 'Suresh', 'hi': 'सुरेश', 'mr': 'सुरेश'},
    'Mane': {'en': 'Mane', 'hi': 'माने', 'mr': 'माने'},
    'Suresh Mane': {'en': 'Suresh Mane', 'hi': 'सुरेश माने', 'mr': 'सुरेश माने'},
    'Lakshmi': {'en': 'Lakshmi', 'hi': 'लक्ष्मी', 'mr': 'लक्ष्मी'},
    'Devi': {'en': 'Devi', 'hi': 'देवी', 'mr': 'देवी'},
    'Lakshmi Devi': {'en': 'Lakshmi Devi', 'hi': 'लक्ष्मी देवी', 'mr': 'लक्ष्मी देवी'},
    'Ramesh': {'en': 'Ramesh', 'hi': 'रमेश', 'mr': 'रमेश'},
    'Pawar': {'en': 'Pawar', 'hi': 'पवार', 'mr': 'पवार'},
    'Rajesh': {'en': 'Rajesh', 'hi': 'राजेश', 'mr': 'राजेश'},
    'Rajesh Kumar': {'en': 'Rajesh Kumar', 'hi': 'राजेश कुमार', 'mr': 'राजेश कुमार'},
    'Uruli': {'en': 'Uruli', 'hi': 'उरुली', 'mr': 'उरुळी'},
    'Kanchan': {'en': 'Kanchan', 'hi': 'कांचन', 'mr': 'कांचन'},
    'Loni': {'en': 'Loni', 'hi': 'लोणी', 'mr': 'लोणी'},
    'Kalbhor': {'en': 'Kalbhor', 'hi': 'काळभोर', 'mr': 'काळभोर'},
    'Loni Kalbhor': {'en': 'Loni Kalbhor', 'hi': 'लोणी काळभोर', 'mr': 'लोणी काळभोर'},
    'Manjari': {'en': 'Manjari', 'hi': 'मांजरी', 'mr': 'मांजरी'},
    'Khurd': {'en': 'Khurd', 'hi': 'खुर्द', 'mr': 'खुर्द'},
    'Manjari Khurd': {'en': 'Manjari Khurd', 'hi': 'मांजरी खुर्द', 'mr': 'मांजरी खुर्द'},
    'Haveli Block': {'en': 'Haveli Block', 'hi': 'हवेली ब्लॉक', 'mr': 'हवेली ब्लॉक'},
    'Mane Dairy Farm': {'en': 'Mane Dairy Farm', 'hi': 'माने डेयरी फार्म', 'mr': 'माने डेअरी फार्म'},
    'Devi Livestock': {'en': 'Devi Livestock', 'hi': 'देवी लाइवस्टॉक', 'mr': 'देवी लाइव्हस्टॉक'},
    'English': {'en': 'English', 'hi': 'अंग्रेज़ी', 'mr': 'इंग्रजी'},
    'Hindi': {'en': 'Hindi', 'hi': 'हिन्दी', 'mr': 'हिंदी'},
    'Marathi': {'en': 'Marathi', 'hi': 'मराठी', 'mr': 'मराठी'},
    'mobile': {'en': 'Mobile Number', 'hi': 'मोबाइल नंबर', 'mr': 'मोबाईल नंबर'},
    'email': {'en': 'Email (Optional)', 'hi': 'ईमेल (वैकल्पिक)', 'mr': 'ईमेल (पर्यायी)'},
    'mobile_number': {'en': 'Mobile Number', 'hi': 'मोबाइल नंबर', 'mr': 'मोबाईल नंबर'},
    'email_optional': {'en': 'Email (Optional)', 'hi': 'ईमेल (वैकल्पिक)', 'mr': 'ईमेल (पर्यायी)'},

    // ── Seeded Alerts (Titles & Messages) ──
    'Health Report Under Treatment: C001': {
      'en': 'Health Report Under Treatment: C001',
      'hi': 'उपचार जारी स्वास्थ्य रिपोर्ट: सी००१',
      'mr': 'उपचार सुरू आरोग्य अहवाल: सी००१',
    },
    'Dr. Rajesh Kumar initiated treatment for Cow C001 (Jersey). Follow prescribed medication twice daily.': {
      'en': 'Dr. Rajesh Kumar initiated treatment for Cow C001 (Jersey). Follow prescribed medication twice daily.',
      'hi': 'डॉ. राजेश कुमार ने गाय सी००१ (जर्सी) का उपचार शुरू किया है। निर्धारित दवा दिन में दो बार दें।',
      'mr': 'डॉ. राजेश कुमार यांनी गाय सी००१ (जर्सी) चे उपचार सुरू केले आहेत. सांगितलेली औषधे दिवसातून दोनदा द्या.',
    },
    'Lab Sample Collected (SMP001)': {
      'en': 'Lab Sample Collected (SMP001)',
      'hi': 'प्रयोगशाला नमूना एकत्र किया गया (एसएमपी००१)',
      'mr': 'प्रयोगशाळा नमुना गोळा केला (एसएमपी००१)',
    },
    'Blood and swab samples collected from Cow C001 have been dispatched to Disease Investigation Section, Pune.': {
      'en': 'Blood and swab samples collected from Cow C001 have been dispatched to Disease Investigation Section, Pune.',
      'hi': 'गाय सी००१ से लिए गए रक्त और स्वाब के नमूने रोग अन्वेषण विभाग, पुणे को भेज दिए गए हैं।',
      'mr': 'गाय सी००१ कडून गोळा केलेले रक्त आणि स्वॅबचे नमुने रोग अन्वेषण विभाग, पुणे येथे पाठवले आहेत.',
    },
    'Upcoming Vet Follow-Up Visit Confirmed': {
      'en': 'Upcoming Vet Follow-Up Visit Confirmed',
      'hi': 'आगामी पशु चिकित्सक फॉलो-अप भेंट की पुष्टि हुई',
      'mr': 'आगामी पशुवैद्यक फॉलो-अप भेटीची पुष्टी झाली',
    },
    'Dr. Rajesh Kumar scheduled a follow-up clinical visit for Cow C001 in 3 days. Please ensure the animal is secured.': {
      'en': 'Dr. Rajesh Kumar scheduled a follow-up clinical visit for Cow C001 in 3 days. Please ensure the animal is secured.',
      'hi': 'डॉ. राजेश कुमार ने गाय सी००१ के लिए ३ दिनों में फॉलो-अप नैदानिक भेंट निर्धारित की है। कृपया पशु को सुरक्षित रखें।',
      'mr': 'डॉ. राजेश कुमार यांनी गाय सी००१ साठी ३ दिवसांत पुढील तपासणी भेट निश्चित केली आहे. कृपया जनावराला बांधून ठेवा.',
    },
    'Vaccination Due: Cow C001 (FMD Booster)': {
      'en': 'Vaccination Due: Cow C001 (FMD Booster)',
      'hi': 'टीकाकरण बाकी: गाय सी००१ (एफएमडी बूस्टर)',
      'mr': 'लसीकरण बाकी: गाय सी००१ (लाळ्या खुरकूत बूस्टर)',
    },
    'Annual Foot & Mouth Disease booster vaccination is due within 7 days for Cow C001.': {
      'en': 'Annual Foot & Mouth Disease booster vaccination is due within 7 days for Cow C001.',
      'hi': 'गाय सी००१ के लिए वार्षिक खुरपका-मुंहपका रोग (एफएमडी) बूस्टर टीकाकरण ७ दिनों के भीतर होना है।',
      'mr': 'गाय सी००१ साठी वार्षिक लाळ्या खुरकूत (एफएमडी) बूस्टर लसीकरण ७ दिवसांच्या आत होणे बाकी आहे.',
    },
    'Mortality Report Recorded (C009)': {
      'en': 'Mortality Report Recorded (C009)',
      'hi': 'पशु मृत्यु रिपोर्ट दर्ज की गई (सी००९)',
      'mr': 'जनावर मृत्यू अहवाल नोंदवला गेला (सी००९)',
    },
    'Mortality report for Cow C009 logged. Veterinary authorities notified. Maintain biosecurity on farm.': {
      'en': 'Mortality report for Cow C009 logged. Veterinary authorities notified. Maintain biosecurity on farm.',
      'hi': 'गाय सी००९ की मृत्यु रिपोर्ट दर्ज हो गई है। पशु चिकित्सा अधिकारियों को सूचित कर दिया गया है। फार्म पर जैव सुरक्षा बनाए रखें।',
      'mr': 'गाय सी००९ चा मृत्यू अहवाल नोंदवला गेला. पशुवैद्यकीय अधिकाऱ्यांना कळवले आहे. फार्मवर जैवसुरक्षा पाळा.',
    },
    '🚨 Urgent: FMD Alert — Haveli Block': {
      'en': '🚨 Urgent: FMD Alert — Haveli Block',
      'hi': '🚨 अति आवश्यक: एफएमडी अलर्ट — हवेली ब्लॉक',
      'mr': '🚨 तातडीचे: लाळ्या खुरकूत इशारा — हवेली ब्लॉक',
    },
    'Urgent: FMD Alert — Haveli Block': {
      'en': 'Urgent: FMD Alert — Haveli Block',
      'hi': 'अति आवश्यक: एफएमडी अलर्ट — हवेली ब्लॉक',
      'mr': 'तातडीचे: लाळ्या खुरकूत इशारा — हवेली ब्लॉक',
    },
    'District AH Dept issued an outbreak advisory for Haveli Block. Avoid cattle movement and common grazing.': {
      'en': 'District AH Dept issued an outbreak advisory for Haveli Block. Avoid cattle movement and common grazing.',
      'hi': 'जिला पशुपालन विभाग ने हवेली ब्लॉक के लिए प्रकोप सलाह जारी की है। मवेशियों की आवाजाही और खुले चराने से बचें।',
      'mr': 'जिल्हा पशुसंवर्धन विभागाने हवेली ब्लॉकसाठी उद्रेक सल्ला जारी केला आहे. जनावरांची ने-आण व मोकळे चराई टाळा.',
    },
    '📢 Free Vaccination Camp: Uruli Kanchan': {
      'en': '📢 Free Vaccination Camp: Uruli Kanchan',
      'hi': '📢 निःशुल्क टीकाकरण शिविर: उरुली कांचन',
      'mr': '📢 मोफत लसीकरण शिबिर: उरुळी कांचन',
    },
    'Free Vaccination Camp: Uruli Kanchan': {
      'en': 'Free Vaccination Camp: Uruli Kanchan',
      'hi': 'निःशुल्क टीकाकरण शिविर: उरुली कांचन',
      'mr': 'मोफत लसीकरण शिबिर: उरुळी कांचन',
    },
    'Free ring vaccination camp Sep 10-12 at Uruli Kanchan Veterinary Dispensary.': {
      'en': 'Free ring vaccination camp Sep 10-12 at Uruli Kanchan Veterinary Dispensary.',
      'hi': 'उरुली कांचन पशु औषधालय में १०-१२ सितंबर को निःशुल्क रिंग टीकाकरण शिविर आयोजित किया जा रहा है।',
      'mr': 'उरुळी कांचन पशुवैद्यकीय दवाखान्यात १०-१२ सप्टेंबर रोजी मोफत रिंग लसीकरण शिबिर आहे.',
    },
    '🚨 Urgent Mortality: Cow C009 (Uruli Kanchan)': {
      'en': '🚨 Urgent Mortality: Cow C009 (Uruli Kanchan)',
      'hi': '🚨 अति आवश्यक मृत्यु: गाय सी००९ (उरुली कांचन)',
      'mr': '🚨 तातडीचा मृत्यू: गाय सी००९ (उरुळी कांचन)',
    },
    'Urgent Mortality: Cow C009 (Uruli Kanchan)': {
      'en': 'Urgent Mortality: Cow C009 (Uruli Kanchan)',
      'hi': 'अति आवश्यक मृत्यु: गाय सी००९ (उरुली कांचन)',
      'mr': 'तातडीचा मृत्यू: गाय सी००९ (उरुळी कांचन)',
    },
    'Sudden death reported with nasal bleeding at Green Meadows Farm (Ramesh Pawar). Immediate carcass inspection & biosecurity required.': {
      'en': 'Sudden death reported with nasal bleeding at Green Meadows Farm (Ramesh Pawar). Immediate carcass inspection & biosecurity required.',
      'hi': 'ग्रीन मीडोज फार्म (रमेश पवार) में नाक से खून बहने के साथ अचानक मृत्यु दर्ज हुई। तत्काल शव निरीक्षण और जैव सुरक्षा आवश्यक है।',
      'mr': 'ग्रीन मीडोज फार्म (रमेश पवार) येथे नाकातून रक्त येऊन अचानक मृत्यू नोंदवला गेला. त्वरित मृतदेह तपासणी व जैवसुरक्षा आवश्यक.',
    },
    '🚨 CRITICAL: 4 Buffaloes Affected (Manjari Khurd)': {
      'en': '🚨 CRITICAL: 4 Buffaloes Affected (Manjari Khurd)',
      'hi': '🚨 गंभीर: ४ भैंसें प्रभावित (मांजरी खुर्द)',
      'mr': '🚨 गंभीर: ४ म्हशी बाधित (मांजरी खुर्द)',
    },
    'CRITICAL: 4 Buffaloes Affected (Manjari Khurd)': {
      'en': 'CRITICAL: 4 Buffaloes Affected (Manjari Khurd)',
      'hi': 'गंभीर: ४ भैंसें प्रभावित (मांजरी खुर्द)',
      'mr': 'गंभीर: ४ म्हशी बाधित (मांजरी खुर्द)',
    },
    'Farmer Lakshmi Devi reported 4 Murrah buffaloes with severe diarrhea, mucosal ulcers, and high fever. Potential outbreak.': {
      'en': 'Farmer Lakshmi Devi reported 4 Murrah buffaloes with severe diarrhea, mucosal ulcers, and high fever. Potential outbreak.',
      'hi': 'किसान लक्ष्मी देवी ने गंभीर दस्त, श्लेष्मा छालों और तेज बुखार से पीड़ित ४ मुर्रा भैंसों की सूचना दी। संभावित प्रकोप।',
      'mr': 'शेतकरी लक्ष्मी देवी यांनी तीव्र जुलाब, तोंडात फोड आणि उच्च ताप असलेल्या ४ मुऱ्हा म्हशींची माहिती दिली. संभाव्य उद्रेक.',
    },
    'New High-Risk Case: Cow C010 (Loni Kalbhor)': {
      'en': 'New High-Risk Case: Cow C010 (Loni Kalbhor)',
      'hi': 'नया उच्च-जोखिम मामला: गाय सी०१० (लोणी काळभोर)',
      'mr': 'नवीन उच्च-जोखीम केस: गाय सी०१० (लोणी काळभोर)',
    },
    'Suresh Mane reported high fever and throat swelling in Sahiwal cow. Assigned to Dr. Rajesh Kumar.': {
      'en': 'Suresh Mane reported high fever and throat swelling in Sahiwal cow. Assigned to Dr. Rajesh Kumar.',
      'hi': 'सुरेश माने ने साहीवाल गाय में तेज बुखार और गले में सूजन की सूचना दी। डॉ. राजेश कुमार को सौंपा गया।',
      'mr': 'सुरेश माने यांनी साहिवाल गाईमध्ये तीव्र ताप आणि घशात सूज आल्याची माहिती दिली. डॉ. राजेश कुमार यांच्याकडे सोपवले.',
    },

    // ── Clinical Observations & Prescriptions (Profile & Vet Visits) ──
    'Oral ulcers observed on dental pad and tongue. Interdigital sores with mild purulent discharge. Temperature: 104.2°F. Animal isolated.': {
      'en': 'Oral ulcers observed on dental pad and tongue. Interdigital sores with mild purulent discharge. Temperature: 104.2°F. Animal isolated.',
      'hi': 'डेंटल पैड और जीभ पर मुंह के छाले देखे गए। पैरों के बीच घाव और मवाद का स्राव। तापमान: १०४.२°F। पशु को अलग रखा गया।',
      'mr': 'हिरडी व जिभेवर तोंडाचे फोड आढळले. पायांच्या बोटांमध्ये व्रण व पू चा स्राव. तापमान: १०४.२°F. जनावर वेगळे ठेवले.',
    },
    'Submandibular oedema and dyspnoea noted over phone. Suspected Haemorrhagic Septicaemia.': {
      'en': 'Submandibular oedema and dyspnoea noted over phone. Suspected Haemorrhagic Septicaemia.',
      'hi': 'फोन पर जबड़े के नीचे सूजन (गलगंड) और सांस लेने में कठिनाई दर्ज की गई। गलघोंटू (एचएस) की आशंका।',
      'mr': 'फोनवरून जबड्याखाली सूज आणि श्वास घेण्यास त्रास नोंदवला गेला. संशयित घटसर्प (एचएस).',
    },
    'Scheduled follow-up: Evaluate healing of oral & foot lesions, assess milk recovery, complete antibiotic booster.': {
      'en': 'Scheduled follow-up: Evaluate healing of oral & foot lesions, assess milk recovery, complete antibiotic booster.',
      'hi': 'निर्धारित फॉलो-अप: मुंह और पैर के घावों के भरने का मूल्यांकन, दूध उत्पादन में सुधार की जांच, एंटीबायोटिक बूस्टर पूरा करना।',
      'mr': 'नियोजित पाठपुरावा: तोंड व पायाच्या जखमा भरल्याचे मूल्यमापन, दूध उत्पादन पुनर्प्राप्ती तपासणे, प्रतिजैविक बूस्टर पूर्ण करणे.',
    },
    'Inj. Oxytetracycline 15ml IM, Inj. Meloxicam 10ml IM, Antiseptic foot spray applied': {
      'en': 'Inj. Oxytetracycline 15ml IM, Inj. Meloxicam 10ml IM, Antiseptic foot spray applied',
      'hi': 'इंजेक्शन ऑक्सीटेट्रासाइक्लिन १५ मिली IM, इंजेक्शन मेलोक्सिकैम १० मिली IM, एंटीसेप्टिक फुट स्प्रे लगाया गया',
      'mr': 'इंजेक्शन ऑक्सिटेट्रासायक्लिन १५ मिली IM, इंजेक्शन मेलोक्सिकॅम १० मिली IM, जंतुनाशक पायाचा फवारा लावला',
    },
    'Treatment initiated with Oxytetracycline and antiseptic dressing. Follow-up scheduled.': {
      'en': 'Treatment initiated with Oxytetracycline and antiseptic dressing. Follow-up scheduled.',
      'hi': 'ऑक्सीटेट्रासाइक्लिन और एंटीसेप्टिक ड्रेसिंग के साथ उपचार शुरू किया गया। फॉलो-अप निर्धारित।',
      'mr': 'ऑक्सिटेट्रासायक्लिन आणि जंतुनाशक मलमपट्टीसह उपचार सुरू केले. पुढील भेट नियोजित.',
    },
    'Case assigned to Dr. Rajesh Kumar. Field visit en route.': {
      'en': 'Case assigned to Dr. Rajesh Kumar. Field visit en route.',
      'hi': 'मामला डॉ. राजेश कुमार को सौंपा गया। फील्ड विजिट जारी है।',
      'mr': 'प्रकरण डॉ. राजेश कुमार यांच्याकडे सोपवले. प्रत्यक्ष भेट नियोजित.',
    },
    'Urgent report submitted: throat swelling and high fever': {
      'en': 'Urgent report submitted: throat swelling and high fever',
      'hi': 'अति आवश्यक रिपोर्ट दर्ज: गले में सूजन और तेज बुखार',
      'mr': 'तातडीचा अहवाल नोंदवला: घशात सूज आणि तीव्र ताप',
    },
    'Acute Foot & Mouth Disease (FMD) — high suspicion': {
      'en': 'Acute Foot & Mouth Disease (FMD) — high suspicion',
      'hi': 'तीव्र खुरपका-मुंहपका रोग (एफएमडी) — उच्च आशंका',
      'mr': 'तीव्र लाळ्या खुरकूत रोग (एफएमडी) — दाट संशय',
    },
    'Ring vaccination advised for herd. Lesions cleaned with KMNO4.': {
      'en': 'Ring vaccination advised for herd. Lesions cleaned with KMNO4.',
      'hi': 'झुंड के लिए रिंग टीकाकरण की सलाह दी गई। घावों को पोटेशियम परमैंगनेट (KMNO4) से साफ किया गया।',
      'mr': 'कळपासाठी रिंग लसीकरणाचा सल्ला दिला. जखमा पोटॅशियम परमँगनेटने स्वच्छ केल्या.',
    },
    '1 cow (C001)': {
      'en': '1 cow (C001)',
      'hi': '१ गाय (सी००१)',
      'mr': '१ गाय (सी००१)',
    },
    'Fever, salivation, mouth ulcers, lameness': {
      'en': 'Fever, salivation, mouth ulcers, lameness',
      'hi': 'बुखार, लार टपकना, मुंह में छाले, लंगड़ाना',
      'mr': 'ताप, लाळ गळणे, तोंडाचे फोड, लंगडणे',
    },
    'speak_notes': {
      'en': 'Record Voice Note',
      'hi': 'बोलकर नोट्स दर्ज करें',
      'mr': 'बोलून नोंदी नोंदवा',
    },
    'voice_added': {
      'en': 'Voice Note Added',
      'hi': 'आवाज़ जोड़ी गई',
      'mr': 'ध्वनी संदेश जोडला',
    },
    'listening': {
      'en': 'Listening...',
      'hi': 'सुन रहे हैं...',
      'mr': 'ऐकत आहे...',
    },
    'remove': {
      'en': 'Remove',
      'hi': 'हटाएं',
      'mr': 'काढून टाका',
    },
    'Voice and photo help the veterinarian diagnose faster.': {
      'en': 'Voice and photo help the veterinarian diagnose faster.',
      'hi': 'आवाज़ और फोटो से पशु चिकित्सक को जल्दी निदान करने में मदद मिलती है।',
      'mr': 'आवाज आणि फोटोमुळे पशुवैद्यकाला लवकर निदान करण्यास मदत होते.',
    },
    'voice_photo_help_diag': {
      'en': 'Voice and photo help the veterinarian diagnose faster.',
      'hi': 'आवाज़ और फोटो से पशु चिकित्सक को जल्दी निदान करने में मदद मिलती है।',
      'mr': 'आवाज आणि फोटोमुळे पशुवैद्यकाला लवकर निदान करण्यास मदत होते.',
    },
    'Confirm the animal location for vet dispatch.': {
      'en': 'Confirm the animal location for vet dispatch.',
      'hi': 'पशु चिकित्सक भेजने के लिए पशु का स्थान सुनिश्चित करें।',
      'mr': 'पशुवैद्यक पाठवण्यासाठी जनावराचे ठिकाण निश्चित करा.',
    },
    'confirm_animal_location_diag': {
      'en': 'Confirm the animal location for vet dispatch.',
      'hi': 'पशु चिकित्सक भेजने के लिए पशु का स्थान सुनिश्चित करें।',
      'mr': 'पशुवैद्यक पाठवण्यासाठी जनावराचे ठिकाण निश्चित करा.',
    },
    'extra_notes_vet_hint': {
      'en': 'Any extra notes for the vet...',
      'hi': 'पशु चिकित्सक के लिए कोई अतिरिक्त टिप्पणी...',
      'mr': 'पशुवैद्यकासाठी काही अतिरिक्त माहिती...',
    },
    'acquiring_device_gps': {
      'en': 'Acquiring device GPS...',
      'hi': 'डिवाइस जीपीएस प्राप्त किया जा रहा है...',
      'mr': 'डिव्हाइस जीपीएस मिळवत आहे...',
    },
  };
}

/// Helper extension for concise translation syntax in widgets.
extension LocalizationExt on BuildContext {
  String tr(String key, {Map<String, String>? params}) {
    return LocalizationService.instance.tr(key, params: params);
  }

  String translateText(String? text) {
    return LocalizationService.instance.translateText(text);
  }

  String translateSpecies(String? species) {
    return LocalizationService.instance.translateSpecies(species);
  }

  String translateBreed(String? breed) {
    return LocalizationService.instance.translateBreed(breed);
  }

  String translateSymptom(String symptom) {
    return LocalizationService.instance.translateSymptom(symptom);
  }

  String translateStatus(String status) {
    return LocalizationService.instance.translateStatus(status);
  }

  String translateTag(String? tag) {
    return LocalizationService.instance.translateTag(tag);
  }
}

