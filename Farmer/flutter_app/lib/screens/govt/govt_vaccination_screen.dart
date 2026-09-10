// Vaccination Command Screen — campaign management and coverage tracking

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import 'govt_theme.dart';
import 'govt_models.dart';
import 'govt_mock_data.dart';
import 'widgets/govt_widgets.dart';

class GovtVaccinationScreen extends StatefulWidget {
  final FarmerDataService dataService;
  const GovtVaccinationScreen({super.key, required this.dataService});

  @override
  State<GovtVaccinationScreen> createState() => _GovtVaccinationScreenState();
}

class _GovtVaccinationScreenState extends State<GovtVaccinationScreen> {
  final _campaigns = GovtMockData.getCampaigns();

  @override
  Widget build(BuildContext context) {
    final totalTarget = _campaigns.fold(0, (s, c) => s + c.targetAnimals);
    final totalVaccinated = _campaigns.fold(0, (s, c) => s + c.vaccinatedAnimals);
    final coveragePct = totalTarget > 0 ? (totalVaccinated / totalTarget * 100) : 0.0;
    final activeCampaigns = _campaigns.where((c) => c.status == CampaignStatus.active).length;

    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: GovtColors.brandDark,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vaccination Command', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                Text('Campaign management & coverage tracking', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
            actions: [
              IconButton(icon: const Icon(Icons.add_circle_outline_rounded), onPressed: () => _showCreateCampaign(context)),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Metrics ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.25,
                    children: [
                      GovernmentMetricCard(label: 'ELIGIBLE ANIMALS', value: '${(totalTarget / 1000).toStringAsFixed(0)}K', icon: Icons.pets_rounded, color: GovtColors.textPrimary),
                      GovernmentMetricCard(label: 'VACCINATED', value: '${(totalVaccinated / 1000).toStringAsFixed(0)}K', icon: Icons.vaccines_rounded, color: GovtColors.success),
                      GovernmentMetricCard(
                        label: 'PENDING',
                        value: '${((totalTarget - totalVaccinated) / 1000).toStringAsFixed(0)}K',
                        icon: Icons.pending_actions_rounded,
                        color: GovtColors.warning,
                      ),
                      GovernmentMetricCard(
                        label: 'COVERAGE',
                        value: '${coveragePct.round()}%',
                        icon: Icons.donut_large_rounded,
                        color: GovtColors.brand,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Coverage Summary ──────────────────────────────────────
                Padding(
                  padding: GovtSpacing.pagePadding,
                  child: GovtSectionCard(
                    child: Row(
                      children: [
                        VaccinationRingChart(percent: coveragePct, label: 'Overall', color: GovtColors.brand),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Overall Coverage', style: GovtTypography.sectionTitle),
                              const SizedBox(height: 4),
                              Text('$activeCampaigns active campaign${activeCampaigns != 1 ? 's' : ''}', style: GovtTypography.caption),
                              const SizedBox(height: 12),
                              GovtProgressBar(value: coveragePct / 100),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Flexible(child: Text('$totalVaccinated vaccinated', style: const TextStyle(fontSize: 11, color: GovtColors.success), overflow: TextOverflow.ellipsis)),
                                  const SizedBox(width: 8),
                                  Flexible(child: Text('${totalTarget - totalVaccinated} pending', style: const TextStyle(fontSize: 11, color: GovtColors.warning), overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: GovtSpacing.pagePadding,
                  child: Row(
                    children: [
                      const Expanded(child: SectionHeader(title: 'Vaccination Campaigns')),
                      GovtButton(label: 'New Campaign', icon: Icons.add_rounded, compact: true, onPressed: () => _showCreateCampaign(context)),
                    ],
                  ),
                ),

                // ── Campaign Cards ────────────────────────────────────────
                ..._campaigns.map((c) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: GestureDetector(
                    onTap: () => _openCampaignDetail(context, c),
                    child: _campaignCard(c),
                  ),
                )),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _campaignCard(VaccinationCampaign c) {
    final statusColor = _statusColor(c.status);
    return Container(
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: GovtRadius.lgRadius,
        border: Border.all(color: GovtColors.border),
        boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: statusColor.withValues(alpha: 0.15))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: GovtRadius.smRadius),
                  child: Icon(Icons.vaccines_rounded, size: 18, color: statusColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: GovtTypography.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(c.disease, style: GovtTypography.caption),
                    ],
                  ),
                ),
                StatusChip(label: c.statusLabel, color: statusColor),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    _campDetail(Icons.location_on_rounded, c.targetDistrict),
                    _campDetail(Icons.pets_rounded, c.animalSpecies),
                    _campDetail(Icons.group_rounded, '${c.assignedTeams.length} teams'),
                  ],
                ),
                const SizedBox(height: 10),
                // Progress
                Row(
                  children: [
                    Text('${c.coveragePercent.round()}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: statusColor)),
                    const SizedBox(width: 10),
                    Expanded(child: GovtProgressBar(value: c.coveragePercent / 100, color: statusColor)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Flexible(child: Text('${c.vaccinatedAnimals.toString().padLeft(5)} vaccinated', style: const TextStyle(fontSize: 11, color: GovtColors.success), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Flexible(child: Text('${c.pendingAnimals} pending', style: const TextStyle(fontSize: 11, color: GovtColors.warning), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: GovtColors.textDisabled),
                    const SizedBox(width: 4),
                    Flexible(child: Text('${_fmt(c.startDate)} – ${_fmt(c.endDate)}', style: GovtTypography.caption, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Text('VIEW DETAILS →', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _campDetail(IconData icon, String text) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: GovtColors.textSecondary),
          const SizedBox(width: 4),
          Flexible(child: Text(text, style: GovtTypography.caption, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  void _openCampaignDetail(BuildContext context, VaccinationCampaign c) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _CampaignDetailScreen(campaign: c)));
  }

  void _showCreateCampaign(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create Campaign — connect to backend'), backgroundColor: GovtColors.brand),
    );
  }

  Color _statusColor(CampaignStatus s) {
    switch (s) {
      case CampaignStatus.active:
        return GovtColors.brand;
      case CampaignStatus.planned:
        return GovtColors.warning;
      case CampaignStatus.paused:
        return GovtColors.riskHigh;
      case CampaignStatus.completed:
        return GovtColors.success;
    }
  }

  String _fmt(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}

// ─── Campaign Detail Screen ────────────────────────────────────────────────────

class _CampaignDetailScreen extends StatelessWidget {
  final VaccinationCampaign campaign;
  const _CampaignDetailScreen({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      appBar: AppBar(
        backgroundColor: GovtColors.surface,
        foregroundColor: GovtColors.textPrimary,
        elevation: 0,
        title: Text(campaign.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: GovtColors.textPrimary)),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: GovtColors.border)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Coverage Ring + Stats
          GovtSectionCard(
            child: Row(
              children: [
                VaccinationRingChart(percent: campaign.coveragePercent, label: 'Coverage', color: GovtColors.brand),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(campaign.disease, style: GovtTypography.bodyMedium),
                      const SizedBox(height: 8),
                      _statRow('Target', '${campaign.targetAnimals}', GovtColors.textPrimary),
                      _statRow('Vaccinated', '${campaign.vaccinatedAnimals}', GovtColors.success),
                      _statRow('Pending', '${campaign.pendingAnimals}', GovtColors.warning),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          GovtSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Campaign Details'),
                _infoRow('District', campaign.targetDistrict),
                _infoRow('Block', campaign.targetBlock),
                _infoRow('Villages', campaign.targetVillages),
                _infoRow('Species', campaign.animalSpecies),
                _infoRow('Start Date', '${campaign.startDate.day}/${campaign.startDate.month}/${campaign.startDate.year}'),
                _infoRow('End Date', '${campaign.endDate.day}/${campaign.endDate.month}/${campaign.endDate.year}'),
                _infoRow('Teams Assigned', campaign.assignedTeams.join(', ')),
              ],
            ),
          ),

          const SizedBox(height: 12),

          GovtSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Daily Progress', subtitle: 'Last 7 days'),
                _barChartSimple([1800, 2200, 1950, 3100, 2800, 3400, 3000]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label, style: GovtTypography.caption),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: GovtTypography.caption)),
          Expanded(child: Text(value, style: GovtTypography.bodyMedium)),
        ],
      ),
    );
  }

  Widget _barChartSimple(List<int> values) {
    final max = values.fold(0, (a, b) => a > b ? a : b).toDouble();
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.asMap().entries.map((e) {
          final pct = e.value / max;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(height: 55 * pct, decoration: BoxDecoration(color: GovtColors.brand, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 3),
                  Text(labels[e.key], style: const TextStyle(fontSize: 8, color: GovtColors.textDisabled)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
