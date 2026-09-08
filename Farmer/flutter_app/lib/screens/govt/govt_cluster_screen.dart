// Government Cluster Screen — detect and manage outbreak clusters

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../models/cluster.dart';

class GovtClusterScreen extends StatelessWidget {
  final FarmerDataService dataService;
  const GovtClusterScreen({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        final clusters = dataService.getAllClusters();
        final actions = dataService.getAllResponseActions();

        return Scaffold(
          backgroundColor: const Color(0xFFECF0F8),
          appBar: AppBar(
            title: const Text('Outbreak Clusters', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFFB71C1C),
            foregroundColor: Colors.white,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Disclaimer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Clusters are identified based on ≥3 reports, same village, similar species and symptoms within 7 days. '
                        'These are PRELIMINARY SURVEILLANCE INDICATORS, not confirmed outbreaks.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (clusters.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
                        SizedBox(height: 12),
                        Text('No clusters detected', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  ),
                ),

              ...clusters.map((c) => _clusterCard(context, c, actions)),

              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _clusterCard(BuildContext context, OutbreakCluster cluster, actions) {
    final riskColor = switch (cluster.risk) {
      ClusterRisk.critical => const Color(0xFFB71C1C),
      ClusterRisk.high => const Color(0xFFE65100),
      ClusterRisk.possible => const Color(0xFFF57F17),
    };

    final clusterActions = actions.where((a) => a.clusterId == cluster.clusterId).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: Column(
        children: [
          // Header
          Container(
            color: riskColor,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cluster.risk.displayName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('${cluster.village} · ${cluster.block} · ${cluster.district}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                _statusBadge(cluster.status),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats
                Row(
                  children: [
                    _stat('Reports', cluster.reportCount.toString()),
                    _stat('Animals', cluster.affectedAnimals.toString()),
                    _stat('Mortality', cluster.mortalityCount.toString()),
                    _stat('Days', _daysSince(cluster.firstReportDate).toString()),
                  ],
                ),

                const SizedBox(height: 12),

                Text('Species: ${cluster.species}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),

                // Common symptoms
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: cluster.commonSymptoms.map((s) => Chip(
                    label: Text(s, style: const TextStyle(fontSize: 11)),
                    backgroundColor: Colors.red.shade50,
                    side: BorderSide(color: Colors.red.shade100),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  )).toList(),
                ),

                const SizedBox(height: 12),

                // Existing response actions
                if (clusterActions.isNotEmpty) ...[
                  const Text('Response Actions:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  ...clusterActions.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Text(a.type.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(a.title, style: const TextStyle(fontSize: 12))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(a.status.name, style: const TextStyle(fontSize: 10)),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 8),
                ],

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.update, size: 16),
                        label: const Text('Update Status'),
                        onPressed: () => _updateStatus(context, cluster),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: riskColor,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.add_task, size: 16),
                        label: const Text('Create Action'),
                        onPressed: () => _createResponseAction(context, cluster),
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

  Widget _statusBadge(ClusterStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white54),
      ),
      child: Text(status.displayName,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  int _daysSince(DateTime date) => DateTime.now().difference(date).inDays + 1;

  void _updateStatus(BuildContext context, OutbreakCluster cluster) {
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
              const Text('Update Cluster Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(height: 12),
              ...ClusterStatus.values.map((s) => ListTile(
                    title: Text(s.displayName),
                    leading: Radio<ClusterStatus>(
                      value: s,
                      groupValue: cluster.status,
                      onChanged: (v) {
                        if (v != null) {
                          dataService.updateClusterStatus(cluster.clusterId, v);
                          Navigator.pop(ctx);
                        }
                      },
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _createResponseAction(BuildContext context, OutbreakCluster cluster) {
    ResponseActionType selectedType = ResponseActionType.fieldVisit;
    final ctrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create Response Action',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(height: 16),
              const Text('Action Type:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ResponseActionType.values.map((t) {
                  final sel = selectedType == t;
                  return ChoiceChip(
                    label: Text('${t.emoji} ${t.displayName}',
                        style: const TextStyle(fontSize: 12)),
                    selected: sel,
                    onSelected: (_) => setModalState(() => selectedType = t),
                    selectedColor: Colors.purple.shade100,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(
                  labelText: 'Additional notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A148C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    final action = ResponseAction(
                      actionId: dataService.generateActionId(),
                      clusterId: cluster.clusterId,
                      type: selectedType,
                      title: '${selectedType.displayName} — ${cluster.village}',
                      description: ctrl.text.trim().isEmpty
                          ? '${selectedType.displayName} in ${cluster.village}'
                          : ctrl.text.trim(),
                      location: '${cluster.village}, ${cluster.block}, ${cluster.district}',
                      assignedTo: 'Dr. Rajesh Kumar',
                      status: ResponseActionStatus.assigned,
                    );
                    dataService.addResponseAction(action);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Response action created'),
                        backgroundColor: Colors.purple,
                      ),
                    );
                  },
                  child: const Text('CREATE ACTION', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
