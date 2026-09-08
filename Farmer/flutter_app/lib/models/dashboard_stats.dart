// Dashboard statistics — computed from live application data.
// Never hardcoded.

class DashboardStats {
  final int totalAnimals;
  final int healthyAnimals;
  final int monitoringAnimals;
  final int activeCases;
  final int vaccinationsDue;
  final int importantAlerts;

  const DashboardStats({
    required this.totalAnimals,
    required this.healthyAnimals,
    required this.monitoringAnimals,
    required this.activeCases,
    required this.vaccinationsDue,
    required this.importantAlerts,
  });

  static const DashboardStats empty = DashboardStats(
    totalAnimals: 0,
    healthyAnimals: 0,
    monitoringAnimals: 0,
    activeCases: 0,
    vaccinationsDue: 0,
    importantAlerts: 0,
  );
}
