// Laboratory Network Screen — sample tracking and lab surveillance

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import 'govt_theme.dart';
import 'govt_models.dart';
import 'govt_mock_data.dart';
import 'widgets/govt_widgets.dart';

class GovtLabScreen extends StatefulWidget {
  final FarmerDataService dataService;
  const GovtLabScreen({super.key, required this.dataService});

  @override
  State<GovtLabScreen> createState() => _GovtLabScreenState();
}

class _GovtLabScreenState extends State<GovtLabScreen> {
  final _samples = GovtMockData.getLabSamples();
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final pending = _samples.where((s) => s.status == LabSampleStatus.collected || s.status == LabSampleStatus.inTransit || s.status == LabSampleStatus.received).length;
    final testing = _samples.where((s) => s.status == LabSampleStatus.underTesting).length;
    final positive = _samples.where((s) => s.result == LabSampleResult.positive).length;
    final negative = _samples.where((s) => s.result == LabSampleResult.negative).length;

    final filtered = _filter == 'All'
        ? _samples
        : _filter == 'Pending'
            ? _samples.where((s) => s.status == LabSampleStatus.collected || s.status == LabSampleStatus.inTransit || s.status == LabSampleStatus.received).toList()
            : _filter == 'Testing'
                ? _samples.where((s) => s.status == LabSampleStatus.underTesting).toList()
                : _filter == 'Positive'
                    ? _samples.where((s) => s.result == LabSampleResult.positive).toList()
                    : _samples.where((s) => s.result == LabSampleResult.negative).toList();

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
                Text('Laboratory Network', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                Text('Sample tracking & diagnostic surveillance', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Lab Metrics ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      _metricTile('Collected', _samples.length, GovtColors.brand),
                      _metricTile('Pending', pending, GovtColors.warning),
                      _metricTile('Testing', testing, GovtColors.info),
                      _metricTile('Positive', positive, GovtColors.critical),
                      _metricTile('Negative', negative, GovtColors.success),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Filter chips ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Pending', 'Testing', 'Positive', 'Negative']
                          .map((f) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () => setState(() => _filter = f),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _filter == f ? GovtColors.brand : GovtColors.surfaceSubtle,
                                      borderRadius: GovtRadius.smRadius,
                                      border: Border.all(color: _filter == f ? GovtColors.brand : GovtColors.border),
                                    ),
                                    child: Text(
                                      f,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _filter == f ? Colors.white : GovtColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: GovtSpacing.pagePadding,
                  child: SectionHeader(title: 'Samples (${filtered.length})', subtitle: 'Tap a sample to view details'),
                ),

                // ── Sample list ───────────────────────────────────────────
                ...filtered.map((s) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: GestureDetector(
                    onTap: () => _openSampleDetail(context, s),
                    child: _sampleCard(s),
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

  Widget _metricTile(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: GovtColors.surface,
          borderRadius: GovtRadius.smRadius,
          border: Border.all(color: GovtColors.border),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: const TextStyle(fontSize: 9, color: GovtColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _sampleCard(LabSample s) {
    final resultColor = s.result == LabSampleResult.positive
        ? GovtColors.critical
        : s.result == LabSampleResult.negative
            ? GovtColors.success
            : GovtColors.textDisabled;

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
                Text(s.sampleId, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.textSecondary, letterSpacing: 0.3)),
                const Spacer(),
                StatusChip(label: s.statusLabel, color: _statusColor(s.status)),
              ],
            ),
            const SizedBox(height: 8),
            Text('${s.animalSpecies} · ${s.suspectedDisease}', style: GovtTypography.bodyMedium),
            const SizedBox(height: 2),
            Text('${s.village}, ${s.district}', style: GovtTypography.caption),
            const SizedBox(height: 8),
            const Divider(height: 1, color: GovtColors.divider),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.science_rounded, size: 13, color: GovtColors.textDisabled),
                const SizedBox(width: 4),
                Expanded(child: Text(s.laboratory, style: GovtTypography.caption, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: resultColor.withValues(alpha: 0.1),
                    borderRadius: GovtRadius.smRadius,
                    border: Border.all(color: resultColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    s.resultLabel,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: resultColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openSampleDetail(BuildContext context, LabSample s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        expand: false,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(child: Text(s.sampleId, style: GovtTypography.sectionTitle)),
                StatusChip(label: s.statusLabel, color: _statusColor(s.status)),
              ],
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Sample Information'),
            _detailRow('Case ID', s.caseId),
            _detailRow('Animal', s.animalSpecies),
            _detailRow('Location', '${s.village}, ${s.district}'),
            _detailRow('Suspected Disease', s.suspectedDisease),
            _detailRow('Collected By', s.collectedBy),
            _detailRow('Collection Date', '${s.collectedAt.day}/${s.collectedAt.month}/${s.collectedAt.year}'),
            _detailRow('Laboratory', s.laboratory),
            _detailRow('Result', s.resultLabel),
            if (s.resultNotes != null) ...[
              const SizedBox(height: 12),
              const Text('Lab Notes', style: GovtTypography.sectionTitle),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: GovtColors.surfaceSubtle, borderRadius: GovtRadius.smRadius, border: Border.all(color: GovtColors.border)),
                child: Text(s.resultNotes!, style: GovtTypography.body),
              ),
            ],
            const SizedBox(height: 16),
            GovtTimeline(events: [
              GovtTimelineEvent(title: 'Sample collected', description: 'By ${s.collectedBy}', timestamp: s.collectedAt, isCompleted: true),
              GovtTimelineEvent(title: 'Dispatched to lab', description: s.laboratory, timestamp: s.collectedAt.add(const Duration(hours: 2)), isCompleted: s.status != LabSampleStatus.collected),
              GovtTimelineEvent(title: 'Lab received', isCompleted: s.status == LabSampleStatus.underTesting || s.status == LabSampleStatus.resultReady || s.status == LabSampleStatus.completed),
              GovtTimelineEvent(title: 'Under testing', isCompleted: s.status == LabSampleStatus.resultReady || s.status == LabSampleStatus.completed),
              GovtTimelineEvent(title: 'Result issued', timestamp: s.resultDate, isCompleted: s.status == LabSampleStatus.completed || s.status == LabSampleStatus.resultReady),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: GovtTypography.caption)),
          Expanded(child: Text(value, style: GovtTypography.bodyMedium)),
        ],
      ),
    );
  }

  Color _statusColor(LabSampleStatus s) {
    switch (s) {
      case LabSampleStatus.collected:
        return GovtColors.textSecondary;
      case LabSampleStatus.inTransit:
        return GovtColors.warning;
      case LabSampleStatus.received:
        return GovtColors.info;
      case LabSampleStatus.underTesting:
        return GovtColors.brand;
      case LabSampleStatus.resultReady:
        return GovtColors.accent;
      case LabSampleStatus.completed:
        return GovtColors.success;
    }
  }
}
