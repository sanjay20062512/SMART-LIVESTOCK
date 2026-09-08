// Reporting Center Screen — categorized government reports

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import 'govt_theme.dart';
import 'govt_models.dart';
import 'govt_mock_data.dart';
import 'widgets/govt_widgets.dart';

class GovtReportsScreen extends StatefulWidget {
  final FarmerDataService dataService;
  const GovtReportsScreen({super.key, required this.dataService});

  @override
  State<GovtReportsScreen> createState() => _GovtReportsScreenState();
}

class _GovtReportsScreenState extends State<GovtReportsScreen> {
  final _reports = GovtMockData.getReports();
  ReportCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == null
        ? _reports
        : _reports.where((r) => r.category == _selectedCategory).toList();

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
                Text('Reporting Center', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                Text('Official surveillance & operational reports', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
            actions: [
              IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => _generateReport(context)),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Category tiles ────────────────────────────────────────
                Container(
                  color: GovtColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Report Categories', style: GovtTypography.label),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _categoryChip(null, 'All', Icons.all_inclusive_rounded),
                            ...ReportCategory.values.map((c) => _categoryChip(c, c.shortLabel, c.icon)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: GovtSpacing.pagePadding,
                  child: Row(
                    children: [
                      Expanded(child: SectionHeader(title: 'Reports (${filtered.length})')),
                      GovtButton(
                        label: 'Generate',
                        icon: Icons.add_rounded,
                        compact: true,
                        onPressed: () => _generateReport(context),
                      ),
                    ],
                  ),
                ),

                // ── Report list ───────────────────────────────────────────
                ...filtered.map((r) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: GestureDetector(
                    onTap: () => _openReport(context, r),
                    child: _reportCard(r),
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

  Widget _categoryChip(ReportCategory? cat, String label, IconData icon) {
    final isSelected = _selectedCategory == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = cat),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? GovtColors.brand : GovtColors.surfaceSubtle,
            borderRadius: GovtRadius.smRadius,
            border: Border.all(color: isSelected ? GovtColors.brand : GovtColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: isSelected ? Colors.white : GovtColors.textSecondary),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : GovtColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reportCard(GovtReport r) {
    return Container(
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: GovtRadius.lgRadius,
        border: Border.all(color: GovtColors.border),
        boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: r.category.color.withValues(alpha: 0.1), borderRadius: GovtRadius.smRadius),
                  child: Icon(r.category.icon, size: 18, color: r.category.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.categoryLabel, style: const TextStyle(fontSize: 10, color: GovtColors.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                      Text(r.title, style: GovtTypography.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                StatusChip(label: 'Ready', color: GovtColors.success, icon: Icons.check_circle_rounded),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: GovtColors.divider),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.map_outlined, size: 13, color: GovtColors.textDisabled),
                const SizedBox(width: 4),
                Expanded(child: Text(r.coverage, style: GovtTypography.caption, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 13, color: GovtColors.textDisabled),
                const SizedBox(width: 4),
                Expanded(child: Text(r.generatedBy, style: GovtTypography.caption, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '${r.reportDate.day}/${r.reportDate.month}/${r.reportDate.year}',
                  style: GovtTypography.caption,
                ),
                const Spacer(),
                _actionBtn(Icons.visibility_rounded, 'View', () => _openReport(context, r)),
                const SizedBox(width: 8),
                _actionBtn(Icons.download_rounded, 'Download', () => _downloadReport(context, r)),
                const SizedBox(width: 8),
                _actionBtn(Icons.share_rounded, 'Share', () => _shareReport(context, r)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: GovtColors.surfaceSubtle,
            borderRadius: GovtRadius.smRadius,
            border: Border.all(color: GovtColors.border),
          ),
          child: Icon(icon, size: 15, color: GovtColors.textSecondary),
        ),
      ),
    );
  }

  void _openReport(BuildContext context, GovtReport r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(child: Text(r.title, style: GovtTypography.sectionTitle)),
                StatusChip(label: 'Ready', color: GovtColors.success),
              ],
            ),
            const SizedBox(height: 8),
            Text(r.categoryLabel, style: const TextStyle(fontSize: 12, color: GovtColors.textSecondary)),
            const SizedBox(height: 16),
            _reportInfoRow('Coverage', r.coverage),
            _reportInfoRow('Generated By', r.generatedBy),
            _reportInfoRow('Date', '${r.reportDate.day}/${r.reportDate.month}/${r.reportDate.year}'),
            const SizedBox(height: 16),
            // Demo preview
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: GovtColors.surfaceSubtle, borderRadius: GovtRadius.mdRadius, border: Border.all(color: GovtColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('REPORT PREVIEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: GovtColors.textDisabled, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Text(r.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Coverage: ${r.coverage}', style: GovtTypography.body),
                  Text('Generated by: ${r.generatedBy}', style: GovtTypography.caption),
                  const SizedBox(height: 8),
                  const Text('This is a demo preview. Connect to backend to load full report data.', style: TextStyle(fontSize: 11, color: GovtColors.textSecondary, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: GovtButton(label: 'Download PDF', icon: Icons.download_rounded, outlined: true, onPressed: () => _downloadReport(context, r))),
                const SizedBox(width: 10),
                Expanded(child: GovtButton(label: 'Share Report', icon: Icons.share_rounded, onPressed: () => _shareReport(context, r))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: GovtTypography.caption)),
          Expanded(child: Text(value, style: GovtTypography.bodyMedium)),
        ],
      ),
    );
  }

  void _generateReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report generation — connect to backend'), backgroundColor: GovtColors.brand),
    );
  }

  void _downloadReport(BuildContext context, GovtReport r) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading: ${r.title}'), backgroundColor: GovtColors.brand),
    );
  }

  void _shareReport(BuildContext context, GovtReport r) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing: ${r.title}'), backgroundColor: GovtColors.brand),
    );
  }
}

// ─── Extension helpers for ReportCategory ─────────────────────────────────────

extension ReportCategoryExt on ReportCategory {
  String get shortLabel {
    switch (this) {
      case ReportCategory.dailySurveillance:
        return 'Daily';
      case ReportCategory.weeklyDiseaseSummary:
        return 'Weekly';
      case ReportCategory.outbreakReport:
        return 'Outbreak';
      case ReportCategory.vaccinationReport:
        return 'Vaccination';
      case ReportCategory.mortalityReport:
        return 'Mortality';
      case ReportCategory.laboratoryReport:
        return 'Lab';
      case ReportCategory.districtHealthReport:
        return 'District';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportCategory.dailySurveillance:
        return Icons.today_rounded;
      case ReportCategory.weeklyDiseaseSummary:
        return Icons.calendar_view_week_rounded;
      case ReportCategory.outbreakReport:
        return Icons.warning_rounded;
      case ReportCategory.vaccinationReport:
        return Icons.vaccines_rounded;
      case ReportCategory.mortalityReport:
        return Icons.trending_down_rounded;
      case ReportCategory.laboratoryReport:
        return Icons.science_rounded;
      case ReportCategory.districtHealthReport:
        return Icons.maps_home_work_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ReportCategory.dailySurveillance:
        return GovtColors.brand;
      case ReportCategory.weeklyDiseaseSummary:
        return GovtColors.info;
      case ReportCategory.outbreakReport:
        return GovtColors.critical;
      case ReportCategory.vaccinationReport:
        return GovtColors.success;
      case ReportCategory.mortalityReport:
        return GovtColors.riskHigh;
      case ReportCategory.laboratoryReport:
        return GovtColors.accent;
      case ReportCategory.districtHealthReport:
        return GovtColors.warning;
    }
  }
}
