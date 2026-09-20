import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/services/localization_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Multilingual Localization Coverage Tests', () {
    late LocalizationService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = LocalizationService.instance;
    });

    test('English dictionary & translation helpers', () async {
      await service.setLanguage(AppLanguage.english);

      expect(service.tr('animal'), 'Animal');
      expect(service.tr('submitted'), 'SUBMITTED');
      expect(service.tr('case_id'), 'Case ID');
      expect(service.tr('enter_full_name'), 'Please enter your full name.');
      expect(service.translateSpecies('Cow'), 'Cow');
      expect(service.translateBreed('Jersey'), 'Jersey');
      expect(service.translateText('Reduced Milk Yield, Swollen Udder'), 'Reduced Milk Yield, Swollen Udder');
      expect(service.translateText('1 animal(s) affected'), '1 animal(s) affected');
    });

    test('Hindi dictionary & dynamic phrase translations', () async {
      await service.setLanguage(AppLanguage.hindi);

      expect(service.tr('animal'), 'पशु');
      expect(service.tr('submitted'), 'जमा किया गया');
      expect(service.tr('case_id'), 'केस आईडी');
      expect(service.tr('enter_full_name'), 'कृपया अपना पूरा नाम दर्ज करें।');
      expect(service.translateSpecies('Cow'), 'गाय');
      expect(service.translateBreed('Jersey'), 'जर्सी');
      expect(service.translateText('Acres'), 'एकड़');
      expect(service.translateText('Reduced Milk Yield, Swollen Udder'), 'दूध उत्पादन कम होना, थन में सूजन');
      expect(service.translateText('1 animal(s) affected'), '1 पशु प्रभावित');
      expect(service.translateText('MEDIUM Risk'), 'मध्यम जोखिम');
      expect(service.translateText('Sanjay Kumar'), 'संजय कुमार');
      expect(service.translateText('Green Meadows Farm'), 'ग्रीन मीडोज फार्म');
      expect(service.translateBreed('Holstein Friesian (HF)'), 'होलस्टीन फ्रीजियन');
      expect(service.translateTag('C001'), 'सी००१');
      expect(service.translateTag('C002'), 'सी००२');
      expect(service.translateTag('G001'), 'जी००१');
      expect(service.translateText('Sanjay'), 'संजय');
      expect(service.translateText('Suresh Mane'), 'सुरेश माने');
      expect(service.translateText('Lakshmi Devi'), 'लक्ष्मी देवी');
      expect(service.translateText('Loni Kalbhor'), 'लोणी काळभोर');
      expect(service.translateText('Uruli Kanchan, Haveli, Pune'), 'उरुली कांचन, हवेली, पुणे');
      expect(service.translateTag('SMP001'), 'एसएमपी००१');
      expect(service.translateText('New High-Risk Case: Cow C010 (Loni Kalbhor)'), 'नया उच्च-जोखिम मामला: गाय सी०१० (लोणी काळभोर)');
      expect(service.translateText('🚨 CRITICAL: 4 Buffaloes Affected (Manjari Khurd)'), '🚨 गंभीर: ४ भैंसें प्रभावित (मांजरी खुर्द)');
      expect(service.translateText('Inj. Oxytetracycline 15ml IM, Inj. Meloxicam 10ml IM, Antiseptic foot spray applied'), 'इंजेक्शन ऑक्सीटेट्रासाइक्लिन १५ मिली IM, इंजेक्शन मेलोक्सिकैम १० मिली IM, एंटीसेप्टिक फुट स्प्रे लगाया गया');
    });

    test('Marathi dictionary & dynamic phrase translations', () async {
      await service.setLanguage(AppLanguage.marathi);

      expect(service.tr('animal'), 'जनावर');
      expect(service.tr('submitted'), 'सबमिट झाले');
      expect(service.tr('case_id'), 'प्रकरण आयडी');
      expect(service.tr('enter_full_name'), 'कृपया आपले पूर्ण नाव प्रविष्ट करा.');
      expect(service.translateSpecies('Cow'), 'गाय');
      expect(service.translateBreed('Jersey'), 'जर्सी');
      expect(service.translateText('Acres'), 'एकर');
      expect(service.translateText('Reduced Milk Yield, Swollen Udder'), 'दूध उत्पादन घटले, कास सुजणे');
      expect(service.translateText('1 animal(s) affected'), '1 प्राणी बाधित');
      expect(service.translateText('MEDIUM Risk'), 'मध्यम जोखीम');
      expect(service.translateText('Sanjay Kumar'), 'संजय कुमार');
      expect(service.translateText('Green Meadows Farm'), 'ग्रीन मेडोज फार्म');
      expect(service.translateBreed('Holstein Friesian (HF)'), 'होल्स्टिन फ्रीजियन');
      expect(service.translateTag('C001'), 'सी००१');
      expect(service.translateTag('C002'), 'सी००२');
      expect(service.translateTag('G001'), 'जी००१');
      expect(service.translateTag('C009'), 'सी००९');
      expect(service.translateText('Sanjay'), 'संजय');
      expect(service.translateText('Suresh Mane'), 'सुरेश माने');
      expect(service.translateText('Lakshmi Devi'), 'लक्ष्मी देवी');
      expect(service.translateText('Loni Kalbhor'), 'लोणी काळभोर');
      expect(service.translateTag('SMP001'), 'एसएमपी००१');
      expect(service.translateText('New High-Risk Case: Cow C010 (Loni Kalbhor)'), 'नवीन उच्च-जोखीम केस: गाय सी०१० (लोणी काळभोर)');
      expect(service.translateText('🚨 CRITICAL: 4 Buffaloes Affected (Manjari Khurd)'), '🚨 गंभीर: ४ म्हशी बाधित (मांजरी खुर्द)');
      expect(service.translateText('Inj. Oxytetracycline 15ml IM, Inj. Meloxicam 10ml IM, Antiseptic foot spray applied'), 'इंजेक्शन ऑक्सिटेट्रासायक्लिन १५ मिली IM, इंजेक्शन मेलोक्सिकॅम १० मिली IM, जंतुनाशक पायाचा फवारा लावला');
    });
  });
}
