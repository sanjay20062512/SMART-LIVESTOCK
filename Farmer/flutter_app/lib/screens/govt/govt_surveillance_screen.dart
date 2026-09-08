// Risk Intelligence Screen — AI-assisted disease risk assessment workspace

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import 'govt_theme.dart';
import 'govt_mock_data.dart';
import 'widgets/govt_widgets.dart';

class GovtSurveillanceScreen extends StatefulWidget {
  final FarmerDataService dataService;
  const GovtSurveillanceScreen({super.key, required this.dataService});

  @override
  State<GovtSurveillanceScreen> createState() => _GovtSurveillanceScreenState();
}

class _GovtSurveillanceScreenState extends State<GovtSurveillanceScreen> {
  String _selectedDistrict = 'Erode';
  String _selectedSpecies = 'All Species';
  String _selectedDisease = 'All Diseases';
  String _selectedTimeRange = '7 Days';

  final _districts = ['Erode', 'Namakkal', 'Salem', 'Coimbatore'];
  final _species = ['All Species', 'Cattle', 'Buffalo', 'Goat', 'Sheep', 'Pig'];
  final _diseases = ['All Diseases', 'FMD', 'HS', 'PPR', 'BQ', 'Brucellosis'];
  final _timeRanges = ['24 Hours', '7 Days', '14 Days', '30 Days'];

  @override
  Widget build(BuildContext context) {
    final intel = GovtMockData.getRiskIntelligence();
    final riskZones = (intel['riskZones'] as List).cast<Map<String, dynamic>>();

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
                Text('Risk Intelligence', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                Text('AI-assisted disease risk assessment', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
            actions: [
              IconButton(icon: const Icon(Icons.tune_rounded), onPressed: () {}),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Filter Strip ──────────────────────────────────────────
                Container(
                  color: GovtColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('District', _selectedDistrict, _districts, (v) => setState(() => _selectedDistrict = v)),
                        const SizedBox(width: 8),
                        _filterChip('Species', _selectedSpecies, _species, (v) => setState(() => _selectedSpecies = v)),
                        const SizedBox(width: 8),
                        _filterChip('Disease', _selectedDisease, _diseases, (v) => setState(() => _selectedDisease = v)),
                        const SizedBox(width: 8),
                        _filterChip('Period', _selectedTimeRange, _timeRanges, (v) => setState(() => _selectedTimeRange = v)),
                      ],
                    ),
                  ),
                ),

                // ── Risk Map ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: GovtSectionCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$_selectedDistrict District — Risk Map',
                                      style: GovtTypography.sectionTitle),
                                  Text('Updated: ${intel['lastUpdated']}', style: GovtTypography.caption),
                                ],
                              ),
                            ),
                            RiskBadge(level: intel['riskLevel'] as String),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DistrictRiskMapCanvas(riskZones: riskZones, district: _selectedDistrict),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Risk Summary Panel ────────────────────────────────────
                Padding(
                  padding: GovtSpacing.pagePadding,
                  child: GovtSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'AI-Assisted Risk Summary', subtitle: 'DEMO — Not a confirmed outbreak'),
                        // Disclaimer
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: GovtColors.warningLight,
                            borderRadius: GovtRadius.smRadius,
                            border: Border.all(color: GovtColors.warning.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline_rounded, size: 16, color: GovtColors.warning),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This is an AI-assisted risk signal based on reported data. It does NOT confirm an outbreak. Always validate with veterinary field investigation.',
                                  style: TextStyle(fontSize: 11, color: GovtColors.warning, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _riskSummaryItem('Current Risk', intel['riskLevel'] as String, (intel['riskLevel'] as String).riskColor),
                            _riskSummaryItem('Confidence', '${intel['confidence']}%', GovtColors.brand),
                            _riskSummaryItem('Trend', intel['trend'] as String, GovtColors.critical),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Contributing Factors ──────────────────────────────────
                Padding(
                  padding: GovtSpacing.pagePadding,
                  child: GovtSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Contributing Risk Factors'),
                        ...(intel['contributingFactors'] as List<String>).asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _factorColor(entry.key).withValues(alpha: 0.12),
                                    borderRadius: GovtRadius.smRadius,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _factorColor(entry.key)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(entry.value, style: GovtTypography.body),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Village Risk Breakdown ────────────────────────────────
                Padding(
                  padding: GovtSpacing.pagePadding,
                  child: GovtSectionCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: SectionHeader(title: 'Village Risk Breakdown'),
                        ),
                        const Divider(height: 1, color: GovtColors.border),
                        ...riskZones.map((zone) => _villageRiskRow(zone)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String selected, List<String> options, void Function(String) onChanged) {
    return GestureDetector(
      onTap: () => _showPicker(label, options, onChanged),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected.contains('All') ? GovtColors.surfaceSubtle : GovtColors.brandLight,
          borderRadius: GovtRadius.smRadius,
          border: Border.all(color: selected.contains('All') ? GovtColors.border : GovtColors.brand.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected.contains('All') ? GovtColors.textSecondary : GovtColors.brand,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: selected.contains('All') ? GovtColors.textSecondary : GovtColors.brand),
          ],
        ),
      ),
    );
  }

  void _showPicker(String title, List<String> options, void Function(String) onChanged) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select $title', style: GovtTypography.sectionTitle),
            const SizedBox(height: 12),
            ...options.map((o) => ListTile(
              dense: true,
              title: Text(o, style: GovtTypography.body),
              trailing: Icon(Icons.check_rounded, size: 16, color: GovtColors.brand),
              onTap: () { onChanged(o); Navigator.pop(ctx); },
            )),
          ],
        ),
      ),
    );
  }

  Widget _riskSummaryItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label, style: GovtTypography.metricLabel),
        ],
      ),
    );
  }

  Widget _villageRiskRow(Map<String, dynamic> zone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: GovtColors.divider))),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: (zone['risk'] as String).riskColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(zone['name'] as String, style: GovtTypography.bodyMedium)),
          Text('${zone['cases']} cases', style: GovtTypography.caption),
          const SizedBox(width: 12),
          RiskBadge(level: zone['risk'] as String, compact: true),
        ],
      ),
    );
  }

  Color _factorColor(int i) {
    const colors = [GovtColors.critical, GovtColors.riskHigh, GovtColors.warning, GovtColors.brand, GovtColors.textSecondary];
    return colors[i % colors.length];
  }
}
