// Sample Collection Screen

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../models/case.dart';
import '../../models/sample.dart';

class VetSampleScreen extends StatefulWidget {
  final FarmerDataService dataService;
  final LivestockCase lcase;

  const VetSampleScreen({super.key, required this.dataService, required this.lcase});

  @override
  State<VetSampleScreen> createState() => _VetSampleScreenState();
}

class _VetSampleScreenState extends State<VetSampleScreen> {
  String _sampleType = 'Blood';
  final _reasonCtrl = TextEditingController();
  String _lab = 'Maharashtra Animal Disease Investigation Laboratory, Pune';
  SampleStatus _status = SampleStatus.collected;
  bool _saving = false;

  static const _sampleTypes = ['Blood', 'Faecal', 'Nasal Swab', 'Tissue', 'Milk', 'Urine', 'Other'];
  static const _labs = [
    'Maharashtra Animal Disease Investigation Laboratory, Pune',
    'State Veterinary Diagnostic Laboratory, Mumbai',
    'Regional Disease Diagnostic Laboratory, Nagpur',
    'National Research Centre on Equines, Hisar',
    'Other',
  ];

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_reasonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the reason for sample collection'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _saving = true);

    final now = DateTime.now();
    final sample = Sample(
      sampleId: widget.dataService.generateSampleId(),
      caseId: widget.lcase.caseId,
      animalId: widget.lcase.animalId,
      animalTag: widget.lcase.animalTag,
      sampleType: _sampleType,
      collectionDate: '${now.day}/${now.month}/${now.year}',
      collectionLocation: '${widget.lcase.village}, ${widget.lcase.block}, ${widget.lcase.district}',
      reason: _reasonCtrl.text.trim(),
      laboratory: _lab,
      status: _status,
      collectedBy: 'Dr. Rajesh Kumar',
    );

    widget.dataService.addSample(sample);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _saving = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample recorded successfully'),
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
        title: const Text('Sample Collection', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Case summary
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.science, color: Colors.white70, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${widget.lcase.caseId} · ${widget.lcase.species}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(widget.lcase.farmerName,
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _card('Sample Type', [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _sampleTypes.map((t) {
                  final selected = _sampleType == t;
                  return ChoiceChip(
                    label: Text(t),
                    selected: selected,
                    onSelected: (_) => setState(() => _sampleType = t),
                    selectedColor: Colors.purple.shade100,
                  );
                }).toList(),
              ),
            ]),

            const SizedBox(height: 12),

            _card('Reason for Collection', [
              TextField(
                controller: _reasonCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g. Rule out haemorrhagic septicaemia, confirm FMD...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ]),

            const SizedBox(height: 12),

            _card('Laboratory', [
              DropdownButtonFormField<String>(
                initialValue: _lab,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: _labs.map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (v) => setState(() => _lab = v!),
              ),
            ]),

            const SizedBox(height: 12),

            _card('Initial Status', [
              RadioGroup<SampleStatus>(
                groupValue: _status,
                onChanged: (v) {
                  if (v != null) setState(() => _status = v);
                },
                child: Column(
                  children: SampleStatus.values.map((s) => RadioListTile<SampleStatus>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.displayName),
                    value: s,
                  )).toList(),
                ),
              ),
            ]),

            const SizedBox(height: 24),

            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('RECORD SAMPLE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
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
}
