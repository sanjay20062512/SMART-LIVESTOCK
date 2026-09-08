// Veterinary Case Queue Screen — full sortable/filterable case list

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../models/case.dart';
import 'vet_case_detail_screen.dart';

class VetCaseQueueScreen extends StatefulWidget {
  final FarmerDataService dataService;
  const VetCaseQueueScreen({super.key, required this.dataService});

  @override
  State<VetCaseQueueScreen> createState() => _VetCaseQueueScreenState();
}

class _VetCaseQueueScreenState extends State<VetCaseQueueScreen> {
  String _filterRisk = 'All';
  String _filterStatus = 'All';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.dataService,
      builder: (context, _) {
        var cases = widget.dataService.getAllCases().toList();

        if (_filterRisk != 'All') {
          cases = cases.where((c) => c.riskLevel == _filterRisk).toList();
        }
        if (_filterStatus != 'All') {
          cases = cases.where((c) => c.status.displayName == _filterStatus).toList();
        }

        // Sort by priority
        cases.sort((a, b) {
          const order = {'CRITICAL': 0, 'HIGH': 1, 'MEDIUM': 2, 'LOW': 3};
          return (order[a.riskLevel] ?? 3).compareTo(order[b.riskLevel] ?? 3);
        });

        return Scaffold(
          backgroundColor: const Color(0xFFF0F4FF),
          appBar: AppBar(
            title: const Text('Case Queue', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Column(
            children: [
              // Filters
              Container(
                color: const Color(0xFF1565C0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      _filterChip('All', _filterRisk, (v) => setState(() => _filterRisk = v)),
                      _filterChip('CRITICAL', _filterRisk, (v) => setState(() => _filterRisk = v), color: Colors.red),
                      _filterChip('HIGH', _filterRisk, (v) => setState(() => _filterRisk = v), color: Colors.orange),
                      _filterChip('MEDIUM', _filterRisk, (v) => setState(() => _filterRisk = v), color: Colors.amber),
                      _filterChip('LOW', _filterRisk, (v) => setState(() => _filterRisk = v), color: Colors.green),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: cases.isEmpty
                    ? const Center(child: Text('No cases match filter.', style: TextStyle(color: Colors.grey, fontSize: 16)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: cases.length,
                        itemBuilder: (ctx, i) => _buildCaseCard(ctx, cases[i]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(String label, String current, ValueChanged<String> onTap, {Color? color}) {
    final selected = current == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(
          fontWeight: FontWeight.bold,
          color: selected ? Colors.white : (color ?? Colors.white70),
          fontSize: 12,
        )),
        selected: selected,
        onSelected: (_) => onTap(label),
        selectedColor: color ?? const Color(0xFF1565C0),
        backgroundColor: Colors.white.withValues(alpha: 0.15),
        checkmarkColor: Colors.white,
        side: BorderSide(color: selected ? Colors.transparent : Colors.white30),
      ),
    );
  }

  Widget _buildCaseCard(BuildContext context, LivestockCase c) {
    final (color, icon) = switch (c.riskLevel) {
      'CRITICAL' => (const Color(0xFFB71C1C), Icons.emergency_rounded),
      'HIGH' => (const Color(0xFFE65100), Icons.warning_rounded),
      'MEDIUM' => (const Color(0xFFF57F17), Icons.info_rounded),
      _ => (const Color(0xFF2E7D32), Icons.check_circle_outline),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VetCaseDetailScreen(dataService: widget.dataService, lcase: c),
          ),
        ),
        child: Column(
          children: [
            Container(
              color: color,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text('${c.riskLevel} RISK',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  const Spacer(),
                  Text(c.caseId,
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${c.species} · ${c.animalTag}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(c.farmerName,
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: c.symptoms.take(3).map((s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(s, style: const TextStyle(fontSize: 11)),
                          )).toList(),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 13, color: Colors.grey),
                            const SizedBox(width: 2),
                            Text('${c.village}, ${c.district}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(width: 12),
                            const Icon(Icons.people, size: 13, color: Colors.grey),
                            const SizedBox(width: 2),
                            Text(c.affectedCount != null ? '${c.affectedCount} animals' : '—',
                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(c.status.displayName,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      ),
                      const SizedBox(height: 4),
                      Text(_formatDate(c.createdAt),
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      if (c.assignedVetName != null) ...[
                        const SizedBox(height: 4),
                        Text('Assigned', style: TextStyle(fontSize: 11, color: Colors.green.shade700)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
