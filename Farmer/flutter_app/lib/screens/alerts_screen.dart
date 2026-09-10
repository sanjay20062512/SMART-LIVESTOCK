import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../models/alert.dart';
import '../theme/app_theme.dart';

class AlertsScreen extends StatefulWidget {
  final FarmerDataService dataService;

  const AlertsScreen({super.key, required this.dataService});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
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

  Color _severityColor(AlertSeverity s) {
    switch (s) {
      case AlertSeverity.info:
        return AppColors.info;
      case AlertSeverity.warning:
        return AppColors.warning;
      case AlertSeverity.high:
        return AppColors.error;
      case AlertSeverity.critical:
        return AppColors.riskCritical;
    }
  }

  IconData _categoryIcon(AlertCategory c) {
    switch (c) {
      case AlertCategory.diseaseAlert:
        return Icons.coronavirus_outlined;
      case AlertCategory.vaccinationReminder:
        return Icons.vaccines_outlined;
      case AlertCategory.followUpReminder:
        return Icons.calendar_today_outlined;
      case AlertCategory.weatherRisk:
        return Icons.cloud_outlined;
      case AlertCategory.governmentAdvisory:
        return Icons.policy_outlined;
      case AlertCategory.veterinarianMessage:
        return Icons.local_hospital_outlined;
      case AlertCategory.mortalityAlert:
        return Icons.warning_amber_rounded;
      case AlertCategory.highRiskHealthAlert:
        return Icons.health_and_safety_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final alerts = widget.dataService.getAlerts();
    final unread = widget.dataService.unreadAlertCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Alerts & Advisories',
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
        actions: [
          if (unread > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () => widget.dataService.markAllAlertsRead(),
                icon: const Icon(Icons.done_all_rounded, size: 16, color: Colors.white),
                label: const Text(
                  'Mark All Read',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: alerts.isEmpty
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
                        Icons.notifications_none_rounded,
                        size: 36,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No alerts yet',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Alerts will appear here when health reports,\nmortality events, or advisories are created.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: alerts.length,
              itemBuilder: (ctx, i) {
                final alert = alerts[i];
                final color = _severityColor(alert.severity);

                return Dismissible(
                  key: Key(alert.id),
                  direction: DismissDirection.startToEnd,
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    widget.dataService.markAlertRead(alert.id);
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      side: BorderSide(
                        color: alert.isRead
                            ? AppColors.border
                            : color.withValues(alpha: 0.5),
                        width: alert.isRead ? 1 : 1.5,
                      ),
                    ),
                    color: alert.isRead ? AppColors.surface : color.withValues(alpha: 0.03),
                    child: InkWell(
                      onTap: () {
                        widget.dataService.markAlertRead(alert.id);
                        _showAlertDetails(context, alert, color);
                      },
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: color.withValues(alpha: 0.12),
                                  child: Icon(
                                    _categoryIcon(alert.category),
                                    color: color,
                                    size: 20,
                                  ),
                                ),
                                if (!alert.isRead)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      width: 9,
                                      height: 9,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.5),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          alert.title,
                                          style: TextStyle(
                                            fontWeight: alert.isRead
                                                ? FontWeight.w600
                                                : FontWeight.w800,
                                            fontSize: 14,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(AppRadius.chip),
                                        ),
                                        child: Text(
                                          alert.severity.displayName
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: color,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    alert.category.displayName,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    alert.message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _formatDate(alert.date),
                                    style: const TextStyle(
                                        color: AppColors.textTertiary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAlertDetails(
      BuildContext context, AppAlert alert, Color color) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.dialog)),
        title: Row(
          children: [
            Icon(_categoryIcon(alert.category), color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                alert.title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: Text(
                alert.severity.displayName.toUpperCase(),
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w800, fontSize: 11),
              ),
            ),
            const SizedBox(height: 12),
            Text(alert.message, style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Text(
              alert.category.displayName,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(alert.date),
              style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
