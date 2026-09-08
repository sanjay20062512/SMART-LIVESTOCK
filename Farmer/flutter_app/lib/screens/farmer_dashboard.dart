// Farmer Dashboard — Simplified, accessible home screen for livestock farmers.
// Features a giant "REPORT ANIMAL PROBLEM" main action, secondary quick actions,
// simplified dynamic health summaries, and multi-language support.

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../services/localization_service.dart';
import '../models/dashboard_stats.dart';
import 'symptom_report_screen.dart';
import 'vet_request_screen.dart';

class FarmerDashboard extends StatelessWidget {
  final FarmerDataService dataService;
  final void Function(int index) onNavigateToTab;

  const FarmerDashboard({
    super.key,
    required this.dataService,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final stats = dataService.getDashboardStatistics();
    final profile = dataService.profile;
    final activity = dataService.getRecentActivity(limit: 6);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.agriculture_rounded, color: colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 10),
            Text(
              context.tr('app_title'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          // Online Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  context.tr('online'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Alerts Icon with Badge
          IconButton(
            icon: Badge(
              isLabelVisible: dataService.unreadAlertCount > 0,
              label: Text('${dataService.unreadAlertCount}'),
              child: const Icon(Icons.notifications_outlined, size: 26),
            ),
            tooltip: context.tr('alerts'),
            onPressed: () => onNavigateToTab(3),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Header
            _buildWelcomeHeader(context, profile.fullName, profile.farmName, colorScheme),
            const SizedBox(height: 20),

            // ==============================================================
            // MAIN ACTION: GIANT "REPORT ANIMAL PROBLEM" BUTTON
            // ==============================================================
            _buildGiantReportButton(context),
            const SizedBox(height: 22),

            // Secondary Quick Actions
            _buildSecondaryActions(context),
            const SizedBox(height: 24),

            // Simple Health Summary (4 clear cards)
            Text(
              'Farm Health Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            _buildHealthSummaryGrid(context, stats),
            const SizedBox(height: 24),

            // Recent Activity Feed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('recent_activity'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateToTab(1),
                  child: const Text('See All Cases'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRecentActivityList(context, activity),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, String name, String? farmName, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: const Text('👨‍🌾', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('hello_farmer', params: {'name': name}),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (farmName != null && farmName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    farmName,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Giant, high-contrast button for farmers
  Widget _buildGiantReportButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD32F2F).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: const Color(0xFFC62828), // High visibility deep red/orange
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SymptomReportScreen(dataService: dataService),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    color: Color(0xFFC62828),
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('report_animal_problem'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap here to describe symptoms & get advice',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryActions(BuildContext context) {
    return Row(
      children: [
        // My Cases / Animals
        Expanded(
          child: _buildActionTile(
            context,
            icon: Icons.pets_rounded,
            title: context.tr('my_animals_cases'),
            color: const Color(0xFF2E7D32),
            onTap: () => onNavigateToTab(1),
          ),
        ),
        const SizedBox(width: 12),

        // Request Veterinarian
        Expanded(
          child: _buildActionTile(
            context,
            icon: Icons.local_hospital_rounded,
            title: context.tr('request_veterinarian'),
            color: const Color(0xFF1976D2),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VetRequestScreen(dataService: dataService),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthSummaryGrid(BuildContext context, DashboardStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          label: context.tr('animals_reported'),
          value: '${stats.totalAnimals}',
          icon: Icons.pets_rounded,
          color: const Color(0xFF2E7D32),
        ),
        _buildStatCard(
          label: context.tr('active_cases'),
          value: '${stats.activeCases}',
          icon: Icons.emergency_rounded,
          color: stats.activeCases > 0 ? const Color(0xFFD32F2F) : Colors.grey,
        ),
        _buildStatCard(
          label: context.tr('vaccination_due'),
          value: '${stats.vaccinationsDue}',
          icon: Icons.vaccines_rounded,
          color: const Color(0xFF7B1FA2),
        ),
        _buildStatCard(
          label: context.tr('important_alerts'),
          value: '${stats.importantAlerts}',
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFE65100),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList(BuildContext context, List<Map<String, dynamic>> activity) {
    if (activity.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.history_rounded, size: 36, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'No recent reports or actions yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1.5,
      child: Column(
        children: activity.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == activity.length - 1;
          final type = item['type'] as String;

          Color iconColor = Colors.green;
          IconData iconData = Icons.pets_rounded;

          if (type == 'health_report') {
            iconColor = Colors.orange.shade800;
            iconData = Icons.medical_services_rounded;
          } else if (type == 'mortality_report') {
            iconColor = Colors.red.shade900;
            iconData = Icons.warning_rounded;
          } else if (type == 'vet_request') {
            iconColor = Colors.blue.shade800;
            iconData = Icons.local_hospital_rounded;
          }

          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: iconColor.withValues(alpha: 0.15),
                  child: Icon(iconData, color: iconColor, size: 20),
                ),
                title: Text(
                  item['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  item['subtitle'] as String,
                  style: const TextStyle(fontSize: 12.5),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                onTap: () => onNavigateToTab(1),
              ),
              if (!isLast) const Divider(height: 1, indent: 64, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}