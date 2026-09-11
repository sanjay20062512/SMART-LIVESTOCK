// Veterinary Case Detail Screen — full view with actions

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../models/case.dart';
import '../../models/sample.dart';
import '../../models/vet_visit.dart';
import 'vet_sample_screen.dart';
import 'vet_visit_screen.dart';

class VetCaseDetailScreen extends StatelessWidget {
  final FarmerDataService dataService;
  final LivestockCase lcase;

  const VetCaseDetailScreen({
    super.key,
    required this.dataService,
    required this.lcase,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        final c = dataService.getCaseById(lcase.caseId) ?? lcase;
        final samples = dataService.getSamplesForCase(c.caseId);
        final visits = dataService.getVisitsForCase(c.caseId);

        final riskColor = switch (c.riskLevel) {
          'CRITICAL' => const Color(0xFFB71C1C),
          'HIGH' => const Color(0xFFE65100),
          'MEDIUM' => const Color(0xFFF57F17),
          _ => const Color(0xFF2E7D32),
        };

        return Scaffold(
          backgroundColor: const Color(0xFFF0F4FF),
          appBar: AppBar(
            title: Text(c.caseId, style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: riskColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Risk badge
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: riskColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_rounded, color: Colors.white),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${c.riskLevel} RISK',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Preliminary risk assessment',
                              style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      _statusPill(c.status.displayName),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Farmer & Farm info
                _section('Farmer & Farm', [
                  _row('Farmer', c.farmerName),
                  _row('Farm', c.farmName),
                  _row('Village', c.village),
                  _row('Block', c.block),
                  _row('District', c.district),
                ]),

                // Animal details
                _section('Animal Details', [
                  _row('Species', c.species),
                  if (c.breed != null) _row('Breed', c.breed!),
                  if (c.age != null) _row('Age', c.age!),
                  if (c.gender != null) _row('Gender', c.gender!),
                  _row('Tag', c.animalTag),
                ]),

                // Clinical info
                _section('Clinical Information', [
                  _row('Symptoms', c.symptoms.join(', ')),
                  if (c.duration != null) _row('Duration', c.duration!),
                  if (c.affectedCount != null) _row('Animals Affected', c.affectedCount!),
                  if (c.otherAnimalsAffected != null)
                    _row('Other Animals Affected', c.otherAnimalsAffected!),
                  if (c.nearbyFarmsAffected != null)
                    _row('Nearby Farms Affected', c.nearbyFarmsAffected!),
                ]),

                // Evidence
                if (c.hasVoiceNote || c.hasPhoto || c.hasVideo)
                  _section('Evidence', [
                    if (c.hasVoiceNote) _evidenceChip('Voice Note'),
                    if (c.hasPhoto) _evidenceChip('Photo'),
                    if (c.hasVideo) _evidenceChip('Video'),
                  ]),

                // Clinical Observation (if added)
                if (c.clinicalObservation != null)
                  _section('Clinical Observation', [
                    Text(c.clinicalObservation!,
                        style: const TextStyle(fontSize: 14, height: 1.4)),
                  ]),

                // Treatment (if added)
                if (c.treatmentSummary != null)
                  _section('Treatment Summary', [
                    Text(c.treatmentSummary!,
                        style: const TextStyle(fontSize: 14, height: 1.4)),
                  ]),

                // Samples
                if (samples.isNotEmpty)
                  _section('Laboratory Samples', samples.map((s) => _sampleRow(s)).toList()),

                // Visits
                if (visits.isNotEmpty)
                  _section('Field Visits', visits.map((v) => _visitRow(v)).toList()),

                // Timeline
                _section('Case Timeline', c.timeline.map((e) => _timelineEvent(e)).toList()),

                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomNavigationBar: _buildActionBar(context, c),
        );
      },
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A237E))),
          const Divider(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _evidenceChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  Widget _sampleRow(Sample s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.science_outlined, size: 16, color: Colors.purple),
          const SizedBox(width: 8),
          Expanded(
            child: Text('${s.sampleType} · ${s.collectedBy}',
                style: const TextStyle(fontSize: 13)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(s.status.displayName,
                style: TextStyle(fontSize: 11, color: Colors.purple.shade700, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _visitRow(VetVisit v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            v.isCompleted ? Icons.check_circle : Icons.schedule,
            size: 16,
            color: v.isCompleted ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${v.vetName} · ${v.scheduledDate.day}/${v.scheduledDate.month}',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Text(v.isCompleted ? 'Completed' : 'Scheduled',
              style: TextStyle(
                fontSize: 11,
                color: v.isCompleted ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  Widget _timelineEvent(CaseTimelineEvent e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF1565C0),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 28,
                color: Colors.blue.shade100,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.status,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(e.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                if (e.actor != null)
                  Text('by ${e.actor}',
                      style: const TextStyle(color: Colors.blueGrey, fontSize: 11)),
              ],
            ),
          ),
          Text(
            '${e.timestamp.hour}:${e.timestamp.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white54),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionBar(BuildContext context, LivestockCase c) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.directions_car, size: 18),
                  label: const Text('Schedule Visit', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: c.status == FullCaseStatus.caseClosed ? null : () => _scheduleVisit(context, c),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.science, size: 18),
                  label: const Text('Add Sample', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: c.status == FullCaseStatus.caseClosed ? null : () => _addSample(context, c),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.note_add, size: 18),
                  label: const Text('Add Observation'),
                  onPressed: () => _addObservation(context, c),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.upgrade, size: 18),
                  label: const Text('Update Status'),
                  onPressed: () => _updateStatus(context, c),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: c.isEscalatedToGovt || c.status == FullCaseStatus.escalated
                    ? Colors.grey.shade700
                    : Colors.deepOrange.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(
                c.isEscalatedToGovt || c.status == FullCaseStatus.escalated
                    ? Icons.check_circle_rounded
                    : Icons.report_problem_rounded,
                size: 18,
              ),
              label: Text(
                c.isEscalatedToGovt || c.status == FullCaseStatus.escalated
                    ? 'Escalated to Govt Surveillance'
                    : 'Escalate Case to Government',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: c.isEscalatedToGovt || c.status == FullCaseStatus.escalated
                  ? null
                  : () => _handleEscalateCase(context, c),
            ),
          ),
        ],
      ),
    );
  }

  void _handleEscalateCase(BuildContext context, LivestockCase c) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.report_problem_rounded, color: Colors.deepOrange),
            const SizedBox(width: 8),
            const Expanded(child: Text('Escalate Case to Government')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Escalating Case #${c.caseId} (${c.species}, ${c.animalTag}) will dispatch an emergency high-priority alert to the State Government Surveillance Portal.',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Reason for Escalation (Optional)',
                hintText: 'e.g. Suspected contagious epidemic outbreak...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange.shade800,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              dataService.escalateCase(
                c.caseId,
                reason: reasonCtrl.text.trim().isNotEmpty ? reasonCtrl.text.trim() : null,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✓ Case #${c.caseId} escalated to Government Surveillance.'),
                  backgroundColor: Colors.deepOrange.shade800,
                ),
              );
            },
            child: const Text('Escalate Now'),
          ),
        ],
      ),
    );
  }

  void _scheduleVisit(BuildContext context, LivestockCase c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VetVisitScreen(dataService: dataService, lcase: c),
      ),
    );
  }

  void _addSample(BuildContext context, LivestockCase c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VetSampleScreen(dataService: dataService, lcase: c),
      ),
    );
  }

  void _addObservation(BuildContext context, LivestockCase c) {
    final ctrl = TextEditingController(text: c.clinicalObservation ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clinical Observation'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter clinical findings, symptoms observed, preliminary assessment...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              c.clinicalObservation = ctrl.text.trim();
              dataService.updateCaseStatus(c.caseId, FullCaseStatus.investigation,
                  actor: 'Veterinarian', description: 'Clinical observation added.');
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _updateStatus(BuildContext context, LivestockCase c) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Update Case Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(height: 16),
              RadioGroup<FullCaseStatus>(
                groupValue: c.status,
                onChanged: (v) {
                  if (v != null) {
                    dataService.updateCaseStatus(c.caseId, v, actor: 'Veterinarian');
                    Navigator.pop(ctx);
                  }
                },
                child: Column(
                  children: FullCaseStatus.values.map((s) => ListTile(
                    title: Text(s.displayName),
                    leading: Radio<FullCaseStatus>(value: s),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
