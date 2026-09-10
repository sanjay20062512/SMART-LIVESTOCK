// Farmer Dashboard — Simplified, accessible home screen for livestock farmers.
// Features a giant "REPORT ANIMAL PROBLEM" main action, secondary quick actions,
// simplified dynamic health summaries, and multi-language support.

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../services/localization_service.dart';
import '../models/dashboard_stats.dart';
import '../theme/app_theme.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.border,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppRadius.smRadius,
              ),
              child: const Icon(Icons.agriculture_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              context.tr('app_title'),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 19,
                color: AppColors.primary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          // Online Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: AppRadius.fullRadius,
              border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  context.tr('online'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.successDark,
                  ),
                ),
              ],
            ),
          ),

          // Alerts Icon with Badge
          IconButton(
            icon: Badge(
              isLabelVisible: dataService.unreadAlertCount > 0,
              label: Text('${dataService.unreadAlertCount}'),
              backgroundColor: AppColors.error,
              child: const Icon(Icons.notifications_outlined, size: 24, color: AppColors.textSecondary),
            ),
            tooltip: context.tr('alerts'),
            onPressed: () => onNavigateToTab(3),
          ),
          const SizedBox(width: 4),
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppShadows.primaryShadow(AppColors.primary),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: AppRadius.smRadius,
            ),
            child: const Center(
              child: Text('👨‍🌾', style: TextStyle(fontSize: 28)),
            ),
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
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                if (farmName != null && farmName.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    farmName,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: AppRadius.smRadius,
            ),
            child: const Column(
              children: [
                Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 16),
                SizedBox(height: 2),
                Text('Today', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Giant, high-contrast button for farmers — intentionally red for emergency visibility
  Widget _buildGiantReportButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.lgRadius,
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.farmerEmergency, Color(0xFFB71C1C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.lgRadius,
          boxShadow: AppShadows.primaryShadow(AppColors.farmerEmergency),
        ),
        child: InkWell(
          borderRadius: AppRadius.lgRadius,
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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.smRadius,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.medical_services_rounded,
                      color: AppColors.farmerEmergency,
                      size: 32,
                    ),
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
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Tap here to describe symptoms & get advice',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.3),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: AppRadius.xsRadius,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.mdRadius,
        child: InkWell(
          borderRadius: AppRadius.mdRadius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: AppRadius.smRadius,
                  ),
                  child: Center(child: Icon(icon, color: color, size: 24)),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: color,
                    height: 1.3,
                  ),
                ),
              ],
            ),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: AppRadius.smRadius,
              ),
              child: Center(child: Icon(icon, color: color, size: 20)),
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
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
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
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: const Padding(
          padding: EdgeInsets.all(28),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.history_rounded, size: 40, color: AppColors.textDisabled),
                SizedBox(height: 10),
                Text(
                  'No recent reports or actions yet.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Use the Report button above to get started.',
                  style: TextStyle(color: AppColors.textDisabled, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: activity.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == activity.length - 1;
          final type = item['type'] as String;

          Color iconColor = AppColors.success;
          IconData iconData = Icons.pets_rounded;

          if (type == 'health_report') {
            iconColor = AppColors.warning;
            iconData = Icons.medical_services_rounded;
          } else if (type == 'mortality_report') {
            iconColor = AppColors.error;
            iconData = Icons.warning_rounded;
          } else if (type == 'vet_request') {
            iconColor = AppColors.info;
            iconData = Icons.local_hospital_rounded;
          }

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: AppRadius.smRadius,
                  ),
                  child: Center(child: Icon(iconData, color: iconColor, size: 20)),
                ),
                title: Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  item['subtitle'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: AppRadius.xsRadius,
                  ),
                  child: const Center(
                    child: Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
                  ),
                ),
                onTap: () => onNavigateToTab(1),
              ),
              if (!isLast) const Divider(height: 1, indent: 72, endIndent: 16, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }
}