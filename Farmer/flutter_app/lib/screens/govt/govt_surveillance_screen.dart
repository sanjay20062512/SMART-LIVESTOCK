// Government Surveillance Screen — State → District → Block → Village drill-down

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../models/case.dart';

class GovtSurveillanceScreen extends StatelessWidget {
  final FarmerDataService dataService;
  const GovtSurveillanceScreen({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        final cases = dataService.getAllCases();
        final byVillage = dataService.getCasesByVillage();
        final byDistrict = dataService.getCasesByDistrict();
        final mortality = dataService.getMortalityReports();

        return Scaffold(
          backgroundColor: const Color(0xFFECF0F8),
          appBar: AppBar(
            title: const Text('Geographic Surveillance', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFF4A148C),
            foregroundColor: Colors.white,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // State summary
              _levelCard(
                context,
                level: 'STATE',
                name: 'Maharashtra',
                icon: Icons.map_rounded,
                color: const Color(0xFF4A148C),
                stats: {
                  'Total Cases': cases.length.toString(),
                  'Mortality': mortality.length.toString(),
                  'Districts Affected': byDistrict.length.toString(),
                },
              ),

              const SizedBox(height: 16),

              // District breakdown
              ...byDistrict.entries.map((entry) {
                final districtCases = entry.value;
                final districtVillages = <String>{};
                for (final c in districtCases) {
                  districtVillages.add(c.village);
                }
                return _levelCard(
                  context,
                  level: 'DISTRICT',
                  name: entry.key,
                  icon: Icons.location_city_rounded,
                  color: const Color(0xFF1565C0),
                  stats: {
                    'Cases': districtCases.length.toString(),
                    'Villages Affected': districtVillages.length.toString(),
                    'Critical': districtCases.where((c) => c.riskLevel == 'CRITICAL').length.toString(),
                  },
                  children: _buildVillageCards(context, districtCases, byVillage),
                );
              }),

              if (cases.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text('No cases reported yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ),
                ),

              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildVillageCards(
      BuildContext context,
      List<LivestockCase> districtCases,
      Map<String, List<LivestockCase>> byVillage) {
    final villages = <String>{};
    for (final c in districtCases) {
      villages.add(c.village);
    }

    return villages.map((village) {
      final villageCases = byVillage[village] ?? [];
      final highRisk = villageCases.where((c) => c.riskLevel == 'HIGH' || c.riskLevel == 'CRITICAL').length;
      final isCluster = villageCases.length >= 3;

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 0, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCluster ? Colors.red.shade200 : Colors.grey.shade200,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: isCluster ? Colors.red.shade50 : Colors.blue.shade50,
            child: Text(
              village.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: isCluster ? Colors.red : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Row(
            children: [
              Text(village, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              if (isCluster) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('⚠ CLUSTER',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
                ),
              ],
            ],
          ),
          subtitle: Text('${villageCases.length} cases · $highRisk high risk',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          children: villageCases.map((c) => ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                leading: _riskDot(c.riskLevel),
                title: Text('${c.caseId} · ${c.species}',
                    style: const TextStyle(fontSize: 13)),
                subtitle: Text(c.farmerName, style: const TextStyle(fontSize: 11)),
                trailing: Text(c.status.displayName,
                    style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
              )).toList(),
        ),
      );
    }).toList();
  }

  Widget _levelCard(
    BuildContext context, {
    required String level,
    required String name,
    required IconData icon,
    required Color color,
    required Map<String, String> stats,
    List<Widget>? children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color,
              borderRadius: children != null
                  ? const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))
                  : BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white70, size: 20),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(level,
                        style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
                    Text(name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: stats.entries.map((e) => Expanded(
                child: Column(
                  children: [
                    Text(e.value,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                    Text(e.key,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                        textAlign: TextAlign.center),
                  ],
                ),
              )).toList(),
            ),
          ),
          if (children != null) ...[
            const Divider(height: 1),
            ...children,
          ],
        ],
      ),
    );
  }

  Widget _riskDot(String risk) {
    final color = switch (risk) {
      'CRITICAL' => Colors.red,
      'HIGH' => Colors.orange,
      'MEDIUM' => Colors.amber,
      _ => Colors.green,
    };
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
