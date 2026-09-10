import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../models/treatment_record.dart';
import '../theme/app_theme.dart';

class TreatmentScreen extends StatefulWidget {
  final FarmerDataService dataService;

  const TreatmentScreen({super.key, required this.dataService});

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  @override
  void initState() {
    super.initState();
    widget.dataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    widget.dataService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => setState(() {});

  Color _statusColor(TreatmentStatus s) {
    switch (s) {
      case TreatmentStatus.notStarted:
        return AppColors.textTertiary;
      case TreatmentStatus.ongoing:
        return AppColors.info;
      case TreatmentStatus.followUpDue:
        return AppColors.warning;
      case TreatmentStatus.completed:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final treatments = widget.dataService.getTreatments();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Treatment Records',
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
      body: treatments.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
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
                        Icons.medical_services_outlined,
                        size: 36,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No treatment records yet',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Treatment records are created by the veterinarian\n'
                      'through the veterinarian module.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: treatments.length,
              itemBuilder: (ctx, i) {
                final t = treatments[i];
                final color = _statusColor(t.status);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    side: const BorderSide(color: AppColors.border, width: 1),
                  ),
                  color: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.condition,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppRadius.chip),
                              ),
                              child: Text(
                                t.status.displayName,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Animal Tag: ${t.animalTag}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const Divider(height: 24, color: AppColors.borderLight),
                        _row('Treatment', t.treatment),
                        _row('Medicine', t.medicine),
                        if (t.veterinarian != null)
                          _row('Veterinarian', t.veterinarian!),
                        _row(
                          'Start Date',
                          '${t.startDate.day}/${t.startDate.month}/${t.startDate.year}',
                        ),
                        if (t.followUpDate != null)
                          _row(
                            'Follow-up',
                            '${t.followUpDate!.day}/${t.followUpDate!.month}/${t.followUpDate!.year}',
                          ),
                        if (t.instructions != null) ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Instructions:',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(AppRadius.input),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              t.instructions!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
