// My Cases Screen — Simple cards showing case #, status, animal, and details.
// Replaces complicated reports view with straightforward case tracking for livestock farmers.

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../services/localization_service.dart';
import '../models/health_report.dart';
import '../models/mortality_report.dart';
import '../models/vet_request.dart';
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
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          context.tr('my_animals_cases'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primary,
          indicatorWeight: 3,
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
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Report New Problem', style: TextStyle(fontWeight: FontWeight.bold)),
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
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.folder_open_rounded, size: 36, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
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
    Color badgeColor = Colors.blue;
    if (riskLevel == RiskLevel.low) badgeColor = Colors.green;
    if (riskLevel == RiskLevel.medium) badgeColor = Colors.orange.shade800;
    if (riskLevel == RiskLevel.high) badgeColor = Colors.deepOrange;
    if (riskLevel == RiskLevel.critical) badgeColor = Colors.red.shade900;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      caseId,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (riskLevel != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Risk: ${riskLevel.displayName}',
                        style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openHealthCaseModal(BuildContext context, HealthReport report) {
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
      'TREATMENT STARTED',
      'CASE CLOSED',
    ];

    final currentIndex = status.index;

    return Column(
      children: stages.asMap().entries.map((e) {
        final idx = e.key;
        final name = e.value;
        final isPassed = idx <= currentIndex;
        final isLast = idx == stages.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 9,
                  backgroundColor: isPassed ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                  child: isPassed ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 28,
                    color: isPassed ? const Color(0xFF2E7D32) : Colors.grey.shade300,
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
                    color: isPassed ? Colors.black87 : Colors.grey,
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
