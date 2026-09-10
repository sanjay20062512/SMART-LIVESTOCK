// Smart Livestock — Government Area Detail Screen
// Detailed district-level epidemiological dossier with action response dispatch.

import 'package:flutter/material.dart';
import 'govt_theme.dart';
import 'govt_models.dart';
import '../../services/farmer_data_service.dart';

class GovtAreaDetailScreen extends StatefulWidget {
  final DistrictRiskProfile district;
  final FarmerDataService dataService;

  const GovtAreaDetailScreen({
    super.key,
    required this.district,
    required this.dataService,
  });

  @override
  State<GovtAreaDetailScreen> createState() => _GovtAreaDetailScreenState();
}

class _GovtAreaDetailScreenState extends State<GovtAreaDetailScreen> {
  late DistrictRiskProfile _d;

  @override
  void initState() {
    super.initState();
    _d = widget.district;
  }

  void _showAssignResponseDialog() {
    final teams = ['Mobile Vet Unit Alpha (Dr. Shinde)', 'Rapid Response Team 02 (Dr. Patil)', 'Epidemiology Field Team 05'];
    String selectedTeam = teams.first;

    showModalBottomSheet(
      context: context,
      backgroundColor: GovtColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Assign Response Team', style: GovtTypography.sectionTitle),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Deploying priority veterinary intervention for ${_d.name} district.',
                    style: GovtTypography.caption,
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Available Field Team', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GovtColors.textPrimary)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: GovtColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedTeam,
                        items: teams.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (v) {
                          if (v != null) setModalState(() => selectedTeam = v);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GovtColors.brand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: const Text('CONFIRM DEPLOYMENT', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: GovtColors.brandDark,
                            content: Text('✓ $selectedTeam dispatched to ${_d.name} jurisdiction.'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSendAdvisoryDialog() {
    final msgCtrl = TextEditingController(
      text: 'GOVT ADVISORY: ${_d.primaryDisease} surveillance alert active in ${_d.name}. Vaccinate susceptible cattle and report any vesicular symptoms immediately.',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GovtColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Broadcast Farmer Advisory', style: GovtTypography.sectionTitle),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Will broadcast SMS & app notifications to registered farmers in ${_d.name}.',
                style: GovtTypography.caption,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: msgCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: GovtColors.border),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GovtColors.riskHigh,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.campaign_rounded, size: 16),
                  label: const Text('BROADCAST TO REGISTERED FARMERS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: GovtColors.brandDark,
                        content: Text('✓ Advisory broadcast initiated for ${_d.name} farmers.'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = GovtColors.getHeatmapColor(_d.riskScore);
    final riskLight = GovtColors.getHeatmapLightColor(_d.riskScore);

    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      appBar: AppBar(
        backgroundColor: GovtColors.surface,
        foregroundColor: GovtColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Text('${_d.name} District Intelligence', style: GovtTypography.sectionTitle),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: riskLight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: riskColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 7, height: 7, decoration: BoxDecoration(color: riskColor, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text(
                  '${_d.riskScore}% ${_d.riskLevel}',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: riskColor),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: GovtSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Location & Risk Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GovtColors.surface,
                borderRadius: GovtRadius.mdRadius,
                border: Border.all(color: GovtColors.border),
                boxShadow: const [
                  BoxShadow(color: GovtColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: riskLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${_d.riskScore}%',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: riskColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_d.name}, Maharashtra', style: GovtTypography.cardTitle),
                        const SizedBox(height: 2),
                        Text('Risk score: ${_d.riskScore}% — ${_d.riskLevel}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: riskColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4 Compact Metrics Cards
            Row(
              children: [
                Expanded(child: _metricCard('ACTIVE CASES', '${_d.cases}', GovtColors.textPrimary)),
                const SizedBox(width: 8),
                Expanded(child: _metricCard('MORTALITY', '${_d.mortality}', GovtColors.critical)),
                const SizedBox(width: 8),
                Expanded(child: _metricCard('VACCINATION', '${_d.vaccinationCoverage}%', GovtColors.brand)),
                const SizedBox(width: 8),
                Expanded(child: _metricCard('TREND', _d.trend, _d.trend.startsWith('↑') ? GovtColors.critical : GovtColors.success)),
              ],
            ),
            const SizedBox(height: 14),

            // Top Disease Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: GovtColors.surface,
                borderRadius: GovtRadius.mdRadius,
                border: Border.all(color: GovtColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.coronavirus_outlined, size: 20, color: GovtColors.brand),
                  const SizedBox(width: 10),
                  const Text('TOP DISEASE: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GovtColors.textMuted)),
                  Expanded(
                    child: Text(
                      _d.primaryDisease,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GovtColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Why High Risk Card
            Container(
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
                    children: const [
                      Icon(Icons.analytics_outlined, size: 16, color: GovtColors.brand),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'WHY IS THIS AREA HIGH-RISK?',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: GovtColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._d.whyHighRisk.map((reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 4, right: 8),
                          child: Icon(Icons.circle, size: 6, color: GovtColors.brand),
                        ),
                        Expanded(
                          child: Text(
                            reason,
                            style: const TextStyle(fontSize: 12.5, color: GovtColors.textSecondary, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Recommended Response Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GovtColors.surfaceSubtle,
                borderRadius: GovtRadius.mdRadius,
                border: Border.all(color: GovtColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.rule_folder_outlined, size: 16, color: GovtColors.brand),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'RECOMMENDED RESPONSE',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: GovtColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _responseStep('1', 'Immediate field investigation deployment in affected clusters'),
                  _responseStep('2', 'Targeted ring vaccination buffer prioritized across adjacent villages'),
                  _responseStep('3', 'Sample collection and diagnostic laboratory confirmation SLA < 24h'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Primary Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GovtColors.brand,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.group_add_rounded, size: 16),
                    label: const Text('ASSIGN RESPONSE', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                    onPressed: _showAssignResponseDialog,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: GovtColors.brand,
                      side: const BorderSide(color: GovtColors.brand),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.campaign_outlined, size: 16),
                    label: const Text('SEND ADVISORY', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                    onPressed: _showSendAdvisoryDialog,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GovtColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: GovtColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: valueColor), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _responseStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(top: 2, right: 8),
            decoration: const BoxDecoration(
              color: GovtColors.brand,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(num, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: GovtColors.textPrimary, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
