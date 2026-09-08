// Alerts Screen — dynamic list of all alerts.

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../models/alert.dart';

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
        return Colors.blue;
      case AlertSeverity.warning:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.red;
      case AlertSeverity.critical:
        return Colors.red.shade900;
    }
  }

  IconData _categoryIcon(AlertCategory c) {
    switch (c) {
      case AlertCategory.diseaseAlert:
        return Icons.coronavirus;
      case AlertCategory.vaccinationReminder:
        return Icons.vaccines;
      case AlertCategory.followUpReminder:
        return Icons.calendar_today;
      case AlertCategory.weatherRisk:
        return Icons.cloud;
      case AlertCategory.governmentAdvisory:
        return Icons.policy;
      case AlertCategory.veterinarianMessage:
        return Icons.local_hospital;
      case AlertCategory.mortalityAlert:
        return Icons.warning;
      case AlertCategory.highRiskHealthAlert:
        return Icons.health_and_safety;
    }
  }

  @override
  Widget build(BuildContext context) {
    final alerts = widget.dataService.getAlerts();
    final unread = widget.dataService.unreadAlertCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alerts & Advisories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => widget.dataService.markAllAlertsRead(),
              child: const Text('Mark All Read'),
            ),
        ],
      ),
      body: alerts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No alerts yet.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Alerts will appear here when health reports,\nmortality events, or advisories are created.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
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
                    color: Colors.green,
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    widget.dataService.markAlertRead(alert.id);
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: alert.isRead
                            ? Colors.transparent
                            : color.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    color: alert.isRead ? null : color.withValues(alpha: 0.04),
                    child: InkWell(
                      onTap: () {
                        widget.dataService.markAlertRead(alert.id);
                        _showAlertDetails(context, alert, color);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  backgroundColor: color.withValues(alpha: 0.15),
                                  child: Icon(
                                    _categoryIcon(alert.category),
                                    color: color,
                                    size: 22,
                                  ),
                                ),
                                if (!alert.isRead)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 5,
                                      backgroundColor: color,
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
                                                ? FontWeight.normal
                                                : FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          alert.severity.displayName
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: color,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    alert.category.displayName,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    alert.message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(alert.date),
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 11),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(_categoryIcon(alert.category), color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(alert.title)),
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
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                alert.severity.displayName.toUpperCase(),
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(alert.message),
            const SizedBox(height: 12),
            Text(
              alert.category.displayName,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            Text(
              _formatDate(alert.date),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
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
