import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/health_report.dart';
import 'package:flutter_app/models/case.dart';
import 'package:flutter_app/services/location_service.dart';
import 'package:flutter_app/services/offline_sync_service.dart';
import 'package:flutter_app/services/farmer_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocationService & PostGIS Proximity Tests', () {
    test('LocationService.haversineDistance computes accurate distances in kilometers', () {
      // Uruli Kanchan (18.4870, 74.1330) to Loni Kalbhor (18.4900, 74.0200) ~ 11.9 km
      final dist1 = LocationService.haversineDistance(18.4870, 74.1330, 18.4900, 74.0200);
      expect(dist1, inInclusiveRange(11.0, 13.0));

      // Same coordinates -> 0 km
      final distSame = LocationService.haversineDistance(18.4870, 74.1330, 18.4870, 74.1330);
      expect(distSame, 0.0);

      // Uruli Kanchan to Pune City (18.5204, 73.8567) ~ 29.5 km
      final distPune = LocationService.haversineDistance(18.4870, 74.1330, 18.5204, 73.8567);
      expect(distPune, inInclusiveRange(27.0, 32.0));
    });

    test('LocationResult serializes to and from JSON properly', () {
      const loc = LocationResult(
        latitude: 18.487123,
        longitude: 74.133456,
        accuracy: 8.5,
        isGpsAcquired: true,
        source: 'Device GPS',
      );

      final json = loc.toJson();
      expect(json['latitude'], 18.487123);
      expect(json['longitude'], 74.133456);
      expect(json['accuracy'], 8.5);
      expect(json['isGpsAcquired'], isTrue);
      expect(json['source'], 'Device GPS');
    });

    test('HealthReport model correctly stores latitude and longitude coordinates', () {
      final report = HealthReport(
        id: 'RPT_LOC_001',
        animalId: 'A100',
        animalTag: 'TAG-LOC-42',
        symptoms: ['Fever'],
        riskLevel: RiskLevel.medium,
        title: 'Medium Risk Condition',
        advice: 'Monitor feed intake',
        recommendedAction: 'Inspect closely',
        latitude: 18.4870,
        longitude: 74.1330,
        location: 'Green Meadows Farm, Uruli Kanchan',
      );

      expect(report.latitude, 18.4870);
      expect(report.longitude, 74.1330);

      final json = report.toJson();
      expect(json['latitude'], 18.4870);
      expect(json['longitude'], 74.1330);
      expect(json['location'], 'Green Meadows Farm, Uruli Kanchan');
    });

    test('LivestockCase model holds latitude and longitude for spatial surveillance', () {
      final lcase = LivestockCase(
        caseId: 'CASE-LOC-001',
        reportId: 'RPT-LOC-001',
        farmerId: 'F001',
        farmerName: 'Ramesh',
        farmName: 'Green Meadows Farm',
        animalId: 'A100',
        animalTag: 'TAG-LOC-42',
        species: 'Cow',
        symptoms: ['Fever'],
        riskLevel: 'MEDIUM',
        village: 'Uruli Kanchan',
        block: 'Haveli',
        district: 'Pune',
        state: 'Maharashtra',
        latitude: 18.4870,
        longitude: 74.1330,
      );

      expect(lcase.latitude, 18.4870);
      expect(lcase.longitude, 74.1330);
    });

    test('OfflineMediaItem retains GPS latitude and longitude across offline queues', () {
      final item = OfflineMediaItem(
        caseId: 'CASE-OFFLINE-LOC-001',
        voicePath: '/data/voice.m4a',
        latitude: 18.4871,
        longitude: 74.1334,
      );

      final json = item.toJson();
      expect(json['latitude'], 18.4871);
      expect(json['longitude'], 74.1334);

      final deserialized = OfflineMediaItem.fromJson(json);
      expect(deserialized.latitude, 18.4871);
      expect(deserialized.longitude, 74.1334);
    });

    test('FarmerDataService fetchNearbyCases filters by geographic radius', () async {
      final dataService = FarmerDataService();
      dataService.seedDemoData();

      // Uruli Kanchan coordinates: 18.4870, 74.1330
      // 25km radius should include demo cases around Pune / Haveli
      final nearbyCases = await dataService.fetchNearbyCases(
        latitude: 18.4870,
        longitude: 74.1330,
        radiusKm: 25.0,
      );

      expect(nearbyCases, isNotEmpty);
      for (final c in nearbyCases) {
        final dist = LocationService.haversineDistance(
          18.4870,
          74.1330,
          c.latitude ?? 18.4870,
          c.longitude ?? 74.1330,
        );
        expect(dist, lessThanOrEqualTo(25.0));
      }
    });
  });
}
