// Animal data model
// Contains predefined breed catalogues and simple age bracket options.

import 'package:flutter/material.dart';
import '../services/localization_service.dart';

enum AnimalSpecies { cow, buffalo, goat, sheep, poultry, pig, other }

enum AnimalGender { male, female, unknown }

enum HealthStatus { healthy, underMonitoring, activeCase, critical }

extension AnimalSpeciesExt on AnimalSpecies {
  String get displayName {
    final lang = LocalizationService.instance.currentLanguage;
    switch (lang) {
      case AppLanguage.hindi:
        switch (this) {
          case AnimalSpecies.cow:
            return 'गाय';
          case AnimalSpecies.buffalo:
            return 'भैंस';
          case AnimalSpecies.goat:
            return 'बकरी';
          case AnimalSpecies.sheep:
            return 'भेड़';
          case AnimalSpecies.poultry:
            return 'पोल्ट्री / मुर्गी';
          case AnimalSpecies.pig:
            return 'सूअर';
          case AnimalSpecies.other:
            return 'अन्य';
        }
      case AppLanguage.marathi:
        switch (this) {
          case AnimalSpecies.cow:
            return 'गाय';
          case AnimalSpecies.buffalo:
            return 'म्हैस';
          case AnimalSpecies.goat:
            return 'शेळी';
          case AnimalSpecies.sheep:
            return 'मेंढी';
          case AnimalSpecies.poultry:
            return 'पोल्ट्री / कोंबडी';
          case AnimalSpecies.pig:
            return 'डुक्कर';
          case AnimalSpecies.other:
            return 'इतर';
        }
      case AppLanguage.english:
        switch (this) {
          case AnimalSpecies.cow:
            return 'Cow';
          case AnimalSpecies.buffalo:
            return 'Buffalo';
          case AnimalSpecies.goat:
            return 'Goat';
          case AnimalSpecies.sheep:
            return 'Sheep';
          case AnimalSpecies.poultry:
            return 'Poultry';
          case AnimalSpecies.pig:
            return 'Pig';
          case AnimalSpecies.other:
            return 'Other';
        }
    }
  }

  String get emoji {
    switch (this) {
      case AnimalSpecies.cow:
        return '🐮';
      case AnimalSpecies.buffalo:
        return '🐃';
      case AnimalSpecies.goat:
        return '🐐';
      case AnimalSpecies.sheep:
        return '🐑';
      case AnimalSpecies.poultry:
        return '🐔';
      case AnimalSpecies.pig:
        return '🐷';
      case AnimalSpecies.other:
        return '🐾';
    }
  }

  IconData get icon {
    switch (this) {
      case AnimalSpecies.cow:
      case AnimalSpecies.buffalo:
        return Icons.agriculture_rounded;
      case AnimalSpecies.goat:
      case AnimalSpecies.sheep:
        return Icons.pets_rounded;
      case AnimalSpecies.poultry:
        return Icons.egg_rounded;
      case AnimalSpecies.pig:
        return Icons.cruelty_free_rounded;
      case AnimalSpecies.other:
        return Icons.category_rounded;
    }
  }

  List<String> get predefinedBreeds {
    switch (this) {
      case AnimalSpecies.cow:
        return const [
          'Jersey',
          'Holstein Friesian (HF)',
          'Sahiwal',
          'Gir',
          'Red Sindhi',
          'Kangayam',
          'Other',
        ];
      case AnimalSpecies.buffalo:
        return const [
          'Murrah',
          'Jaffarabadi',
          'Surti',
          'Mehsana',
          'Other',
        ];
      case AnimalSpecies.goat:
        return const [
          'Boer',
          'Saanen',
          'Jamunapari',
          'Malabari',
          'Kanni Adu',
          'Other',
        ];
      case AnimalSpecies.sheep:
        return const [
          'Mecheri',
          'Vembur',
          'Madras Red',
          'Ramanadhapuram White',
          'Other',
        ];
      case AnimalSpecies.poultry:
        return const [
          'Broiler',
          'Layer',
          'Country Chicken',
          'Other',
        ];
      case AnimalSpecies.pig:
        return const [
          'Large White Yorkshire',
          'Landrace',
          'Duroc',
          'Other',
        ];
      case AnimalSpecies.other:
        return const ['General / Mixed Breed', 'Other'];
    }
  }
}

extension AnimalGenderExt on AnimalGender {
  String get displayName {
    final lang = LocalizationService.instance.currentLanguage;
    switch (lang) {
      case AppLanguage.hindi:
        switch (this) {
          case AnimalGender.male:
            return 'नर';
          case AnimalGender.female:
            return 'मादा';
          case AnimalGender.unknown:
            return 'अज्ञात';
        }
      case AppLanguage.marathi:
        switch (this) {
          case AnimalGender.male:
            return 'नर';
          case AnimalGender.female:
            return 'मादी';
          case AnimalGender.unknown:
            return 'अज्ञात';
        }
      case AppLanguage.english:
        switch (this) {
          case AnimalGender.male:
            return 'Male';
          case AnimalGender.female:
            return 'Female';
          case AnimalGender.unknown:
            return 'Unknown';
        }
    }
  }
}

extension HealthStatusExt on HealthStatus {
  String get displayName {
    final lang = LocalizationService.instance.currentLanguage;
    switch (lang) {
      case AppLanguage.hindi:
        switch (this) {
          case HealthStatus.healthy:
            return 'स्वस्थ';
          case HealthStatus.underMonitoring:
            return 'निगरानी में';
          case HealthStatus.activeCase:
            return 'सक्रिय केस';
          case HealthStatus.critical:
            return 'गंभीर';
        }
      case AppLanguage.marathi:
        switch (this) {
          case HealthStatus.healthy:
            return 'निरोगी';
          case HealthStatus.underMonitoring:
            return 'निरीक्षणाखाली';
          case HealthStatus.activeCase:
            return 'सक्रिय केस';
          case HealthStatus.critical:
            return 'गंभीर';
        }
      case AppLanguage.english:
        switch (this) {
          case HealthStatus.healthy:
            return 'Healthy';
          case HealthStatus.underMonitoring:
            return 'Under Monitoring';
          case HealthStatus.activeCase:
            return 'Active Case';
          case HealthStatus.critical:
            return 'Critical';
        }
    }
  }
}

class Animal {
  final String id;
  final String earTag; // Animal ID / Ear Tag
  final AnimalSpecies species;
  final String breed;
  final AnimalGender gender;
  final String age; // e.g. "2–5 years"
  HealthStatus healthStatus;
  final String? photoPath; // placeholder for image
  final String? location;
  final String? herdId;
  final String? farmId;
  final DateTime createdAt;

  // Health tracking
  DateTime? lastHealthReport;
  DateTime? lastVetVisit;

  Animal({
    required this.id,
    required this.earTag,
    required this.species,
    required this.breed,
    required this.gender,
    required this.age,
    this.healthStatus = HealthStatus.healthy,
    this.photoPath,
    this.location,
    this.herdId,
    this.farmId,
    DateTime? createdAt,
    this.lastHealthReport,
    this.lastVetVisit,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Returns a copy of this animal with selected fields overridden.
  Animal copyWith({
    String? id,
    String? earTag,
    AnimalSpecies? species,
    String? breed,
    AnimalGender? gender,
    String? age,
    HealthStatus? healthStatus,
    String? photoPath,
    String? location,
    String? herdId,
    String? farmId,
  }) {
    return Animal(
      id: id ?? this.id,
      earTag: earTag ?? this.earTag,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      healthStatus: healthStatus ?? this.healthStatus,
      photoPath: photoPath ?? this.photoPath,
      location: location ?? this.location,
      herdId: herdId ?? this.herdId,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt,
      lastHealthReport: lastHealthReport,
      lastVetVisit: lastVetVisit,
    );
  }

  /// Converts to a Map for future API serialisation.
  Map<String, dynamic> toJson() => {
        'id': id,
        'earTag': earTag,
        'species': species.name,
        'breed': breed,
        'gender': gender.name,
        'age': age,
        'healthStatus': healthStatus.name,
        'photoPath': photoPath,
        'location': location,
        'herdId': herdId,
        'farmId': farmId,
        'createdAt': createdAt.toIso8601String(),
      };
}
