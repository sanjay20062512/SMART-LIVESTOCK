// Report Hub Screen — Report tab in the bottom navigation.

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../services/localization_service.dart';

import 'symptom_report_screen.dart';
import 'mortality_report_screen.dart';
import 'vet_request_screen.dart';
import 'my_reports_screen.dart';

class ReportHubScreen extends StatelessWidget {
  final FarmerDataService dataService;

  const ReportHubScreen({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    final recentReports = dataService.getRecentActivity(limit: 5)
        .where((a) =>
            a['type'] == 'health_report' ||
            a['type'] == 'mortality_report' ||
            a['type'] == 'vet_request')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('report_an_issue'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('what_to_report'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Three large actions
            _BigActionCard(
              icon: Icons.health_and_safety,
              label: context.tr('report_symptoms'),
              description: context.tr('report_symptoms_desc'),
              color: Colors.orange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SymptomReportScreen(dataService: dataService),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _BigActionCard(
              icon: Icons.warning_amber_rounded,
              label: context.tr('report_mortality'),
              description: context.tr('report_mortality_desc'),
              color: Colors.red,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MortalityReportScreen(dataService: dataService),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _BigActionCard(
              icon: Icons.local_hospital,
              label: context.tr('request_vet'),
              description: context.tr('request_vet_desc'),
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VetRequestScreen(dataService: dataService),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // My recent reports
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('my_recent_reports'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MyReportsScreen(dataService: dataService),
                    ),
                  ),
                  child: Text(context.tr('see_all_cases')),
                ),
              ],
            ),
            const SizedBox(height: 8),
            recentReports.isEmpty
                ? Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          context.tr('no_reports_yet_desc'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                : Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: recentReports.asMap().entries.map((entry) {
                        final item = entry.value;
                        final isLast =
                            entry.key == recentReports.length - 1;
                        final type = item['type'] as String;
                        return Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _colorForType(type)
                                    .withValues(alpha: 0.15),
                                child: Icon(
                                  _iconForType(type),
                                  color: _colorForType(type),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                type == 'health_report'
                                    ? context.tr('activity_health_reported')
                                    : (type == 'mortality_report'
                                        ? context.tr('activity_mortality_reported')
                                        : (type == 'vet_request'
                                            ? context.tr('activity_vet_requested')
                                            : item['title'] as String)),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                context.translateText(
                                  (item['subtitle'] as String)
                                      .replaceAll('Â·', '•')
                                      .replaceAll('Â', '')
                                      .replaceAll('â€”', '—'),
                                ),
                              ),
                              trailing: Text(
                                _timeAgo(context, item['date'] as DateTime),
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ),
                            if (!isLast)
                              const Divider(
                                  height: 1, indent: 16, endIndent: 16),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'health_report':
        return Colors.orange;
      case 'mortality_report':
        return Colors.red;
      case 'vet_request':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'health_report':
        return Icons.health_and_safety;
      case 'mortality_report':
        return Icons.warning;
      case 'vet_request':
        return Icons.local_hospital;
      default:
        return Icons.description;
    }
  }

  String _timeAgo(BuildContext context, DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return context.tr('just_now');
    if (diff.inHours < 1) return '${diff.inMinutes}m ${context.tr("ago")}';
    if (diff.inDays < 1) return '${diff.inHours}h ${context.tr("ago")}';
    return '${diff.inDays}d ${context.tr("ago")}';
  }
}

class _BigActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _BigActionCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
