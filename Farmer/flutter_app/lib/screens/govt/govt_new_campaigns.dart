// Smart Livestock — NEW Government Campaigns Screen
// Ports React VaccinationCampaignsView: campaign cards, progress bars, metrics.

import 'package:flutter/material.dart';
import 'govt_theme.dart';
import 'govt_new_data.dart';

class GovtNewCampaigns extends StatefulWidget {
  const GovtNewCampaigns({super.key});

  @override
  State<GovtNewCampaigns> createState() => _GovtNewCampaignsState();
}

class _GovtNewCampaignsState extends State<GovtNewCampaigns> {
  late List<VaccinationCampaign> _campaigns;

  @override
  void initState() {
    super.initState();
    _campaigns = getInitialCampaigns();
  }

  void _markComplete(String id) {
    setState(() {
      for (final c in _campaigns) {
        if (c.id == id) c.status = 'Completed';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeCamps = _campaigns.where((c) => c.status == 'Active').length;
    const totalTargeted = 42700;
    const totalVaccinated = 29742;
    const overallCoverage = 69.6;
    const pendingVillages = 34;

    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFFE6F4F1), borderRadius: BorderRadius.circular(4)),
                            child: const Text('State Prophylaxis Bureau', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF087F73), letterSpacing: 0.5)),
                          ),
                          const SizedBox(width: 6),
                          const Text('•', style: TextStyle(color: Color(0xFF667482), fontSize: 11)),
                          const SizedBox(width: 6),
                          const Text('Target Herd Immunity: 85%', style: TextStyle(fontSize: 11, color: Color(0xFF667482))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text('Vaccination Campaign Command Center', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF18232B), letterSpacing: -0.4)),
                      const SizedBox(height: 4),
                      const Text('Manage prophylactic immunisation drives, deploy biologicals, and eliminate district immunity deficits.', style: TextStyle(fontSize: 11.5, color: Color(0xFF667482), height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── 5 Metrics ────────────────────────────────────────────────────
            LayoutBuilder(builder: (ctx, c) {
              final cols = c.maxWidth >= 700 ? 5 : (c.maxWidth >= 500 ? 3 : 2);
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cols,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: cols >= 5 ? 1.5 : 1.3,
                children: [
                  _metricBox('Active Campaigns', '$activeCamps', 'Statewide deployed', const Color(0xFF12304A)),
                  _metricBox('Animals Targeted', totalTargeted.toLocaleString(), 'Reserved biologicals', const Color(0xFF18232B)),
                  _metricBox('Animals Vaccinated', totalVaccinated.toLocaleString(), 'Field verified', const Color(0xFF087F73)),
                  _metricBox('Overall Coverage', '$overallCoverage%', 'Target: 85% mandate', const Color(0xFF1769AA)),
                  _metricBox('Pending Villages', '$pendingVillages', 'Under active drive', const Color(0xFFC94343)),
                ],
              );
            }),
            const SizedBox(height: 16),

            // ── Warning Banner ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5D6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD99A18).withValues(alpha: 0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFD99A18)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Critical Immunity Deficit Detected: Pune & Nagpur Belts', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF18232B))),
                        SizedBox(height: 4),
                        Text('District risk: 78% | Vaccination coverage: 61.2% | Gap: 23.8% deficit | Priority: Critical', style: TextStyle(fontSize: 11, color: Color(0xFF667482), height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Campaign List ─────────────────────────────────────────────────
            Text('Active & Scheduled State Drives (${_campaigns.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF18232B))),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (ctx, c) {
              final cols = c.maxWidth >= 700 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: cols == 2 ? 1.5 : 1.7,
                ),
                itemCount: _campaigns.length,
                itemBuilder: (_, i) => _campaignCard(_campaigns[i]),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _metricBox(String label, String value, String sub, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE4EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF667482), letterSpacing: 0.3), maxLines: 1),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: valueColor, letterSpacing: -0.3)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 9.5, color: Color(0xFF667482)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _campaignCard(VaccinationCampaign camp) {
    final priorityColor = camp.priority == 'Critical'
        ? const Color(0xFFC94343)
        : camp.priority == 'High'
            ? const Color(0xFFD99A18)
            : const Color(0xFF1769AA);
    final priorityBg = camp.priority == 'Critical'
        ? const Color(0xFFFDECEC)
        : camp.priority == 'High'
            ? const Color(0xFFFFF5D6)
            : const Color(0xFFEAF3FB);
    final progressColor = camp.coveragePercentage >= 80
        ? const Color(0xFF16845B)
        : camp.coveragePercentage >= 60
            ? const Color(0xFF087F73)
            : const Color(0xFFD99A18);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4EAF0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(camp.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF18232B)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text('${camp.targetDistrict} (${camp.blocks.take(2).join(', ')}${camp.blocks.length > 2 ? '...' : ''})', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF1769AA))),
                    Text('${camp.disease} • ${camp.animalSpecies}', style: const TextStyle(fontSize: 10, color: Color(0xFF667482)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(color: priorityBg, borderRadius: BorderRadius.circular(4)),
                    child: Text('${camp.priority} Priority', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: priorityColor)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: camp.status == 'Completed' ? const Color(0xFFE6F4EF) : const Color(0xFFEAF3FB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(camp.status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: camp.status == 'Completed' ? const Color(0xFF087F73) : const Color(0xFF1769AA))),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${camp.vaccinatedAnimals.toLocaleString()} of ${camp.targetAnimals.toLocaleString()} animals', style: const TextStyle(fontSize: 10, color: Color(0xFF667482))),
              Text('${camp.coveragePercentage.toStringAsFixed(0)}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: progressColor)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: camp.coveragePercentage / 100,
              backgroundColor: const Color(0xFFEAF3FB),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 10),

          // Village stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFF7F9FB), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                _villageStatBox('Target', '${camp.targetVillagesCount}', const Color(0xFF18232B)),
                _villageStatBox('Completed', '${camp.completedVillagesCount}', const Color(0xFF16845B)),
                _villageStatBox('Pending', '${camp.pendingVillagesCount}', const Color(0xFFC94343)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Bottom row: dates + action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 11, color: Color(0xFF667482)),
                  const SizedBox(width: 4),
                  Text('${camp.startDate} → ${camp.endDate}', style: const TextStyle(fontSize: 10, color: Color(0xFF667482))),
                ],
              ),
              if (camp.status != 'Completed')
                GestureDetector(
                  onTap: () => _markComplete(camp.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFE6F4EF), borderRadius: BorderRadius.circular(6)),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 12, color: Color(0xFF16845B)),
                        SizedBox(width: 3),
                        Text('Complete', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF16845B))),
                      ],
                    ),
                  ),
                )
              else
                const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF16845B)),
                    SizedBox(width: 4),
                    Text('Completed', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF16845B))),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _villageStatBox(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF667482))),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: valueColor)),
        ],
      ),
    );
  }
}

extension _IntFormat on int {
  String toLocaleString() {
    final s = toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
