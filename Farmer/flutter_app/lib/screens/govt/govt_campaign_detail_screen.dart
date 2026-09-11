// Smart Livestock — Government Campaign Detail Screen
// Detailed campaign progress tracking, village-level interaction,
// field team deployment, government actions, and demo risk impact simulation.

import 'package:flutter/material.dart';
import 'govt_theme.dart';
import 'govt_models.dart';
import 'govt_campaign_engine.dart';
import 'govt_mock_data.dart';
import 'govt_area_detail_screen.dart';
import '../../services/farmer_data_service.dart';

class GovtCampaignDetailScreen extends StatefulWidget {
  final VaccinationCampaign campaign;
  final FarmerDataService dataService;

  const GovtCampaignDetailScreen({
    super.key,
    required this.campaign,
    required this.dataService,
  });

  @override
  State<GovtCampaignDetailScreen> createState() => _GovtCampaignDetailScreenState();
}

class _GovtCampaignDetailScreenState extends State<GovtCampaignDetailScreen> {
  late VaccinationCampaign _campaign;
  late List<VillageCampaignData> _villages;

  @override
  void initState() {
    super.initState();
    _campaign = widget.campaign;
    _villages = List.from(_campaign.villages);

    // Fallback if campaign doesn't have populated villages list
    if (_villages.isEmpty) {
      _villages = [
        VillageCampaignData(name: 'Village A (Khadakwasla)', target: 500, vaccinated: 500, status: 'Completed', assignedTeam: 'Team Alpha', recommendedAction: 'Target achieved. Surveillance active.'),
        VillageCampaignData(name: 'Village B (Wagholi)', target: 600, vaccinated: 552, status: 'Completed', assignedTeam: 'Team Alpha', recommendedAction: 'Target achieved.'),
        VillageCampaignData(name: 'Village C (Saswad)', target: 480, vaccinated: 355, status: 'In Progress', assignedTeam: 'Team Beta', recommendedAction: 'Coverage ongoing.'),
        VillageCampaignData(name: 'Village D (Manchar)', target: 420, vaccinated: 214, status: 'In Progress', assignedTeam: 'Mobile Unit 03', recommendedAction: 'Deploy additional vaccination team.'),
        VillageCampaignData(name: 'Village E (Jejuri)', target: 550, vaccinated: 126, status: 'Low Coverage', assignedTeam: null, recommendedAction: 'Deploy additional vaccination team.'),
      ];
    }
  }

  void _openVillageDetails(VillageCampaignData village) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final cov = village.coveragePercent;
            final isLow = village.hasLowCoverage;

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: GovtColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: GovtColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Village Header & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          village.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: GovtColors.textPrimary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (village.isCompleted
                              ? GovtColors.riskLow
                              : (isLow ? GovtColors.critical : GovtColors.warning))
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: village.isCompleted
                                ? GovtColors.riskLow
                                : (isLow ? GovtColors.critical : GovtColors.warning),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: village.isCompleted
                                    ? GovtColors.riskLow
                                    : (isLow ? GovtColors.critical : GovtColors.warning),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              village.isCompleted ? 'COMPLETED' : 'IN PROGRESS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: village.isCompleted
                                    ? GovtColors.riskLow
                                    : (isLow ? GovtColors.critical : GovtColors.warning),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Coverage Percentage Highlight
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GovtColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GovtColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Vaccination Coverage',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GovtColors.textSecondary),
                        ),
                        Text(
                          '${cov.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: village.isCompleted
                                ? GovtColors.riskLow
                                : (isLow ? GovtColors.critical : GovtColors.warning),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Animals Breakdown Strip
                  Row(
                    children: [
                      Expanded(
                        child: _villageMetricCard(
                          label: 'Animals Targeted',
                          value: '${village.target}',
                          color: GovtColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _villageMetricCard(
                          label: 'Vaccinated',
                          value: '${village.vaccinated}',
                          color: GovtColors.riskLow,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _villageMetricCard(
                          label: 'Remaining',
                          value: '${village.remaining}',
                          color: village.remaining > 0 ? GovtColors.critical : GovtColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Recommended Action
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GovtColors.brandFaint,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GovtColors.brandLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RECOMMENDED ACTION',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GovtColors.brandDark, letterSpacing: 0.3),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          village.recommendedAction,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: GovtColors.textPrimary),
                        ),
                        if (village.assignedTeam != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Current Assignment: ${village.assignedTeam}',
                            style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: GovtColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Action Button: ASSIGN TEAM
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GovtColors.brand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.group_add_rounded, size: 16),
                      label: const Text('ASSIGN TEAM', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showAssignTeamModal(village);
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

  void _showAssignTeamModal(VillageCampaignData village) {
    final teams = [
      'Mobile Vet Unit Alpha (Dr. Shinde)',
      'Rapid Response Team 02 (Dr. Patil)',
      'Epidemiology Field Team 05 (Dr. Kadam)',
      'Special Cattle Ring Squad (Dr. More)',
    ];
    String selectedTeam = teams.first;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: GovtColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ASSIGN FIELD VACCINATION TEAM',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GovtColors.textPrimary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: GovtColors.textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Deploying priority field personnel to ${village.name}.',
                    style: const TextStyle(fontSize: 12, color: GovtColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  const Text('Select Available Field Team', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: GovtColors.textSecondary)),
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
                        items: teams.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12.5)))).toList(),
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
                      label: const Text('CONFIRM DEPLOYMENT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                      onPressed: () {
                        setState(() {
                          village.assignedTeam = selectedTeam;
                          village.status = 'In Progress';
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: GovtColors.brandDark,
                            content: Text('✓ $selectedTeam successfully assigned to ${village.name}.'),
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

  void _showAdvisoryBroadcastModal() {
    final msgCtrl = TextEditingController(
      text: 'GOVERNMENT ADVISORY: Active ${_campaign.disease} vaccination drive in ${_campaign.targetDistrict} District. Present all cattle and buffalo for mandatory free immunization.',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: GovtColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('BROADCAST CAMPAIGN ADVISORY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GovtColors.textPrimary)),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: GovtColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Will broadcast SMS & app push notification to livestock farmers in ${_campaign.targetDistrict}.',
                style: const TextStyle(fontSize: 12, color: GovtColors.textSecondary),
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
                    backgroundColor: GovtColors.brand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.campaign_rounded, size: 16),
                  label: const Text('SEND BROADCAST', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: GovtColors.brandDark,
                        content: Text('✓ Campaign advisory broadcasted to ${_campaign.targetDistrict} farmers.'),
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

  void _openDistrictAreaDetail() {
    final allDistricts = GovtMockData.getMaharashtraDistricts();
    final match = allDistricts.firstWhere(
      (d) => d.name.toLowerCase() == _campaign.targetDistrict.toLowerCase(),
      orElse: () => allDistricts.first,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GovtAreaDetailScreen(
          district: match,
          dataService: widget.dataService,
        ),
      ),
    );
  }

  void _markCampaignComplete() {
    setState(() {
      _campaign.status = CampaignStatus.completed;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: GovtColors.brandDark,
        content: Text('✓ Campaign "${_campaign.name}" marked as Completed.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalTarget = _campaign.targetAnimals;
    final totalVaccinated = _campaign.vaccinatedAnimals;
    final pendingAnimals = _campaign.pendingAnimals;
    final covPct = _campaign.coveragePercent;

    final targetVillages = _campaign.targetVillagesCount > 0 ? _campaign.targetVillagesCount : _villages.length;
    final completedVillages = _campaign.completedVillagesCount > 0 ? _campaign.completedVillagesCount : _villages.where((v) => v.isCompleted).length;
    final pendingVillages = _campaign.pendingVillagesCount > 0 ? _campaign.pendingVillagesCount : (targetVillages - completedVillages);

    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      appBar: AppBar(
        backgroundColor: GovtColors.surface,
        foregroundColor: GovtColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Text(_campaign.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
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
            // ── Header Card ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
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
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _campaign.name.toUpperCase(),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: GovtColors.textPrimary, letterSpacing: -0.2),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_campaign.targetDistrict.toUpperCase()} DISTRICT',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GovtColors.brandDark),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _campaign.priority == CampaignPriority.critical
                              ? GovtColors.critical.withValues(alpha: 0.12)
                              : GovtColors.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _campaign.priority == CampaignPriority.critical
                                ? GovtColors.critical
                                : GovtColors.warning,
                          ),
                        ),
                        child: Text(
                          '${_campaign.priority.label} PRIORITY',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: _campaign.priority == CampaignPriority.critical
                                ? GovtColors.critical
                                : GovtColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: GovtColors.border),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Text(
                        'Campaign status:',
                        style: TextStyle(fontSize: 12, color: GovtColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: GovtColors.riskLow,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _campaign.statusLabel.toUpperCase(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GovtColors.riskLow),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Campaign Progress Card ───────────────────────────────────────
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
                  const Text('CAMPAIGN PROGRESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: GovtColors.textSecondary)),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_fmtNum(totalVaccinated)} / ${_fmtNum(totalTarget)} animals',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: GovtColors.textPrimary),
                      ),
                      Text(
                        '${covPct.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GovtColors.brand),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: totalTarget > 0 ? (totalVaccinated / totalTarget).clamp(0.0, 1.0) : 0.0,
                      minHeight: 12,
                      backgroundColor: GovtColors.surfaceSubtle,
                      valueColor: const AlwaysStoppedAnimation(GovtColors.brand),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Village counts
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: GovtColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _progressVillageStat('Target villages:', '$targetVillages', GovtColors.textPrimary),
                        _divider(),
                        _progressVillageStat('Completed:', '$completedVillages', GovtColors.riskLow),
                        _divider(),
                        _progressVillageStat('Pending:', '$pendingVillages', GovtColors.warning),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Vaccination Status Breakdown ──────────────────────────────────
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
                  const Text('VACCINATION STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: GovtColors.textSecondary)),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _statusCard('TARGET', _fmtNum(totalTarget), GovtColors.textPrimary),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _statusCard('COMPLETED', _fmtNum(totalVaccinated), GovtColors.riskLow),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _statusCard('PENDING', _fmtNum(pendingAnimals), GovtColors.warning),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Village-Level Progress Breakdown ──────────────────────────────
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'VILLAGE-LEVEL PROGRESS',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: GovtColors.textPrimary),
                      ),
                      Text(
                        'Tap village for action',
                        style: TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: GovtColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ..._villages.take(8).map((village) {
                    final pct = village.coveragePercent;
                    final isComplete = village.isCompleted;
                    final isLow = village.hasLowCoverage;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => _openVillageDetails(village),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                          decoration: BoxDecoration(
                            color: GovtColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isLow ? GovtColors.critical.withValues(alpha: 0.3) : GovtColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  village.name,
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: GovtColors.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${pct.round()}%',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: isComplete
                                      ? GovtColors.riskLow
                                      : (isLow ? GovtColors.critical : GovtColors.warning),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isComplete)
                                const Text('✓', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: GovtColors.riskLow))
                              else if (isLow)
                                const Text('⚠', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: GovtColors.critical))
                              else
                                const SizedBox(width: 12),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right_rounded, size: 16, color: GovtColors.textMuted),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Campaign Performance Timeline Chart ───────────────────────────
            _buildTimelineChart(),
            const SizedBox(height: 14),

            // ── Simulated Risk Reduction Impact Card (DEMO / MOCK DATA) ────────
            _buildDemoRiskImpactCard(),
            const SizedBox(height: 18),

            // ── Government Actions Bar ─────────────────────────────────────────
            _buildGovernmentActionsBar(),
          ],
        ),
      ),
    );
  }

  // ─── Sub-widgets ────────────────────────────────────────────────────────────

  Widget _buildTimelineChart() {
    final points = _campaign.timelinePoints.isNotEmpty
        ? _campaign.timelinePoints
        : const [
            CampaignProgressPoint(dayLabel: 'Day 1', coverage: 42.0),
            CampaignProgressPoint(dayLabel: 'Day 7', coverage: 51.0),
            CampaignProgressPoint(dayLabel: 'Day 14', coverage: 63.0),
            CampaignProgressPoint(dayLabel: 'Day 21', coverage: 70.1),
            CampaignProgressPoint(dayLabel: 'Day 30', coverage: 78.0),
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
          const Text('VACCINATION COVERAGE — CAMPAIGN PROGRESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: GovtColors.textSecondary)),
          const SizedBox(height: 4),
          const Text('Demonstrated coverage increase over time', style: TextStyle(fontSize: 11, color: GovtColors.textMuted)),
          const SizedBox(height: 14),

          // Horizontal progress sequence
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: points.asMap().entries.map((entry) {
              final idx = entry.key;
              final pt = entry.value;
              final isLast = idx == points.length - 1;

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
                              '${pt.coverage.round()}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isLast ? GovtColors.brandDark : GovtColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isLast ? GovtColors.brand : GovtColors.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(pt.dayLabel, style: const TextStyle(fontSize: 9.5, color: GovtColors.textMuted)),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 12,
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

  Widget _buildDemoRiskImpactCard() {
    // Pune demo: Before 78% -> After 64%
    final simulation = GovtCampaignEngine.simulateRiskReduction(
      currentRisk: 78,
      currentCoverage: 61,
      targetCoverage: 82,
    );

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
              const Text(
                'PROJECTED RISK IMPACT',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: GovtColors.textSecondary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Text(
                  'DEMO / MOCK DATA',
                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Before Campaign', style: TextStyle(fontSize: 10.5, color: GovtColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      'Risk = ${simulation.beforeRisk}%',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GovtColors.critical),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, size: 16, color: GovtColors.brand),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Projected Post-Drive', style: TextStyle(fontSize: 10.5, color: GovtColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      'Risk = ${simulation.afterRisk}%',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GovtColors.riskLow),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Simulated epidemiological attenuation upon reaching 82% herd coverage.',
            style: TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: GovtColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildGovernmentActionsBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GOVERNMENT RESPONSE ACTIONS',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: GovtColors.textSecondary),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GovtColors.brand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.group_add_rounded, size: 15),
                label: const Text('ASSIGN TEAM', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                onPressed: () {
                  if (_villages.isNotEmpty) {
                    _showAssignTeamModal(_villages.first);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: GovtColors.brand,
                  side: const BorderSide(color: GovtColors.brand),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.campaign_outlined, size: 15),
                label: const Text('SEND ADVISORY', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                onPressed: _showAdvisoryBroadcastModal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: GovtColors.textPrimary,
                  side: const BorderSide(color: GovtColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.map_outlined, size: 15),
                label: const Text('VIEW AREA', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                onPressed: _openDistrictAreaDetail,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: GovtColors.riskLow,
                  side: const BorderSide(color: GovtColors.riskLow),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 15),
                label: const Text('MARK COMPLETE', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                onPressed: _markCampaignComplete,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _villageMetricCard({required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: GovtColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9.5, color: GovtColors.textMuted, fontWeight: FontWeight.w600), maxLines: 1),
          const SizedBox(height: 3),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _statusCard(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: GovtColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GovtColors.border),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: GovtColors.textSecondary, letterSpacing: 0.3)),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _progressVillageStat(String label, String val, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: GovtColors.textMuted)),
        const SizedBox(height: 2),
        Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  Widget _divider() => Container(width: 1, height: 24, color: GovtColors.border);

  String _fmtNum(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    }
    return '$n';
  }
}
