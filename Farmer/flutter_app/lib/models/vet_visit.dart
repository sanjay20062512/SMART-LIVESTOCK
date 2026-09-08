// Veterinary field visit model

class VetVisit {
  final String visitId;
  final String caseId;
  final String farmerId;
  final String farmerName;
  final String farmLocation;
  final String vetId;
  final String vetName;
  final DateTime scheduledDate;
  DateTime? actualDate;
  String? observations; // clinical observations
  String? animalsExamined;
  String? symptomsObserved;
  String? preliminaryAssessment;
  String? actionTaken;
  String? treatmentGiven;
  DateTime? followUpDate;
  bool isCompleted;

  VetVisit({
    required this.visitId,
    required this.caseId,
    required this.farmerId,
    required this.farmerName,
    required this.farmLocation,
    required this.vetId,
    required this.vetName,
    required this.scheduledDate,
    this.actualDate,
    this.observations,
    this.animalsExamined,
    this.symptomsObserved,
    this.preliminaryAssessment,
    this.actionTaken,
    this.treatmentGiven,
    this.followUpDate,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'visitId': visitId,
        'caseId': caseId,
        'vetName': vetName,
        'scheduledDate': scheduledDate.toIso8601String(),
        'isCompleted': isCompleted,
        'observations': observations,
      };
}
