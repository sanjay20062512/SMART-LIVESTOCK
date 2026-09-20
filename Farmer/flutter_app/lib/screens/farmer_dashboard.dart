// Farmer Dashboard — Simplified, accessible home screen for livestock farmers.
// Features a giant "REPORT ANIMAL PROBLEM" main action, secondary quick actions,
// simplified dynamic health summaries, and multi-language support.

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/farmer_data_service.dart';
import '../services/localization_service.dart';
import '../models/dashboard_stats.dart';
import '../widgets/brand_logo.dart';
import '../widgets/language_selector_button.dart';
import '../widgets/livestock_vector_icon.dart';
import '../models/animal.dart';
import '../models/health_report.dart';
import '../models/mortality_report.dart';
import '../models/vet_request.dart';
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
            // Compact brand logo — preserves aspect ratio, no square container
            const BrandLogo.small(),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                context.tr('app_title'),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Language Selector Button
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LanguageSelectorButton(),
          ),
          const SizedBox(width: 6),

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
              context.tr('farm_health_summary'),
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
                  child: Text(context.tr('see_all_cases')),
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
                  context.tr('hello_farmer', params: {'name': context.translateText(name)}),
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
                    context.translateText(farmName),
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
            child: Column(
              children: [
                const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 16),
                const SizedBox(height: 2),
                Text(context.tr('today'), style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
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
                      Text(
                        context.tr('report_problem_subtitle'),
                        style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.3),
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
            color: AppColors.success,
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
                    color: color == AppColors.success ? AppColors.successLight : color.withValues(alpha: 0.10),
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
          color: AppColors.success,
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
                color: color == AppColors.success ? AppColors.successLight : color.withValues(alpha: 0.10),
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
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.history_rounded, size: 40, color: AppColors.textDisabled),
                const SizedBox(height: 10),
                Text(
                  context.tr('no_recent_activity'),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('use_report_button_to_start'),
                  style: const TextStyle(color: AppColors.textDisabled, fontSize: 12),
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
          bool isLivestock = false;
          AnimalSpecies? species;

          if (type == 'animal_added') {
            isLivestock = true;
            species = item['species'] as AnimalSpecies?;
          } else if (type == 'health_report') {
            iconColor = AppColors.warning;
            iconData = Icons.medical_services_rounded;
          } else if (type == 'mortality_report') {
            iconColor = AppColors.error;
            iconData = Icons.warning_rounded;
          } else if (type == 'vet_request') {
            iconColor = AppColors.info;
            iconData = Icons.local_hospital_rounded;
          }

          String title = item['title'] as String;
          String subtitle = '';

          if (type == 'animal_added') {
            title = context.tr('activity_animal_registered');
            final a = item['animal'] as Animal?;
            final speciesName = (species ?? a?.species)?.displayName ?? context.tr('animal');
            final tag = a?.earTag ?? '';
            final localizedTag = context.translateTag(tag);
            final tagStr = localizedTag.isNotEmpty ? '($localizedTag)' : '';
            final breedStr = a != null ? context.translateBreed(a.breed) : '';
            subtitle = '$speciesName $tagStr • $breedStr'.trim();
          } else if (type == 'health_report') {
            final r = item['report'] as HealthReport?;
            final tag = r?.animalTag ?? '';
            final localizedTag = context.translateTag(tag);
            title = '${context.tr('activity_health_reported')}${localizedTag.isNotEmpty ? ': $localizedTag' : ''}';
            if (r != null) {
              final riskStr = r.riskLevel.displayName;
              final syms = r.symptoms.take(2).map((s) => context.translateText(s)).join(', ');
              subtitle = '$riskStr — $syms';
            } else {
              subtitle = context.translateText(item['subtitle'] as String);
            }
          } else if (type == 'mortality_report') {
            final m = item['mortality'] as MortalityReport?;
            final tag = m?.animalTag ?? '';
            final localizedTag = context.translateTag(tag);
            title = '${context.tr('activity_mortality_reported')}${localizedTag.isNotEmpty ? ': $localizedTag' : ''}';
            final count = m?.numberAffected ?? 1;
            subtitle = context.tr('animals_affected_count', params: {'count': '$count'});
          } else if (type == 'vet_request') {
            final v = item['request'] as VetRequest?;
            final tag = v?.animalTag ?? '';
            final localizedTag = context.translateTag(tag);
            title = '${context.tr('activity_vet_requested')}${localizedTag.isNotEmpty ? ': $localizedTag' : ''}';
            subtitle = context.translateText(v?.reason ?? item['subtitle'] as String);
          } else {
            subtitle = context.translateText(item['subtitle'] as String);
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
                  child: Center(
                    child: isLivestock
                        ? LivestockVectorIcon(
                            species: species,
                            speciesName: item['speciesName'] as String? ?? item['subtitle'] as String?,
                            color: iconColor,
                            size: 22,
                          )
                        : Icon(iconData, color: iconColor, size: 20),
                  ),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  subtitle,
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