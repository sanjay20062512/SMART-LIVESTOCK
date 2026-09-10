// Smart Livestock — Government Dashboard Screen
// Executive Animal Health Intelligence Dashboard focused on Maharashtra Surveillance.
// Answers immediately: WHERE is the risk? WHAT disease? WHY is it high-risk? WHAT to do next?

import 'package:flutter/material.dart';
import 'govt_theme.dart';
import 'govt_models.dart';
import 'govt_mock_data.dart';
import 'widgets/govt_maharashtra_map_widget.dart';
import 'govt_area_detail_screen.dart';
import '../../services/farmer_data_service.dart';

class GovtDashboardScreen extends StatefulWidget {
  final FarmerDataService dataService;
  final ValueChanged<int>? onNavigateTab;

  const GovtDashboardScreen({
    super.key,
    required this.dataService,
    this.onNavigateTab,
  });

  @override
  State<GovtDashboardScreen> createState() => _GovtDashboardScreenState();
}

class _GovtDashboardScreenState extends State<GovtDashboardScreen> {
  late List<DistrictRiskProfile> _districts;
  late DistrictRiskProfile _selectedDistrict;
  String _selectedDisease = 'All';
  String _selectedTimeframe = '7 Days';

  // Location selector state
  String _currentDistrict = 'All Districts';
  final String _currentBlock = 'All Blocks';

  @override
  void initState() {
    super.initState();
    _districts = GovtMockData.getMaharashtraDistricts();
    _selectedDistrict = _districts.first; // Nagpur (81% Critical)
  }

  void _onDistrictSelected(DistrictRiskProfile d) {
    setState(() {
      _selectedDistrict = d;
      _currentDistrict = d.name;
    });
  }

  void _navigateToAreaDetail(DistrictRiskProfile d) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GovtAreaDetailScreen(
          district: d,
          dataService: widget.dataService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Location Selector Breadcrumb ──────────────────────────────────
            _buildLocationSelector(),
            const SizedBox(height: 14),

            // ── Top KPI Row (Only 4 Compact Cards) ───────────────────────────
            _buildKpiRow(),
            const SizedBox(height: 16),

            // ── Main Feature: Disease Heat Map ────────────────────────────────
            GovtMaharashtraMapWidget(
              districts: _districts,
              selectedDistrict: _selectedDistrict,
              onSelectDistrict: _onDistrictSelected,
              selectedDisease: _selectedDisease,
              onDiseaseChanged: (d) => setState(() => _selectedDisease = d),
              selectedTimeframe: _selectedTimeframe,
              onTimeframeChanged: (t) => setState(() => _selectedTimeframe = t),
            ),
            const SizedBox(height: 14),

            // ── Selected District Detail Panel (Directly on Dashboard) ────────
            _buildDistrictIntelligencePanel(),
            const SizedBox(height: 16),

            // ── "Why Is Risk Increasing?" Intelligence Panel ───────────────────
            _buildWhyRiskIncreasingPanel(),
            const SizedBox(height: 16),

            // ── Priority Actions ──────────────────────────────────────────────
            _buildPriorityActions(),
            const SizedBox(height: 16),

            // ── Recent Alerts (Top 3 Only) ────────────────────────────────────
            _buildRecentAlertsSection(),
          ],
        ),
      ),
    );
  }

  // ─── 1. Location Selector ───────────────────────────────────────────────────

  Widget _buildLocationSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GovtColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 16, color: GovtColors.brand),
            const SizedBox(width: 8),
            const Text('Maharashtra', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GovtColors.textPrimary)),
            const Text(' → ', style: TextStyle(fontSize: 12, color: GovtColors.textMuted)),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _currentDistrict,
                isDense: true,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GovtColors.brand),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: GovtColors.brand),
                items: [
                  'All Districts',
                  ..._districts.map((d) => d.name),
                ].map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _currentDistrict = val;
                      if (val != 'All Districts') {
                        final found = _districts.firstWhere((d) => d.name == val);
                        _selectedDistrict = found;
                      }
                    });
                  }
                },
              ),
            ),
            const Text(' → ', style: TextStyle(fontSize: 12, color: GovtColors.textMuted)),
            Text(_currentBlock, style: const TextStyle(fontSize: 11.5, color: GovtColors.textMuted)),
          ],
        ),
      ),
    );
  }

  // ─── 2. Top KPI Row ─────────────────────────────────────────────────────────

  Widget _buildKpiRow() {
    return Row(
      children: [
        Expanded(
          child: _kpiCard(
            label: 'ACTIVE CASES',
            value: '248',
            trend: '+12% this week',
            isNegative: true,
            icon: Icons.coronavirus_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _kpiCard(
            label: 'HIGH-RISK AREAS',
            value: '07',
            trend: '3 critical',
            isNegative: true,
            icon: Icons.warning_amber_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _kpiCard(
            label: 'MORTALITY',
            value: '18',
            trend: '-8% this week',
            isNegative: false,
            icon: Icons.heart_broken_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _kpiCard(
            label: 'VACCINATION',
            value: '76%',
            trend: '+5% this month',
            isNegative: false,
            icon: Icons.vaccines_outlined,
          ),
        ),
      ],
    );
  }

  Widget _kpiCard({
    required String label,
    required String value,
    required String trend,
    required bool isNegative,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GovtColors.border),
        boxShadow: const [
          BoxShadow(color: GovtColors.shadow, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: GovtTypography.metricLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 14, color: GovtColors.textMuted),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GovtTypography.metricValue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            trend,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isNegative ? GovtColors.critical : GovtColors.success,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─── 3. Selected District Detail Panel ──────────────────────────────────────

  Widget _buildDistrictIntelligencePanel() {
    final d = _selectedDistrict;
    final riskColor = GovtColors.getHeatmapColor(d.riskScore);
    final riskLight = GovtColors.getHeatmapLightColor(d.riskScore);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: GovtColors.border),
        boxShadow: const [
          BoxShadow(color: GovtColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // District Header & Severity Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.name.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GovtColors.textPrimary), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('Primary Disease: ${d.primaryDisease}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GovtColors.brand), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: riskLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: riskColor.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${d.riskScore}% RISK', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: riskColor)),
                    Text(d.riskLevel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: riskColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4 Sub-metrics Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: GovtColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(child: _subMetric('Cases', '${d.cases}')),
                _divider(),
                Expanded(child: _subMetric('Mortality', '${d.mortality}')),
                _divider(),
                Expanded(child: _subMetric('Vaccine', '${d.vaccinationCoverage}%')),
                _divider(),
                Expanded(child: _subMetric('Trend', d.trend, color: d.trend.startsWith('↑') ? GovtColors.critical : GovtColors.success)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // WHY IS THIS AREA HIGH-RISK?
          const Text(
            'WHY IS THIS AREA HIGH-RISK?',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.3, color: GovtColors.textPrimary),
          ),
          const SizedBox(height: 6),
          ...d.whyHighRisk.take(3).map((reason) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: GovtColors.brand, fontWeight: FontWeight.w800)),
                Expanded(
                  child: Text(
                    reason,
                    style: const TextStyle(fontSize: 12, color: GovtColors.textSecondary, height: 1.3),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 10),

          // RECOMMENDED ACTION
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: GovtColors.brandFaint,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: GovtColors.brandLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded, size: 16, color: GovtColors.brand),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('RECOMMENDED ACTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GovtColors.brandDark)),
                      const SizedBox(height: 2),
                      Text(
                        d.recommendedAction,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: GovtColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Button: VIEW AREA DETAILS
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: GovtColors.brand,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('VIEW AREA DETAILS', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              onPressed: () => _navigateToAreaDetail(d),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subMetric(String label, String val, {Color? color}) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color ?? GovtColors.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9.5, color: GovtColors.textMuted)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 20, color: GovtColors.border);
  }

  // ─── 4. "WHY IS RISK INCREASING?" Intelligence Panel ────────────────────────

  Widget _buildWhyRiskIncreasingPanel() {
    final factors = GovtMockData.whyRiskFactors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: GovtColors.border),
        boxShadow: const [
          BoxShadow(color: GovtColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(
                child: Text('WHY IS RISK INCREASING?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.3, color: GovtColors.textPrimary), overflow: TextOverflow.ellipsis),
              ),
              SizedBox(width: 8),
              Text('State Overview', style: TextStyle(fontSize: 11, color: GovtColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          ...factors.map((f) {
            final double prog = (f['progress'] as num).toDouble();
            final String title = f['title'] as String;
            final String val = f['value'] as String;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GovtColors.textPrimary), overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: prog,
                        minHeight: 8,
                        backgroundColor: GovtColors.surfaceSubtle,
                        valueColor: const AlwaysStoppedAnimation(GovtColors.brand),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 44,
                    child: Text(
                      val,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: GovtColors.critical),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── 5. Priority Actions ────────────────────────────────────────────────────

  Widget _buildPriorityActions() {
    final actions = GovtMockData.priorityActions;

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
          const Text('PRIORITY ACTIONS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.3, color: GovtColors.textPrimary)),
          const SizedBox(height: 10),
          ...actions.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: GovtColors.brandDark,
                    content: Text('Action Selected: ${item['detail']}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: GovtColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: GovtColors.border),
                ),
                child: Row(
                  children: [
                    Text(item['icon']!, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item['label']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GovtColors.textPrimary), overflow: TextOverflow.ellipsis),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 16, color: GovtColors.textMuted),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  // ─── 6. Recent Alerts (Top 3 Only) ──────────────────────────────────────────

  Widget _buildRecentAlertsSection() {
    final alerts = GovtMockData.recentAlerts;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text('RECENT ALERTS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.3, color: GovtColors.textPrimary), overflow: TextOverflow.ellipsis),
              ),
              TextButton(
                onPressed: () => widget.onNavigateTab?.call(2), // Jump to Alerts Tab (index 2)
                child: const Text('VIEW ALL ALERTS →', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.brand)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...alerts.map((a) {
            final color = a['severity'] == 'critical'
                ? GovtColors.critical
                : (a['severity'] == 'warning' ? GovtColors.warning : GovtColors.info);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: GovtColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: GovtColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 4, right: 8),
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a['title']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GovtColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text('${a['location']} • ${a['time']}', style: const TextStyle(fontSize: 11, color: GovtColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
