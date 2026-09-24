// Veterinary Case Queue Screen — full sortable/filterable case list

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../models/case.dart';
import '../../theme/app_theme.dart';
import 'vet_case_detail_screen.dart';

import '../../services/localization_service.dart';

class VetCaseQueueScreen extends StatefulWidget {
  final FarmerDataService dataService;
  const VetCaseQueueScreen({super.key, required this.dataService});

  @override
  State<VetCaseQueueScreen> createState() => _VetCaseQueueScreenState();
}

class _VetCaseQueueScreenState extends State<VetCaseQueueScreen> {
  String _filterRisk = 'All';
  final String _filterStatus = 'All';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.dataService, LocalizationService.instance]),
      builder: (context, _) {
        var cases = widget.dataService.getAllCases().toList();

        if (_filterRisk != 'All') {
          cases = cases.where((c) => c.riskLevel == _filterRisk).toList();
        }
        if (_filterStatus != 'All') {
          cases = cases.where((c) => c.status.displayName == _filterStatus).toList();
        }

        // Sort by priority
        cases.sort((a, b) {
          const order = {'CRITICAL': 0, 'HIGH': 1, 'MEDIUM': 2, 'LOW': 3};
          return (order[a.riskLevel] ?? 3).compareTo(order[b.riskLevel] ?? 3);
        });

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false, // tab screen — no back arrow
            title: Text(
              context.tr('case_queue'),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.2,
              ),
            ),
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          body: Column(
            children: [
              // Filters
              Container(
                color: AppColors.primaryDark,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Row(
                    children: [
                      _filterChip(context.tr('all'), 'All', _filterRisk, (v) => setState(() => _filterRisk = v)),
                      _filterChip(context.tr('critical'), 'CRITICAL', _filterRisk, (v) => setState(() => _filterRisk = v), color: AppColors.error),
                      _filterChip(context.tr('high_risk'), 'HIGH', _filterRisk, (v) => setState(() => _filterRisk = v), color: AppColors.riskHigh),
                      _filterChip(context.tr('medium_risk'), 'MEDIUM', _filterRisk, (v) => setState(() => _filterRisk = v), color: AppColors.warning),
                      _filterChip(context.tr('low_risk'), 'LOW', _filterRisk, (v) => setState(() => _filterRisk = v), color: AppColors.success),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: cases.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inbox_rounded, size: 48, color: AppColors.textDisabled),
                            const SizedBox(height: 12),
                            Text(
                              context.tr('no_cases_found'),
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: cases.length,
                        itemBuilder: (ctx, i) => _buildCaseCard(ctx, cases[i]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(String displayLabel, String valueKey, String current, ValueChanged<String> onTap, {Color? color}) {
    final selected = current == valueKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(displayLabel, style: TextStyle(
          fontWeight: FontWeight.bold,
          color: selected ? Colors.white : (color ?? Colors.white70),
          fontSize: 12,
        )),
        selected: selected,
        onSelected: (_) => onTap(valueKey),
        selectedColor: color ?? const Color(0xFF1565C0),
        backgroundColor: Colors.white.withValues(alpha: 0.15),
        checkmarkColor: Colors.white,
        side: BorderSide(color: selected ? Colors.transparent : Colors.white30),
      ),
    );
  }

  Widget _buildCaseCard(BuildContext context, LivestockCase c) {
    final riskColor = AppColors.getRiskColor(c.riskLevel);
    final riskIcon = AppColors.getRiskIcon(c.riskLevel);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VetCaseDetailScreen(dataService: widget.dataService, lcase: c),
            ),
          ),
          child: Column(
            children: [
              // Risk level header strip
              Container(
                color: riskColor,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: Row(
                  children: [
                    Icon(riskIcon, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('risk_header', params: {'level': context.tr(c.riskLevel.toLowerCase())}),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      c.caseId,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Card body
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${context.translateSpecies(c.species)} · ${c.animalTag}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(c.farmerName,
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: c.symptoms.take(3).map((s) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryFaint,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primaryLight),
                              ),
                              child: Text(context.translateSymptom(s), style: const TextStyle(fontSize: 11, color: AppColors.primaryDark)),
                            )).toList(),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 13, color: AppColors.textMuted),
                              const SizedBox(width: 2),
                              Text('${c.village}, ${c.district}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              const SizedBox(width: 12),
                              const Icon(Icons.people, size: 13, color: AppColors.textMuted),
                              const SizedBox(width: 2),
                              Text(c.affectedCount != null ? context.tr('n_animals', params: {'count': '${c.affectedCount}'}) : '—',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                          if (c.hasPhoto || c.hasVideo || c.hasVoiceNote) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                if (c.hasPhoto)
                                  Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.blue.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.photo_camera_rounded, size: 11, color: Colors.blue),
                                        const SizedBox(width: 3),
                                        Text(context.tr('photo'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                                      ],
                                    ),
                                  ),
                                if (c.hasVideo)
                                  Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.teal.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.videocam_rounded, size: 12, color: Colors.teal),
                                        const SizedBox(width: 3),
                                        Text(context.tr('video'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal)),
                                      ],
                                    ),
                                  ),
                                if (c.hasVoiceNote)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.orange.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.mic_rounded, size: 11, color: Colors.orange),
                                        const SizedBox(width: 3),
                                        Text(context.tr('voice'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: AppRadius.xsRadius,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(context.translateStatus(c.status.displayName),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              )),
                        ),
                        const SizedBox(height: 4),
                        Text(_formatDate(context, c.createdAt),
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        if (c.assignedVetName != null) ...[
                          const SizedBox(height: 4),
                          Text(context.tr('assigned'),
                              style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inHours < 1) return context.tr('m_ago', params: {'n': '${diff.inMinutes}'});
    if (diff.inHours < 24) return context.tr('h_ago', params: {'n': '${diff.inHours}'});
    return context.tr('d_ago', params: {'n': '${diff.inDays}'});
  }
}
