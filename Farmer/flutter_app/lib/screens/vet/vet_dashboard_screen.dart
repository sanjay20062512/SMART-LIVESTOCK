// Veterinary Dashboard Screen

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../models/case.dart';
import 'vet_case_detail_screen.dart';

class VetDashboardScreen extends StatelessWidget {
  final FarmerDataService dataService;

  const VetDashboardScreen({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        final cases = dataService.getAllCases();
        final critical = cases.where((c) => c.riskLevel == 'CRITICAL').toList();
        final high = cases.where((c) => c.riskLevel == 'HIGH').toList();
        final pending = cases
            .where((c) =>
                c.status == FullCaseStatus.submitted ||
                c.status == FullCaseStatus.underReview)
            .toList();
        final clusters = dataService.getAllClusters();
        final visits = dataService.getAllVisits()
            .where((v) => !v.isCompleted)
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF0F4FF),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 130,
                pinned: true,
                backgroundColor: const Color(0xFF1565C0),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.medical_services, color: Colors.white70, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Dr. Rajesh Kumar · Veterinary Officer',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Veterinary Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  if (clusters.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(right: 16, top: 8),
                      child: Chip(
                        avatar: const Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                        label: Text('${clusters.length} Cluster${clusters.length > 1 ? 's' : ''}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.orange.shade100,
                      ),
                    ),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Stat cards
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        _statCard('CRITICAL', critical.length.toString(),
                            Icons.emergency_rounded, const Color(0xFFB71C1C), Colors.red.shade50),
                        _statCard('HIGH RISK', high.length.toString(),
                            Icons.warning_rounded, const Color(0xFFE65100), Colors.orange.shade50),
                        _statCard('Pending Review', pending.length.toString(),
                            Icons.inbox_rounded, const Color(0xFF1565C0), Colors.blue.shade50),
                        _statCard('Visits Due', visits.length.toString(),
                            Icons.directions_car_rounded, const Color(0xFF2E7D32), Colors.green.shade50),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Priority case queue header
                    Row(
                      children: [
                        const Text(
                          'Priority Case Queue',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Cases sorted by priority
                    ..._buildPriorityCases(context, cases),

                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, Color bg) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 26),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Text(label,
                  style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPriorityCases(BuildContext context, List<LivestockCase> cases) {
    final sorted = [...cases]..sort((a, b) {
        const order = {'CRITICAL': 0, 'HIGH': 1, 'MEDIUM': 2, 'LOW': 3};
        return (order[a.riskLevel] ?? 3).compareTo(order[b.riskLevel] ?? 3);
      });

    if (sorted.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text('No cases yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ),
        ),
      ];
    }

    return sorted.take(5).map((c) => _caseCard(context, c)).toList();
  }

  Widget _caseCard(BuildContext context, LivestockCase c) {
    final (color, bg, icon) = switch (c.riskLevel) {
      'CRITICAL' => (const Color(0xFFB71C1C), Colors.red.shade50, Icons.emergency_rounded),
      'HIGH' => (const Color(0xFFE65100), Colors.orange.shade50, Icons.warning_rounded),
      'MEDIUM' => (const Color(0xFFF57F17), Colors.yellow.shade50, Icons.info_rounded),
      _ => (const Color(0xFF2E7D32), Colors.green.shade50, Icons.check_circle_outline),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          '${c.caseId} · ${c.species} · ${c.animalTag}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.symptoms.take(2).join(', '),
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Colors.grey),
                const SizedBox(width: 2),
                Text('${c.village}, ${c.district}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const Spacer(),
                _statusChip(c.status.displayName),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VetCaseDetailScreen(dataService: dataService, lcase: c),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
    );
  }
}
