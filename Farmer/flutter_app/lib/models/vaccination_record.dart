import '../services/localization_service.dart';

enum VaccinationStatus { due, upcoming, completed, overdue }

extension VaccinationStatusExt on VaccinationStatus {
  String get displayName {
    final lang = LocalizationService.instance.currentLanguage;
    switch (this) {
      case VaccinationStatus.due:
        if (lang == AppLanguage.hindi) return 'देय';
        if (lang == AppLanguage.marathi) return 'देय';
        return 'Due';
      case VaccinationStatus.upcoming:
        if (lang == AppLanguage.hindi) return 'आगामी';
        if (lang == AppLanguage.marathi) return 'आगामी';
        return 'Upcoming';
      case VaccinationStatus.completed:
        if (lang == AppLanguage.hindi) return 'पूर्ण';
        if (lang == AppLanguage.marathi) return 'पूर्ण झाले';
        return 'Completed';
      case VaccinationStatus.overdue:
        if (lang == AppLanguage.hindi) return 'विलंबित';
        if (lang == AppLanguage.marathi) return 'थकबाकी / विलंबित';
        return 'Overdue';
    }
  }
}

class VaccinationRecord {
  final String id;
  final String animalId;
  final String animalTag; // denormalised for display
  final String vaccineName;
  final DateTime? date; // null if not yet administered
  final DateTime? nextDueDate;
  VaccinationStatus status;
  final String? veterinarian;
  final bool isVerified; // true = verified by vet/authority

  VaccinationRecord({
    required this.id,
    required this.animalId,
    required this.animalTag,
    required this.vaccineName,
    this.date,
    this.nextDueDate,
    required this.status,
    this.veterinarian,
    this.isVerified = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'animalId': animalId,
        'animalTag': animalTag,
        'vaccineName': vaccineName,
        'date': date?.toIso8601String(),
        'nextDueDate': nextDueDate?.toIso8601String(),
        'status': status.name,
        'veterinarian': veterinarian,
        'isVerified': isVerified,
      };
}
