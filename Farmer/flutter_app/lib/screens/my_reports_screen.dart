import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../services/localization_service.dart';
import '../models/health_report.dart';
import '../models/case.dart';
import '../models/mortality_report.dart';
import '../models/vet_request.dart';
import '../theme/app_theme.dart';
import 'symptom_report_screen.dart';

class MyReportsScreen extends StatefulWidget {
  final FarmerDataService dataService;

  const MyReportsScreen({super.key, required this.dataService});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    widget.dataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    widget.dataService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final healthReports = widget.dataService.getHealthReports();
    final mortalityReports = widget.dataService.getMortalityReports();
    final vetRequests = widget.dataService.getVetRequests();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('my_animals_cases'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.2),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.65),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: [
            Tab(text: 'Health (${healthReports.length})'),
            Tab(text: 'Mortality (${mortalityReports.length})'),
            Tab(text: 'Vet Visits (${vetRequests.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHealthCasesList(healthReports),
          _buildMortalityCasesList(mortalityReports),
          _buildVetRequestsList(vetRequests),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.farmerEmergency,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Report New Problem', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SymptomReportScreen(dataService: widget.dataService),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 36,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCasesList(List<HealthReport> reports) {
    if (reports.isEmpty) return _buildEmptyState('No health cases reported yet.');
    final sorted = [...reports]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: sorted.length,
      itemBuilder: (ctx, i) {
        final r = sorted[i];
        return _buildCaseCard(
          caseId: 'Case #${r.id}',
          title: '${r.species ?? "Animal"} — ${r.animalTag}',
          subtitle: r.symptoms.take(3).join(', '),
          date: r.createdAt,
          riskLevel: r.riskLevel,
          status: r.caseStatus.displayName,
          onTap: () => _openHealthCaseModal(ctx, r),
        );
      },
    );
  }

  Widget _buildMortalityCasesList(List<MortalityReport> reports) {
    if (reports.isEmpty) return _buildEmptyState('No mortality cases reported.');
    final sorted = [...reports]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: sorted.length,
      itemBuilder: (ctx, i) {
        final r = sorted[i];
        return _buildCaseCard(
          caseId: 'Death #${r.id}',
          title: 'Animal: ${r.animalTag}',
          subtitle: '${r.numberAffected} animal(s) affected',
          date: r.createdAt,
          riskLevel: RiskLevel.critical,
          status: 'Submitted',
          onTap: () => _openMortalityCaseModal(ctx, r),
        );
      },
    );
  }

  Widget _buildVetRequestsList(List<VetRequest> requests) {
    if (requests.isEmpty) return _buildEmptyState('No veterinarian visits requested.');
    final sorted = [...requests]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: sorted.length,
      itemBuilder: (ctx, i) {
        final r = sorted[i];
        return _buildCaseCard(
          caseId: 'Vet Request #${r.id}',
          title: 'Animal: ${r.animalTag}',
          subtitle: r.reason,
          date: r.createdAt,
          status: r.caseStatus.displayName,
          onTap: () => _openVetRequestModal(ctx, r),
        );
      },
    );
  }

  Widget _buildCaseCard({
    required String caseId,
    required String title,
    required String subtitle,
    required DateTime date,
    RiskLevel? riskLevel,
    required String status,
    required VoidCallback onTap,
  }) {
    Color badgeColor = AppColors.info;
    if (riskLevel == RiskLevel.low) badgeColor = AppColors.riskLow;
    if (riskLevel == RiskLevel.medium) badgeColor = AppColors.riskMedium;
    if (riskLevel == RiskLevel.high) badgeColor = AppColors.riskHigh;
    if (riskLevel == RiskLevel.critical) badgeColor = AppColors.riskCritical;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      color: AppColors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      caseId,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (riskLevel != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Risk: ${riskLevel.displayName}',
                        style: TextStyle(color: badgeColor, fontWeight: FontWeight.w700, fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 11),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openHealthCaseModal(BuildContext context, HealthReport report) {
    final linkedCase = widget.dataService.getCaseById(report.id.replaceFirst('RPT', 'CASE')) ??
        widget.dataService.getCaseById(report.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        builder: (ctx, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Case #${report.id}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Animal: ${report.animalTag} · ${report.breed ?? "Standard"}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 16),

              // Government Escalation Alert Banner (if escalated)
              if (linkedCase?.isEscalatedToGovt == true ||
                  linkedCase?.status == FullCaseStatus.escalated ||
                  report.caseStatus == CaseStatus.escalated) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.deepOrange.shade300, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emergency_rounded, color: Colors.deepOrange, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ESCALATED TO GOVERNMENT SURVEILLANCE',
                              style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w800, fontSize: 12.5),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Case escalated to regional animal health authorities for emergency epidemic response.',
                              style: TextStyle(color: Colors.deepOrange.shade900, fontSize: 12, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Unified Veterinary Care & Clinical Findings Card
              if (linkedCase?.assignedVetName != null ||
                  (linkedCase?.clinicalObservation != null && linkedCase!.clinicalObservation!.isNotEmpty)) ...[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Assigned Vet Info
                      if (linkedCase?.assignedVetName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
                            border: Border(bottom: BorderSide(color: Color(0xFFDCFCE7))),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.medical_services_rounded, color: AppColors.primaryDark, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          linkedCase!.assignedVetName!,
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryDark,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text('ATTENDING VET', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                                        ),
                                      ],
                                    ),
                                    if (linkedCase.visitScheduledDate != null) ...[
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Icon(Icons.event_available_rounded, size: 14, color: AppColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Visit: ${linkedCase.visitScheduledDate!.day}/${linkedCase.visitScheduledDate!.month}/${linkedCase.visitScheduledDate!.year}',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Clinical Findings Body
                      if (linkedCase?.clinicalObservation != null && linkedCase!.clinicalObservation!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.assignment_turned_in_rounded, color: AppColors.primary, size: 17),
                                  SizedBox(width: 7),
                                  Text(
                                    'Veterinarian Findings & Diagnosis',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: AppColors.primaryDark,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  linkedCase.clinicalObservation!,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    height: 1.45,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (linkedCase.treatmentSummary != null && linkedCase.treatmentSummary!.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.medication_rounded, color: Colors.blue, size: 16),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Treatment: ${linkedCase.treatmentSummary!}',
                                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Risk Badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_rounded, color: Colors.red, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      '${report.riskLevel.displayName} HEALTH RISK',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text('Reported Problems:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: report.symptoms
                    .map((s) => Chip(
                          label: Text(s),
                          backgroundColor: Colors.grey.shade100,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),

              const Text('Advice Given:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(report.advice, style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 12),

              const Text('Recommended Action:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(report.recommendedAction, style: const TextStyle(color: Colors.black87)),
              const SizedBox(height: 16),

              if (report.hasVoiceNote) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.mic_rounded, color: Colors.orange),
                      SizedBox(width: 10),
                      Text('Voice note recorded with this case', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const Text('Status Timeline:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              _buildTimeline(report.caseStatus),
            ],
          ),
        ),
      ),
    );
  }

  void _openMortalityCaseModal(BuildContext context, MortalityReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        builder: (ctx, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mortality Report #${report.id}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Animal: ${report.animalTag}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              _buildDetailRow('Date', '${report.date.day}/${report.date.month}/${report.date.year}'),
              _buildDetailRow('Time', report.time),
              _buildDetailRow('Animals Died', '${report.numberAffected}'),
              _buildDetailRow('Location', report.location ?? 'Farm Location'),
              if (report.symptomsBeforeDeath.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Symptoms before death:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: report.symptomsBeforeDeath.map((s) => Chip(label: Text(s))).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openVetRequestModal(BuildContext context, VetRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        builder: (ctx, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vet Request #${request.id}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Animal: ${request.animalTag}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              _buildDetailRow('Reason', request.reason),
              _buildDetailRow('Status', request.caseStatus.displayName),
              if (request.preferredDate != null)
                _buildDetailRow('Preferred Date',
                    '${request.preferredDate!.day}/${request.preferredDate!.month}/${request.preferredDate!.year}'),
              if (request.preferredTime != null)
                _buildDetailRow('Preferred Time', request.preferredTime!),
              const SizedBox(height: 16),
              const Text('Timeline:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              _buildTimeline(request.caseStatus),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildTimeline(CaseStatus status) {
    final stages = [
      'SUBMITTED',
      'UNDER REVIEW',
      'VET ASSIGNED',
      'VISIT SCHEDULED',
      'SAMPLE COLLECTED',
      'LAB REFERRED',
      'TREATMENT STARTED',
      if (status == CaseStatus.escalated) 'ESCALATED TO GOVT',
      'CASE CLOSED',
    ];

    int targetIndex = 0;
    switch (status) {
      case CaseStatus.open:
        targetIndex = 0;
        break;
      case CaseStatus.underReview:
        targetIndex = 1;
        break;
      case CaseStatus.vetAssigned:
        targetIndex = 2;
        break;
      case CaseStatus.visitScheduled:
        targetIndex = 3;
        break;
      case CaseStatus.sampleCollected:
        targetIndex = 4;
        break;
      case CaseStatus.labReferred:
        targetIndex = 5;
        break;
      case CaseStatus.investigation:
        targetIndex = 5;
        break;
      case CaseStatus.treatmentStarted:
        targetIndex = 6;
        break;
      case CaseStatus.escalated:
        targetIndex = 7;
        break;
      case CaseStatus.closed:
        targetIndex = stages.length - 1;
        break;
    }

    return Column(
      children: stages.asMap().entries.map((e) {
        final idx = e.key;
        final name = e.value;
        final isPassed = idx <= targetIndex;
        final isLast = idx == stages.length - 1;
        final isEscalatedNode = name == 'ESCALATED TO GOVT';

        final activeColor = isEscalatedNode ? Colors.deepOrange.shade800 : const Color(0xFF2E7D32);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 9,
                  backgroundColor: isPassed ? activeColor : Colors.grey.shade300,
                  child: isPassed ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 28,
                    color: isPassed ? activeColor : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: isPassed ? FontWeight.bold : FontWeight.normal,
                    color: isPassed ? (isEscalatedNode ? Colors.deepOrange.shade900 : Colors.black87) : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
