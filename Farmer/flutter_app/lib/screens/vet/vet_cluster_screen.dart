// Veterinary Cluster Screen — view possible outbreak clusters and escalate

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../models/cluster.dart';
import '../../models/case.dart';

class VetClusterScreen extends StatelessWidget {
  final FarmerDataService dataService;
  const VetClusterScreen({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        final clusters = dataService.getAllClusters();

        return Scaffold(
          backgroundColor: const Color(0xFFF0F4FF),
          appBar: AppBar(
            title: const Text('Possible Clusters', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          ),
          body: clusters.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
                      SizedBox(height: 16),
                      Text('No clusters detected', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      SizedBox(height: 8),
                      Text('All regions are under normal surveillance',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: clusters.length,
                  itemBuilder: (ctx, i) => _clusterCard(ctx, clusters[i]),
                ),
        );
      },
    );
  }

  Widget _clusterCard(BuildContext context, OutbreakCluster cluster) {
    final riskColor = switch (cluster.risk) {
      ClusterRisk.critical => const Color(0xFFB71C1C),
      ClusterRisk.high => const Color(0xFFE65100),
      ClusterRisk.possible => const Color(0xFFF57F17),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Container(
            color: riskColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cluster.risk.displayName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('${cluster.village}, ${cluster.district}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(cluster.status.displayName,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats row
                Row(
                  children: [
                    _stat('Reports', cluster.reportCount.toString(), Icons.description),
                    _stat('Animals', cluster.affectedAnimals.toString(), Icons.pets),
                    _stat('Mortality', cluster.mortalityCount.toString(), Icons.warning_rounded),
                    _stat('Species', cluster.species.split(' ').first, Icons.agriculture),
                  ],
                ),

                const SizedBox(height: 12),

                // Symptoms
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: cluster.commonSymptoms.map((s) => Chip(
                    label: Text(s, style: const TextStyle(fontSize: 11)),
                    backgroundColor: Colors.orange.shade50,
                    side: BorderSide(color: Colors.orange.shade200),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),

                const SizedBox(height: 12),

                // Disclaimer
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.amber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'POSSIBLE CLUSTER — Not a confirmed outbreak. Further investigation required.',
                          style: TextStyle(fontSize: 11, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('View Cases'),
                        onPressed: () => _viewCases(context, cluster),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.upload, size: 16),
                        label: const Text('Escalate'),
                        onPressed: cluster.status == ClusterStatus.escalated
                            ? null
                            : () => _escalate(context, cluster),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  void _viewCases(BuildContext context, OutbreakCluster cluster) {
    final cases = dataService.getAllCases()
        .where((c) => cluster.caseIds.contains(c.caseId))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Cluster Cases',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...cases.map((c) => ListTile(
                  leading: const Icon(Icons.agriculture),
                  title: Text('${c.caseId} · ${c.species} · ${c.animalTag}'),
                  subtitle: Text('${c.farmerName} · ${c.riskLevel}'),
                  trailing: Text(c.status.displayName,
                      style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                )),
          ],
        ),
      ),
    );
  }

  void _escalate(BuildContext context, OutbreakCluster cluster) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Escalate to Government'),
        content: const Text(
            'This will escalate the cluster to the Government Surveillance dashboard. '
            'The government will receive a high-priority notification.\n\n'
            'Proceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
            onPressed: () {
              dataService.updateClusterStatus(cluster.clusterId, ClusterStatus.escalated);
              // Also update related cases
              for (final caseId in cluster.caseIds) {
                final c = dataService.getCaseById(caseId);
                if (c != null) {
                  c.isEscalatedToGovt = true;
                  dataService.updateCaseStatus(caseId, FullCaseStatus.escalated,
                      actor: 'Veterinarian',
                      description: 'Cluster escalated to Government Surveillance.');
                }
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Cluster escalated to Government'),
                  backgroundColor: Colors.deepOrange,
                ),
              );
            },
            child: const Text('Escalate'),
          ),
        ],
      ),
    );
  }
}
