// Groq & Weather Advisory Service for Maharashtra Livestock Farmers
// Integrates Groq LLM API for dynamic veterinary intelligence and Open-Meteo for real-time weather & THI calculation.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Weather metric container including livestock comfort index (THI)
class DistrictWeatherData {
  final String district;
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double precipitation;
  final double windSpeed;
  final int weatherCode;
  final String conditionName;
  final String conditionMarathi;
  final String conditionHindi;
  final double thiIndex; // Temperature-Humidity Index for livestock
  final String thiCategory;
  final String thiCategoryMarathi;
  final String thiCategoryHindi;
  final String thiAdvice;
  final String thiAdviceMarathi;
  final String thiAdviceHindi;
  final DateTime timestamp;

  const DistrictWeatherData({
    required this.district,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.precipitation,
    required this.windSpeed,
    required this.weatherCode,
    required this.conditionName,
    required this.conditionMarathi,
    required this.conditionHindi,
    required this.thiIndex,
    required this.thiCategory,
    required this.thiCategoryMarathi,
    required this.thiCategoryHindi,
    required this.thiAdvice,
    required this.thiAdviceMarathi,
    required this.thiAdviceHindi,
    required this.timestamp,
  });

  /// Calculates Livestock THI (Temperature-Humidity Index):
  /// THI = (0.8 * T) + [(RH / 100) * (T - 14.4)] + 46.4
  /// Reference: National Dairy Research Institute (NDRI) & MAFSU standards
  static double calculateTHI(double tempC, int rhPercent) {
    final thi = (0.8 * tempC) + ((rhPercent / 100.0) * (tempC - 14.4)) + 46.4;
    return double.parse(thi.toStringAsFixed(1));
  }

  static (String, String, String, String, String, String) getTHICategory(double thi) {
    if (thi < 72.0) {
      return (
        'Comfortable (No Stress)',
        'सामान्य (तणाव नाही)',
        'सामान्य (तनाव नहीं)',
        'Livestock are in optimal thermal comfort. Normal milk yield and feed intake expected.',
        'पशू उत्तम आरामदायी स्थितीत आहेत. दुधाचे उत्पादन आणि चारा खाणे सामान्य राहील.',
        'पशु इष्टतम आराम की स्थिति में हैं। दूध उत्पादन और चारा खाना सामान्य रहेगा।',
      );
    } else if (thi < 78.0) {
      return (
        'Mild Stress',
        'सौम्य उष्णता ताण',
        'हल्का ताप तनाव',
        'Mild heat stress. Ensure continuous fresh drinking water and good barn ventilation.',
        'किंचित उष्णतेचा ताण. सतत ताजे पिण्याचे पाणी आणि गोठ्यात हवा खेळती राहील याची खात्री करा.',
        'हल्का गर्मी का तनाव। पीने का ताजा पानी और अच्छी हवा की व्यवस्था करें।',
      );
    } else if (thi < 88.0) {
      return (
        'Moderate Stress',
        'मध्यम उष्णता ताण',
        'मध्यम ताप तनाव',
        'Significant stress! Provide shade, foggers/sprinklers, feed during cooler morning/evening hours, and add electrolytes.',
        'महत्त्वपूर्ण ताण! सावली, फॉगर्स/स्प्रिंकलर्सची सोय करा. सकाळी/संध्याकाळी थंड वेळेत चारा द्या आणि पाण्यात इलेक्ट्रोलाइट्स मिसळा.',
        'भारी तनाव! छाया, फॉगर्स/स्प्रिंकलर की व्यवस्था करें। सुबह/शाम ठंडे समय में चारा दें और पानी में इलेक्ट्रोलाइट्स मिलाएं।',
      );
    } else {
      return (
        'Severe Heat Alert',
        'तीव्र उष्णता ताण (धोका)',
        'गंभीर ताप तनाव (खतरा)',
        'Severe danger of heat stroke and sharp drop in milk yield. Bathe cattle twice daily, use fans, avoid transit.',
        'उष्माघाताचा तीव्र धोका आणि दुधात मोठी घट होऊ शकते. जनावरांना दिवसातून दोनदा आंघोळ घाला, पंखे वापरा, प्रवास टाळा.',
        'हीट स्ट्रोक का गंभीर खतरा और दूध में भारी कमी। पशुओं को दिन में दो बार नहलाएं, पंखे चलाएं, यात्रा से बचें।',
      );
    }
  }

  static (String, String, String) decodeWeatherCode(int code) {
    switch (code) {
      case 0:
        return ('Clear Sky', 'निरभ्र आकाश', 'साफ आसमान');
      case 1:
      case 2:
      case 3:
        return ('Partly Cloudy', 'अंशतः ढगाळ', 'आंशिक रूप से बादल');
      case 45:
      case 48:
        return ('Foggy / Mist', 'धुके', 'कोहरा');
      case 51:
      case 53:
      case 55:
        return ('Drizzle', 'हलका पाऊस', 'बूंदाबांदी');
      case 61:
      case 63:
      case 65:
        return ('Rain', 'पाऊस', 'बारिश');
      case 71:
      case 73:
      case 75:
        return ('Snow / Hail', 'गारपीट', 'ओलावृष्टि');
      case 80:
      case 81:
      case 82:
        return ('Rain Showers', 'मुसळधार पाऊस', 'तेज बौछारें');
      case 95:
      case 96:
      case 99:
        return ('Thunderstorm', 'विजांसह वादळ', 'तूफान और बिजली');
      default:
        return ('Cloudy', 'ढगाळ वातावरण', 'बादल छाए रहेंगे');
    }
  }
}

/// Detailed livestock disease intelligence model for Maharashtra
class SeasonalDiseaseInfo {
  final String id;
  final String name;
  final String marathiName;
  final String hindiName;
  final String pathogenType; // Viral, Bacterial, Protozoan, Parasitic
  final List<String> affectedAnimals; // Cattle, Buffalo, Goat, Sheep, Poultry
  final String season; // Monsoon, Winter, Summer, All Seasons
  final String riskLevel; // Critical, High, Moderate
  final List<String> highRiskDistricts;
  final String transmissionTrigger;
  final List<String> symptoms;
  final List<String> preventiveActions;
  final String vaccinationInfo;
  final String emergencyFirstAid;

  const SeasonalDiseaseInfo({
    required this.id,
    required this.name,
    required this.marathiName,
    required this.hindiName,
    required this.pathogenType,
    required this.affectedAnimals,
    required this.season,
    required this.riskLevel,
    required this.highRiskDistricts,
    required this.transmissionTrigger,
    required this.symptoms,
    required this.preventiveActions,
    required this.vaccinationInfo,
    required this.emergencyFirstAid,
  });
}

/// District metadata for all 36 districts of Maharashtra
class MaharashtraDistrict {
  final String name;
  final String marathiName;
  final String hindiName;
  final String zone; // Konkan, Western Maharashtra, Marathwada, Vidarbha, Khandesh
  final double latitude;
  final double longitude;

  const MaharashtraDistrict({
    required this.name,
    required this.marathiName,
    required this.hindiName,
    required this.zone,
    required this.latitude,
    required this.longitude,
  });
}

class GroqWeatherService {
  static final GroqWeatherService instance = GroqWeatherService._internal();
  GroqWeatherService._internal();

  static const String groqApiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
  static const String groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  // Available models on this key in priority order
  static const List<String> availableModels = [
    'openai/gpt-oss-120b',
    'openai/gpt-oss-20b',
    'qwen/qwen3.8-27b',
  ];

  // All 36 Districts of Maharashtra with coordinates and agro-climatic zones
  static const List<MaharashtraDistrict> maharashtraDistricts = [
    // Western Maharashtra (Sugar Belt / High Dairy)
    MaharashtraDistrict(name: 'Pune', marathiName: 'पुणे', hindiName: 'पुणे', zone: 'Western Maharashtra', latitude: 18.5204, longitude: 73.8567),
    MaharashtraDistrict(name: 'Ahmednagar', marathiName: 'अहिल्यानगर (अहमदनगर)', hindiName: 'अहमदनगर', zone: 'Western Maharashtra', latitude: 19.0952, longitude: 74.7496),
    MaharashtraDistrict(name: 'Kolhapur', marathiName: 'कोल्हापूर', hindiName: 'कोल्हापुर', zone: 'Western Maharashtra', latitude: 16.7050, longitude: 74.2433),
    MaharashtraDistrict(name: 'Satara', marathiName: 'सातारा', hindiName: 'सतारा', zone: 'Western Maharashtra', latitude: 17.6805, longitude: 74.0183),
    MaharashtraDistrict(name: 'Sangli', marathiName: 'सांगली', hindiName: 'सांगली', zone: 'Western Maharashtra', latitude: 16.8524, longitude: 74.5815),
    MaharashtraDistrict(name: 'Solapur', marathiName: 'सोलापूर', hindiName: 'सोलापुर', zone: 'Western Maharashtra', latitude: 17.6599, longitude: 75.9064),

    // Khandesh / North Maharashtra
    MaharashtraDistrict(name: 'Nashik', marathiName: 'नाशिक', hindiName: 'नासिक', zone: 'North Maharashtra', latitude: 19.9975, longitude: 73.7898),
    MaharashtraDistrict(name: 'Jalgaon', marathiName: 'जळगाव', hindiName: 'जलगांव', zone: 'North Maharashtra', latitude: 21.0077, longitude: 75.5626),
    MaharashtraDistrict(name: 'Dhule', marathiName: 'धुळे', hindiName: 'धुले', zone: 'North Maharashtra', latitude: 20.9042, longitude: 74.7749),
    MaharashtraDistrict(name: 'Nandurbar', marathiName: 'नंदुरबार', hindiName: 'नंदुरबार', zone: 'North Maharashtra', latitude: 21.3703, longitude: 74.2407),

    // Marathwada
    MaharashtraDistrict(name: 'Chhatrapati Sambhajinagar', marathiName: 'छत्रपती संभाजीनगर (औरंगाबाद)', hindiName: 'छत्रपति संभाजीनगर', zone: 'Marathwada', latitude: 19.8762, longitude: 75.3433),
    MaharashtraDistrict(name: 'Jalna', marathiName: 'जालना', hindiName: 'जालना', zone: 'Marathwada', latitude: 19.8347, longitude: 75.8816),
    MaharashtraDistrict(name: 'Beed', marathiName: 'बीड', hindiName: 'बीड', zone: 'Marathwada', latitude: 18.9891, longitude: 75.7601),
    MaharashtraDistrict(name: 'Latur', marathiName: 'लातूर', hindiName: 'लातूर', zone: 'Marathwada', latitude: 18.4088, longitude: 76.5604),
    MaharashtraDistrict(name: 'Dharashiv', marathiName: 'धाराशिव (उस्मानाबाद)', hindiName: 'धाराशिव', zone: 'Marathwada', latitude: 18.1856, longitude: 76.0423),
    MaharashtraDistrict(name: 'Nanded', marathiName: 'नांदेड', hindiName: 'नांदेड़', zone: 'Marathwada', latitude: 19.1383, longitude: 77.3210),
    MaharashtraDistrict(name: 'Parbhani', marathiName: 'परभणी', hindiName: 'परभणी', zone: 'Marathwada', latitude: 19.2644, longitude: 76.7748),
    MaharashtraDistrict(name: 'Hingoli', marathiName: 'हिंगोली', hindiName: 'हिंगोली', zone: 'Marathwada', latitude: 19.7196, longitude: 77.1478),

    // Vidarbha
    MaharashtraDistrict(name: 'Nagpur', marathiName: 'नागपूर', hindiName: 'नागपुर', zone: 'Vidarbha', latitude: 21.1458, longitude: 79.0882),
    MaharashtraDistrict(name: 'Amravati', marathiName: 'अमरावती', hindiName: 'अमरावती', zone: 'Vidarbha', latitude: 20.9374, longitude: 77.7796),
    MaharashtraDistrict(name: 'Akola', marathiName: 'अकोला', hindiName: 'अकोला', zone: 'Vidarbha', latitude: 20.7002, longitude: 77.0082),
    MaharashtraDistrict(name: 'Yavatmal', marathiName: 'यवतमाळ', hindiName: 'यवतमाल', zone: 'Vidarbha', latitude: 20.3888, longitude: 78.1204),
    MaharashtraDistrict(name: 'Buldhana', marathiName: 'बुलढाणा', hindiName: 'बुलढाणा', zone: 'Vidarbha', latitude: 20.5312, longitude: 76.1843),
    MaharashtraDistrict(name: 'Washim', marathiName: 'वाशिम', hindiName: 'वाशिम', zone: 'Vidarbha', latitude: 20.1110, longitude: 77.1332),
    MaharashtraDistrict(name: 'Wardha', marathiName: 'वर्धा', hindiName: 'वर्धा', zone: 'Vidarbha', latitude: 20.7453, longitude: 78.6022),
    MaharashtraDistrict(name: 'Chandrapur', marathiName: 'चंद्रपूर', hindiName: 'चंद्रपुर', zone: 'Vidarbha', latitude: 19.9615, longitude: 79.2961),
    MaharashtraDistrict(name: 'Gadchiroli', marathiName: 'गडचिरोली', hindiName: 'गडचिरोली', zone: 'Vidarbha', latitude: 20.1804, longitude: 79.9934),
    MaharashtraDistrict(name: 'Bhandara', marathiName: 'भंडारा', hindiName: 'भंडारा', zone: 'Vidarbha', latitude: 21.1667, longitude: 79.6500),
    MaharashtraDistrict(name: 'Gondia', marathiName: 'गोंदिया', hindiName: 'गोंदिया', zone: 'Vidarbha', latitude: 21.4604, longitude: 80.1961),

    // Konkan & Coastal
    MaharashtraDistrict(name: 'Thane', marathiName: 'ठाणे', hindiName: 'ठाणे', zone: 'Konkan', latitude: 19.2183, longitude: 72.9781),
    MaharashtraDistrict(name: 'Palghar', marathiName: 'पालघर', hindiName: 'पालघर', zone: 'Konkan', latitude: 19.6967, longitude: 72.7699),
    MaharashtraDistrict(name: 'Raigad', marathiName: 'रायगड', hindiName: 'रायगढ़', zone: 'Konkan', latitude: 18.5158, longitude: 73.1812),
    MaharashtraDistrict(name: 'Ratnagiri', marathiName: 'रत्नागिरी', hindiName: 'रत्नागिरी', zone: 'Konkan', latitude: 16.9902, longitude: 73.3120),
    MaharashtraDistrict(name: 'Sindhudurg', marathiName: 'सिंधुदुर्ग', hindiName: 'सिंधुदुर्ग', zone: 'Konkan', latitude: 16.1157, longitude: 73.7125),
    MaharashtraDistrict(name: 'Mumbai City', marathiName: 'मुंबई शहर', hindiName: 'मुंबई', zone: 'Konkan', latitude: 18.9388, longitude: 72.8354),
    MaharashtraDistrict(name: 'Mumbai Suburban', marathiName: 'मुंबई उपनगर', hindiName: 'मुंबई उपनगर', zone: 'Konkan', latitude: 19.1136, longitude: 72.8697),
  ];

  /// Comprehensive repository of Maharashtra livestock diseases by season
  static const List<SeasonalDiseaseInfo> maharashtraDiseaseKnowledgeBase = [
    // ─────────────── MONSOON DISEASES (पावसाळा / खरीप) ───────────────
    SeasonalDiseaseInfo(
      id: 'hs_monsoon',
      name: 'Haemorrhagic Septicaemia (HS)',
      marathiName: 'घटसर्प (एच.एस.)',
      hindiName: 'गलघोंटू (एच.एस.)',
      pathogenType: 'Bacterial (Pasteurella multocida)',
      affectedAnimals: ['Cattle', 'Buffalo'],
      season: 'Monsoon',
      riskLevel: 'Critical',
      highRiskDistricts: ['Pune', 'Kolhapur', 'Satara', 'Ahmednagar', 'Sangli', 'Solapur', 'Nashik', 'Nagpur', 'Amravati', 'Nanded'],
      transmissionTrigger: 'Waterlogged pastures, high humidity (>75%), stress from cold rainwater ingestion and draft work in mud.',
      symptoms: [
        'Sudden high fever (106°F - 107°F / 41°C)',
        'Severe painful swelling around throat, neck, and brisket (गळ्याला मोठी सूज)',
        'Heavy frothy salivation and tongue protrusion (लाळ गळणे)',
        'Respiratory distress with loud snoring sounds (घरघर आवाज)',
        'Animal stops eating, death can occur within 12-24 hours if untreated',
      ],
      preventiveActions: [
        'Keep animals in clean, dry sheds with raised bedding away from damp mud.',
        'Never allow livestock to drink from stagnant puddles or muddy overflow water.',
        'Provide clean, dry fodder and avoid damp silage.',
        'Isolate sick animals immediately from the herd.',
      ],
      vaccinationInfo: 'HS Vaccine (Alum Precipitated or Oil Adjuvant) before monsoon onset (May-June). Booster annually.',
      emergencyFirstAid: 'Call veterinarian immediately for injectable antibiotics (Ceftiofur/Oxytetracycline) and anti-inflammatories. Keep animal propped up.',
    ),

    SeasonalDiseaseInfo(
      id: 'bq_monsoon',
      name: 'Black Quarter (BQ)',
      marathiName: 'फऱ्या (ब्लॅक क्वार्टर)',
      hindiName: 'लंगड़ा बुखार / फऱ्या',
      pathogenType: 'Bacterial (Clostridium chauvoei spores)',
      affectedAnimals: ['Cattle', 'Buffalo', 'Sheep'],
      season: 'Monsoon',
      riskLevel: 'Critical',
      highRiskDistricts: ['Pune', 'Ahmednagar', 'Solapur', 'Beed', 'Chhatrapati Sambhajinagar', 'Jalna', 'Latur', 'Yavatmal', 'Chandrapur'],
      transmissionTrigger: 'Dormant bacterial soil spores stirred up by initial heavy monsoon showers and ingested with grass roots.',
      symptoms: [
        'Sudden acute lameness / limping in hind or forequarters (लंगडणे)',
        'Hot, painful swelling on heavy muscles (thigh, shoulder)',
        'Crepitation / crackling paper sound (चरचर आवाज) on pressing the swollen thigh due to gas formation',
        'High body temperature, depression, refusal to stand',
        'Swelling turns cold and painless before rapid mortality',
      ],
      preventiveActions: [
        'Avoid grazing young cattle (6 months to 2 years) in water-logged pastures where BQ was reported previously.',
        'Never open carcasses of dead BQ animals — bury deep with lime (चुन्यासह खोल पुरणे).',
        'Quarantine affected areas immediately.',
      ],
      vaccinationInfo: 'BQ Vaccine or Combined HS+BQ Vaccine annually before monsoon (May). Very effective.',
      emergencyFirstAid: 'Immediate high-dose Penicillin injection by vet in early stages. Keep animal comfortable on dry straw.',
    ),

    SeasonalDiseaseInfo(
      id: 'fmd_monsoon_winter',
      name: 'Foot and Mouth Disease (FMD)',
      marathiName: 'लाळ-खुरकूत (एफ.एम.डी.)',
      hindiName: 'खुरपका-मुंहपका रोग',
      pathogenType: 'Viral (Aphthovirus Type O, A, Asia-1)',
      affectedAnimals: ['Cattle', 'Buffalo', 'Goat', 'Sheep', 'Pig'],
      season: 'Monsoon & Winter',
      riskLevel: 'High',
      highRiskDistricts: ['Pune', 'Kolhapur', 'Ahmednagar', 'Nashik', 'Sangli', 'Satara', 'Nagpur', 'Amravati', 'Latur', 'Jalgaon'],
      transmissionTrigger: 'Aerosol droplet spread, contaminated feed/water, transit of animals during agricultural markets in wet and cold weather.',
      symptoms: [
        'Profuse, continuous ropy salivation (तारेसारखी लाळ गळणे)',
        'Painful blisters and ulcers on tongue, gums, lips, and inside mouth (तोंडातील फोड)',
        'Blisters between hooves (खुरांमधील जखमा), causing severe limping and inability to walk',
        'Sudden dramatic drop in milk production (दुधात मोठी घट)',
        'High fever, abortion in pregnant cows',
      ],
      preventiveActions: [
        'Restrict livestock movement and entry of strange cattle into the farm.',
        'Disinfect shed floors and entrance footbaths with 4% Sodium Carbonate (धुण्याचा सोडा) or 1:1000 Potassium Permanganate (पोटॅशियम परमँगनेट).',
        'Provide soft, easily digestible gruel (कडबा किंवा दलिया).',
      ],
      vaccinationInfo: 'FMD Trivalent Vaccine twice a year (every 6 months under National Animal Disease Control Program - NADCP).',
      emergencyFirstAid: 'Wash mouth with 1% Alum (तुरटीचे पाणी) or KMNO4 solution. Apply Boroglycerine in mouth. Apply Antiseptic fly-repellent ointment (Himax/Charmil) on hooves.',
    ),

    SeasonalDiseaseInfo(
      id: 'theileriosis_monsoon',
      name: 'Bovine Theileriosis (Tick Fever)',
      marathiName: 'थायलेरियासिस (गोचीड ताप)',
      hindiName: 'थायलेरियासिस (चीचड़ी बुखार)',
      pathogenType: 'Protozoan (Theileria annulata via Hyalomma Ticks)',
      affectedAnimals: ['Cattle (HF / Jersey crossbreds)'],
      season: 'Monsoon & Summer',
      riskLevel: 'High',
      highRiskDistricts: ['Pune', 'Kolhapur', 'Ahmednagar', 'Satara', 'Sangli', 'Nashik', 'Jalgaon', 'Thane'],
      transmissionTrigger: 'Explosion of hard tick (Hyalomma) populations in humid cracks of cattle sheds during monsoon and warm humid spells.',
      symptoms: [
        'Persistent high fever (104°F - 106°F)',
        'Prominent swelling of superficial lymph nodes in front of shoulder (खांद्यापुढील गाठी सुजणे)',
        'Severe anaemia, pale/yellowish gums and eyes (डोळे पांढरे/पिवळे पडणे)',
        'Laboured breathing, rapid weight loss, drop in milk yield',
      ],
      preventiveActions: [
        'Regular spraying of acaricide/tick spray (Deltamethrin/Flumethrin/Amitraz) on animals and shed walls/cracks.',
        'Flame gun treatment on concrete shed cracks to kill tick eggs.',
        'Keep shed free of wooden cracks and dry cow dung cakes.',
      ],
      vaccinationInfo: 'Raksha-Vac T / Theileriosis Cell Culture Vaccine for crossbred calves above 2 months of age.',
      emergencyFirstAid: 'Urgent Buparvaquone injection (Zubion/Butalex) with hematinics and liver tonic by licensed vet.',
    ),

    SeasonalDiseaseInfo(
      id: 'ppr_monsoon_winter',
      name: 'Peste des Petits Ruminants (PPR / Goat Plague)',
      marathiName: 'शेळ्या-मेंढ्यांमधील पी.पी.आर. (शेळी प्लेग / महामारी)',
      hindiName: 'पीपीआर / बकरी प्लेग',
      pathogenType: 'Viral (Morbillivirus)',
      affectedAnimals: ['Goat', 'Sheep'],
      season: 'Monsoon & Winter',
      riskLevel: 'Critical',
      highRiskDistricts: ['Ahmednagar', 'Solapur', 'Beed', 'Osmanabad (Dharashiv)', 'Latur', 'Jalna', 'Nashik', 'Yavatmal', 'Buldhana'],
      transmissionTrigger: 'Close grouping of sheep/goats during rain shelter, transit, cold damp nights and grazing damp forage.',
      symptoms: [
        'High fever, dullness, shivering',
        'Severe necrotic ulcers in mouth with foul odor (तोंडात व्रण आणि दुर्गंधी)',
        'Watery to thick mucus nasal discharge, crusty eyes (नाकातून व डोळ्यातून घाण)',
        'Profuse, foul-smelling severe diarrhea causing extreme dehydration (तीव्र हगवण)',
        'Pneumonia with heavy coughing and rapid mortality (up to 80% in kids)',
      ],
      preventiveActions: [
        'Quarantine new goats for 21 days before mixing with local flock.',
        'Keep goat sheds dry, elevated, and well-aerated with good curtain protection against cold night winds.',
        'Provide warm electrolyte water and ORS.',
      ],
      vaccinationInfo: 'Live attenuated PPR Vaccine (Raksha-PPR / Sungri 96) once in 3 years for all goats above 3 months.',
      emergencyFirstAid: 'Supportive antibiotics to stop secondary pneumonia, electrolyte rehydration, antidiarrheal bolus, multivitamin injections.',
    ),

    // ─────────────── WINTER DISEASES (हिवाळा / रब्बी) ───────────────
    SeasonalDiseaseInfo(
      id: 'pneumonia_winter',
      name: 'Bovine Respiratory Disease (Pneumonia)',
      marathiName: 'न्यूमोनिया (फुफ्फुसाचा संसर्ग / सर्दी-खोकला)',
      hindiName: 'निमोनिया / फेफड़ों का संक्रमण',
      pathogenType: 'Mixed Viral & Bacterial',
      affectedAnimals: ['Cattle', 'Buffalo', 'Goat', 'Sheep'],
      season: 'Winter',
      riskLevel: 'High',
      highRiskDistricts: ['Pune', 'Nashik', 'Nagpur', 'Amravati', 'Kolhapur', 'Satara', 'Ahmednagar', 'Bhandara', 'Gondia'],
      transmissionTrigger: 'Sudden drop in night temperatures (below 10-15°C), cold drafts in sheds, poor ventilation causing ammonia gas buildup.',
      symptoms: [
        'Frequent coughing and wheezing (खोकला व घरघर)',
        'Thick yellowish-green nasal discharge (नाकातून घट्ट शेंबूड)',
        'High temperature (103°F - 105°F)',
        'Rapid, shallow breathing with flared nostrils',
        'Calves and young kids curl up and stop nursing',
      ],
      preventiveActions: [
        'Cover barn sides with gunny bags or tarpaulin at night to block direct cold wind drafts, keeping top vents open.',
        'Provide thick dry paddy straw bedding for newborn calves and kids.',
        'Keep shed dry to avoid ammonia fume accumulation.',
      ],
      vaccinationInfo: 'Ensure early colostrum feeding in newborn calves within 2 hours of birth for maternal immunity.',
      emergencyFirstAid: 'Administer broad-spectrum antibiotics (Enrofloxacin/Ceftiofur) and Meloxicam with respiratory decongestants via veterinarian.',
    ),

    SeasonalDiseaseInfo(
      id: 'enterotoxemia_winter',
      name: 'Enterotoxemia (Pulpy Kidney Disease)',
      marathiName: 'फिडक्या / विषबाधा (एंटेरोटॉक्सेमिया)',
      hindiName: 'फिड़किया रोग',
      pathogenType: 'Bacterial (Clostridium perfringens Type D)',
      affectedAnimals: ['Goat', 'Sheep'],
      season: 'Winter',
      riskLevel: 'High',
      highRiskDistricts: ['Solapur', 'Ahmednagar', 'Sangli', 'Beed', 'Dharashiv', 'Latur', 'Jalna', 'Parbhani', 'Nashik'],
      transmissionTrigger: 'Overfeeding on lush green cereal crops (wheat/gram/legume pasture) or high carbohydrate grain flush in winter.',
      symptoms: [
        'Sudden convulsions, throwing head backwards (मान मागे वळवणे)',
        'Frothing at the mouth and grinding of teeth',
        'Severe abdominal pain, jumping/kicking at belly',
        'Greenish watery diarrhea with mucus in subacute cases',
        'Fastest growing, healthiest lambs/kids die suddenly without prior illness',
      ],
      preventiveActions: [
        'Gradual transition from dry fodder to lush green winter pastures over 7-10 days.',
        'Avoid sudden excessive grain feeding.',
        'Deworm flock with broad spectrum anthelmintic (Albendazole/Ivermectin) before season.',
      ],
      vaccinationInfo: 'Enterotoxemia (ET) Vaccine annually in sheep & goats (October-November before winter flush).',
      emergencyFirstAid: 'Immediate Enterotoxemia antiserum in early stage, activated charcoal drench, gentle alkalinizing agents.',
    ),

    SeasonalDiseaseInfo(
      id: 'goat_sheep_pox_winter',
      name: 'Sheep Pox and Goat Pox',
      marathiName: 'शेळी व मेंढी देवी (गोचीड देवी)',
      hindiName: 'बकरी और भेड़ चेचक (माता रोग)',
      pathogenType: 'Viral (Capripoxvirus)',
      affectedAnimals: ['Goat', 'Sheep'],
      season: 'Winter',
      riskLevel: 'Moderate',
      highRiskDistricts: ['Ahmednagar', 'Solapur', 'Nashik', 'Pune', 'Beed', 'Amravati', 'Yavatmal', 'Buldhana'],
      transmissionTrigger: 'Contact spread via dry scabs and aerosol transmission during cold winter dry spells and night crowding.',
      symptoms: [
        'Round red spots turning into painful nodules and scabs on lips, nostrils, ears, udder, and hairless body areas (अंगावर देवीचे फोड)',
        'High fever (104°F - 106°F)',
        'Swollen eyelids with discharge',
        'Secondary bacterial infection and maggots in broken scabs',
      ],
      preventiveActions: [
        'Isolate infected animals immediately.',
        'Apply antiseptic ointments on pox scabs to prevent flies.',
        'Burn or disinfect fallen scabs in shed.',
      ],
      vaccinationInfo: 'Goat Pox / Sheep Pox Vaccine annually in October before winter onset.',
      emergencyFirstAid: 'Apply Neem decoction wash or Povidone Iodine on lesions. Provide soft green fodder and vitamin A+E supplements.',
    ),

    // ─────────────── SUMMER DISEASES (उन्हाळा / उन्हाळी ताण) ───────────────
    SeasonalDiseaseInfo(
      id: 'heat_stress_summer',
      name: 'Severe Heat Stress & Heat Stroke',
      marathiName: 'उष्माघात व उन्हाळी ताण (हीट स्ट्रोक)',
      hindiName: 'लू लगना / हीट स्ट्रोक और दूध में गिरावट',
      pathogenType: 'Environmental & Physiological (Hyperthermia)',
      affectedAnimals: ['Cattle (HF / Jersey)', 'Buffalo', 'Poultry'],
      season: 'Summer',
      riskLevel: 'Critical',
      highRiskDistricts: ['Nagpur', 'Chandrapur', 'Akola', 'Amravati', 'Wardha', 'Solapur', 'Jalgaon', 'Yavatmal', 'Latur', 'Nanded'],
      transmissionTrigger: 'Extreme ambient temperature (>40°C - 47°C in Vidarbha/Marathwada), direct solar radiation, lack of shaded shelters.',
      symptoms: [
        'Excessive open-mouth panting with tongue hanging out (तोंड उघडे ठेवून धाप लागणे)',
        'Heavy drooling and elevated body temperature (>105°F without infection)',
        'Sharp decline in milk production (30-50% milk drop / दूध घटणे)',
        'Reduced feed intake and excessive continuous water drinking',
        'Staggering gait, collapse, and heat coma in severe cases',
      ],
      preventiveActions: [
        'Install shade nets (75% green agro-net), ceiling fans, and mist/fogger systems in dairy sheds.',
        'Bathe buffaloes and crossbred cows 2-3 times daily during peak afternoon hours (11 AM - 3 PM).',
        'Offer cool, clean drinking water 24/7 (cows drink up to 100-150 liters/day in summer).',
        'Shift feeding time to cool early morning (5-7 AM) and late evening (7-9 PM).',
        'Add dietary mineral mixture, yeast culture, and baking soda (Sodium bicarbonate 50g/cow/day).',
      ],
      vaccinationInfo: 'Ensure all pre-summer deworming and vaccination completed by February.',
      emergencyFirstAid: 'Immediately move animal to cool shade. Pour cold water continuously on head and neck. Offer cold electrolyte water. Vet will give IV cold saline and antioxidants.',
    ),

    SeasonalDiseaseInfo(
      id: 'babesiosis_summer',
      name: 'Babesiosis (Red Water Disease)',
      marathiName: 'बाबेसिएसिस (लाल लघवीचा आजार / रक्तमूत)',
      hindiName: 'बबेसिओसिस (लाल पेशाब की बीमारी)',
      pathogenType: 'Protozoan (Babesia bigemina via Rhipicephalus Boophilus ticks)',
      affectedAnimals: ['Cattle', 'Buffalo'],
      season: 'Summer',
      riskLevel: 'High',
      highRiskDistricts: ['Pune', 'Kolhapur', 'Ahmednagar', 'Satara', 'Nashik', 'Sangli', 'Solapur', 'Nagpur', 'Amravati'],
      transmissionTrigger: 'Rhipicephalus microplus tick bites transmitting hemoprotozoan parasites that destroy red blood cells in hot weather.',
      symptoms: [
        'Dark red or coffee-coloured urine (गडद लाल रंगाची लघवी)',
        'Very high temperature (105°F - 107°F)',
        'Severe anaemia, pale/jaundiced yellowish mucous membranes',
        'Rapid heartbeat and marked weakness',
        'Rapid death if untreated within 24-48 hours',
      ],
      preventiveActions: [
        'Strict tick control program using Amitraz/Deltamethrin pour-on solutions.',
        'Keep cowshed cracks sealed with cement.',
        'Avoid grazing in tick-infested pastures during peak summer.',
      ],
      vaccinationInfo: 'Tick management is primary prevention. Regular veterinary herd screening.',
      emergencyFirstAid: 'Immediate Diminazene Aceturate (Berenil) or Imidocarb Dipropionate injection strictly by licensed veterinarian, followed by iron and liver supplements.',
    ),

    SeasonalDiseaseInfo(
      id: 'mastitis_all_season',
      name: 'Bovine Mastitis',
      marathiName: 'मस्टायटिस (स्तनदाह / कासदाह)',
      hindiName: 'थनैला रोग',
      pathogenType: 'Bacterial (Staphylococcus, Streptococcus, E. coli)',
      affectedAnimals: ['Cattle', 'Buffalo'],
      season: 'All Seasons (Monsoon & Summer Peak)',
      riskLevel: 'High',
      highRiskDistricts: ['Pune', 'Kolhapur', 'Ahmednagar', 'Satara', 'Sangli', 'Nashik', 'Solapur', 'Jalgaon'],
      transmissionTrigger: 'Dirty muddy barn floor, milking with unwashed hands, fly nuisance, incomplete milking, udder trauma.',
      symptoms: [
        'Hot, swollen, hard and painful udder quarter (कास सुजणे व कडक होणे)',
        'Abnormal milk: watery, bloody, yellowish flakes or clots (दुधात गाठी / रक्त / पातळ पाणी)',
        'Cow kicks or refuses to allow milking due to severe tenderness',
        'Permanent loss of milk quarter if neglected',
      ],
      preventiveActions: [
        'Practice pre-milking and post-milking teat dip with 0.5% Povidone-Iodine solution.',
        'Clean udder with warm water and wipe dry with a single-use clean cloth.',
        'Do not let cows sit down on floor for 30 minutes after milking (feed them green fodder immediately).',
      ],
      vaccinationInfo: 'Maintain good milking hygiene and California Mastitis Test (CMT) monthly screening.',
      emergencyFirstAid: 'Frequent complete strip milking every 2 hours. Intramammary antibiotic infusions and anti-inflammatories under veterinary guidance.',
    ),
  ];

  /// Find district object by name
  MaharashtraDistrict getDistrict(String districtName) {
    final clean = districtName.trim().toLowerCase();
    for (final d in maharashtraDistricts) {
      if (d.name.toLowerCase() == clean ||
          d.marathiName.toLowerCase().contains(clean) ||
          d.hindiName.toLowerCase() == clean ||
          clean.contains(d.name.toLowerCase())) {
        return d;
      }
    }
    // Default to Pune
    return maharashtraDistricts[0];
  }

  /// Determines current season in Maharashtra based on calendar month
  static String getCurrentMaharashtraSeason() {
    final month = DateTime.now().month;
    if (month >= 6 && month <= 9) {
      return 'Monsoon'; // पावसाळा (June - Sept)
    } else if (month >= 10 || month <= 2) {
      return 'Winter'; // हिवाळा (Oct - Feb)
    } else {
      return 'Summer'; // उन्हाळा (March - May)
    }
  }

  static String getSeasonLocalized(String season, String languageCode) {
    switch (season.toLowerCase()) {
      case 'monsoon':
        if (languageCode == 'mr') return 'पावसाळा (खरीप)';
        if (languageCode == 'hi') return 'मानसून (खरीफ)';
        return 'Monsoon (Kharif)';
      case 'winter':
        if (languageCode == 'mr') return 'हिवाळा (रब्बी)';
        if (languageCode == 'hi') return 'सर्दी / शीत ऋतु (रबी)';
        return 'Winter (Rabi)';
      case 'summer':
        if (languageCode == 'mr') return 'उन्हाळा (उष्णता काळ)';
        if (languageCode == 'hi') return 'गर्मी (ग्रीष्म ऋतु)';
        return 'Summer (Zaid)';
      default:
        if (languageCode == 'mr') return 'सर्व ऋतू';
        if (languageCode == 'hi') return 'सभी मौसम';
        return 'All Seasons';
    }
  }

  /// Get relevant seasonal diseases for a specific Maharashtra district & season
  List<SeasonalDiseaseInfo> getSeasonalDiseases({
    required String districtName,
    required String season,
  }) {
    return maharashtraDiseaseKnowledgeBase.where((d) {
      final matchesSeason = d.season.toLowerCase().contains(season.toLowerCase()) || d.season == 'All Seasons';
      return matchesSeason;
    }).toList();
  }

  /// Fetch live weather from Open-Meteo for the specified Maharashtra district
  Future<DistrictWeatherData> fetchDistrictWeather(String districtName, {double? lat, double? lon}) async {
    final district = getDistrict(districtName);
    final targetLat = lat ?? district.latitude;
    final targetLon = lon ?? district.longitude;

    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?'
        'latitude=$targetLat&longitude=$targetLon'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m'
        '&timezone=Asia%2FKolkata',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 7));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current'] as Map<String, dynamic>;

        final temp = (current['temperature_2m'] as num).toDouble();
        final apparentTemp = (current['apparent_temperature'] as num).toDouble();
        final humidity = (current['relative_humidity_2m'] as num).toInt();
        final precip = (current['precipitation'] as num).toDouble();
        final wind = (current['wind_speed_10m'] as num).toDouble();
        final weatherCode = (current['weather_code'] as num).toInt();

        final (condEn, condMr, condHi) = DistrictWeatherData.decodeWeatherCode(weatherCode);
        final thi = DistrictWeatherData.calculateTHI(temp, humidity);
        final (thiCatEn, thiCatMr, thiCatHi, thiAdvEn, thiAdvMr, thiAdvHi) = DistrictWeatherData.getTHICategory(thi);

        return DistrictWeatherData(
          district: district.name,
          temperature: temp,
          apparentTemperature: apparentTemp,
          humidity: humidity,
          precipitation: precip,
          windSpeed: wind,
          weatherCode: weatherCode,
          conditionName: condEn,
          conditionMarathi: condMr,
          conditionHindi: condHi,
          thiIndex: thi,
          thiCategory: thiCatEn,
          thiCategoryMarathi: thiCatMr,
          thiCategoryHindi: thiCatHi,
          thiAdvice: thiAdvEn,
          thiAdviceMarathi: thiAdvMr,
          thiAdviceHindi: thiAdvHi,
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Error fetching live weather from Open-Meteo: $e. Using local climate fallback.');
    }

    // Fallback climate data tailored to Maharashtra seasons
    final month = DateTime.now().month;
    double defaultTemp = 28.0;
    int defaultRh = 70;
    if (month >= 6 && month <= 9) {
      defaultTemp = 26.5;
      defaultRh = 80;
    } else if (month >= 10 || month <= 2) {
      defaultTemp = 22.0;
      defaultRh = 55;
    } else {
      defaultTemp = 36.0;
      defaultRh = 40;
    }

    final thi = DistrictWeatherData.calculateTHI(defaultTemp, defaultRh);
    final (thiCatEn, thiCatMr, thiCatHi, thiAdvEn, thiAdvMr, thiAdvHi) = DistrictWeatherData.getTHICategory(thi);

    return DistrictWeatherData(
      district: district.name,
      temperature: defaultTemp,
      apparentTemperature: defaultTemp + 2,
      humidity: defaultRh,
      precipitation: 0.0,
      windSpeed: 8.5,
      weatherCode: 2,
      conditionName: 'Partly Cloudy',
      conditionMarathi: 'अंशतः ढगाळ',
      conditionHindi: 'आंशिक रूप से बादल',
      thiIndex: thi,
      thiCategory: thiCatEn,
      thiCategoryMarathi: thiCatMr,
      thiCategoryHindi: thiCatHi,
      thiAdvice: thiAdvEn,
      thiAdviceMarathi: thiAdvMr,
      thiAdviceHindi: thiAdvHi,
      timestamp: DateTime.now(),
    );
  }

  /// Calls Groq LLM API with the provided user key to generate dynamic veterinary insights
  Future<String> fetchGroqAdvisory({
    required String districtName,
    required DistrictWeatherData weather,
    required String season,
    String? livestockType,
    String? customQuestion,
    String language = 'en',
  }) async {
    final district = getDistrict(districtName);

    String langInstruction = 'English';
    if (language == 'mr') {
      langInstruction = 'Marathi (मराठी). Write completely in Marathi using Devanagari script. Use simple words that an ordinary Maharashtra farmer can understand.';
    } else if (language == 'hi') {
      langInstruction = 'Hindi (हिन्दी). Write completely in Hindi using Devanagari script. Use simple everyday Hindi words that any farmer can understand.';
    }

    final systemPrompt = '''
You are a friendly village veterinary doctor helping small and medium livestock farmers in Maharashtra.
Write in a very simple, clear, and easy-to-understand language — like you are talking to a farmer in person.
DO NOT use complex medical tables, technical English disease codes, or difficult jargon.
Use short sentences. Use simple local words. Use emojis to make it friendly.
Always respond fully in $langInstruction — do NOT mix languages.
Keep the total response under 400 words.

Cover these 4 simple points:
1. 🌡️ Weather today — how it affects animals (1-2 lines)
2. ⚠️ 3-4 diseases to watch out for this season (one line each, simple name + simple symptom)
3. ✅ 4-5 simple things the farmer should do TODAY
4. 🚨 Warning signs — when to call the vet immediately
''';

    final userPrompt = customQuestion != null && customQuestion.trim().isNotEmpty
        ? '''
Location: ${district.name} district, Maharashtra
Weather now: ${weather.temperature}°C, ${weather.humidity}% humidity, ${weather.conditionName}
Season: $season
Animals: ${livestockType ?? 'Cows, Buffaloes, Goats, Sheep'}

Farmer's question: "$customQuestion"

Answer in simple $langInstruction as if explaining to a farmer face-to-face. Keep it short and practical.
'''
        : '''
Give simple livestock health advice for:
- Place: ${district.name}, Maharashtra (${district.zone} region)
- Weather: ${weather.temperature}°C, ${weather.humidity}% humidity, rain: ${weather.precipitation}mm
- Heat stress level (THI): ${weather.thiIndex} — ${weather.thiCategory}
- Season: $season
- Animals on farm: ${livestockType ?? 'Cows, Buffaloes, Goats, Sheep, Poultry'}

Write in simple $langInstruction. Short sentences. Easy words. Practical tips only.
''';

    for (final model in availableModels) {
      try {
        final response = await http.post(
          Uri.parse(groqApiUrl),
          headers: {
            'Authorization': 'Bearer $groqApiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {'role': 'user', 'content': '$systemPrompt\n\n$userPrompt'},
            ],
            'temperature': 0.5,
            'max_tokens': 1100,
          }),
        ).timeout(const Duration(seconds: 14));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final content = data['choices']?[0]?['message']?['content'] as String?;
          if (content != null && content.isNotEmpty) {
            return content.trim();
          }
        } else {
          debugPrint('Groq API error on model $model: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        debugPrint('Groq request failed on model $model: $e');
      }
    }

    // Fallback response if offline or API limit
    return _generateLocalAdvisoryFallback(district, weather, season, language);
  }

  String _generateLocalAdvisoryFallback(
    MaharashtraDistrict district,
    DistrictWeatherData weather,
    String season,
    String language,
  ) {
    if (language == 'mr') {
      return '''
### 🌦️ ${district.marathiName} जिल्हा हवामान व पशुआरोग्य सल्लागार

**१. सद्य हवामान व पशु ताण निर्देशांक (THI):**
- तापमान: ${weather.temperature}°C | आर्द्रता: ${weather.humidity}% | THI: ${weather.thiIndex} (${weather.thiCategoryMarathi})
- ${weather.thiAdvice}

**२. ${district.marathiName} जिल्ह्यात $season ऋतूत पसरू शकणारे मुख्य आजार:**
- **घटसर्प (HS) व फऱ्या (BQ):** पावसाळ्यात साचलेल्या पाण्याच्या संपर्कामुळे आणि गवतातील जिवाणूंमुळे पसरतो.
- **लाळ-खुरकूत (FMD):** थंड आणि दमट हवेत वेगाने पसरणारा विषाणूजन्य आजार.
- **गोचीड ताप (थायलेरियासिस):** संकरित जनावरांमध्ये गोचीड चावल्याने उच्च ताप व ॲनिमिया होतो.
- **शेळ्या-मेंढ्यांचा पी.पी.आर. (PPR):** तोंडात व्रण व अतिसाराचा धोका.

**३. तातडीने करायच्या उपाययोजना:**
1. गोठा कोरडा, स्वच्छ आणि हवेशीर ठेवावा. जनावरांना चिखलात उभे राहू देऊ नका.
2. पिण्यासाठी स्वच्छ व शुद्ध पाण्याचा वापर करा.
3. लाळ-खुरकूत व घटसर्प लस पशुवैद्यकीय दवाखान्यातून वेळेवर टोचून घ्यावी.
4. संकरित गायींना गोचीड प्रतिबंधक औषधांची फवारणी करावी.

📞 *तातडीच्या मदतीसाठी स्थानिक पशुवैद्यकीय दवाखाना अथवा १९६२ टोल फ्री हेल्पलाईनशी संपर्क साधा.*
''';
    } else if (language == 'hi') {
      return '''
### 🌦️ ${district.hindiName} जिला मौसम एवं पशु स्वास्थ्य सलाह

**१. वर्तमान मौसम एवं पशु आराम सूचकांक (THI):**
- तापमान: ${weather.temperature}°C | आर्द्रता: ${weather.humidity}% | THI: ${weather.thiIndex}
- ${weather.thiAdvice}

**२. $season मौसम में ${district.hindiName} में फैलने वाली प्रमुख बीमारियां:**
- **गलघोंटू (HS) एवं लंगड़ा बुखार (BQ):** बारिश और नमी के मौसम में तेजी से फैलने वाले जीवाणु रोग।
- **खुरपका-मुंहपका (FMD):** मुंह और खुरों में छाले पैदा करने वाला संक्रामक रोग।
- **चीचड़ी बुखार (Theileriosis):** संकर गायों में चीचड़ों के काटने से तेज बुखार।
- **पीपीआर (PPR):** बकरियों और भेड़ों में दस्त और बुखार की महामारी।

**३. आवश्यक सावधानियां:**
1. पशुशाला को सूखा और हवादार रखें।
2. पशुओं को दूषित पानी पीने से बचाएं।
3. समय पर टीकाकरण (HS, BQ, FMD) अवश्य कराएं।

📞 *आपातकालीन स्थिति में निकटतम पशु चिकित्सा अधिकारी से संपर्क करें।*
''';
    }

    return '''
### 🌦️ ${district.name} District Livestock Weather & Disease Advisory

**1. Current Climate & Animal Comfort Index (THI):**
- Temperature: ${weather.temperature}°C | Humidity: ${weather.humidity}% | THI: ${weather.thiIndex} (${weather.thiCategory})
- ${weather.thiAdvice}

**2. High-Risk Seasonal Diseases in ${district.name} ($season Season):**
- **Haemorrhagic Septicaemia (HS) & Black Quarter (BQ):** High bacterial risk in wet pastures and humid conditions.
- **Foot and Mouth Disease (FMD):** Spreads rapidly via aerosols and animal movement.
- **Bovine Theileriosis (Tick Fever):** Threatens crossbred cattle with tick infestation.
- **PPR (Goat Plague) & Enterotoxemia:** Critical risk for sheep and goat flocks.

**3. Actionable Farm Management Steps:**
1. Keep sheds dry, elevated, and well-bedded to prevent foot rot and ammonia buildup.
2. Provide clean drinking water; avoid stagnant floodwater.
3. Complete mandatory FMD, HS, and BQ vaccinations at the nearest veterinary dispensary.
4. Apply approved tick control sprays (Amitraz/Deltamethrin) on animals and shed walls.

📞 *For veterinary emergencies, contact your local government veterinary dispensary or dial 1962.*
''';
  }
}
