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

    // 3. Try loaded JSON string for English
    text ??= _loadedStrings['en']?[key];

    // 4. Try embedded fallback dictionary for English
    text ??= _embeddedFallbackStrings['en']?[key];

    // 5. Raw key fallback
    text ??= key;

    if (params != null && params.isNotEmpty) {
      params.forEach((k, v) {
        text = text!.replaceAll('{$k}', v);
      });
    }

    return text!;
  }

  // â”€â”€â”€ In-memory fallback dictionary â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const Map<String, Map<String, String>> _embeddedFallbackStrings = {
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
      'demo_otp_notice': 'Demo OTP: 123456 (Frontend Prototype)',
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
      'take_photo': 'Take Photo',
      'record_video': 'Record Video',
      'record_voice': 'Record Voice',
      'write_description': 'Write Description',
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

      // Profile & Settings
      'farmer_details': 'Farmer Details',
      'farm_details': 'Farm Details',
      'app_settings': 'App Settings',
      'change_language': 'Change Language',
      'logout': 'Logout',
      'logout_confirm': 'Are you sure you want to log out?'
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
      'demo_otp_notice': 'डेमो ओटीपी: 123456 (प्रोटोटाइप)',
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
      'take_photo': 'फोटो लें',
      'record_video': 'वीडियो बनाएं',
      'record_voice': 'आवाज़ रिकॉर्ड करें',
      'write_description': 'विवरण लिखें',
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
      'logout': 'लॉगआउट करें',
      'logout_confirm': 'क्या आप लॉगआउट करना चाहते हैं?'
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
      'demo_otp_notice': 'डेमो ओटीपी: 123456 (प्रोटोटाइप)',
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
      'take_photo': 'फोटो काढा',
      'record_video': 'व्हिडिओ बनवा',
      'record_voice': 'आवाज रेकॉर्ड करा',
      'write_description': 'तपशील लिहा',
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
      'logout': 'लॉगआउट करा',
      'logout_confirm': 'आपण नक्की लॉगआउट करू इच्छिता का?'
    }
  };
}

/// Helper extension for concise translation syntax in widgets.
extension LocalizationExt on BuildContext {
  String tr(String key, {Map<String, String>? params}) {
    return LocalizationService.instance.tr(key, params: params);
  }
}
