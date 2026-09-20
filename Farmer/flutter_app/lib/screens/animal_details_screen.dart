// Animal Details Screen — shows full information, health records, vaccination, treatment.

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../services/localization_service.dart';
import '../models/animal.dart';
import '../models/health_report.dart';
import '../models/vaccination_record.dart';
import '../models/treatment_record.dart';
import '../models/vet_request.dart';
import 'add_animal_screen.dart';
import 'symptom_report_screen.dart';
import 'vet_request_screen.dart';

class AnimalDetailsScreen extends StatefulWidget {
  final String animalId;
  final FarmerDataService dataService;

  const AnimalDetailsScreen({
    super.key,
    required this.animalId,
    required this.dataService,
  });

  @override
  State<AnimalDetailsScreen> createState() => _AnimalDetailsScreenState();
}

class _AnimalDetailsScreenState extends State<AnimalDetailsScreen> {
  @override
  void initState() {
    super.initState();
    widget.dataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    widget.dataService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => setState(() {});

  Animal? get _animal =>
      widget.dataService.getAnimalById(widget.animalId);

  Color _statusColor(HealthStatus s) {
    switch (s) {
      case HealthStatus.healthy:
        return Colors.green;
      case HealthStatus.underMonitoring:
        return Colors.orange;
      case HealthStatus.activeCase:
        return Colors.red;
      case HealthStatus.critical:
        return Colors.red.shade900;
    }
  }

  @override
  Widget build(BuildContext context) {
    final animal = _animal;

    if (animal == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('animal_details'))),
        body: Center(child: Text(context.tr('animal_not_found'))),
      );
    }

    final healthReports = widget.dataService.getHealthReportsForAnimal(animal.id);
    final vaccinations = widget.dataService.getVaccinationsForAnimal(animal.id);
    final treatments = widget.dataService.getTreatmentsForAnimal(animal.id);
    final vetRequests = widget.dataService.getVetRequestsForAnimal(animal.id);
    final statusColor = _statusColor(animal.healthStatus);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${context.translateSpecies(animal.species.displayName)} — ${context.translateTag(animal.earTag)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: context.tr('edit_animal'),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddAnimalScreen(
                    dataService: widget.dataService,
                    existingAnimal: animal,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.circle, color: statusColor, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    context.translateText(animal.healthStatus.displayName),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Animal Information
            _sectionCard(
              title: context.tr('animal_information'),
              icon: Icons.info_outline,
              children: [
                _infoRow(context.tr('animal_id_tag'), context.translateTag(animal.earTag)),
                _infoRow(context.tr('species'), context.translateSpecies(animal.species.displayName)),
                _infoRow(context.tr('breed'), context.translateBreed(animal.breed)),
                _infoRow(context.tr('gender'), context.translateText(animal.gender.displayName)),
                _infoRow(context.tr('age'), context.translateText(animal.age)),
                _infoRow(context.tr('location'), context.translateText(animal.location ?? '—')),
              ],
            ),
            const SizedBox(height: 16),

            // Health Overview
            _sectionCard(
              title: context.tr('health_overview'),
              icon: Icons.health_and_safety_outlined,
              children: [
                _infoRow(context.tr('current_status'), context.translateText(animal.healthStatus.displayName)),
                _infoRow(
                  context.tr('last_health_report'),
                  animal.lastHealthReport != null
                      ? _formatDate(animal.lastHealthReport!)
                      : context.tr('none'),
                ),
                _infoRow(
                  context.tr('last_vet_visit'),
                  animal.lastVetVisit != null
                      ? _formatDate(animal.lastVetVisit!)
                      : context.tr('none'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Health Records
            _expandableSection(
              title: context.tr('health_records'),
              icon: Icons.description_outlined,
              count: healthReports.length,
              child: healthReports.isEmpty
                  ? _emptyMessage(context.tr('no_health_records'))
                  : Column(
                      children: healthReports
                          .map((r) => _HealthReportTile(report: r))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),

            // Vaccination
            _expandableSection(
              title: context.tr('vaccination'),
              icon: Icons.vaccines_outlined,
              count: vaccinations.length,
              child: vaccinations.isEmpty
                  ? _emptyMessage(context.tr('no_vaccinations'))
                  : Column(
                      children: vaccinations
                          .map((v) => _VaccinationTile(record: v))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),

            // Treatment
            _expandableSection(
              title: context.tr('treatment'),
              icon: Icons.medical_services_outlined,
              count: treatments.length,
              child: treatments.isEmpty
                  ? _emptyMessage(context.tr('no_treatments'))
                  : Column(
                      children: treatments
                          .map((t) => _TreatmentTile(record: t))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),

            // Vet Requests
            _expandableSection(
              title: context.tr('vet_requests'),
              icon: Icons.local_hospital_outlined,
              count: vetRequests.length,
              child: vetRequests.isEmpty
                  ? _emptyMessage(context.tr('no_vet_requests'))
                  : Column(
                      children: vetRequests
                          .map((v) => _VetRequestTile(request: v))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SymptomReportScreen(
                            dataService: widget.dataService,
                            preselectedAnimalId: animal.id,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.health_and_safety),
                    label: Text(context.tr('report_symptoms')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VetRequestScreen(
                            dataService: widget.dataService,
                            preselectedAnimalId: animal.id,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.local_hospital),
                    label: Text(context.tr('request_vet')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _expandableSection({
    required String title,
    required IconData icon,
    required int count,
    required Widget child,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (count > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyMessage(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(msg, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─── Tiles ────────────────────────────────────────────────────────────────────

class _HealthReportTile extends StatelessWidget {
  final HealthReport report;

  const _HealthReportTile({required this.report});

  Color _riskColor(RiskLevel r) {
    switch (r) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
      case RiskLevel.critical:
        return Colors.red.shade900;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(report.riskLevel);
    return Card(
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    context.translateText(report.riskLevel.displayName),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11),
                  ),
                ),
                const Spacer(),
                Text(
                  '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(context.translateText(report.title), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: report.symptoms
                  .map((s) => Chip(
                        label: Text(context.translateText(s), style: const TextStyle(fontSize: 11)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _VaccinationTile extends StatelessWidget {
  final VaccinationRecord record;

  const _VaccinationTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.vaccines, color: Colors.purple),
      title: Text(context.translateText(record.vaccineName),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(
        record.date != null
            ? '${context.tr("given")}: ${record.date!.day}/${record.date!.month}/${record.date!.year}'
            : context.tr('none'),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: record.status == VaccinationStatus.completed
              ? Colors.green.withValues(alpha: 0.15)
              : Colors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          context.translateText(record.status.displayName),
          style: TextStyle(
            color: record.status == VaccinationStatus.completed
                ? Colors.green
                : Colors.orange,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TreatmentTile extends StatelessWidget {
  final TreatmentRecord record;

  const _TreatmentTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.translateText(record.condition),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${context.tr("treatment")}: ${context.translateText(record.treatment)}'),
            Text('${context.tr("medicine")}: ${context.translateText(record.medicine)}'),
            if (record.veterinarian != null) Text('${context.tr("vet")}: ${context.translateText(record.veterinarian!)}'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                context.translateText(record.status.displayName),
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VetRequestTile extends StatelessWidget {
  final VetRequest request;

  const _VetRequestTile({required this.request});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.local_hospital, color: Colors.blue),
      title: Text(context.translateText(request.reason),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(context.translateStatus(request.caseStatus.displayName)),
      trailing: Text(
        '${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}',
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }
}
