import '../services/localization_service.dart';

enum TreatmentStatus { notStarted, ongoing, followUpDue, completed }

extension TreatmentStatusExt on TreatmentStatus {
  String get displayName {
    final lang = LocalizationService.instance.currentLanguage;
    switch (this) {
      case TreatmentStatus.notStarted:
        if (lang == AppLanguage.hindi) return 'शुरू नहीं हुआ';
        if (lang == AppLanguage.marathi) return 'सुरू झाले नाही';
        return 'Not Started';
      case TreatmentStatus.ongoing:
        if (lang == AppLanguage.hindi) return 'प्रगति पर';
        if (lang == AppLanguage.marathi) return 'प्रगतीपथावर';
        return 'Ongoing';
      case TreatmentStatus.followUpDue:
        if (lang == AppLanguage.hindi) return 'फॉलो-अप बाकी';
        if (lang == AppLanguage.marathi) return 'फॉलो-अप बाकी';
        return 'Follow-up Due';
      case TreatmentStatus.completed:
        if (lang == AppLanguage.hindi) return 'पूर्ण हुआ';
        if (lang == AppLanguage.marathi) return 'पूर्ण झाले';
        return 'Completed';
    }
  }
}

class TreatmentRecord {
  final String id;
  final String animalId;
  final String animalTag; // denormalised for display
  final String condition;
  final String treatment;
  final String medicine;
  final String? instructions;
  final String? veterinarian;
  final DateTime startDate;
  final DateTime? followUpDate;
  TreatmentStatus status;

  TreatmentRecord({
    required this.id,
    required this.animalId,
    required this.animalTag,
    required this.condition,
    required this.treatment,
    required this.medicine,
    this.instructions,
    this.veterinarian,
    required this.startDate,
    this.followUpDate,
    this.status = TreatmentStatus.ongoing,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'animalId': animalId,
        'animalTag': animalTag,
        'condition': condition,
        'treatment': treatment,
        'medicine': medicine,
        'instructions': instructions,
        'veterinarian': veterinarian,
        'startDate': startDate.toIso8601String(),
        'followUpDate': followUpDate?.toIso8601String(),
        'status': status.name,
      };
}
