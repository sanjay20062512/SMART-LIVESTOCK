// Alert data model
import '../services/localization_service.dart';

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
    final lang = LocalizationService.instance.currentLanguage;
    switch (lang) {
      case AppLanguage.hindi:
        switch (this) {
          case AlertCategory.diseaseAlert:
            return 'रोग चेतावनी';
          case AlertCategory.vaccinationReminder:
            return 'टीकाकरण अनुस्मारक';
          case AlertCategory.followUpReminder:
            return 'फॉलो-अप अनुस्मारक';
          case AlertCategory.weatherRisk:
            return 'मौसम जोखिम';
          case AlertCategory.governmentAdvisory:
            return 'सरकारी सलाह';
          case AlertCategory.veterinarianMessage:
            return 'पशु चिकित्सक संदेश';
          case AlertCategory.mortalityAlert:
            return 'मृत्यु अलर्ट';
          case AlertCategory.highRiskHealthAlert:
            return 'उच्च जोखिम स्वास्थ्य अलर्ट';
        }
      case AppLanguage.marathi:
        switch (this) {
          case AlertCategory.diseaseAlert:
            return 'रोग इशारा';
          case AlertCategory.vaccinationReminder:
            return 'लसीकरण स्मरणपत्र';
          case AlertCategory.followUpReminder:
            return 'फॉलो-अप स्मरणपत्र';
          case AlertCategory.weatherRisk:
            return 'हवामान जोखीम';
          case AlertCategory.governmentAdvisory:
            return 'शासकीय सल्ला';
          case AlertCategory.veterinarianMessage:
            return 'पशुवैद्यक संदेश';
          case AlertCategory.mortalityAlert:
            return 'मृत्यू इशारा';
          case AlertCategory.highRiskHealthAlert:
            return 'उच्च जोखीम आरोग्य इशारा';
        }
      case AppLanguage.english:
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
}

extension AlertSeverityExt on AlertSeverity {
  String get displayName {
    final lang = LocalizationService.instance.currentLanguage;
    switch (lang) {
      case AppLanguage.hindi:
        switch (this) {
          case AlertSeverity.info:
            return 'सूचना';
          case AlertSeverity.warning:
            return 'चेतावनी';
          case AlertSeverity.high:
            return 'उच्च';
          case AlertSeverity.critical:
            return 'गंभीर';
        }
      case AppLanguage.marathi:
        switch (this) {
          case AlertSeverity.info:
            return 'माहिती';
          case AlertSeverity.warning:
            return 'इशारा';
          case AlertSeverity.high:
            return 'उच्च';
          case AlertSeverity.critical:
            return 'गंभीर';
        }
      case AppLanguage.english:
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
}

class AppAlert {
  final String id;
  final AlertCategory category;
  final String title;
  final String message;
  final DateTime date;
  bool isRead;
  final AlertSeverity severity;
  final String? relatedId; // animalId, reportId, caseId etc.
  final String targetRole; // 'FARMER', 'VETERINARIAN', or 'ALL'

  AppAlert({
    required this.id,
    required this.category,
    required this.title,
    required this.message,
    DateTime? date,
    this.isRead = false,
    required this.severity,
    this.relatedId,
    this.targetRole = 'FARMER',
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
        'targetRole': targetRole,
      };
}
