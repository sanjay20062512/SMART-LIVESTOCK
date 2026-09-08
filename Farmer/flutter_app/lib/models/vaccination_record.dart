// Vaccination Record data model

enum VaccinationStatus { due, upcoming, completed, overdue }

extension VaccinationStatusExt on VaccinationStatus {
  String get displayName {
    switch (this) {
      case VaccinationStatus.due:
        return 'Due';
      case VaccinationStatus.upcoming:
        return 'Upcoming';
      case VaccinationStatus.completed:
        return 'Completed';
      case VaccinationStatus.overdue:
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
