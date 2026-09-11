// Smart Livestock — Government Vaccination Campaigns Command Center
// Connected directly to the Maharashtra Disease Risk Map & Village Field Teams.
// Follows the clean, light design system of Farmer & Veterinary modules.

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import 'govt_theme.dart';
import 'govt_models.dart';
import 'govt_mock_data.dart';
import 'govt_campaign_engine.dart';
import 'govt_campaign_detail_screen.dart';
import 'widgets/govt_create_campaign_dialog.dart';
import 'widgets/govt_maharashtra_map_widget.dart';

class GovtVaccinationScreen extends StatefulWidget {
  final FarmerDataService dataService;

  const GovtVaccinationScreen({
    super.key,
    required this.dataService,
  });

  @override
  State<GovtVaccinationScreen> createState() => _GovtVaccinationScreenState();
}

class _GovtVaccinationScreenState extends State<GovtVaccinationScreen> {
  late List<VaccinationCampaign> _campaigns;
  late List<DistrictRiskProfile> _districts;
  late DistrictRiskProfile _selectedMapDistrict;
  String _selectedDisease = 'All';
  String _selectedTimeframe = '7 Days';

  @override
  void initState() {
    super.initState();
    _campaigns = GovtMockData.getCampaigns();
    _districts = GovtMockData.getMaharashtraDistricts();

    // Default selected district to Pune (Critical gap)
    _selectedMapDistrict = _districts.firstWhere(
      (d) => d.name.toLowerCase() == 'pune',
      orElse: () => _districts.first,
    );
  }

  void _openCreateCampaignFlow({
    String? district,
    String? disease,
    CampaignPriority? priority,
  }) {
    GovtCreateCampaignDialog.show(
      context,
      initialDistrict: district,
      initialDisease: disease,
      initialPriority: priority,
      onCampaignCreated: (newCamp) {
        setState(() {
          _campaigns.insert(0, newCamp);
        });
      },
    );
  }

  void _openCampaignDetails(VaccinationCampaign c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GovtCampaignDetailScreen(
          campaign: c,
          dataService: widget.dataService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Exact aggregates per spec: 6 active, 24,850 target, 17,420 vaccinated, 70.1% coverage
    final activeCount = _campaigns.where((c) => c.status == CampaignStatus.active).length;
    final totalTarget = _campaigns.fold(0, (s, c) => s + c.targetAnimals);
    final totalVaccinated = _campaigns.fold(0, (s, c) => s + c.vaccinatedAnimals);
    final coveragePct = totalTarget > 0 ? (totalVaccinated / totalTarget * 100) : 0.0;

    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      appBar: AppBar(
        backgroundColor: GovtColors.surface,
        foregroundColor: GovtColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VACCINATION CAMPAIGNS',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GovtColors.textPrimary, letterSpacing: -0.2),
            ),
            Text(
              'Government Field Immunization & Risk Response',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: GovtColors.brandDark),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: GovtColors.brand,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('CREATE CAMPAIGN', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
              onPressed: () => _openCreateCampaignFlow(),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: GovtColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 1. CAMPAIGN OVERVIEW (Top Strip) ──────────────────────────────
            _buildCampaignOverview(activeCount, totalTarget, totalVaccinated, coveragePct),
            const SizedBox(height: 16),

            // ── 2. RISK-TO-CAMPAIGN INTELLIGENCE ("CAMPAIGN PRIORITY") ────────
            _buildRiskToCampaignIntelligence(),
            const SizedBox(height: 16),

            // ── 3. SECONDARY CAMPAIGN MAP (Reused Maharashtra Map) ────────────
            _buildCampaignMapView(),
            const SizedBox(height: 16),

            // ── 4. ACTIVE CAMPAIGNS ───────────────────────────────────────────
            _buildActiveCampaignsSection(),
            const SizedBox(height: 16),

            // ── 5. CAMPAIGN ALERTS ────────────────────────────────────────────
            _buildCampaignAlertsSection(),
            const SizedBox(height: 16),

            // ── 6. CAMPAIGN PERFORMANCE (Progress Timeline Chart) ─────────────
            _buildCampaignPerformanceChart(),
          ],
        ),
      ),
    );
  }

  // ─── 1. Campaign Overview ───────────────────────────────────────────────────

  Widget _buildCampaignOverview(int active, int target, int vaccinated, double coverage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: GovtColors.border),
        boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(
                child: Text(
                  'VACCINATION CAMPAIGNS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: GovtColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'State Coverage Overview',
                style: TextStyle(fontSize: 10.5, color: GovtColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 360) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _overviewStat('Active Campaigns', active.toString().padLeft(2, '0'), GovtColors.brandDark)),
                        _verticalDivider(),
                        Expanded(child: _overviewStat('Animals Targeted', _fmtNumber(target), GovtColors.textPrimary)),
                      ],
                    ),
                    const Divider(height: 16, color: GovtColors.border),
                    Row(
                      children: [
                        Expanded(child: _overviewStat('Vaccinated', _fmtNumber(vaccinated), GovtColors.riskLow)),
                        _verticalDivider(),
                        Expanded(child: _overviewStat('Coverage', '${coverage.toStringAsFixed(1)}%', GovtColors.brand)),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _overviewStat('Active Campaigns', active.toString().padLeft(2, '0'), GovtColors.brandDark),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: _overviewStat('Animals Targeted', _fmtNumber(target), GovtColors.textPrimary),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: _overviewStat('Vaccinated', _fmtNumber(vaccinated), GovtColors.riskLow),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: _overviewStat('Coverage', '${coverage.toStringAsFixed(1)}%', GovtColors.brand),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _overviewStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: GovtColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 1, height: 28, color: GovtColors.border);
  }

  // ─── 2. Risk-To-Campaign Intelligence ("CAMPAIGN PRIORITY") ─────────────────

  Widget _buildRiskToCampaignIntelligence() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: GovtColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: const [
              Text(
                'CAMPAIGN PRIORITY',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: GovtColors.textPrimary),
              ),
              Text(
                'Risk-to-Vaccination Intelligence',
                style: TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: GovtColors.brand),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // PUNE Priority Card
          _buildPriorityIntelligenceCard(
            district: 'PUNE',
            diseaseRisk: '78% CRITICAL',
            riskColor: GovtColors.critical,
            vaccination: '61%',
            coverageGap: '17%',
            recommendation: 'Launch targeted FMD vaccination campaign.',
            disease: 'FMD',
            priority: CampaignPriority.critical,
          ),
          const SizedBox(height: 12),

          // NASHIK Priority Card
          _buildPriorityIntelligenceCard(
            district: 'NASHIK',
            diseaseRisk: '68% HIGH',
            riskColor: GovtColors.warning,
            vaccination: '54%',
            coverageGap: '22%',
            recommendation: 'Increase vaccination coverage.',
            disease: 'Brucellosis',
            priority: CampaignPriority.high,
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityIntelligenceCard({
    required String district,
    required String diseaseRisk,
    required Color riskColor,
    required String vaccination,
    required String coverageGap,
    required String recommendation,
    required String disease,
    required CampaignPriority priority,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GovtColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GovtColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                district,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GovtColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: riskColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⚠ ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: riskColor)),
                    Text(
                      'HIGH PRIORITY',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: riskColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Metrics row: Disease Risk, Vaccination, Coverage Gap
          Row(
            children: [
              Expanded(
                child: _subMetricPair('Disease Risk', diseaseRisk, riskColor),
              ),
              Expanded(
                child: _subMetricPair('Vaccination', vaccination, GovtColors.brand),
              ),
              Expanded(
                child: _subMetricPair('Coverage Gap', coverageGap, GovtColors.critical),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Recommendation & Create Campaign Button
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: GovtColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RECOMMENDATION:',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: GovtColors.textSecondary, letterSpacing: 0.3),
                ),
                const SizedBox(height: 3),
                Text(
                  recommendation,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GovtColors.textPrimary),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GovtColors.brand,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 15),
                    label: const Text('CREATE CAMPAIGN', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                    onPressed: () => _openCreateCampaignFlow(
                      district: district,
                      disease: disease,
                      priority: priority,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _subMetricPair(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: GovtColors.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  // ─── 3. Secondary Campaign Map (Reusing Maharashtra Map) ────────────────────

  Widget _buildCampaignMapView() {
    final d = _selectedMapDistrict;
    final isPune = d.name.toLowerCase() == 'pune';

    // Per prompt Section 6:
    // PUNE: Vaccination Coverage 61%, Campaign Progress 70%, Target Villages 18, Pending Villages 7, [VIEW CAMPAIGN]
    final coverage = isPune ? 61 : d.vaccinationCoverage;
    final progress = isPune ? 70 : (coverage + 10).clamp(0, 100);
    final targetVillages = isPune ? 18 : 12;
    final pendingVillages = isPune ? 7 : 4;

    return Container(
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: GovtColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Expanded(
                  child: Text(
                    'CAMPAIGN COVERAGE MAP',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: GovtColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Tap district to inspect',
                  style: TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: GovtColors.textMuted),
                ),
              ],
            ),
          ),

          // Reused Maharashtra Map Widget in vaccinationCoverage mode
          GovtMaharashtraMapWidget(
            districts: _districts,
            selectedDistrict: _selectedMapDistrict,
            onSelectDistrict: (dist) => setState(() => _selectedMapDistrict = dist),
            selectedDisease: _selectedDisease,
            onDiseaseChanged: (dis) => setState(() => _selectedDisease = dis),
            selectedTimeframe: _selectedTimeframe,
            onTimeframeChanged: (time) => setState(() => _selectedTimeframe = time),
            mode: MapDisplayMode.vaccinationCoverage,
          ),
          const SizedBox(height: 10),

          // Selected District Campaign Inspector
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GovtColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GovtColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        d.name.toUpperCase(),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GovtColors.textPrimary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: (coverage >= 80
                              ? const Color(0xFF16A34A)
                              : (coverage >= 50 ? const Color(0xFFCA8A04) : const Color(0xFFDC2626)))
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          coverage >= 80 ? 'GOOD' : (coverage >= 50 ? 'NEEDS ATTENTION' : 'CRITICAL GAP'),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: coverage >= 80
                                ? const Color(0xFF16A34A)
                                : (coverage >= 50 ? const Color(0xFFCA8A04) : const Color(0xFFDC2626)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 4 key metrics
                  Row(
                    children: [
                      Expanded(child: _subMetricPair('Vaccination Coverage', '$coverage%', GovtColors.brand)),
                      Expanded(child: _subMetricPair('Campaign Progress', '$progress%', GovtColors.textPrimary)),
                      Expanded(child: _subMetricPair('Target Villages', '$targetVillages', GovtColors.textPrimary)),
                      Expanded(child: _subMetricPair('Pending Villages', '$pendingVillages', GovtColors.warning)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Button: VIEW CAMPAIGN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GovtColors.brandDark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                      label: const Text('VIEW CAMPAIGN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      onPressed: () {
                        // Find active campaign for this district or open default
                        final match = _campaigns.firstWhere(
                          (c) => c.targetDistrict.toLowerCase() == d.name.toLowerCase(),
                          orElse: () => _campaigns.first,
                        );
                        _openCampaignDetails(match);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 4. Active Campaigns ────────────────────────────────────────────────────

  Widget _buildActiveCampaignsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: GovtColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: const [
              Text(
                'ACTIVE CAMPAIGNS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: GovtColors.textPrimary),
              ),
              Text(
                'High-priority operational drives',
                style: TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: GovtColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Show the top active campaigns (e.g. Pune FMD & Nashik Brucellosis)
          ..._campaigns.take(4).map((c) => _buildCampaignCard(c)),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(VaccinationCampaign c) {
    final progress = c.coveragePercent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GovtColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GovtColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name.toUpperCase(),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GovtColors.textPrimary),
                    ),
                    Text(
                      '${c.targetDistrict} District',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GovtColors.brandDark),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: GovtColors.riskLow.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: GovtColors.riskLow),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: GovtColors.riskLow),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Target animals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Target: ${_fmtNumber(c.targetAnimals)} animals',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: GovtColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Progress: ${progress.round()}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GovtColors.brand),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress / 100.0,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(GovtColors.brand),
            ),
          ),
          const SizedBox(height: 12),

          // Button: VIEW CAMPAIGN
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: GovtColors.brand,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              icon: const Icon(Icons.visibility_outlined, size: 15),
              label: const Text('VIEW CAMPAIGN', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
              onPressed: () => _openCampaignDetails(c),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 5. Campaign Alerts ─────────────────────────────────────────────────────

  Widget _buildCampaignAlertsSection() {
    final alerts = GovtMockData.getCampaignAlerts();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: GovtColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CAMPAIGN ALERTS',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: GovtColors.textPrimary),
          ),
          const SizedBox(height: 10),

          ...alerts.map((a) {
            final isLow = a['type'] == 'low_coverage';
            final color = isLow ? GovtColors.critical : GovtColors.riskLow;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(isLow ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded, size: 15, color: color),
                      const SizedBox(width: 6),
                      Text(
                        a['title'] as String,
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${a['district']} — ${a['village']}',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: GovtColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Text('Vaccination: ${a['vaccination']}%', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: color)),
                      Text('Target: ${a['target']}', style: const TextStyle(fontSize: 11, color: GovtColors.textMuted)),
                      Text('Completed: ${a['completed']}', style: const TextStyle(fontSize: 11, color: GovtColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Action: "${a['action']}"',
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: GovtColors.textSecondary),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── 6. Campaign Performance Progress Chart ─────────────────────────────────

  Widget _buildCampaignPerformanceChart() {
    // 42% → 51% → 63% → 70% per prompt
    final stages = [
      {'label': 'Day 1', 'val': 42},
      {'label': 'Day 7', 'val': 51},
      {'label': 'Day 14', 'val': 63},
      {'label': 'Day 21', 'val': 70},
      {'label': 'Day 30', 'val': 78},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: GovtColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CAMPAIGN PERFORMANCE',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: GovtColors.textPrimary),
          ),
          const SizedBox(height: 2),
          const Text(
            'Vaccination Coverage — Campaign Progress',
            style: TextStyle(fontSize: 11, color: GovtColors.textMuted),
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: stages.asMap().entries.map((entry) {
              final idx = entry.key;
              final s = entry.value;
              final isLast = idx == stages.length - 1;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: isLast ? GovtColors.brandLight : GovtColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: isLast ? GovtColors.brand : GovtColors.border),
                            ),
                            child: Text(
                              '${s['val']}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isLast ? GovtColors.brandDark : GovtColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isLast ? GovtColors.brand : GovtColors.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(s['label'] as String, style: const TextStyle(fontSize: 9.5, color: GovtColors.textMuted)),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 14,
                        height: 1.5,
                        color: GovtColors.border,
                        margin: const EdgeInsets.only(bottom: 12),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _fmtNumber(int n) {
    if (n >= 1000) {
      final k = n / 1000;
      return '${k.toStringAsFixed(k % 1 == 0 ? 0 : 1)}k';
    }
    return '$n';
  }
}
