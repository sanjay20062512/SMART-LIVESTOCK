// Smart Livestock — NEW Government Dashboard Screen
// Faithfully ports the React OverviewView from the Government web module.

import 'package:flutter/material.dart';
import 'govt_theme.dart';
import 'govt_new_data.dart';
import '../../services/farmer_data_service.dart';

class GovtNewDashboard extends StatelessWidget {
  final ValueChanged<int> onNavigateTab;
  final FarmerDataService? dataService;

  const GovtNewDashboard({
    super.key,
    required this.onNavigateTab,
    this.dataService,
  });

  @override
  Widget build(BuildContext context) {
    final highRisk = maharashtraDistricts.where((d) => d.riskScore >= 56).toList();
    final alerts = dataService != null ? dataService!.getGovtAlertsList() : getInitialAlerts();

    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            _buildHeader(context),
            const SizedBox(height: 20),

            // ── 4 KPI Cards ───────────────────────────────────────────────
            _buildKpiRow(context, highRisk),
            const SizedBox(height: 20),

            // ── Maharashtra Health Pulse ───────────────────────────────────
            _buildHealthPulse(highRisk),
            const SizedBox(height: 20),

            // ── High-Risk Districts + Alerts ──────────────────────────────
            LayoutBuilder(builder: (ctx, c) {
              if (c.maxWidth >= 700) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildHighRiskDistricts(context, highRisk)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildAlertsCard(context, alerts)),
                  ],
                );
              }
              return Column(
                children: [
                  _buildHighRiskDistricts(context, highRisk),
                  const SizedBox(height: 16),
                  _buildAlertsCard(context, alerts),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4F1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'State Surveillance Bureau',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF087F73), letterSpacing: 0.5),
              ),
            ),
            const SizedBox(width: 6),
            const Text('•', style: TextStyle(color: Color(0xFF667482), fontSize: 11)),
            const SizedBox(width: 6),
            const Text('Q3 Live Cycle', style: TextStyle(fontSize: 11, color: Color(0xFF667482))),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Government Health Command Center',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF18232B), letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        const Text(
          'Monitor animal-health risks, vaccination progress, and field response across Maharashtra.',
          style: TextStyle(fontSize: 12, color: Color(0xFF667482), height: 1.4),
        ),
      ],
    );
  }

  // ── KPI Cards ───────────────────────────────────────────────────────────────
  Widget _buildKpiRow(BuildContext context, List<DistrictData> highRisk) {
    return LayoutBuilder(builder: (ctx, c) {
      final cols = c.maxWidth >= 700 ? 4 : 2;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: cols,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: c.maxWidth >= 700 ? 1.75 : 1.32,
        children: [
          _kpiCard(
            title: 'Active Disease Cases', value: '1,284',
            sub: 'Confirmed syndromic reports', badge: '+8.4% this week',
            badgeColor: const Color(0xFFFDECEC), badgeTextColor: const Color(0xFFC94343),
            iconBg: const Color(0xFFFDECEC), iconColor: const Color(0xFFC94343),
            icon: Icons.monitor_heart_outlined,
            onTap: () => onNavigateTab(3),
          ),
          _kpiCard(
            title: 'High-Risk Districts', value: highRisk.length.toString(),
            sub: '3 newly flagged this week', badge: 'Surge Area',
            badgeColor: const Color(0xFFFFF5D6), badgeTextColor: const Color(0xFFB87A04),
            iconBg: const Color(0xFFFFF5D6), iconColor: const Color(0xFFD99A18),
            icon: Icons.warning_amber_rounded,
            onTap: () => onNavigateTab(1),
          ),
          _kpiCard(
            title: 'Vaccination Coverage', value: '68.5%',
            sub: 'State target: 85% mandate', badge: '+5.2% this month',
            badgeColor: const Color(0xFFE6F4F1), badgeTextColor: const Color(0xFF087F73),
            iconBg: const Color(0xFFE6F4F1), iconColor: const Color(0xFF087F73),
            icon: Icons.vaccines_outlined,
            onTap: () => onNavigateTab(2),
          ),
          _kpiCard(
            title: 'Pending Actions', value: '24',
            sub: '7 urgent field response tasks', badge: '3 awaiting lab',
            badgeColor: const Color(0xFFEAF3FB), badgeTextColor: const Color(0xFF1769AA),
            iconBg: const Color(0xFFEAF3FB), iconColor: const Color(0xFF1769AA),
            icon: Icons.assignment_outlined,
            onTap: () => onNavigateTab(4),
          ),
        ],
      );
    });
  }

  Widget _kpiCard({
    required String title, required String value, required String sub,
    required String badge, required Color badgeColor, required Color badgeTextColor,
    required Color iconBg, required Color iconColor, required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: GovtColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE4EAF0)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(7)),
                    child: Icon(icon, size: 14, color: iconColor),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(4)),
                      child: Text(badge, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: badgeTextColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF18232B), letterSpacing: -0.5)),
                  Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF18232B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(sub, style: const TextStyle(fontSize: 8.5, color: Color(0xFF667482)), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Maharashtra Health Pulse ─────────────────────────────────────────────────
  Widget _buildHealthPulse(List<DistrictData> highRisk) {
    return Container(
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4EAF0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF7F9FB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: Color(0xFFE4EAF0))),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Maharashtra Health Pulse', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF18232B))),
                      SizedBox(height: 2),
                      Text('Consolidated state epidemiological risk index and response readiness snapshot.', style: TextStyle(fontSize: 10.5, color: Color(0xFF667482))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFFF5D6), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFD99A18).withValues(alpha: 0.4))),
                  child: const Text('Elevated State Vigilance', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFB87A04))),
                ),
              ],
            ),
          ),
          // Metrics row
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(builder: (ctx, c) {
              final metrics = [
                _MetricItem('Overall State Risk', '58/100', 'Elevated threshold', const Color(0xFFD99A18)),
                _MetricItem('Total Cases', '1,284', '+8.4% weekly', const Color(0xFF18232B)),
                _MetricItem('High-Risk Districts', '${maharashtraDistricts.where((d) => d.riskScore >= 56).length}', 'Across 5 divisions', const Color(0xFFC94343)),
                _MetricItem('Vaccination', '68.5%', '+5.2% monthly', const Color(0xFF087F73)),
                _MetricItem('Mortality', '43', '-4% trend', const Color(0xFF18232B)),
                _MetricItem('Response Teams', '19 Units', '100% Deployed', const Color(0xFF1769AA)),
              ];
              final cols = c.maxWidth >= 600 ? 6 : 3;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cols,
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
                childAspectRatio: cols == 6 ? 1.3 : 2.2,
                children: metrics.map((m) => _buildMetricCell(m)).toList(),
              );
            }),
          ),
          // Progress bars
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                const Divider(color: Color(0xFFE4EAF0)),
                const SizedBox(height: 10),
                _progressBar('State Vaccination Mandate Progress (Target: 85%)', 68.5, const Color(0xFF087F73)),
                const SizedBox(height: 10),
                _progressBar('Veterinary Task Resolution Index (30-Day Rate)', 79.2, const Color(0xFF1769AA)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCell(_MetricItem m) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(m.label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF667482), letterSpacing: 0.3), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Text(m.value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: m.color, letterSpacing: -0.3)),
        Text(m.sub, style: const TextStyle(fontSize: 9, color: Color(0xFF667482)), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _progressBar(String label, double value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF18232B)))),
            Text('${value.toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: const Color(0xFFEAF3FB),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // ── High-Risk Districts ──────────────────────────────────────────────────────
  Widget _buildHighRiskDistricts(BuildContext context, List<DistrictData> highRisk) {
    return Container(
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('High-Risk Districts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF18232B))),
                      Text('Ranked by risk score & vaccination deficit.', style: TextStyle(fontSize: 10.5, color: Color(0xFF667482))),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateTab(1),
                  child: const Row(
                    children: [
                      Text('Map', style: TextStyle(fontSize: 11, color: Color(0xFF1769AA), fontWeight: FontWeight.w700)),
                      Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF1769AA)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE4EAF0)),
          ...highRisk.take(5).map((d) => _districtRow(context, d)),
        ],
      ),
    );
  }

  Widget _districtRow(BuildContext context, DistrictData d) {
    final color = _riskColor(d.riskLevel);
    final bgColor = _riskBgColor(d.riskLevel);
    return InkWell(
      onTap: () => onNavigateTab(1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE4EAF0)))),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(d.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF18232B))),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
                        child: Text(riskLevelLabel(d.riskLevel).toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: color)),
                      ),
                      const SizedBox(width: 4),
                      Text('${d.riskScore}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${d.suspectedDisease.split('(').first.trim()} • Cases: ${d.activeCases} • Coverage: ${d.vaccinationCoverage}%',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF667482)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF667482)),
          ],
        ),
      ),
    );
  }

  // ── Alerts Card ──────────────────────────────────────────────────────────────
  Widget _buildAlertsCard(BuildContext context, List<GovtAlert> alerts) {
    return Container(
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recent Alerts & Advisories', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF18232B))),
                      Text('Critical outbreak flags and containment milestones.', style: TextStyle(fontSize: 10.5, color: Color(0xFF667482))),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateTab(4),
                  child: const Row(
                    children: [
                      Text('All', style: TextStyle(fontSize: 11, color: Color(0xFF1769AA), fontWeight: FontWeight.w700)),
                      Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF1769AA)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE4EAF0)),
          ...alerts.take(4).map((a) => _alertRow(a)),
        ],
      ),
    );
  }

  Widget _alertRow(GovtAlert a) {
    final priorityColor = a.priority == 'Critical'
        ? const Color(0xFFC94343)
        : a.priority == 'High'
            ? const Color(0xFFD99A18)
            : const Color(0xFF1769AA);
    final priorityBg = a.priority == 'Critical'
        ? const Color(0xFFFDECEC)
        : a.priority == 'High'
            ? const Color(0xFFFFF5D6)
            : const Color(0xFFEAF3FB);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE4EAF0)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(color: priorityBg, borderRadius: BorderRadius.circular(4)),
                child: Text(a.priority.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: priorityColor)),
              ),
              const SizedBox(width: 6),
              Expanded(child: Text(a.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF18232B)), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text(a.time, style: const TextStyle(fontSize: 9, color: Color(0xFF667482))),
            ],
          ),
          const SizedBox(height: 4),
          Text(a.description, style: const TextStyle(fontSize: 10.5, color: Color(0xFF667482), height: 1.35), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(a.district, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1769AA))),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
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

class _MetricItem {
  final String label, value, sub;
  final Color color;
  const _MetricItem(this.label, this.value, this.sub, this.color);
}
