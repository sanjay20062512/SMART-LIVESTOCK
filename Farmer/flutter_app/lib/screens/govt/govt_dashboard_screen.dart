// Government Dashboard Screen — Real-time disease surveillance & high-risk alerts

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../models/cluster.dart';
import '../../models/government_alert.dart';
import '../../models/advisory.dart';

class GovtDashboardScreen extends StatelessWidget {
  final FarmerDataService dataService;
  const GovtDashboardScreen({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        final govtClusters = dataService.getGovernmentClusters();
        // Mandatory requirement & extra frontend safety check: ONLY high-risk alerts
        final govtAlerts = dataService.getGovernmentAlerts().where((a) => a.riskLevel == ClusterRisk.high).toList();
        final advisories = dataService.getPublishedAdvisories();
        final actions = dataService.getAllResponseActions();

        // Calculate summary metrics dynamically for High-Risk surveillance
        final activeHighRiskAlertsCount = govtAlerts.length;
        final highRiskClustersCount = govtClusters.length;
        final totalAffectedAnimals = govtClusters.fold<int>(0, (sum, c) => sum + c.animalCount);
        final affectedDistrictsCount = govtClusters.map((c) => c.district).toSet().length;
        final criticalCasesCount = dataService.criticalCaseCount;

        return Scaffold(
          backgroundColor: const Color(0xFFECF0F8),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: const Color(0xFF4A148C),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4A148C), Color(0xFF311B92)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 45, 20, 16),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.account_balance, color: Colors.white70, size: 18),
                            SizedBox(width: 8),
                            Text('Maharashtra Animal Husbandry Dept.',
                                style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text('Government Surveillance Dashboard',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 2),
                        Text('Real-time Disease Outbreak Sync & High-Risk Alerts',
                            style: TextStyle(color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // Summary KPI Cards Grid (Strictly High-Risk Focus)
                    _sectionTitle('Surveillance Summary'),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.6,
                      children: [
                        _summaryCard('Active High-Risk Alerts', activeHighRiskAlertsCount.toString(),
                            Icons.error_outline_rounded, const Color(0xFFB71C1C), const Color(0xFFFFEBEE)),
                        _summaryCard('High-Risk Clusters', highRiskClustersCount.toString(),
                            Icons.warning_amber_rounded, const Color(0xFFD32F2F), const Color(0xFFFFEBEE)),
                        _summaryCard('Affected Animals', totalAffectedAnimals.toString(),
                            Icons.pets_rounded, const Color(0xFF1565C0), const Color(0xFFE3F2FD)),
                        _summaryCard('Affected Districts', affectedDistrictsCount.toString(),
                            Icons.map_rounded, const Color(0xFF4A148C), const Color(0xFFF3E5F5)),
                        _summaryCard('Critical Cases', criticalCasesCount.toString(),
                            Icons.health_and_safety, const Color(0xFFC62828), const Color(0xFFFFEBEE)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Requirement 10: High-Risk Government Alerts Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionTitle('🚨 High-Risk Government Disease Alerts'),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${govtAlerts.length} Active',
                            style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (govtAlerts.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(Icons.verified_user, color: Colors.green, size: 48),
                              SizedBox(height: 8),
                              Text('No High-Risk Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('All regions currently clear of high-risk disease outbreaks.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      )
                    else
                      ...govtAlerts.map((alert) => _govtAlertCard(context, alert)),

                    const SizedBox(height: 24),

                    // District Breakdown & Response Actions
                    _sectionTitle('📍 District Overview'),
                    _districtCard(context, dataService.getAllCases()),

                    const SizedBox(height: 20),

                    _sectionTitle('📢 Recent Advisories (${advisories.length})'),
                    ...advisories.take(3).map((a) => _advisoryTile(a)),

                    const SizedBox(height: 20),

                    _sectionTitle('🎯 Response Actions (${actions.length})'),
                    ...actions.take(3).map((a) => _actionTile(a)),

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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
      ),
    );
  }

  Widget _summaryCard(String title, String count, IconData icon, Color color, Color bg) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 22),
              Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          Text(
            title,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color.withValues(alpha: 0.85)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _govtAlertCard(BuildContext context, GovernmentAlert alert) {
    final statusColor = alert.status == GovernmentAlertStatus.acknowledged
        ? Colors.blue
        : (alert.status == GovernmentAlertStatus.underResponse ? Colors.purple : Colors.red);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Alert Red Header
          Container(
            color: const Color(0xFFB71C1C),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.warning_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HIGH RISK DISEASE ALERT',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                      Text(
                        '${alert.location} · ${alert.district}, ${alert.state}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    alert.status.displayName,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
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
                Text(
                  alert.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),

                // Specs & counts
                Row(
                  children: [
                    _alertStat('Species', alert.species),
                    _alertStat('Animals Affected', alert.animalCount.toString()),
                    _alertStat('Reports', alert.reportCount.toString()),
                    _alertStat('Mortality', alert.mortality.toString()),
                  ],
                ),

                const SizedBox(height: 10),

                // Suspected Disease
                Row(
                  children: [
                    const Icon(Icons.coronavirus, size: 16, color: Colors.red),
                    const SizedBox(width: 6),
                    Text(
                      'Suspected: ${alert.suspectedDisease}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Symptoms
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: alert.symptoms.map((s) => Chip(
                    label: Text(s, style: const TextStyle(fontSize: 11)),
                    backgroundColor: Colors.red.shade50,
                    side: BorderSide(color: Colors.red.shade200),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  )).toList(),
                ),

                const SizedBox(height: 14),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('View Cluster'),
                        onPressed: () => _viewFullCluster(context, alert.clusterId),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (alert.status == GovernmentAlertStatus.newAlert)
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: const Text('Acknowledge'),
                          onPressed: () {
                            dataService.acknowledgeGovernmentAlert(alert.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('High-risk alert acknowledged by Government Authority'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A148C),
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.local_hospital_outlined, size: 16),
                          label: const Text('Mark Response'),
                          onPressed: () {
                            dataService.updateGovernmentAlertStatus(alert.id, GovernmentAlertStatus.underResponse);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Response status updated to UNDER RESPONSE'),
                                backgroundColor: Colors.purple,
                              ),
                            );
                          },
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

  Widget _alertStat(String label, String val) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  void _viewFullCluster(BuildContext context, String clusterId) {
    final cluster = dataService.getClusterById(clusterId);
    if (cluster == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    cluster.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('HIGH RISK', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${cluster.location}, ${cluster.district}, ${cluster.state}', style: TextStyle(color: Colors.grey.shade700)),
            const Divider(height: 24),
            const Text('Complete Details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Text('• Species: ${cluster.species}'),
            Text('• Total Reports: ${cluster.reportCount}'),
            Text('• Animals Affected: ${cluster.animalCount}'),
            Text('• Mortality Count: ${cluster.mortality}'),
            Text('• Suspected Disease: ${cluster.suspectedDisease}'),
            Text('• Veterinary Status: ${cluster.status.displayName}'),
            Text('• Description: ${cluster.description}'),
            const SizedBox(height: 12),
            const Text('Symptoms:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: cluster.symptoms.map((s) => Chip(label: Text(s, style: const TextStyle(fontSize: 11)))).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _districtCard(BuildContext context, cases) {
    final byCaseVillage = dataService.getCasesByVillage();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFF4A148C),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.location_on, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text('Pune District · Maharashtra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ...byCaseVillage.entries.map((e) => ListTile(
                title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${e.value.length} cases reported'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: e.value.length >= 2 ? Colors.red.shade100 : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    e.value.length >= 2 ? 'HIGH SURVEILLANCE' : '${e.value.length} Cases',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: e.value.length >= 2 ? Colors.red.shade800 : Colors.orange.shade800),
                  ),
                ),
              )),
          if (byCaseVillage.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No cases reported', style: TextStyle(color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  Widget _advisoryTile(Advisory adv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign, color: Color(0xFF4A148C)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(adv.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(adv.targetLocation ?? 'All', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Published', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _actionTile(ResponseAction action) {
    final statusColor = switch (action.status) {
      ResponseActionStatus.planned => Colors.blue,
      ResponseActionStatus.assigned => Colors.orange,
      ResponseActionStatus.inProgress => Colors.deepOrange,
      ResponseActionStatus.completed => Colors.green,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: statusColor, width: 3)),
      ),
      child: Row(
        children: [
          Icon(action.type.icon, size: 22, color: statusColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(action.location, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Text(action.status.name.toUpperCase(),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
        ],
      ),
    );
  }
}
