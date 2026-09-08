// Surveillance Analytics Screen — professional data visualization workspace

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import 'govt_theme.dart';
import 'govt_mock_data.dart';
import 'widgets/govt_widgets.dart';

class GovtAnalyticsScreen extends StatefulWidget {
  final FarmerDataService dataService;
  const GovtAnalyticsScreen({super.key, required this.dataService});

  @override
  State<GovtAnalyticsScreen> createState() => _GovtAnalyticsScreenState();
}

class _GovtAnalyticsScreenState extends State<GovtAnalyticsScreen> {
  String _period = '7 Days';
  String _district = 'All Districts';

  final _periods = ['7 Days', '14 Days', '30 Days', '90 Days'];
  final _districts = ['All Districts', 'Erode', 'Namakkal', 'Salem', 'Coimbatore'];

  @override
  Widget build(BuildContext context) {
    final trendData = GovtMockData.getOutbreakTrendData();

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
                Text('Surveillance Analytics', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                Text('Epidemiological data insights', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
            actions: [
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Export', style: TextStyle(fontSize: 12)),
                onPressed: () => _showExportOptions(context),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter bar
                Container(
                  color: GovtColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      _filterDropdown('Period', _period, _periods, (v) => setState(() => _period = v)),
                      const SizedBox(width: 10),
                      _filterDropdown('District', _district, _districts, (v) => setState(() => _district = v)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Disease Incidence Trend
                Padding(
                  padding: GovtSpacing.pagePadding,
                  child: GovtSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Disease Incidence Trend', subtitle: 'New cases per day — current vs. previous period'),
                        OutbreakTrendChart(data: trendData),
                        const SizedBox(height: 8),
                        _chartLegend(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Mortality + Species Distribution row
                Padding(
                  padding: GovtSpacing.pagePadding,
                  child: Row(
                    children: [
                      Expanded(
                        child: GovtSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionHeader(title: 'Mortality', subtitle: '7-day trend'),
                              _barChart([3, 1, 4, 2, 5, 3, 4], GovtColors.critical),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GovtSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionHeader(title: 'By Species'),
                              _speciesBar('Cattle', 0.58, GovtColors.brand),
                              _speciesBar('Buffalo', 0.22, GovtColors.accent),
                              _speciesBar('Goat', 0.14, GovtColors.warning),
                              _speciesBar('Other', 0.06, GovtColors.textDisabled),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // District Comparison
                Padding(
                  padding: GovtSpacing.pagePadding,
                  child: GovtSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'District Comparison', subtitle: 'Active cases by district'),
                        ...[
                          {'name': 'Erode', 'cases': 27, 'max': 30},
                          {'name': 'Namakkal', 'cases': 18, 'max': 30},
                          {'name': 'Salem', 'cases': 12, 'max': 30},
                          {'name': 'Coimbatore', 'cases': 8, 'max': 30},
                        ].map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              SizedBox(width: 80, child: Text(d['name'] as String, style: GovtTypography.caption)),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GovtProgressBar(
                                        value: (d['cases'] as int) / (d['max'] as int),
                                        color: (d['cases'] as int) > 20 ? GovtColors.critical : (d['cases'] as int) > 12 ? GovtColors.warning : GovtColors.brand,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('${d['cases']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GovtColors.textPrimary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Seasonal Disease Trend
                Padding(
                  padding: GovtSpacing.pagePadding,
                  child: GovtSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Seasonal Disease Pattern', subtitle: 'Monthly case distribution (2024)'),
                        _monthlyBar(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Case Resolution Rate
                Padding(
                  padding: GovtSpacing.pagePadding,
                  child: GovtSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Case Resolution Rate'),
                        Row(
                          children: [
                            VaccinationRingChart(percent: 74, label: 'Resolved', color: GovtColors.success),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _resolutionRow('Resolved', 74, GovtColors.success),
                                  const SizedBox(height: 8),
                                  _resolutionRow('Ongoing', 18, GovtColors.warning),
                                  const SizedBox(height: 8),
                                  _resolutionRow('Critical', 8, GovtColors.critical),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Export buttons
                Padding(
                  padding: GovtSpacing.pagePadding,
                  child: Row(
                    children: [
                      Expanded(child: GovtButton(label: 'Export Report', icon: Icons.picture_as_pdf_rounded, outlined: true, onPressed: () => _showExportOptions(context))),
                      const SizedBox(width: 8),
                      Expanded(child: GovtButton(label: 'Export CSV', icon: Icons.table_chart_rounded, outlined: true, onPressed: () => _showExportOptions(context))),
                    ],
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

  Widget _filterDropdown(String label, String value, List<String> options, void Function(String) onChanged) {
    return Expanded(
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          builder: (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(padding: const EdgeInsets.all(16), child: Text('Select $label', style: GovtTypography.sectionTitle)),
              ...options.map((o) => ListTile(
                title: Text(o),
                trailing: o == value ? const Icon(Icons.check_rounded, color: GovtColors.brand) : null,
                onTap: () { onChanged(o); Navigator.pop(ctx); },
              )),
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: GovtColors.surfaceSubtle,
            borderRadius: GovtRadius.smRadius,
            border: Border.all(color: GovtColors.border),
          ),
          child: Row(
            children: [
              Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GovtColors.textPrimary))),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: GovtColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chartLegend() {
    return Row(
      children: [
        Container(width: 16, height: 2, color: GovtColors.brand),
        const SizedBox(width: 4),
        const Text('This period', style: TextStyle(fontSize: 10, color: GovtColors.textSecondary)),
        const SizedBox(width: 12),
        Container(width: 16, height: 2, color: GovtColors.textDisabled),
        const SizedBox(width: 4),
        const Text('Previous period', style: TextStyle(fontSize: 10, color: GovtColors.textSecondary)),
      ],
    );
  }

  Widget _barChart(List<int> values, Color color) {
    final max = values.fold(0, (a, b) => a > b ? a : b).toDouble();
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.asMap().entries.map((e) {
          final pct = max > 0 ? e.value / max : 0.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 55 * pct,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(2)),
                  ),
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

  Widget _speciesBar(String label, double pct, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 52, child: Text(label, style: GovtTypography.caption)),
          Expanded(child: GovtProgressBar(value: pct, color: color, height: 8)),
          const SizedBox(width: 6),
          Text('${(pct * 100).round()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: GovtColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _monthlyBar() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'];
    final values = [8, 6, 9, 14, 19, 22, 18, 25, 27];
    final max = values.fold(0, (a, b) => a > b ? a : b).toDouble();
    return SizedBox(
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.asMap().entries.map((e) {
          final pct = e.value / max;
          final col = e.value > 20 ? GovtColors.critical : e.value > 14 ? GovtColors.warning : GovtColors.brand;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 65 * pct,
                    decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 3),
                  Text(months[e.key], style: const TextStyle(fontSize: 8, color: GovtColors.textDisabled)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _resolutionRow(String label, int pct, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: GovtTypography.body),
        const Spacer(),
        Text('$pct%', style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13)),
      ],
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Export Options', style: GovtTypography.sectionTitle),
            const SizedBox(height: 12),
            ListTile(leading: const Icon(Icons.picture_as_pdf_rounded, color: GovtColors.critical), title: const Text('Generate PDF Report'), onTap: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF generation — connect to backend'))); }),
            ListTile(leading: const Icon(Icons.table_chart_rounded, color: GovtColors.brand), title: const Text('Export CSV Data'), onTap: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV export — connect to backend'))); }),
            ListTile(leading: const Icon(Icons.share_rounded, color: GovtColors.accent), title: const Text('Share Dashboard'), onTap: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share — connect to backend'))); }),
          ],
        ),
      ),
    );
  }
}
