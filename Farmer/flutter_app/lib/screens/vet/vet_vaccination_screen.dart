import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../models/vaccination_record.dart';
import '../../theme/app_theme.dart';

class VetVaccinationScreen extends StatelessWidget {
  final FarmerDataService dataService;
  const VetVaccinationScreen({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        final vaccinations = dataService.getVaccinations();
        final due = vaccinations.where((v) =>
            v.status == VaccinationStatus.due ||
            v.status == VaccinationStatus.overdue).toList();
        final upcoming = vaccinations.where((v) => v.status == VaccinationStatus.upcoming).toList();
        final completed = vaccinations.where((v) => v.status == VaccinationStatus.completed).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Vaccination',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.2,
              ),
            ),
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats
              Row(
                children: [
                  _statChip('Due / Overdue', due.length.toString(), AppColors.error),
                  const SizedBox(width: 10),
                  _statChip('Upcoming', upcoming.length.toString(), AppColors.warning),
                  const SizedBox(width: 10),
                  _statChip('Completed', completed.length.toString(), AppColors.success),
                ],
              ),
              const SizedBox(height: 20),

              if (due.isNotEmpty) ...[
                _sectionHeader('Due / Overdue', AppColors.error),
                ...due.map((v) => _vaccinationCard(v)),
                const SizedBox(height: 12),
              ],

              if (upcoming.isNotEmpty) ...[
                _sectionHeader('Upcoming', AppColors.warning),
                ...upcoming.map((v) => _vaccinationCard(v)),
                const SizedBox(height: 12),
              ],

              if (completed.isNotEmpty) ...[
                _sectionHeader('Completed', AppColors.success),
                ...completed.map((v) => _vaccinationCard(v)),
              ],

              if (vaccinations.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.vaccines_outlined,
                            size: 36,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No vaccination records',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: color),
          ),
        ],
      ),
    );
  }

  Widget _vaccinationCard(VaccinationRecord v) {
    final statusColor = switch (v.status) {
      VaccinationStatus.overdue => AppColors.riskCritical,
      VaccinationStatus.due => AppColors.warning,
      VaccinationStatus.upcoming => AppColors.info,
      VaccinationStatus.completed => AppColors.success,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: const Icon(Icons.vaccines_outlined, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v.vaccineName,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Animal Tag: ${v.animalTag}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                if (v.nextDueDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Due: ${v.nextDueDate!.day}/${v.nextDueDate!.month}/${v.nextDueDate!.year}',
                    style: TextStyle(
                      color: v.status == VaccinationStatus.overdue ? AppColors.error : AppColors.textTertiary,
                      fontSize: 12,
                      fontWeight: v.status == VaccinationStatus.overdue ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ],
                if (v.veterinarian != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Vet: ${v.veterinarian}',
                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Text(
              v.status.name.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
