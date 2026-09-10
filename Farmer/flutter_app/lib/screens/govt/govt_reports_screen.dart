// Smart Livestock — Government Reports Screen (Tab 4)
// Streamlined analytical reporting: Disease Trend, Vaccination Coverage, Mortality, and High-Risk Areas.

import 'package:flutter/material.dart';
import 'govt_theme.dart';
import '../../services/farmer_data_service.dart';

class GovtReportsScreen extends StatefulWidget {
  final FarmerDataService dataService;

  const GovtReportsScreen({
    super.key,
    required this.dataService,
  });

  @override
  State<GovtReportsScreen> createState() => _GovtReportsScreenState();
}

class _GovtReportsScreenState extends State<GovtReportsScreen> {
  String _timeframe = '7 Days';

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: GovtColors.brandDark,
        content: Text('✓ Maharashtra Epidemiological Report ($_timeframe) exported successfully as PDF.'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      appBar: AppBar(
        backgroundColor: GovtColors.surface,
        foregroundColor: GovtColors.textPrimary,
        elevation: 0,
        title: Text('Surveillance Reports', style: GovtTypography.sectionTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: GovtColors.brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
              icon: const Icon(Icons.download_rounded, size: 15),
              label: const Text('EXPORT REPORT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              onPressed: _exportReport,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeframe Selector Chips
            _buildTimeframeSelector(),
            const SizedBox(height: 14),

            // 1. Disease Trend Chart Card
            _buildDiseaseTrendCard(),
            const SizedBox(height: 14),

            // 2. Vaccination Coverage Progress Card
            _buildVaccinationCoverageCard(),
            const SizedBox(height: 14),

            // 3. Mortality Reports Comparison Card
            _buildMortalityReportCard(),
            const SizedBox(height: 14),

            // 4. High-Risk Areas Summary Card
            _buildHighRiskAreasCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    final options = ['7 Days', '30 Days', '90 Days'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((opt) {
          final isSel = _timeframe == opt;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(opt),
              selected: isSel,
              selectedColor: GovtColors.brand,
              backgroundColor: GovtColors.surface,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                color: isSel ? Colors.white : GovtColors.textSecondary,
              ),
              side: BorderSide(color: isSel ? GovtColors.brand : GovtColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              onSelected: (selected) {
                if (selected) setState(() => _timeframe = opt);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── 1. Disease Trend Card ──────────────────────────────────────────────────

  Widget _buildDiseaseTrendCard() {
    final diseases = [
      {'name': 'Foot-and-Mouth Disease (FMD)', 'count': '138 cases', 'trend': '+18%', 'color': GovtColors.critical},
      {'name': 'Brucellosis', 'count': '54 cases', 'trend': '+12%', 'color': GovtColors.riskHigh},
      {'name': 'Haemorrhagic Septicaemia (HS)', 'count': '39 cases', 'trend': '+8%', 'color': GovtColors.warning},
      {'name': 'Black Quarter (BQ)', 'count': '17 cases', 'trend': '-6%', 'color': GovtColors.success},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: GovtRadius.mdRadius,
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
              Expanded(
                child: Text('DISEASE TRENDS', style: GovtTypography.cardTitle, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Text('$_timeframe active', style: GovtTypography.caption),
            ],
          ),
          const SizedBox(height: 14),
          ...diseases.map((d) {
            final color = d['color'] as Color;
            final String trend = d['trend'] as String;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          d['name'] as String,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: GovtColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(d['count'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GovtColors.textPrimary)),
                          const SizedBox(width: 8),
                          Text(
                            trend,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: trend.startsWith('+') ? GovtColors.critical : GovtColors.success),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: d['name'].toString().contains('FMD') ? 0.75 : 0.35,
                      minHeight: 6,
                      backgroundColor: GovtColors.surfaceSubtle,
                      valueColor: AlwaysStoppedAnimation(color),
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

  // ─── 2. Vaccination Coverage Card ───────────────────────────────────────────

  Widget _buildVaccinationCoverageCard() {
    final districts = [
      {'name': 'Nagpur', 'coverage': 0.61, 'label': '61%'},
      {'name': 'Amravati', 'coverage': 0.64, 'label': '64%'},
      {'name': 'Nashik', 'coverage': 0.70, 'label': '70%'},
      {'name': 'Pune', 'coverage': 0.78, 'label': '78%'},
      {'name': 'Satara', 'coverage': 0.88, 'label': '88%'},
      {'name': 'Thane', 'coverage': 0.91, 'label': '91%'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
            children: const [
              Expanded(
                child: Text('VACCINATION COVERAGE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.3, color: GovtColors.textPrimary), overflow: TextOverflow.ellipsis),
              ),
              SizedBox(width: 8),
              Text('Target: 85%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.brand)),
            ],
          ),
          const SizedBox(height: 12),
          ...districts.map((d) {
            final double cov = d['coverage'] as double;
            final isBelow = cov < 0.75;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 75,
                    child: Text(d['name'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GovtColors.textPrimary)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: cov,
                        minHeight: 8,
                        backgroundColor: GovtColors.surfaceSubtle,
                        valueColor: AlwaysStoppedAnimation(isBelow ? GovtColors.warning : GovtColors.success),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 38,
                    child: Text(
                      d['label'] as String,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isBelow ? GovtColors.warning : GovtColors.success),
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

  // ─── 3. Mortality Reports Card ──────────────────────────────────────────────

  Widget _buildMortalityReportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
            children: const [
              Expanded(
                child: Text('MORTALITY REPORTS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.3, color: GovtColors.textPrimary), overflow: TextOverflow.ellipsis),
              ),
              SizedBox(width: 8),
              Text('18 Total (-8%)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.success)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GovtColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(6),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _mortalityItem('Nagpur', '8 mortalities', GovtColors.critical),
                  _vDivider(),
                  _mortalityItem('Amravati', '5 mortalities', GovtColors.riskHigh),
                  _vDivider(),
                  _mortalityItem('Nashik', '4 mortalities', GovtColors.warning),
                  _vDivider(),
                  _mortalityItem('Pune', '1 mortality', GovtColors.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Primary Mortality Etiology: Foot-and-mouth complications in unimmunized adult dairy stock. Mortality reduced 8% due to mobile antibiotic response.',
            style: TextStyle(fontSize: 11.5, color: GovtColors.textSecondary, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _mortalityItem(String district, String count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Text(district, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.textPrimary)),
          const SizedBox(height: 2),
          Text(count, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _vDivider() {
    return Container(width: 1, height: 24, color: GovtColors.border);
  }

  // ─── 4. High-Risk Areas Card ────────────────────────────────────────────────

  Widget _buildHighRiskAreasCard() {
    final areas = [
      {'district': 'Nagpur', 'risk': '81%', 'level': 'CRITICAL', 'color': GovtColors.critical},
      {'district': 'Amravati', 'risk': '72%', 'level': 'HIGH', 'color': GovtColors.riskHigh},
      {'district': 'Nashik', 'risk': '68%', 'level': 'HIGH', 'color': GovtColors.riskHigh},
      {'district': 'Jalgaon', 'risk': '62%', 'level': 'HIGH', 'color': GovtColors.riskHigh},
      {'district': 'Chh. Sambhajinagar', 'risk': '57%', 'level': 'HIGH', 'color': GovtColors.riskHigh},
      {'district': 'Nanded', 'risk': '53%', 'level': 'MEDIUM', 'color': GovtColors.warning},
      {'district': 'Solapur', 'risk': '49%', 'level': 'MEDIUM', 'color': GovtColors.warning},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
            children: const [
              Expanded(
                child: Text('HIGH-RISK GEOGRAPHIC REGIONS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.3, color: GovtColors.textPrimary), overflow: TextOverflow.ellipsis),
              ),
              SizedBox(width: 8),
              Text('7 Areas Flagged', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.critical)),
            ],
          ),
          const SizedBox(height: 10),
          ...areas.map((a) {
            final color = a['color'] as Color;

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: GovtColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a['district'] as String,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GovtColors.textPrimary),
                      ),
                    ),
                    Text(
                      a['risk'] as String,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        a['level'] as String,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color),
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
