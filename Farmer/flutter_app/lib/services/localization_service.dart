// LocalizationService — Centralized language and string dictionary.
// Supports English, தமிழ் (Tamil), and हिन्दी (Hindi).
// Easily extensible for additional Indian languages.

import 'package:flutter/material.dart';

enum AppLanguage {
  english('English', 'en'),
  tamil('தமிழ்', 'ta'),
  hindi('हिन्दी', 'hi');

  final String label;
  final String code;
  const AppLanguage(this.label, this.code);
}

class LocalizationService extends ChangeNotifier {
  static final LocalizationService instance = LocalizationService._internal();
  LocalizationService._internal();

  AppLanguage _currentLanguage = AppLanguage.english;

  AppLanguage get currentLanguage => _currentLanguage;

  void setLanguage(AppLanguage language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();
    }
  }

  void setLanguageByName(String name) {
    final match = AppLanguage.values.firstWhere(
      (l) => l.name.toLowerCase() == name.toLowerCase() ||
             l.label.toLowerCase() == name.toLowerCase() ||
             l.code.toLowerCase() == name.toLowerCase(),
      orElse: () => AppLanguage.english,
    );
    setLanguage(match);
  }

  String tr(String key) {
    final langKey = _currentLanguage.code;
    return _localizedStrings[langKey]?[key] ??
        _localizedStrings['en']?[key] ??
        key;
  }

  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'app_title': 'Smart Livestock',
      'choose_language': 'Choose your language',
      'select_language_subtitle': 'Select a language to continue with the app',
      'continue': 'CONTINUE',
      'next': 'Next',
      'back': 'Back',
      'save': 'Save',
      'cancel': 'Cancel',
      'done': 'Done',
      'submit': 'SUBMIT',
      'edit': 'Edit',
      'edit_farm_details': 'Edit Farm Details',

      // Login & Registration
      'login_title': 'Farmer Login',
      'mobile_number': 'Mobile Number',
      'password': 'Password',
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

      // Dashboard
      'hello_farmer': 'Hello, {name}',
      'online': 'Online',
      'offline': 'Offline',
      'report_animal_problem': 'REPORT ANIMAL PROBLEM',
      'my_animals_cases': 'My Cases',
      'request_veterinarian': 'Request Veterinarian',
      'alerts': 'Alerts',
      'animals_reported': 'Animals Reported',
      'active_cases': 'Active Cases',
      'vaccination_due': 'Vaccination Due',
      'important_alerts': 'Important Alerts',
      'recent_activity': 'Recent Activity',

      // Report Wizard
      'what_animal_problem': 'What animal has a problem?',
      'tell_about_animal': 'Tell us about the animal',
      'animal_id_tag': 'Animal ID / Ear Tag (optional)',
      'select_breed': 'Select Breed ▼',
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
      'sym_fever': 'Fever',
      'sym_not_eating': 'Not eating',
      'sym_breathing': 'Breathing problem',
      'sym_walking': 'Difficulty walking',
      'sym_diarrhea': 'Diarrhea',
      'sym_salivation': 'Excessive salivation',
      'sym_weakness': 'Weakness',
      'sym_skin_lesions': 'Skin lesions',
      'sym_vomiting': 'Vomiting',
      'sym_nasal_discharge': 'Nasal discharge',
      'sym_eye_problem': 'Eye problem',
      'sym_bleeding': 'Bleeding',
      'sym_milk_reduced': 'Milk production reduced',
      'sym_pregnancy_problem': 'Pregnancy/birth problem',
      'sym_other': 'Other',

      // Since when
      'since_when': 'Since when?',
      'today': 'Today',
      'yesterday': 'Yesterday',
      '2_3_days': '2–3 days',
      '4_7_days': '4–7 days',
      'more_than_week': 'More than a week',
      'not_sure': 'Not sure',

      // Eating & Drinking
      'is_animal_eating': 'Is the animal eating?',
      'is_animal_drinking': 'Is the animal drinking water?',
      'yes': 'Yes',
      'less_than_usual': 'Less than usual',
      'no': 'No',

      // How many
      'how_many_affected': 'How many animals have this problem?',

      // Pregnancy & Lactation
      'is_pregnant': 'Pregnant?',
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
      'speak_in_language': 'You can speak in your selected language.',
      'voice_recorded': 'Voice recorded',
      'recording': 'Listening... Speak now',
      'play': 'Play',
      'record_again': 'Record Again',
      'photo_added': 'Photo added',
      'video_added': 'Video added',

      // Location
      'where_is_animal': 'Where is the animal?',
      'use_farm_location': 'Use Farm Location',

      // Summary
      'report_summary': 'Report Summary',
      'submit_report': 'SUBMIT REPORT',

      // Risk Assessment
      'health_risk_assessment': 'Health Risk Assessment',
      'risk_low': 'LOW HEALTH RISK',
      'risk_medium': 'MEDIUM HEALTH RISK',
      'risk_high': 'HIGH HEALTH RISK',
      'risk_critical': 'CRITICAL HEALTH RISK',
      'listen': 'Listen',
      'back_to_home': 'BACK TO HOME',

      // Mortality Report
      'report_animal_death': 'Report Animal Death',
      'how_many_died': 'How many animals died?',
      'when_happened': 'When did it happen?',
      'problems_before_death': 'Problems before death',
      'death_reported_title': 'CRITICAL: Animal death reported',
      'death_reported_msg': 'Please avoid moving animals from the affected area. Veterinary investigation may be required.',

      // Vet Request
      'need_veterinarian': 'Need a Veterinarian?',
      'select_case': 'Select Animal / Case',
      'reason_for_vet': 'Reason for Request',
      'reason_very_sick': 'Animal is very sick',
      'reason_not_improving': 'Animal not improving',
      'reason_death': 'Animal death',
      'reason_vaccination': 'Vaccination',
      'reason_treatment': 'Treatment follow-up',
      'reason_other': 'Other',
      'preferred_visit': 'Preferred Visit Date',
      'preferred_time': 'Preferred Time',
      'morning': 'Morning',
      'afternoon': 'Afternoon',
      'evening': 'Evening',
      'status_submitted': 'SUBMITTED',
      'status_under_review': 'UNDER REVIEW',
      'status_vet_assigned': 'VET ASSIGNED',
      'status_visit_scheduled': 'VISIT SCHEDULED',
      'status_treatment_started': 'TREATMENT STARTED',
      'status_case_closed': 'CASE CLOSED',

      // Profile
      'farmer_details': 'Farmer Details',
      'farm_details': 'Farm Details',
      'logout': 'Logout',
    },

    'ta': {
      'app_title': 'ஸ்மார்ட் கால்நடை',
      'choose_language': 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்',
      'select_language_subtitle': 'தொடர மொழியைத் தேர்வுசெய்யவும்',
      'continue': 'தொடர்க',
      'next': 'அடுத்தது',
      'back': 'பின்செல்',
      'save': 'சேமி',
      'cancel': 'ரத்து செய்',
      'done': 'முடிந்தது',
      'submit': 'சமர்ப்பி',
      'edit': 'மாற்று',
      'edit_farm_details': 'பண்ணை விவரங்களை மாற்று',

      // Login & Registration
      'login_title': 'விவசாயி உள்நுழைவு',
      'mobile_number': 'மொபைல் எண்',
      'password': 'கடவுச்சொல்',
      'confirm_password': 'கடவுச்சொல்லை உறுதிசெய்',
      'login_button': 'உள்நுழைக',
      'forgot_password': 'கடவுச்சொல் மறந்துவிட்டதா?',
      'new_farmer_register': 'புதிய விவசாயியா? பதிவு செய்க',
      'already_account': 'ஏற்கனவே கணக்கு உள்ளதா? உள்நுழைக',
      'about_you': 'உங்களைப் பற்றி',
      'full_name': 'முழு பெயர்',
      'speak_name': 'உங்கள் பெயரைப் பேசுங்கள் 🎤',
      'email_optional': 'மின்னஞ்சல் (விருப்பத்தேர்வு)',
      'where_is_farm': 'உங்கள் பண்ணை எங்கே உள்ளது?',
      'state': 'மாநிலம்',
      'district': 'மாவட்டம்',
      'block_taluk': 'வட்டம் / தாலுகா',
      'village': 'கிராமம்',
      'about_farm': 'உங்கள் பண்ணை பற்றி',
      'farm_name_optional': 'பண்ணை பெயர் (விருப்பத்தேர்வு)',
      'farm_size': 'பண்ணை அளவு',
      'farm_size_unit': 'அளவு அலகு',
      'acres': 'ஏக்கர்',
      'hectares': 'ஹெக்டேர்',
      'cent': 'சென்ட்',
      'farm_location': 'பண்ணை அமைவிடம்',
      'use_current_location': '📍 தற்போதைய இருப்பிடத்தைப் பயன்படுத்து',
      'enter_location_manually': '📝 கைமுறையாக உள்ளிடவும்',
      'livestock_type': 'கால்நடை வகை',
      'cow': 'பசு',
      'buffalo': 'எருமை',
      'goat': 'ஆடு',
      'sheep': 'செம்மறியாடு',
      'pig': 'பன்றி',
      'poultry': 'கோழி',
      'other': 'மற்றவை',
      'language_preferences': 'மொழி & விருப்பங்கள்',
      'preferred_language': 'விருப்ப மொழி',
      'communication_preference': 'தொடர்பு முறை',
      'comm_voice': '🔊 குரல்',
      'comm_text': '📱 உரை',
      'comm_both': 'குரல் மற்றும் உரை',
      'create_farmer_profile': 'விவசாயி சுயவிவரத்தை உருவாக்கு',
      'verify_mobile': 'மொபைல் எண்ணை சரிபார்க்கவும்',
      'demo_otp_notice': 'டெமோ OTP: 123456 (முன்மாதிரி)',
      'create_password_title': 'கடவுச்சொல்லை உருவாக்கவும்',
      'create_account_btn': 'கணக்கை உருவாக்கு',
      'account_created_success': 'கணக்கு வெற்றிகரமாக உருவாக்கப்பட்டது!',

      // Dashboard
      'hello_farmer': 'வணக்கம், {name} 👨‍🌾',
      'online': 'இணையத்தில்',
      'offline': 'ஆஃப்லைன்',
      'report_animal_problem': '🩺 கால்நடை பிரச்சினையைப் புகாரளி',
      'my_animals_cases': '🐄 என் வழக்குகள்',
      'request_veterinarian': '👨‍⚕️ மருத்துவரை அழைக்கவும்',
      'alerts': '🔔 எச்சரிக்கைகள்',
      'animals_reported': 'பதிவான விலங்குகள்',
      'active_cases': 'நடப்பு வழக்குகள்',
      'vaccination_due': 'தடுப்பூசி நிலுவை',
      'important_alerts': 'முக்கிய எச்சரிக்கைகள்',
      'recent_activity': 'சமீபத்திய நிகழ்வுகள்',

      // Report Wizard
      'what_animal_problem': 'எந்த விலங்கிற்கு பிரச்சினை?',
      'tell_about_animal': 'விலங்கு பற்றிய விவரங்கள்',
      'animal_id_tag': 'விலங்கு எண் / காது குறி (விருப்பம்)',
      'select_breed': 'இனத்தைத் தேர்ந்தெடுக்கவும் ▼',
      'gender': 'பாலினம்',
      'male': 'ஆண்',
      'female': 'பெண்',
      'age': 'வயது',
      'age_below_1': '1 வருடத்திற்குள்',
      'age_1_2': '1–2 ஆண்டுகள்',
      'age_2_5': '2–5 ஆண்டுகள்',
      'age_5_10': '5–10 ஆண்டுகள்',
      'age_above_10': '10 ஆண்டுகளுக்கு மேல்',

      // Symptoms
      'what_is_wrong': 'விலங்கிற்கு என்ன பிரச்சினை?',
      'sym_fever': '🌡 காய்ச்சல்',
      'sym_not_eating': '🍽 தீவனம் சாப்பிடவில்லை',
      'sym_breathing': '😮‍💨 மூச்சுத்திணறல்',
      'sym_walking': '🦵 நடப்பதில் சிரமம்',
      'sym_diarrhea': '💩 வயிற்றுப்போக்கு',
      'sym_salivation': '💧 அதிக எச்சில் வடிதல்',
      'sym_weakness': '😴 சோர்வு / பலவீனம்',
      'sym_skin_lesions': '🔴 தோல் புண்கள்',
      'sym_vomiting': '🤮 வாந்தி',
      'sym_nasal_discharge': '🤧 மூக்கு ஒழுகுதல்',
      'sym_eye_problem': '👁 கண் பிரச்சினை',
      'sym_bleeding': '🩸 இரத்தப்போக்கு',
      'sym_milk_reduced': '🍼 பால் அளவு குறைந்தது',
      'sym_pregnancy_problem': '🐣 சினை / ஈற்று பிரச்சினை',
      'sym_other': '❓ மற்றவை',

      // Since when
      'since_when': 'எப்போது முதல்?',
      'today': 'இன்று',
      'yesterday': 'நேற்று',
      '2_3_days': '2–3 நாட்கள்',
      '4_7_days': '4–7 நாட்கள்',
      'more_than_week': 'ஒரு வாரத்திற்கும் மேல்',
      'not_sure': 'தெரியவில்லை',

      // Eating & Drinking
      'is_animal_eating': 'விலங்கு சாப்பிடுகிறதா?',
      'is_animal_drinking': 'விலங்கு தண்ணீர் குடிக்கிறதா?',
      'yes': 'ஆம்',
      'less_than_usual': 'வழக்கத்தை விட குறைவு',
      'no': 'இல்லை',

      // How many
      'how_many_affected': 'எத்தனை விலங்குகள் பாதிக்கப்பட்டுள்ளன?',

      // Pregnancy & Lactation
      'is_pregnant': 'சினை உள்ளதா?',
      'is_lactating': 'தற்போது பால் கறக்கிறதா?',

      // Evidence & Voice
      'show_us_problem': 'பிரச்சினையைக் காட்டவும்',
      'take_photo': '📷 புகைப்படம் எடு',
      'record_video': '🎥 வீடியோ எடு',
      'record_voice': '🎤 குரல் பதிவு செய்',
      'write_description': '✍ விளக்கம் எழுது',
      'tell_what_happened': 'என்ன நடந்தது என்று சொல்லுங்கள்',
      'tap_and_speak': '🎤 தொட்டுப் பேசுங்கள்',
      'tap_to_speak': '🎤 பேசத் தொடங்குங்கள்',
      'speak_in_language': 'உங்கள் விருப்ப மொழியில் பேசலாம்.',
      'voice_recorded': '✓ குரல் பதிவு செய்யப்பட்டது',
      'recording': '🔴 கேட்கிறது... இப்போது பேசுங்கள்',
      'play': '🔊 கேள்',
      'record_again': '🎤 மீண்டும் பேசு',
      'photo_added': '✓ புகைப்படம் சேர்க்கப்பட்டது',
      'video_added': '✓ வீடியோ சேர்க்கப்பட்டது',

      // Location
      'where_is_animal': 'விலங்கு எங்குள்ளது?',
      'use_farm_location': '📍 பண்ணை அமைவிடம்',

      // Summary
      'report_summary': 'புகார் சுருக்கம்',
      'submit_report': 'புகாரை சமர்ப்பி',

      // Risk Assessment
      'health_risk_assessment': 'சுகாதார இடர் மதிப்பீடு',
      'risk_low': 'குறைந்த ஆபத்து',
      'risk_medium': 'நடுத்தர ஆபத்து',
      'risk_high': 'அதிக ஆபத்து',
      'risk_critical': 'அவசர ஆபத்து',
      'listen': '🔊 கேள்',
      'back_to_home': '🏠 முகப்புக்குச் செல்',

      // Mortality Report
      'report_animal_death': 'விலங்கு இறப்புப் புகார்',
      'how_many_died': 'எத்தனை விலங்குகள் இறந்தன?',
      'when_happened': 'எப்போது நடந்தது?',
      'problems_before_death': 'இறப்பதற்கு முன் இருந்த அறிகுறிகள்',
      'death_reported_title': 'அவசரம்: விலங்கு இறப்புப் புகார் பதிவானது',
      'death_reported_msg': 'பாதிக்கப்பட்ட இடத்திலிருந்து விலங்குகளை நகர்த்த வேண்டாம். கால்நடை மருத்துவர் ஆய்வு தேவைப்படலாம்.',

      // Vet Request
      'need_veterinarian': 'மருத்துவர் தேவையா?',
      'select_case': 'விலங்கு / வழக்கைத் தேர்ந்தெடுக்கவும்',
      'reason_for_vet': 'காரணம்',
      'reason_very_sick': 'விலங்கு மிக மோசமாக உள்ளது',
      'reason_not_improving': 'குணமாகவில்லை',
      'reason_death': 'விலங்கு இறப்பு',
      'reason_vaccination': 'தடுப்பூசி',
      'reason_treatment': 'தொடர் சிகிச்சை',
      'reason_other': 'மற்றவை',
      'preferred_visit': 'விருப்பமான நாள்',
      'preferred_time': 'விருப்பமான நேரம்',
      'morning': 'காலை',
      'afternoon': 'மதியம்',
      'evening': 'மாலை',
      'status_submitted': 'சமர்ப்பிக்கப்பட்டது',
      'status_under_review': 'பரிசீலனையில்',
      'status_vet_assigned': 'மருத்துவர் நியமிக்கப்பட்டார்',
      'status_visit_scheduled': 'வருகை திட்டமிடப்பட்டது',
      'status_treatment_started': 'சிகிச்சை தொடங்கியது',
      'status_case_closed': 'வழக்கு முடிந்தது',

      // Profile
      'farmer_details': 'விவசாயி விவரங்கள்',
      'farm_details': 'பண்ணை விவரங்கள்',
      'logout': 'வெளியேறு',
    },

    'hi': {
      'app_title': 'स्मार्ट पशुधन',
      'choose_language': 'अपनी भाषा चुनें',
      'select_language_subtitle': 'ऐप जारी रखने के लिए भाषा चुनें',
      'continue': 'आगे बढ़ें',
      'next': 'आगे',
      'back': 'पीछे',
      'save': 'सहेजें',
      'cancel': 'रद्द करें',
      'done': 'हो गया',
      'submit': 'जमा करें',
      'edit': 'संपादित करें',
      'edit_farm_details': 'फार्म विवरण बदलें',

      // Login & Registration
      'login_title': 'किसान लॉगिन',
      'mobile_number': 'मोबाइल नंबर',
      'password': 'पासवर्ड',
      'confirm_password': 'पासवर्ड पुष्टि करें',
      'login_button': 'लॉगिन करें',
      'forgot_password': 'पासवर्ड भूल गए?',
      'new_farmer_register': 'नए किसान? पंजीकरण करें',
      'already_account': 'पहले से खाता है? लॉगिन करें',
      'about_you': 'आपके बारे में',
      'full_name': 'पूरा नाम',
      'speak_name': 'अपना नाम बोलें 🎤',
      'email_optional': 'ईमेल (वैकल्पिक)',
      'where_is_farm': 'आपका फार्म कहाँ है?',
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
      'use_current_location': '📍 वर्तमान स्थान का उपयोग करें',
      'enter_location_manually': '📝 स्थान स्वयं दर्ज करें',
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
      'comm_voice': '🔊 आवाज़',
      'comm_text': '📱 संदेश',
      'comm_both': 'आवाज़ और संदेश दोनों',
      'create_farmer_profile': 'किसान प्रोफ़ाइल बनाएं',
      'verify_mobile': 'मोबाइल नंबर सत्यापित करें',
      'demo_otp_notice': 'डेमो ओटीपी: 123456 (प्रोटोटाइप)',
      'create_password_title': 'पासवर्ड बनाएं',
      'create_account_btn': 'खाता बनाएं',
      'account_created_success': 'खाता सफलतापूर्वक बन गया!',

      // Dashboard
      'hello_farmer': 'नमस्ते, {name} 👨‍🌾',
      'online': 'ऑनलाइन',
      'offline': 'ऑफ़लाइन',
      'report_animal_problem': '🩺 पशु की समस्या दर्ज करें',
      'my_animals_cases': '🐄 मेरे केस',
      'request_veterinarian': '👨‍⚕️ पशु चिकित्सक बुलाएं',
      'alerts': '🔔 चेतावनियाँ',
      'animals_reported': 'दर्ज पशु',
      'active_cases': 'सक्रिय केस',
      'vaccination_due': 'टीकाकरण बाकी',
      'important_alerts': 'महत्वपूर्ण अलर्ट',
      'recent_activity': 'हाल की गतिविधियाँ',

      // Report Wizard
      'what_animal_problem': 'किस पशु को समस्या है?',
      'tell_about_animal': 'पशु के बारे में बताएं',
      'animal_id_tag': 'पशु आईडी / कान का टैग (वैकल्पिक)',
      'select_breed': 'नस्ल चुनें ▼',
      'gender': 'लिंग',
      'male': 'नर',
      'female': 'मादा',
      'age': 'उम्र',
      'age_below_1': '1 वर्ष से कम',
      'age_1_2': '1–2 वर्ष',
      'age_2_5': '2–5 वर्ष',
      'age_5_10': '5–10 वर्ष',
      'age_above_10': '10 वर्ष से अधिक',

      // Symptoms
      'what_is_wrong': 'पशु को क्या समस्या है?',
      'sym_fever': '🌡 बुखार',
      'sym_not_eating': '🍽 खाना नहीं खा रहा',
      'sym_breathing': '😮‍💨 सांस लेने में तकलीफ',
      'sym_walking': '🦵 चलने में कठिनाई',
      'sym_diarrhea': '💩 दस्त',
      'sym_salivation': '💧 मुंह से अधिक लार टपकना',
      'sym_weakness': '😴 कमजोरी / सुस्ती',
      'sym_skin_lesions': '🔴 त्वचा पर छाले / घाव',
      'sym_vomiting': '🤮 उल्टी',
      'sym_nasal_discharge': '🤧 नाक बहना',
      'sym_eye_problem': '👁 आंख की समस्या',
      'sym_bleeding': '🩸 खून बहना',
      'sym_milk_reduced': '🍼 दूध कम होना',
      'sym_pregnancy_problem': '🐣 गर्भ / प्रसव समस्या',
      'sym_other': '❓ अन्य',

      // Since when
      'since_when': 'कब से?',
      'today': 'आज से',
      'yesterday': 'कल से',
      '2_3_days': '2–3 दिन',
      '4_7_days': '4–7 दिन',
      'more_than_week': 'एक सप्ताह से अधिक',
      'not_sure': 'पक्का नहीं पता',

      // Eating & Drinking
      'is_animal_eating': 'क्या पशु चारा खा रहा है?',
      'is_animal_drinking': 'क्या पशु पानी पी रहा है?',
      'yes': 'हाँ',
      'less_than_usual': 'सामान्य से कम',
      'no': 'नहीं',

      // How many
      'how_many_affected': 'कितने पशु प्रभावित हैं?',

      // Pregnancy & Lactation
      'is_pregnant': 'क्या पशु गाभिन है?',
      'is_lactating': 'क्या वर्तमान में दूध दे रहा है?',

      // Evidence & Voice
      'show_us_problem': 'समस्या दिखाएं',
      'take_photo': '📷 फोटो लें',
      'record_video': '🎥 वीडियो बनाएं',
      'record_voice': '🎤 आवाज़ रिकॉर्ड करें',
      'write_description': '✍ विवरण लिखें',
      'tell_what_happened': 'बताएं क्या हुआ',
      'tap_and_speak': '🎤 दबाएं और बोलें',
      'tap_to_speak': '🎤 बोलने के लिए टैप करें',
      'speak_in_language': 'आप अपनी चुनी हुई भाषा में बोल सकते हैं।',
      'voice_recorded': '✓ आवाज़ रिकॉर्ड हो गई',
      'recording': '🔴 सुन रहे हैं... अब बोलें',
      'play': '🔊 सुनें',
      'record_again': '🎤 दोबारा बोलें',
      'photo_added': '✓ फोटो जोड़ी गई',
      'video_added': '✓ वीडियो जोड़ा गया',

      // Location
      'where_is_animal': 'पशु कहाँ है?',
      'use_farm_location': '📍 फार्म का स्थान',

      // Summary
      'report_summary': 'रिपोर्ट सारांश',
      'submit_report': 'रिपोर्ट जमा करें',

      // Risk Assessment
      'health_risk_assessment': 'स्वास्थ्य जोखिम मूल्यांकन',
      'risk_low': 'कम जोखिम',
      'risk_medium': 'मध्यम जोखिम',
      'risk_high': 'उच्च जोखिम',
      'risk_critical': 'गंभीर जोखिम',
      'listen': '🔊 सुनें',
      'back_to_home': '🏠 होम पर जाएं',

      // Mortality Report
      'report_animal_death': 'पशु मृत्यु की रिपोर्ट',
      'how_many_died': 'कितने पशुओं की मृत्यु हुई?',
      'when_happened': 'यह कब हुआ?',
      'problems_before_death': 'मृत्यु से पहले के लक्षण',
      'death_reported_title': 'गंभीर: पशु मृत्यु की रिपोर्ट दर्ज',
      'death_reported_msg': 'कृपया प्रभावित क्षेत्र से अन्य पशुओं को न हटाएं। पशु चिकित्सक की जांच आवश्यक हो सकती है।',

      // Vet Request
      'need_veterinarian': 'डॉक्टर चाहिए?',
      'select_case': 'पशु / केस चुनें',
      'reason_for_vet': 'कारण',
      'reason_very_sick': 'पशु बहुत बीमार है',
      'reason_not_improving': 'सुधार नहीं हो रहा',
      'reason_death': 'पशु की मृत्यु',
      'reason_vaccination': 'टीकाकरण',
      'reason_treatment': 'उपचार फॉलो-अप',
      'reason_other': 'अन्य',
      'preferred_visit': 'पसंदीदा दिन',
      'preferred_time': 'पसंदीदा समय',
      'morning': 'सुबह',
      'afternoon': 'दोपहर',
      'evening': 'शाम',
      'status_submitted': 'जमा किया गया',
      'status_under_review': 'समीक्षा में',
      'status_vet_assigned': 'डॉक्टर नियुक्त',
      'status_visit_scheduled': 'दौरा निर्धारित',
      'status_treatment_started': 'इलाज शुरू',
      'status_case_closed': 'केस बंद',

      // Profile
      'farmer_details': 'किसान विवरण',
      'farm_details': 'फार्म विवरण',
      'logout': 'लॉगआउट',
    },
  };
}

/// Helper extension for concise translation syntax in widgets.
extension LocalizationExt on BuildContext {
  String tr(String key, {Map<String, String>? params}) {
    String text = LocalizationService.instance.tr(key);
    if (params != null) {
      params.forEach((k, v) {
        text = text.replaceAll('{$k}', v);
      });
    }
    return text;
  }
}
