// Veterinary Visit Screen — schedule and record a field visit

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../models/case.dart';
import '../../models/vet_visit.dart';

class VetVisitScreen extends StatefulWidget {
  final FarmerDataService dataService;
  final LivestockCase lcase;

  const VetVisitScreen({super.key, required this.dataService, required this.lcase});

  @override
  State<VetVisitScreen> createState() => _VetVisitScreenState();
}

class _VetVisitScreenState extends State<VetVisitScreen> {
  DateTime _visitDate = DateTime.now().add(const Duration(hours: 2));
  final _observationsCtrl = TextEditingController();
  final _animalsExaminedCtrl = TextEditingController();
  final _symptomsObservedCtrl = TextEditingController();
  final _assessmentCtrl = TextEditingController();
  final _actionCtrl = TextEditingController();
  final _treatmentCtrl = TextEditingController();
  DateTime? _followUp = DateTime.now().add(const Duration(days: 3));
  bool _isCompleted = false;
  bool _saving = false;

  @override
  void dispose() {
    _observationsCtrl.dispose();
    _animalsExaminedCtrl.dispose();
    _symptomsObservedCtrl.dispose();
    _assessmentCtrl.dispose();
    _actionCtrl.dispose();
    _treatmentCtrl.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _saving = true);
    final visit = VetVisit(
      visitId: widget.dataService.generateVisitId(),
      caseId: widget.lcase.caseId,
      farmerId: widget.lcase.farmerId,
      farmerName: widget.lcase.farmerName,
      farmLocation: '${widget.lcase.village}, ${widget.lcase.block}, ${widget.lcase.district}',
      vetId: 'VET001',
      vetName: 'Dr. Rajesh Kumar',
      scheduledDate: _visitDate,
      actualDate: _isCompleted ? DateTime.now() : null,
      observations: _observationsCtrl.text.trim().isEmpty ? null : _observationsCtrl.text.trim(),
      animalsExamined: _animalsExaminedCtrl.text.trim().isEmpty ? null : _animalsExaminedCtrl.text.trim(),
      symptomsObserved: _symptomsObservedCtrl.text.trim().isEmpty ? null : _symptomsObservedCtrl.text.trim(),
      preliminaryAssessment: _assessmentCtrl.text.trim().isEmpty ? null : _assessmentCtrl.text.trim(),
      actionTaken: _actionCtrl.text.trim().isEmpty ? null : _actionCtrl.text.trim(),
      treatmentGiven: _treatmentCtrl.text.trim().isEmpty ? null : _treatmentCtrl.text.trim(),
      followUpDate: _followUp,
      isCompleted: _isCompleted,
    );

    widget.dataService.addVetVisit(visit);

    if (_isCompleted && _treatmentCtrl.text.trim().isNotEmpty) {
      widget.lcase.treatmentSummary = _treatmentCtrl.text.trim();
      widget.dataService.updateCaseStatus(
        widget.lcase.caseId,
        FullCaseStatus.treatmentStarted,
        actor: 'Veterinarian',
        description: 'Treatment given: ${_treatmentCtrl.text.trim()}',
      );
    }

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _saving = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Visit recorded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('Field Visit', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Case summary
            _infoCard(),
            const SizedBox(height: 16),

            // Visit date
            _card('📅 Visit Date & Time', [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: Color(0xFF1565C0)),
                title: Text(
                  '${_visitDate.day}/${_visitDate.month}/${_visitDate.year}  ${_visitDate.hour}:${_visitDate.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _visitDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) setState(() => _visitDate = date);
                  },
                  child: const Text('Change'),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mark visit as completed'),
                subtitle: const Text('Check if you have already visited'),
                value: _isCompleted,
                onChanged: (v) => setState(() => _isCompleted = v),
              ),
            ]),

            const SizedBox(height: 12),

            _card('🔍 Clinical Observations', [
              _field(_observationsCtrl, 'General observations', maxLines: 3),
              const SizedBox(height: 10),
              _field(_animalsExaminedCtrl, 'Animals examined (e.g. 3 cows)'),
              const SizedBox(height: 10),
              _field(_symptomsObservedCtrl, 'Symptoms observed', maxLines: 2),
            ]),

            const SizedBox(height: 12),

            _card('📋 Assessment & Action', [
              _field(_assessmentCtrl, 'Preliminary assessment', maxLines: 2),
              const SizedBox(height: 10),
              _field(_actionCtrl, 'Action taken', maxLines: 2),
              const SizedBox(height: 10),
              _field(_treatmentCtrl, 'Treatment given (medicine, dosage)', maxLines: 2),
            ]),

            const SizedBox(height: 12),

            _card('📅 Follow-up', [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_repeat, color: Color(0xFF1565C0)),
                title: Text(
                  _followUp != null
                      ? 'Follow-up: ${_followUp!.day}/${_followUp!.month}/${_followUp!.year}'
                      : 'No follow-up',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _followUp ?? DateTime.now().add(const Duration(days: 3)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                    );
                    if (date != null) setState(() => _followUp = date);
                  },
                  child: const Text('Set'),
                ),
              ),
            ]),

            const SizedBox(height: 24),

            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('SAVE VISIT RECORD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.agriculture, color: Colors.white70, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.lcase.farmerName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('${widget.lcase.species} · ${widget.lcase.animalTag} · ${widget.lcase.riskLevel}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text('${widget.lcase.village}, ${widget.lcase.district}',
                    style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
