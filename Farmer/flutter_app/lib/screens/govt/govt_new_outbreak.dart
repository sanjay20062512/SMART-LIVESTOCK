// Smart Livestock — NEW Government Outbreak Monitoring Screen
// Ports React OutbreakMonitoringView: outbreak signals, trend chart (visual bars), risk factors.

import 'package:flutter/material.dart';
import 'govt_theme.dart';
import 'govt_new_data.dart';

import '../../services/farmer_data_service.dart';

class GovtNewOutbreakMonitoring extends StatefulWidget {
  final FarmerDataService? dataService;
  const GovtNewOutbreakMonitoring({super.key, this.dataService});

  @override
  State<GovtNewOutbreakMonitoring> createState() => _GovtNewOutbreakMonitoringState();
}

class _GovtNewOutbreakMonitoringState extends State<GovtNewOutbreakMonitoring>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _diseaseFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<DiseaseOutbreak> get _allSignals {
    final list = List<DiseaseOutbreak>.from(outbreakSignals);
    if (widget.dataService != null) {
      final liveClusters = widget.dataService!.getAllClusters();
      for (final c in liveClusters) {
        if (!list.any((s) => s.id == c.clusterId)) {
          list.insert(
            0,
            DiseaseOutbreak(
              id: c.clusterId,
              diseaseName: c.suspectedDisease.isNotEmpty ? c.suspectedDisease : c.name,
              affectedDistrict: c.district,
              riskLevel: c.riskLevel.name == 'high' ? RiskLevel.critical : RiskLevel.high,
              cases: c.animalCount,
              trendPercentage: 35,
              detectionDate: 'Recently',
              recommendedNextAction: 'Deploy veterinary task force and initiate ring vaccination.',
              pathogenType: 'Viral',
            ),
          );
        }
      }
    }
    return list;
  }

  List<DiseaseOutbreak> get _filtered {
    final signals = _allSignals;
    if (_diseaseFilter == 'All') return signals;
    return signals.where((o) => o.diseaseName.toLowerCase().contains(_diseaseFilter.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFFDECEC), borderRadius: BorderRadius.circular(4)),
                      child: const Text('Surveillance Bio-Intelligence', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFC94343), letterSpacing: 0.5)),
                    ),
                    const SizedBox(width: 6),
                    const Text('•', style: TextStyle(color: Color(0xFF667482), fontSize: 11)),
                    const SizedBox(width: 6),
                    const Text('Real-Time Early Warning', style: TextStyle(fontSize: 11, color: Color(0xFF667482))),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Outbreak Monitoring & Early Warning', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF18232B), letterSpacing: -0.4)),
                const SizedBox(height: 4),
                const Text('Identify emerging transmission clusters and track 30-day syndromic growth curves.', style: TextStyle(fontSize: 11.5, color: Color(0xFF667482), height: 1.4)),
              ],
            ),
          ),
          // ── Filter + TabBar ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    labelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                    unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    labelColor: const Color(0xFF18232B),
                    unselectedLabelColor: const Color(0xFF667482),
                    indicatorColor: const Color(0xFF12304A),
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: '30-Day Trends'),
                      Tab(text: 'Risk Factors'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE4EAF0)),
          // ── Tab Views ─────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTrendsTab(),
                _buildRiskFactorsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Overview Tab ────────────────────────────────────────────────────────────
  Widget _buildOverviewTab() {
    return Column(
      children: [
        // Quick metrics
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth >= 600 ? 3 : 1;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: cols == 3 ? 2.5 : 4.5,
              children: [
                _quickMetricCard('Emerging Outbreak Signals', '7 Active Clusters', '2 Critical in Nagpur & Pune', const Color(0xFFFDECEC), const Color(0xFFC94343), Icons.warning_amber_rounded),
                _quickMetricCard('Avg Case Trend (30-Day)', '+11.4% Surge', 'FMD primary driver', const Color(0xFFFFF5D6), const Color(0xFFD99A18), Icons.trending_up_rounded),
                _quickMetricCard('State Response Readiness', 'Active Containment', '19 units deployed', const Color(0xFFE6F4EF), const Color(0xFF087F73), Icons.shield_outlined),
              ],
            );
          }),
        ),
        const SizedBox(height: 12),
        // Outbreak signals list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Outbreak Signals', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF18232B))),
              // Filter dropdown
              DropdownButton<String>(
                value: _diseaseFilter,
                underline: const SizedBox(),
                style: const TextStyle(fontSize: 11, color: Color(0xFF18232B)),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All Pathogens')),
                  DropdownMenuItem(value: 'Foot-and-Mouth', child: Text('FMD')),
                  DropdownMenuItem(value: 'Brucellosis', child: Text('Brucellosis')),
                  DropdownMenuItem(value: 'Haemorrhagic', child: Text('HS')),
                  DropdownMenuItem(value: 'Anthrax', child: Text('Anthrax')),
                  DropdownMenuItem(value: 'Peste', child: Text('PPR')),
                ],
                onChanged: (v) => setState(() => _diseaseFilter = v ?? 'All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            itemCount: _filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _outbreakCard(_filtered[i]),
          ),
        ),
      ],
    );
  }

  Widget _quickMetricCard(String title, String value, String sub, Color bg, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: GovtColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE4EAF0))),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF667482))),
                Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
                Text(sub, style: const TextStyle(fontSize: 9.5, color: Color(0xFF667482)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _outbreakCard(DiseaseOutbreak o) {
    final rColor = _riskColor(o.riskLevel);
    final rBg = _riskBgColor(o.riskLevel);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.diseaseName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF18232B))),
                    const SizedBox(height: 2),
                    Text('${o.affectedDistrict} District  •  Detected: ${o.detectionDate}', style: const TextStyle(fontSize: 10.5, color: Color(0xFF667482))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(color: rBg, borderRadius: BorderRadius.circular(6), border: Border.all(color: rColor.withValues(alpha: 0.3))),
                child: Text(riskLevelLabel(o.riskLevel).toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: rColor)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _statChip('${o.cases} Cases', const Color(0xFFFDECEC), const Color(0xFFC94343)),
              const SizedBox(width: 8),
              _statChip('+${o.trendPercentage}% trend', const Color(0xFFFFF5D6), const Color(0xFFD99A18)),
              const SizedBox(width: 8),
              _statChip(o.pathogenType, const Color(0xFFEAF3FB), const Color(0xFF1769AA)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFE6F4EF), borderRadius: BorderRadius.circular(7), border: Border.all(color: const Color(0xFF087F73).withValues(alpha: 0.2))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, size: 13, color: Color(0xFF087F73)),
                const SizedBox(width: 6),
                Expanded(child: Text(o.recommendedNextAction, style: const TextStyle(fontSize: 10.5, color: Color(0xFF18232B), height: 1.4))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }

  // ── Trends Tab ──────────────────────────────────────────────────────────────
  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('30-Day Syndromic Trend (Aug 15 – Sep 13)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF18232B))),
          const SizedBox(height: 4),
          const Text('Active case counts by disease over the surveillance window.', style: TextStyle(fontSize: 11, color: Color(0xFF667482))),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _legend('FMD', const Color(0xFFC94343)),
              _legend('LSD', const Color(0xFF8B5CF6)),
              _legend('Brucellosis', const Color(0xFF1769AA)),
              _legend('Anthrax', const Color(0xFFD99A18)),
              _legend('PPR', const Color(0xFF087F73)),
            ],
          ),
          const SizedBox(height: 16),
          // Visual bar chart (using flutter's built-in widgets)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: GovtColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE4EAF0)),
            ),
            child: Column(
              children: outbreakTrendData.map((point) {
                final maxVal = 120.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(width: 44, child: Text(point.date, style: const TextStyle(fontSize: 9.5, color: Color(0xFF667482)))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          children: [
                            _trendBar(point.fmd, maxVal, const Color(0xFFC94343)),
                            const SizedBox(height: 2),
                            _trendBar(point.brucellosis, maxVal, const Color(0xFF1769AA)),
                            const SizedBox(height: 2),
                            _trendBar(point.ppr, maxVal, const Color(0xFF087F73)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(width: 30, child: Text('${point.fmd}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFC94343)), textAlign: TextAlign.right)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          // District comparison
          const Text('District Case Comparison', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF18232B))),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: GovtColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE4EAF0))),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: const BoxDecoration(color: Color(0xFFF7F9FB), borderRadius: BorderRadius.vertical(top: Radius.circular(12)), border: Border(bottom: BorderSide(color: Color(0xFFE4EAF0)))),
                  child: const Row(
                    children: [
                      Expanded(flex: 3, child: Text('District', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF667482)))),
                      Expanded(child: Text('Cases', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF667482)), textAlign: TextAlign.center)),
                      Expanded(child: Text('Mortality', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF667482)), textAlign: TextAlign.center)),
                      Expanded(child: Text('Coverage', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF667482)), textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                ...[
                  {'d': 'Nagpur', 'c': 64, 'm': 8, 'v': 61},
                  {'d': 'Pune', 'c': 62, 'm': 7, 'v': 61},
                  {'d': 'Amravati', 'c': 52, 'm': 5, 'v': 64},
                  {'d': 'Nashik', 'c': 48, 'm': 4, 'v': 54},
                  {'d': 'Jalgaon', 'c': 39, 'm': 3, 'v': 67},
                  {'d': 'Yavatmal', 'c': 32, 'm': 3, 'v': 69},
                ].asMap().entries.map((entry) {
                  final r = entry.value;
                  final isLast = entry.key == 5;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFE4EAF0)))),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(r['d'] as String, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF18232B)))),
                        Expanded(child: Text('${r['c']}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFC94343)), textAlign: TextAlign.center)),
                        Expanded(child: Text('${r['m']}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF667482)), textAlign: TextAlign.center)),
                        Expanded(child: Text('${r['v']}%', style: TextStyle(fontSize: 11.5, color: (r['v'] as int) < 65 ? const Color(0xFFC94343) : const Color(0xFF087F73)), textAlign: TextAlign.center)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _trendBar(int val, double max, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        value: val / max,
        backgroundColor: color.withValues(alpha: 0.1),
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: 5,
      ),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0xFF667482))),
      ],
    );
  }

  // ── Risk Factors Tab ────────────────────────────────────────────────────────
  Widget _buildRiskFactorsTab() {
    final factors = [
      _RiskFactor('Herd Mobility & Unscreened Transit', '35%', 82, '+14%', 'Elevated'),
      _RiskFactor('Vaccination Coverage Deficits (<85%)', '25%', 78, '+9%', 'Critical'),
      _RiskFactor('Post-Monsoon Moisture & Vector Surge', '20%', 68, '+12%', 'Elevated'),
      _RiskFactor('Delayed Syndromic Reporting (>48h)', '12%', 58, '-3%', 'Moderate'),
      _RiskFactor('Historical Soil & Environmental Reservoirs', '8%', 52, '0%', 'Monitoring'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Epidemiological Risk Factor Weights', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF18232B))),
          const SizedBox(height: 4),
          const Text('Scientific weighting of each factor contributing to the state risk index.', style: TextStyle(fontSize: 11, color: Color(0xFF667482))),
          const SizedBox(height: 16),
          ...factors.map((f) => _riskFactorCard(f)),
        ],
      ),
    );
  }

  Widget _riskFactorCard(_RiskFactor f) {
    final statusColor = f.status == 'Critical'
        ? const Color(0xFFC94343)
        : f.status == 'Elevated'
            ? const Color(0xFFE65100)
            : f.status == 'Moderate'
                ? const Color(0xFFD99A18)
                : const Color(0xFF087F73);
    final statusBg = f.status == 'Critical'
        ? const Color(0xFFFDECEC)
        : f.status == 'Elevated'
            ? const Color(0xFFFFEDD5)
            : f.status == 'Moderate'
                ? const Color(0xFFFFF5D6)
                : const Color(0xFFE6F4EF);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(f.factor, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF18232B)))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(4)),
                child: Text(f.status, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Weight: ${f.weight}', style: const TextStyle(fontSize: 10.5, color: Color(0xFF667482))),
              const SizedBox(width: 12),
              Text('Score: ${f.score}/100', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF18232B))),
              const SizedBox(width: 12),
              Text('Trend: ${f.trend}', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: f.trend.startsWith('+') ? const Color(0xFFC94343) : const Color(0xFF087F73))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: f.score / 100,
              backgroundColor: statusColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 7,
            ),
          ),
        ],
      ),
    );
  }

  Color _riskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low: return const Color(0xFF16845B);
      case RiskLevel.moderate: return const Color(0xFFD99A18);
      case RiskLevel.high: return const Color(0xFFE65100);
      case RiskLevel.critical: return const Color(0xFFC94343);
    }
  }

  Color _riskBgColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low: return const Color(0xFFE6F4EF);
      case RiskLevel.moderate: return const Color(0xFFFFF5D6);
      case RiskLevel.high: return const Color(0xFFFFEDD5);
      case RiskLevel.critical: return const Color(0xFFFDECEC);
    }
  }
}

class _RiskFactor {
  final String factor, weight, trend, status;
  final int score;
  const _RiskFactor(this.factor, this.weight, this.score, this.trend, this.status);
}
