// Smart Livestock — Government Disease Map Screen (Tab 2)
// Dedicated full-screen Maharashtra epidemiological surveillance and district heatmap.

import 'package:flutter/material.dart';
import 'govt_theme.dart';
import 'govt_models.dart';
import 'govt_mock_data.dart';
import 'widgets/govt_maharashtra_map_widget.dart';
import 'govt_area_detail_screen.dart';
import '../../services/farmer_data_service.dart';

class GovtDiseaseMapScreen extends StatefulWidget {
  final FarmerDataService dataService;

  const GovtDiseaseMapScreen({
    super.key,
    required this.dataService,
  });

  @override
  State<GovtDiseaseMapScreen> createState() => _GovtDiseaseMapScreenState();
}

class _GovtDiseaseMapScreenState extends State<GovtDiseaseMapScreen> {
  late List<DistrictRiskProfile> _districts;
  late DistrictRiskProfile _selectedDistrict;
  String _selectedDisease = 'All';
  String _selectedTimeframe = '7 Days';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _districts = GovtMockData.getMaharashtraDistricts();
    _selectedDistrict = _districts.first;
  }

  List<DistrictRiskProfile> get _filteredDistricts {
    return _districts.where((d) {
      final matchesSearch = d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.primaryDisease.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDisease = _selectedDisease == 'All' || d.primaryDisease == _selectedDisease;
      return matchesSearch && matchesDisease;
    }).toList();
  }

  void _openDistrictDossier(DistrictRiskProfile d) {
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
    final d = _selectedDistrict;
    final riskColor = GovtColors.getHeatmapColor(d.riskScore);
    final riskLight = GovtColors.getHeatmapLightColor(d.riskScore);

    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar
            Container(
              height: 42,
              decoration: BoxDecoration(
                color: GovtColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GovtColors.border),
              ),
              child: TextField(
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Search Maharashtra district or disease...',
                  hintStyle: TextStyle(fontSize: 12.5, color: GovtColors.textMuted),
                  prefixIcon: Icon(Icons.search_rounded, size: 18, color: GovtColors.textMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            const SizedBox(height: 12),

            // Map Widget with Embedded Controls
            GovtMaharashtraMapWidget(
              districts: _filteredDistricts,
              selectedDistrict: _selectedDistrict,
              onSelectDistrict: (dist) => setState(() => _selectedDistrict = dist),
              selectedDisease: _selectedDisease,
              onDiseaseChanged: (disease) => setState(() => _selectedDisease = disease),
              selectedTimeframe: _selectedTimeframe,
              onTimeframeChanged: (time) => setState(() => _selectedTimeframe = time),
            ),
            const SizedBox(height: 14),

            // District Inspector Card
            Container(
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
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.name, style: GovtTypography.cardTitle, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(
                              'Primary: ${d.primaryDisease}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GovtColors.brand),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: riskLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: riskColor.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          '${d.riskScore}% ${d.riskLevel}',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: riskColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(child: _metric('Active Cases', '${d.cases}', GovtColors.textPrimary)),
                      Expanded(child: _metric('Mortality', '${d.mortality}', GovtColors.critical)),
                      Expanded(child: _metric('Vaccination', '${d.vaccinationCoverage}%', GovtColors.brand)),
                      Expanded(child: _metric('Trend', d.trend, d.trend.startsWith('↑') ? GovtColors.critical : GovtColors.success)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Action Recommended: ${d.recommendedAction}',
                    style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: GovtColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                       style: ElevatedButton.styleFrom(
                        backgroundColor: GovtColors.brand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.description_outlined, size: 16),
                      label: const Text('VIEW AREA DETAILS', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                      onPressed: () => _openDistrictDossier(d),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // District Ranked Surveillance List
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: GovtColors.surface,
                borderRadius: GovtRadius.mdRadius,
                border: Border.all(color: GovtColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DISTRICT RISK RANKINGS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.3, color: GovtColors.textPrimary)),
                  const SizedBox(height: 10),
                  ..._filteredDistricts.map((dist) {
                    final color = GovtColors.getHeatmapColor(dist.riskScore);
                    final isSel = dist.name == _selectedDistrict.name;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => setState(() => _selectedDistrict = dist),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? GovtColors.brandLight : GovtColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isSel ? GovtColors.brand : GovtColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  dist.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12.5, fontWeight: isSel ? FontWeight.w800 : FontWeight.w600, color: GovtColors.textPrimary),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                flex: 2,
                                child: Text(
                                  dist.primaryDisease,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: GovtColors.textMuted),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${dist.riskScore}%',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: color),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9.5, color: GovtColors.textMuted)),
      ],
    );
  }
}
