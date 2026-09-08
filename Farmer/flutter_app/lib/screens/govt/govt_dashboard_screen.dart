// Government Dashboard Screen

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../models/cluster.dart';
import '../../models/advisory.dart';
import '../../models/vaccination_record.dart';

class GovtDashboardScreen extends StatelessWidget {
  final FarmerDataService dataService;
  const GovtDashboardScreen({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        final cases = dataService.getAllCases();
        final clusters = dataService.getAllClusters();
        final advisories = dataService.getPublishedAdvisories();
        final mortality = dataService.getMortalityReports();
        final vaccinations = dataService.getVaccinations();
        final actions = dataService.getAllResponseActions();

        final activeClusters = clusters.where((c) =>
            c.status != ClusterStatus.contained).toList();

        // High risk villages = villages with >1 case
        final byCaseVillage = dataService.getCasesByVillage();
        final highRiskVillages = byCaseVillage.entries
            .where((e) => e.value.length >= 2)
            .length;

        // Vaccination coverage (simple calc from available data)
        final totalAnimals = dataService.getAnimals().length;
        final vaccinated = vaccinations
            .where((v) => v.status == VaccinationStatus.completed)
            .length;
        final coveragePct = totalAnimals > 0
            ? (vaccinated / totalAnimals * 100).round()
            : 0;

        final pendingActions = actions
            .where((a) => a.status != ResponseActionStatus.completed)
            .length;

        return Scaffold(
          backgroundColor: const Color(0xFFECF0F8),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 150,
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
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.account_balance, color: Colors.white70, size: 18),
                            SizedBox(width: 8),
                            Text('Maharashtra Animal Husbandry Dept.',
                                style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Surveillance Dashboard',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Pune District · Real-time Monitoring',
                            style: const TextStyle(color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // Critical alert banner for clusters
                    if (activeClusters.isNotEmpty)
                      _clusterBanner(context, activeClusters),

                    const SizedBox(height: 16),

                    // KPI stat grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.55,
                      children: [
                        _kpiCard('Total Reports', cases.length.toString(),
                            Icons.description_rounded, const Color(0xFF1565C0), Colors.blue.shade50),
                        _kpiCard('Active Cases', dataService.activeCaseCount.toString(),
                            Icons.medical_services_rounded, const Color(0xFFE65100), Colors.orange.shade50),
                        _kpiCard('Critical Cases', dataService.criticalCaseCount.toString(),
                            Icons.emergency_rounded, const Color(0xFFB71C1C), Colors.red.shade50),
                        _kpiCard('Mortality', mortality.length.toString(),
                            Icons.warning_rounded, const Color(0xFF4A148C), Colors.purple.shade50),
                        _kpiCard('Possible Clusters', activeClusters.length.toString(),
                            Icons.hub_rounded, const Color(0xFFE65100), Colors.orange.shade50),
                        _kpiCard('High Risk Villages', highRiskVillages.toString(),
                            Icons.location_on_rounded, const Color(0xFFB71C1C), Colors.red.shade50),
                        _kpiCard('Vacc. Coverage', '$coveragePct%',
                            Icons.vaccines_rounded, const Color(0xFF2E7D32), Colors.green.shade50),
                        _kpiCard('Pending Actions', pendingActions.toString(),
                            Icons.assignment_late_rounded, const Color(0xFF4A148C), Colors.purple.shade50),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // District-level breakdown
                    _sectionTitle('📍 District Overview'),
                    _districtCard(context, cases, clusters),

                    const SizedBox(height: 20),

                    // Published advisories
                    _sectionTitle('📢 Published Advisories (${advisories.length})'),
                    ...advisories.take(3).map((a) => _advisoryTile(a)),

                    const SizedBox(height: 20),

                    // Response actions
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

  Widget _clusterBanner(BuildContext context, List<OutbreakCluster> clusters) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFB71C1C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${clusters.length} POSSIBLE CLUSTER${clusters.length > 1 ? 'S' : ''} DETECTED',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  clusters.map((c) => '${c.village} (${c.species})').join(', '),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () {},
            child: const Text('VIEW', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color, Color bg) {
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
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              Text(label,
                  style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
    );
  }

  Widget _districtCard(BuildContext context, cases, clusters) {
    final byCaseVillage = dataService.getCasesByVillage();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
      ),
      child: Column(
        children: [
          // District header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFF4A148C),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.location_on, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text('Pune District · Maharashtra',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Village breakdown
          ...byCaseVillage.entries.map((e) => ListTile(
                title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${e.value.length} cases · ${e.value.where((c) => c.riskLevel == 'HIGH' || c.riskLevel == 'CRITICAL').length} high risk'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: e.value.length >= 3
                        ? Colors.red.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    e.value.length >= 3 ? '⚠ CLUSTER' : '${e.value.length} Cases',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: e.value.length >= 3 ? Colors.red.shade800 : Colors.orange.shade800),
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
          Text(action.type.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(action.location,
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
