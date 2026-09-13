import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/health_report.dart';
import 'package:flutter_app/models/case.dart';
import 'package:flutter_app/services/farmer_data_service.dart';
import 'package:flutter_app/services/offline_sync_service.dart';
import 'package:flutter_app/screens/symptom_report_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Media & Offline Integration Tests', () {
    test('HealthReport model correctly holds media paths, transcript, and URLs', () {
      final report = HealthReport(
        id: 'RPT_TEST_001',
        animalId: 'A001',
        animalTag: 'TAG-123',
        symptoms: ['Fever', 'Not eating'],
        riskLevel: RiskLevel.high,
        title: 'High Risk Animal Condition',
        advice: 'Isolate animal immediately',
        recommendedAction: 'Call field veterinarian',
        voicePath: '/tmp/test_voice.m4a',
        photoPath: '/tmp/test_photo.jpg',
        videoPath: '/tmp/test_video.mp4',
        voiceTranscript: 'Cow has high fever and is not eating feed',
        hasVoiceNote: true,
        hasPhoto: true,
        hasVideo: true,
      );

      expect(report.hasVoiceNote, isTrue);
      expect(report.voicePath, '/tmp/test_voice.m4a');
      expect(report.photoPath, '/tmp/test_photo.jpg');
      expect(report.videoPath, '/tmp/test_video.mp4');
      expect(report.voiceTranscript, 'Cow has high fever and is not eating feed');

      final json = report.toJson();
      expect(json['hasVoiceNote'], isTrue);
      expect(json['voicePath'], '/tmp/test_voice.m4a');
      expect(json['voiceTranscript'], 'Cow has high fever and is not eating feed');
    });

    test('LivestockCase model holds Supabase public media URLs and transcripts', () {
      final lcase = LivestockCase(
        caseId: 'CASE-001',
        reportId: 'RPT-001',
        farmerId: 'F001',
        farmerName: 'Ramesh',
        farmName: 'Ramesh Dairy',
        animalId: 'A001',
        animalTag: 'COW-42',
        species: 'Cow',
        symptoms: ['Fever'],
        riskLevel: 'HIGH',
        village: 'Uruli Kanchan',
        block: 'Haveli',
        district: 'Pune',
        state: 'Maharashtra',
        hasVoiceNote: true,
        voiceNoteUrl: 'https://supabase.co/storage/v1/object/public/livestock-media/voices/voice1.m4a',
        hasPhoto: true,
        photoUrls: ['https://supabase.co/storage/v1/object/public/livestock-media/photos/photo1.jpg'],
        hasVideo: true,
        videoUrl: 'https://supabase.co/storage/v1/object/public/livestock-media/videos/video1.mp4',
        voiceTranscript: 'High fever observed since yesterday morning',
      );

      expect(lcase.hasVoiceNote, isTrue);
      expect(lcase.voiceNoteUrl, contains('livestock-media/voices/'));
      expect(lcase.photoUrls!.first, contains('livestock-media/photos/'));
      expect(lcase.videoUrl, contains('livestock-media/videos/'));
      expect(lcase.voiceTranscript, 'High fever observed since yesterday morning');
    });

    test('OfflineSyncService enqueues and serializes offline media items', () async {
      final item = OfflineMediaItem(
        caseId: 'CASE-OFFLINE-001',
        voicePath: '/data/user/0/voice.m4a',
        photoPath: '/data/user/0/photo.jpg',
        videoPath: '/data/user/0/video.mp4',
        voiceTranscript: 'Animal salivating excessively',
        language: 'hi-IN',
      );

      final json = item.toJson();
      expect(json['caseId'], 'CASE-OFFLINE-001');
      expect(json['language'], 'hi-IN');
      expect(json['voiceTranscript'], 'Animal salivating excessively');

      final deserialized = OfflineMediaItem.fromJson(json);
      expect(deserialized.caseId, 'CASE-OFFLINE-001');
      expect(deserialized.voiceTranscript, 'Animal salivating excessively');
    });

    testWidgets('Step 8 Evidence displays Voice, Photo, and Video buttons properly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final dataService = FarmerDataService();
      dataService.seedDemoData();

      await tester.pumpWidget(MaterialApp(
        home: SymptomReportScreen(dataService: dataService),
      ));
      await tester.pumpAndSettle();

      Future<void> tapNext() async {
        final finder = find.text('Next');
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      // Step 0 -> Step 1 -> Step 2 (select symptom) -> Steps to Step 7 (Evidence)
      await tapNext();
      await tapNext();

      final feverFinder = find.text('Fever');
      await tester.ensureVisible(feverFinder);
      await tester.pumpAndSettle();
      await tester.tap(feverFinder);
      await tester.pumpAndSettle();
      await tapNext();

      await tapNext(); // Duration
      await tapNext(); // Eating & Drinking
      await tapNext(); // Affected Count
      await tapNext(); // Pregnancy

      // Now at Step 7/8: Evidence
      expect(find.text('Show us the problem'), findsOneWidget);
      expect(find.text('TAP AND SPEAK'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Record Video'), findsOneWidget);
      expect(find.text('Write Description'), findsOneWidget);
    });
  });
}
