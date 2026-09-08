// Treatment Screen — view treatment records.

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../models/treatment_record.dart';

class TreatmentScreen extends StatefulWidget {
  final FarmerDataService dataService;

  const TreatmentScreen({super.key, required this.dataService});

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
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

  Color _statusColor(TreatmentStatus s) {
    switch (s) {
      case TreatmentStatus.notStarted:
        return Colors.grey;
      case TreatmentStatus.ongoing:
        return Colors.blue;
      case TreatmentStatus.followUpDue:
        return Colors.orange;
      case TreatmentStatus.completed:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final treatments = widget.dataService.getTreatments();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Treatment Records',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: treatments.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_services, size: 56, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No treatment records yet.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Treatment records are created by the veterinarian\n'
                    'through the veterinarian module.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: treatments.length,
              itemBuilder: (ctx, i) {
                final t = treatments[i];
                final color = _statusColor(t.status);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: color.withValues(alpha: 0.4), width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.condition,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                t.status.displayName,
                                style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Animal: ${t.animalTag}',
                            style: const TextStyle(color: Colors.grey)),
                        const Divider(height: 20),
                        _row('Treatment', t.treatment),
                        _row('Medicine', t.medicine),
                        if (t.veterinarian != null)
                          _row('Veterinarian', t.veterinarian!),
                        _row(
                          'Start Date',
                          '${t.startDate.day}/${t.startDate.month}/${t.startDate.year}',
                        ),
                        if (t.followUpDate != null)
                          _row(
                            'Follow-up',
                            '${t.followUpDate!.day}/${t.followUpDate!.month}/${t.followUpDate!.year}',
                          ),
                        if (t.instructions != null) ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Instructions:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.blue.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              t.instructions!,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
