// Alert data model

enum AlertCategory {
  diseaseAlert,
  vaccinationReminder,
  followUpReminder,
  weatherRisk,
  governmentAdvisory,
  veterinarianMessage,
  mortalityAlert,
  highRiskHealthAlert,
}

enum AlertSeverity { info, warning, high, critical }

extension AlertCategoryExt on AlertCategory {
  String get displayName {
    switch (this) {
      case AlertCategory.diseaseAlert:
        return 'Disease Alert';
      case AlertCategory.vaccinationReminder:
        return 'Vaccination Reminder';
      case AlertCategory.followUpReminder:
        return 'Follow-up Reminder';
      case AlertCategory.weatherRisk:
        return 'Weather Risk';
      case AlertCategory.governmentAdvisory:
        return 'Government Advisory';
      case AlertCategory.veterinarianMessage:
        return 'Veterinarian Message';
      case AlertCategory.mortalityAlert:
        return 'Mortality Alert';
      case AlertCategory.highRiskHealthAlert:
        return 'High Risk Health Alert';
    }
  }
}

extension AlertSeverityExt on AlertSeverity {
  String get displayName {
    switch (this) {
      case AlertSeverity.info:
        return 'Info';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.high:
        return 'High';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }
}

class AppAlert {
  final String id;
  final AlertCategory category;
  final String title;
  final String message;
  final DateTime date;
  bool isRead;
  final AlertSeverity severity;
  final String? relatedId; // animalId, reportId, etc.

  AppAlert({
    required this.id,
    required this.category,
    required this.title,
    required this.message,
    DateTime? date,
    this.isRead = false,
    required this.severity,
    this.relatedId,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'title': title,
        'message': message,
        'date': date.toIso8601String(),
        'isRead': isRead,
        'severity': severity.name,
        'relatedId': relatedId,
      };
}
