// Treatment Record data model

enum TreatmentStatus { notStarted, ongoing, followUpDue, completed }

extension TreatmentStatusExt on TreatmentStatus {
  String get displayName {
    switch (this) {
      case TreatmentStatus.notStarted:
        return 'Not Started';
      case TreatmentStatus.ongoing:
        return 'Ongoing';
      case TreatmentStatus.followUpDue:
        return 'Follow-up Due';
      case TreatmentStatus.completed:
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
