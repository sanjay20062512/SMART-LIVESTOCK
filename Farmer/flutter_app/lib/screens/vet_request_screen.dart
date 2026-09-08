// Veterinarian Request Screen — Simple vet visit booking for livestock farmers.
// Features reason chips, voice description, visit time picker, and timeline tracking.

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../services/localization_service.dart';
import '../models/animal.dart';
import '../models/vet_request.dart';
import '../models/health_report.dart';

class VetRequestScreen extends StatefulWidget {
  final FarmerDataService dataService;
  final String? preselectedAnimalId;

  const VetRequestScreen({
    super.key,
    required this.dataService,
    this.preselectedAnimalId,
  });

  @override
  State<VetRequestScreen> createState() => _VetRequestScreenState();
}

class _VetRequestScreenState extends State<VetRequestScreen> {
  Animal? _selectedAnimal;
  String _selectedReason = 'Animal is very sick';
  final _descCtrl = TextEditingController();
  bool _hasVoiceNote = false;
  bool _isRecordingVoice = false;

  String _preferredDay = 'Today';
  DateTime? _customDate;
  String _preferredTimeSlot = 'Morning';

  bool _submitted = false;
  String? _requestId;

  final List<String> _reasonOptions = [
    'Animal is very sick',
    'Animal not improving',
    'Animal death',
    'Vaccination',
    'Treatment follow-up',
    'Other',
  ];

  final List<String> _dayOptions = ['Today', 'Tomorrow', 'Choose date'];
  final List<String> _timeSlots = ['Morning', 'Afternoon', 'Evening'];

  @override
  void initState() {
    super.initState();
    final animals = widget.dataService.getAnimals();
    if (widget.preselectedAnimalId != null) {
      _selectedAnimal = widget.dataService.getAnimalById(widget.preselectedAnimalId!);
    } else if (animals.isNotEmpty) {
      _selectedAnimal = animals.first;
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 2)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _customDate = picked;
        _preferredDay = '${picked.day}/${picked.month}';
      });
    }
  }

  void _simulateVoiceRecording() {
    setState(() => _isRecordingVoice = true);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _isRecordingVoice = false;
        _hasVoiceNote = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Voice message attached to vet request!'), backgroundColor: Colors.green),
      );
    });
  }

  void _submit() {
    final animals = widget.dataService.getAnimals();
    final animalTag = _selectedAnimal?.earTag ?? (animals.isNotEmpty ? animals.first.earTag : 'General Request');
    final id = widget.dataService.generateVetRequestId();

    final request = VetRequest(
      id: id,
      animalId: _selectedAnimal?.id,
      animalTag: animalTag,
      reason: _selectedReason,
      currentHealthStatus: _selectedAnimal?.healthStatus.displayName ?? 'Active Case',
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      preferredDate: _customDate ?? (_preferredDay == 'Today' ? DateTime.now() : DateTime.now().add(const Duration(days: 1))),
      preferredTime: _preferredTimeSlot,
      caseStatus: CaseStatus.open,
    );

    request.addTimelineEvent('SUBMITTED', 'Veterinarian request submitted by farmer.');

    widget.dataService.addVetRequest(request);

    setState(() {
      _submitted = true;
      _requestId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _buildConfirmationView();

    final animals = widget.dataService.getAnimals();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          context.tr('need_veterinarian'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animal Selection
            Text(context.tr('select_case'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            animals.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Requesting general visit for farm (No registered animals selected)'),
                  )
                : DropdownButtonFormField<Animal>(
                    initialValue: _selectedAnimal,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.pets_rounded)),
                    items: animals
                        .map((a) => DropdownMenuItem(
                              value: a,
                              child: Text('${a.species.emoji} ${a.species.displayName} (${a.earTag})'),
                            ))
                        .toList(),
                    onChanged: (a) => setState(() => _selectedAnimal = a),
                  ),
            const SizedBox(height: 20),

            // Reason for request
            Text('${context.tr('reason_for_vet')} *', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reasonOptions.map((r) {
                final isSelected = _selectedReason == r;
                return ChoiceChip(
                  label: Text(r, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  selected: isSelected,
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  onSelected: (val) {
                    if (val) setState(() => _selectedReason = r);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Voice Note / Description
            Text('Describe symptoms / condition', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isRecordingVoice
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.mic_rounded, size: 20),
                  label: Text(_isRecordingVoice
                      ? 'Listening...'
                      : (_hasVoiceNote ? '✓ Voice Added' : '🎤 Speak Notes')),
                  onPressed: _isRecordingVoice ? null : _simulateVoiceRecording,
                ),
                if (_hasVoiceNote) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => setState(() => _hasVoiceNote = false),
                    child: const Text('Remove', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Or write brief notes here...',
              ),
            ),
            const SizedBox(height: 20),

            // Preferred Visit Date
            Text(context.tr('preferred_visit'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Row(
              children: _dayOptions.map((day) {
                final isSelected = _preferredDay == day || (_customDate != null && day == 'Choose date');
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(day == 'Choose date' && _customDate != null ? '${_customDate!.day}/${_customDate!.month}' : day),
                    selected: isSelected,
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                    onSelected: (v) {
                      if (day == 'Choose date') {
                        _pickCustomDate();
                      } else {
                        setState(() {
                          _preferredDay = day;
                          _customDate = null;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Preferred Time Slot
            Text(context.tr('preferred_time'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Row(
              children: _timeSlots.map((time) {
                final isSelected = _preferredTimeSlot == time;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(context.tr(time.toLowerCase())),
                    selected: isSelected,
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                    onSelected: (v) {
                      if (v) setState(() => _preferredTimeSlot = time);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 36),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.send_rounded, size: 22),
                label: const Text(
                  'SUBMIT VET REQUEST',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationView() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Request Submitted', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(Icons.check_circle_rounded, color: Color(0xFF1976D2), size: 54),
            ),
            const SizedBox(height: 16),
            const Text(
              'Veterinarian Request Submitted',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text('Request ID: #$_requestId', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // Timeline
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Case Progression Timeline:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 16),
                  _buildTimelineTile('SUBMITTED', 'Your request has been received.', isActive: true, isLast: false),
                  _buildTimelineTile('UNDER REVIEW', 'Coordinator will review the case.', isActive: false, isLast: false),
                  _buildTimelineTile('VET ASSIGNED', 'Veterinarian will be assigned.', isActive: false, isLast: false),
                  _buildTimelineTile('VISIT SCHEDULED', 'Visit date & time confirmed.', isActive: false, isLast: false),
                  _buildTimelineTile('TREATMENT STARTED', 'Vet visit & treatment administered.', isActive: false, isLast: false),
                  _buildTimelineTile('CASE CLOSED', 'Case resolved.', isActive: false, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(context.tr('done'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTile(String status, String description, {required bool isActive, required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 9,
              backgroundColor: isActive ? const Color(0xFF1976D2) : Colors.grey.shade300,
              child: isActive ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isActive ? const Color(0xFF1976D2) : Colors.grey.shade700,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
