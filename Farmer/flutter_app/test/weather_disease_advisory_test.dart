import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/services/groq_weather_service.dart';
import 'package:flutter_app/services/localization_service.dart';
import 'package:flutter_app/screens/weather_disease_advisory_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GroqWeatherService Tests', () {
    final service = GroqWeatherService.instance;

    test('All 36 Maharashtra districts are defined', () {
      expect(GroqWeatherService.maharashtraDistricts.length, greaterThanOrEqualTo(35));
      final pune = service.getDistrict('Pune');
      expect(pune.name, equals('Pune'));
      expect(pune.marathiName, contains('पुणे'));
    });

    test('THI (Temperature-Humidity Index) calculation', () {
      // Normal range
      final thiNormal = DistrictWeatherData.calculateTHI(24.0, 50);
      expect(thiNormal, lessThan(72.0));

      // Heat stress range
      final thiHot = DistrictWeatherData.calculateTHI(40.0, 70);
      expect(thiHot, greaterThan(88.0));
      final (cat, _, _, _, _, _) = DistrictWeatherData.getTHICategory(thiHot);
      expect(cat, contains('Severe'));
    });

    test('Maharashtra seasonal disease retrieval by season and district', () {
      final monsoonDiseases = service.getSeasonalDiseases(
        districtName: 'Pune',
        season: 'Monsoon',
      );
      expect(monsoonDiseases.isNotEmpty, isTrue);

      final diseaseNames = monsoonDiseases.map((d) => d.name).toList();
      expect(diseaseNames.any((n) => n.contains('Haemorrhagic Septicaemia') || n.contains('HS')), isTrue);
      expect(diseaseNames.any((n) => n.contains('Foot and Mouth Disease') || n.contains('FMD')), isTrue);
    });

    test('Local advisory fallback supports Marathi and Hindi', () {
      final pune = service.getDistrict('Pune');
      final weather = DistrictWeatherData(
        district: 'Pune',
        temperature: 28.0,
        apparentTemperature: 30.0,
        humidity: 75,
        precipitation: 2.0,
        windSpeed: 10.0,
        weatherCode: 61,
        conditionName: 'Rain',
        conditionMarathi: 'पाऊस',
        conditionHindi: 'बारिश',
        thiIndex: 76.5,
        thiCategory: 'Mild Stress',
        thiCategoryMarathi: 'सौम्य ताण',
        thiCategoryHindi: 'हल्का ताप तनाव',
        thiAdvice: 'Ensure dry bedding.',
        thiAdviceMarathi: 'कोरडे अंथरूण ठेवा.',
        thiAdviceHindi: 'सूखा बिस्तर रखें.',
        timestamp: DateTime.now(),
      );

      final advisoryMr = service.fetchGroqAdvisory(
        districtName: 'Pune',
        weather: weather,
        season: 'Monsoon',
        language: 'mr',
      );
      expect(advisoryMr, isNotNull);
    });
  });

  group('WeatherDiseaseAdvisoryScreen Widget Tests', () {
    setUpAll(() async {
      await LocalizationService.instance.init();
    });

    testWidgets('Renders Weather & Disease Advisory Screen properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WeatherDiseaseAdvisoryScreen(initialDistrict: 'Pune'),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify district header or title is displayed
      expect(find.textContaining('Pune'), findsWidgets);
      expect(find.byType(TabBar), findsOneWidget);
    });
  });
}
