// Herd data model

import 'animal.dart';

enum HerdHealthStatus { healthy, mixed, alert }

extension HerdHealthStatusExt on HerdHealthStatus {
  String get displayName {
    switch (this) {
      case HerdHealthStatus.healthy:
        return 'Healthy';
      case HerdHealthStatus.mixed:
        return 'Mixed';
      case HerdHealthStatus.alert:
        return 'Alert';
    }
  }
}

class Herd {
  final String id;
  final String name;
  final AnimalSpecies animalType;
  int totalCount;
  final String breed;
  final String ageGroup;
  final String? location;
  HerdHealthStatus healthStatus;
  final DateTime createdAt;

  Herd({
    required this.id,
    required this.name,
    required this.animalType,
    required this.totalCount,
    required this.breed,
    required this.ageGroup,
    this.location,
    this.healthStatus = HerdHealthStatus.healthy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'animalType': animalType.name,
        'totalCount': totalCount,
        'breed': breed,
        'ageGroup': ageGroup,
        'location': location,
        'healthStatus': healthStatus.name,
        'createdAt': createdAt.toIso8601String(),
      };
}
