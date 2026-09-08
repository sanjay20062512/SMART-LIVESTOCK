// Mortality Report data model

class MortalityReport {
  final String id;
  final String? animalId;
  final String? herdId;
  final String animalTag; // denormalised for display
  final DateTime date;
  final String time;
  final String? location;
  final List<String> symptomsBeforeDeath;
  final int numberAffected;
  final String? description;
  final String? photoPath; // placeholder
  final String? voicePath; // placeholder
  final DateTime createdAt;

  MortalityReport({
    required this.id,
    this.animalId,
    this.herdId,
    required this.animalTag,
    required this.date,
    required this.time,
    this.location,
    required this.symptomsBeforeDeath,
    required this.numberAffected,
    this.description,
    this.photoPath,
    this.voicePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'animalId': animalId,
        'herdId': herdId,
        'animalTag': animalTag,
        'date': date.toIso8601String(),
        'time': time,
        'location': location,
        'symptomsBeforeDeath': symptomsBeforeDeath,
        'numberAffected': numberAffected,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
      };
}
