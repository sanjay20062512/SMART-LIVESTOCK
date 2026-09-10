// Government Command Center — National Livestock Animal Health Intelligence & Surveillance
// Real-time surveillance, India GIS heat map, early warning & emergency response.

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import 'govt_theme.dart';
import 'govt_models.dart';
import 'govt_mock_data.dart';
import 'widgets/govt_india_map_widget.dart';

class GovtDashboardScreen extends StatefulWidget {
  final FarmerDataService dataService;
  final ValueChanged<int>? onNavigateToSection;

  const GovtDashboardScreen({
    super.key,
    required this.dataService,
    this.onNavigateToSection,
  });

  @override
  State<GovtDashboardScreen> createState() => _GovtDashboardScreenState();
}

class _GovtDashboardScreenState extends State<GovtDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  final WhyRiskHighAnalysis _whyRisk = GovtMockData.getWhyRiskHigh('Erode');
  final List<OutbreakIncident> _outbreaks = GovtMockData.getOutbreakIncidents();

  String _selectedState = 'TAMIL NADU';
  String _selectedDistrict = 'ERODE';
  String _selectedTrendTimeframe = '7 DAYS';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.dataService,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: GovtColors.pageBackground,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Executive Mission Banner & Jurisdiction Breadcrumb ───
                _buildExecutiveMissionBanner(),
                const SizedBox(height: 16),

                // ── 2. Primary Executive KPI Strip ─────────────────────────
                _buildExecutiveKPIStrip(),
                const SizedBox(height: 20),

                // ── 3. HERO FEATURE — Disease Heatmap & Risk Intelligence (65% / 35%) ──
                _buildHeroHeatmapAndRiskIntelligence(),
                const SizedBox(height: 20),

                // ── 4. Dedicated Active Outbreaks Table & Outbreak Drawer ───
                _buildActiveOutbreaksSection(),
                const SizedBox(height: 20),

                // ── 5. Disease Trend Analytics & Disease Distribution ──────
                _buildDiseaseTrendsAndDistribution(),
                const SizedBox(height: 20),

                // ── 6. Weather Correlation & Vaccination Intelligence ──────
                _buildWeatherCorrelationAndVaccination(),
                const SizedBox(height: 20),

                // ── 7. Laboratory Monitoring & Field Response Telemetry ─────
                _buildLaboratoryAndFieldResponse(),
                const SizedBox(height: 20),

                // ── 8. Early Warning System & Government Alert Center ───────
                _buildEarlyWarningAndAlertsSection(),
                const SizedBox(height: 20),

                // ── 9. Decision Support Engine & Government Reporting ───────
                _buildDecisionSupportAndReporting(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── 1. Executive Mission Banner ────────────────────────────────────────

  Widget _buildExecutiveMissionBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: GovtColors.border),
        boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 820;

          final titleCol = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: GovtColors.riskCritical,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: GovtColors.riskCritical.withValues(alpha: 0.6 * _pulseController.value),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ANIMAL HEALTH INTELLIGENCE COMMAND CENTER',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: GovtColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              const Text(
                'National Livestock Disease Surveillance & Response Grid • Department of Animal Husbandry & Dairying (DAHD)',
                style: TextStyle(fontSize: 11, color: GovtColors.textSecondary),
              ),
            ],
          );

          final jurisdictionPill = Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: GovtColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: GovtColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hub_rounded, size: 14, color: GovtColors.brand),
                const SizedBox(width: 6),
                Text(
                  'INDIA / $_selectedState / $_selectedDistrict / PERUNDURAI',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: GovtColors.textPrimary,
                  ),
                ),
              ],
            ),
          );

          if (isWide) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                titleCol,
                jurisdictionPill,
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleCol,
                const SizedBox(height: 10),
                jurisdictionPill,
              ],
            );
          }
        },
      ),
    );
  }

  // ─── 2. Primary Executive KPI Strip ─────────────────────────────────────

  Widget _buildExecutiveKPIStrip() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int count = 6;
        if (constraints.maxWidth < 680) {
          count = 2;
        } else if (constraints.maxWidth < 1100) {
          count = 3;
        }

        final kpis = [
          _kpiCard('ACTIVE OUTBREAKS', '27', '↑ 12.4% this week', GovtColors.riskCritical, Icons.crisis_alert_rounded),
          _kpiCard('HIGH-RISK ZONES', '14', '+2 detected', GovtColors.riskHigh, Icons.warning_rounded),
          _kpiCard('SUSPECTED CASES', '183', '↑ 18 today', GovtColors.riskHigh, Icons.coronavirus_rounded),
          _kpiCard('ANIMALS AFFECTED', '12,540', '+420 weekly', GovtColors.brandDark, Icons.pets_rounded),
          _kpiCard('VACCINATION COVERAGE', '76.4%', 'Target: 90%', GovtColors.brand, Icons.vaccines_rounded),
          _kpiCard('CRITICAL ALERTS', '06', '↑ 2 today', GovtColors.riskCritical, Icons.notifications_active_rounded),
        ];

        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: count == 6 ? 1.35 : (count == 3 ? 1.55 : 1.4),
          children: kpis,
        );
      },
    );
  }

  Widget _kpiCard(String title, String val, String sub, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: GovtColors.border),
        boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: GovtColors.textSecondary)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          Text(val, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: GovtColors.textPrimary, letterSpacing: -0.5)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(sub, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }

  // ─── 3. HERO FEATURE — Disease Heatmap & Risk Intelligence (Side-by-Side: 65% / 35%) ──

  Widget _buildHeroHeatmapAndRiskIntelligence() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1050;

        final mapWidget = IndiaDiseaseIntelligenceMap(
          currentJurisdictionState: _selectedState,
          currentJurisdictionDistrict: _selectedDistrict,
          onStateSelected: (st) => setState(() => _selectedState = st),
          onDistrictSelected: (dt) => setState(() => _selectedDistrict = dt),
        );

        final riskIntelWidget = _buildRiskIntelligencePanel();

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 65, child: mapWidget),
              const SizedBox(width: 16),
              Expanded(flex: 35, child: riskIntelWidget),
            ],
          );
        } else {
          return Column(
            children: [
              mapWidget,
              const SizedBox(height: 16),
              riskIntelWidget,
            ],
          );
        }
      },
    );
  }

  Widget _buildRiskIntelligencePanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: GovtColors.border),
        boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_outlined, size: 16, color: GovtColors.brand),
                  SizedBox(width: 6),
                  Text('Risk Intelligence', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: GovtColors.criticalLight, borderRadius: BorderRadius.circular(4)),
                child: const Text('CRITICAL 87%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GovtColors.riskCritical)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Current High-Risk Area Header
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: GovtColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: GovtColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CURRENT HIGH-RISK AREA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: GovtColors.textSecondary)),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_whyRisk.areaName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GovtColors.textPrimary)),
                    Text('${_whyRisk.dominantDisease} • ${_whyRisk.trend}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.riskCritical)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // WHY IS THE RISK HIGH? (4 concise reasons)
          const Text('WHY IS THE RISK HIGH?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: GovtColors.textPrimary)),
          const SizedBox(height: 6),
          ..._whyRisk.conciseReasons.map((reason) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Text('• ', style: TextStyle(color: GovtColors.brand, fontWeight: FontWeight.w800, fontSize: 13)),
                    Expanded(child: Text(reason, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GovtColors.textPrimary))),
                  ],
                ),
              )),
          const Divider(height: 18),

          // WHY RISK = 87% (Transparent contribution bars)
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('WHY RISK = 87%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: GovtColors.textPrimary)),
              Text('Decision Support Metric', style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: GovtColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),

          ..._whyRisk.contributors.map((c) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c.factor, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: GovtColors.textPrimary)),
                      Text('${c.percentage}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: c.percentage >= 85 ? GovtColors.riskCritical : GovtColors.riskHigh)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: c.percentage / 100.0,
                      minHeight: 5,
                      backgroundColor: GovtColors.surfaceSubtle,
                      valueColor: AlwaysStoppedAnimation(c.percentage >= 85 ? GovtColors.riskCritical : GovtColors.riskHigh),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),

          // RECOMMENDED ACTION & BUTTON
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: GovtColors.brandLight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: GovtColors.brand.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('RECOMMENDED ACTION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: GovtColors.brandDark)),
                const SizedBox(height: 3),
                Text(
                  _whyRisk.recommendedAction,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GovtColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: GovtColors.brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              icon: const Icon(Icons.assignment_outlined, size: 16),
              label: const Text('OPEN RESPONSE PLAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              onPressed: _openResponsePlanModal,
            ),
          ),
        ],
      ),
    );
  }

  void _openResponsePlanModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: GovtColors.brand, size: 20),
            SizedBox(width: 8),
            Text('Outbreak Response Plan — Erode District', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: GovtColors.textPrimary)),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Surveillance Directive #OP-ERD-2026', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GovtColors.brandDark)),
              const SizedBox(height: 8),
              const Text('1. Mobilize Rapid Veterinary Team V-024 to Perundurai Cluster.', style: TextStyle(fontSize: 11)),
              const Text('2. Enforce 5 km barrier cordon around Veeranam & Kavundampadi villages.', style: TextStyle(fontSize: 11)),
              const Text('3. Dispatch 12,000 emergency FMD oil-adjuvant vaccine doses.', style: TextStyle(fontSize: 11)),
              const Text('4. Close weekly cattle markets along NH-544 corridor for 14 days.', style: TextStyle(fontSize: 11)),
              const Text('5. Expedite pending epithelial scrapings at TANUVAS Lab.', style: TextStyle(fontSize: 11)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: GovtColors.warningLight, borderRadius: BorderRadius.circular(6)),
                child: const Text('Authorized under National Livestock Disease Control Programme (NLDCP).', style: TextStyle(fontSize: 10, color: GovtColors.warning)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovtColors.brand, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: GovtColors.brandDark,
                  content: Text('✓ Response Plan #OP-ERD-2026 dispatched to field veterinary grid.'),
                ),
              );
            },
            child: const Text('AUTHORIZE & DISPATCH'),
          ),
        ],
      ),
    );
  }

  // ─── 4. Dedicated Active Outbreaks Section & Drawer ─────────────────────

  Widget _buildActiveOutbreaksSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: GovtColors.border),
        boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.hub_outlined, size: 18, color: GovtColors.riskCritical),
                  SizedBox(width: 8),
                  Text('ACTIVE OUTBREAKS — SURVEILLANCE & CONTAINMENT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textPrimary)),
                ],
              ),
              Text('${_outbreaks.length} Ongoing Field Investigations', style: const TextStyle(fontSize: 11, color: GovtColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 14),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: GovtColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: GovtColors.border),
            ),
            child: const Row(
              children: [
                SizedBox(width: 75, child: Text('OUTBREAK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GovtColors.textSecondary))),
                SizedBox(width: 90, child: Text('LOCATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GovtColors.textSecondary))),
                SizedBox(width: 75, child: Text('DISEASE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GovtColors.textSecondary))),
                SizedBox(width: 85, child: Text('RISK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GovtColors.textSecondary))),
                SizedBox(width: 60, child: Text('CASES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GovtColors.textSecondary))),
                SizedBox(width: 70, child: Text('MORTALITY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GovtColors.textSecondary))),
                SizedBox(width: 60, child: Text('TREND', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GovtColors.textSecondary))),
                Expanded(child: Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GovtColors.textSecondary))),
                SizedBox(width: 70, child: Text('ACTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GovtColors.textSecondary), textAlign: TextAlign.right)),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Table Rows
          ..._outbreaks.map((ob) {
            final isCritical = ob.riskLevel == 'CRITICAL';
            final isHigh = ob.riskLevel == 'HIGH';
            final color = isCritical ? GovtColors.riskCritical : (isHigh ? GovtColors.riskHigh : GovtColors.riskModerate);

            return InkWell(
              onTap: () => _showOutbreakDrawer(ob),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: GovtColors.divider)),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 75, child: Text(ob.clusterId, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: GovtColors.textPrimary))),
                    SizedBox(width: 90, child: Text(ob.location, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                    SizedBox(width: 75, child: Text(ob.disease, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.brandDark))),
                    SizedBox(
                      width: 85,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                        child: Text(ob.riskLevel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color), textAlign: TextAlign.center),
                      ),
                    ),
                    SizedBox(width: 60, child: Text('${ob.cases}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                    SizedBox(width: 70, child: Text('${ob.mortality}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.riskCritical))),
                    SizedBox(width: 60, child: Text(ob.trend, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: ob.trend.contains('↑') ? GovtColors.riskCritical : GovtColors.riskLow))),
                    Expanded(child: Text(ob.status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GovtColors.textSecondary))),
                    SizedBox(
                      width: 70,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => _showOutbreakDrawer(ob),
                          child: const Text('VIEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showOutbreakDrawer(OutbreakIncident ob) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drawer Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                decoration: const BoxDecoration(
                  color: GovtColors.navyPrimary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('OUTBREAK INTELLIGENCE DOSSIER — ${ob.clusterId}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.6)),
                        const SizedBox(height: 2),
                        Text('${ob.disease} • ${ob.location} District • Risk Score ${ob.riskScore}% (${ob.riskLevel})', style: const TextStyle(fontSize: 11, color: GovtColors.brandLight)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              // Drawer Body
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Timeline Section
                    const Text('TIMELINE & SURVEILLANCE LIFECYCLE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: GovtColors.textPrimary)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: GovtColors.surfaceSubtle, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ob.timeline.entries.map((e) {
                          return Column(
                            children: [
                              Text(e.key, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: GovtColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text(e.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GovtColors.brandDark)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Metrics Grid
                    Row(
                      children: [
                        Expanded(child: _drawerMetricBox('Affected Villages', '${ob.affectedVillages.length} villages', ob.affectedVillages.take(2).join(', '))),
                        const SizedBox(width: 10),
                        Expanded(child: _drawerMetricBox('Cases & Mortality', '${ob.cases} Cases', '${ob.mortality} Fatalities logged')),
                        const SizedBox(width: 10),
                        Expanded(child: _drawerMetricBox('Vaccination Coverage', '${ob.vaccinationCoverage}%', 'Gap: ${90 - ob.vaccinationCoverage}% against target')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _drawerMetricBox('Assigned Team', ob.assignedTeam, 'GPS Live Telemetry Active')),
                        const SizedBox(width: 10),
                        Expanded(child: _drawerMetricBox('Laboratory Status', ob.labStatus, 'TANUVAS Regional Diagnostic Unit')),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Checklist
                    const Text('RESPONSE ACTIONS & DIRECTIVES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: GovtColors.textPrimary)),
                    const SizedBox(height: 8),
                    ...ob.responseChecklist.map((item) {
                      final isDone = item.status == 'Completed';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: GovtColors.border)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked, size: 14, color: isDone ? GovtColors.riskLow : GovtColors.warning),
                                const SizedBox(width: 8),
                                Text(item.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: isDone ? GovtColors.riskLow.withValues(alpha: 0.1) : GovtColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(item.status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: isDone ? GovtColors.riskLow : GovtColors.warning)),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    // 5 Actions Buttons
                    const Text('OFFICIAL INTERVENTIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: GovtColors.textPrimary)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _drawerActionButton('Assign Team', Icons.group_add_rounded, GovtColors.brand, () => _handleDrawerAction('Team V-024 dispatched to cluster.')),
                        _drawerActionButton('Request Sample', Icons.biotech_rounded, GovtColors.info, () => _handleDrawerAction('Sample collection mandate sent to field vet.')),
                        _drawerActionButton('Launch Vaccination', Icons.vaccines_rounded, GovtColors.warning, () => _handleDrawerAction('Emergency ring vaccination drive initialized.')),
                        _drawerActionButton('Send Advisory', Icons.campaign_rounded, GovtColors.riskHigh, () => _handleDrawerAction('Multilingual SMS and app advisory broadcasted to farmers.')),
                        _drawerActionButton('Mark Contained', Icons.verified_rounded, GovtColors.riskLow, () => _handleDrawerAction('Outbreak containment protocol verified and logged.')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _drawerMetricBox(String title, String val, String sub) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: GovtColors.surfaceSubtle, borderRadius: BorderRadius.circular(6), border: Border.all(color: GovtColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: GovtColors.textSecondary)),
          const SizedBox(height: 3),
          Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GovtColors.textPrimary)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 9, color: GovtColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _drawerActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      onPressed: onTap,
    );
  }

  void _handleDrawerAction(String message) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: GovtColors.navyDark, content: Text('✓ $message'), duration: const Duration(seconds: 3)),
    );
  }

  // ─── 5. Disease Trends & Distribution ───────────────────────────────────

  Widget _buildDiseaseTrendsAndDistribution() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;

        final trendCard = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: GovtRadius.mdRadius,
            border: Border.all(color: GovtColors.border),
            boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.show_chart_rounded, size: 18, color: GovtColors.brand),
                      SizedBox(width: 8),
                      Text('DISEASE CASES OVER TIME', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textPrimary)),
                    ],
                  ),
                  Row(
                    children: ['7 DAYS', '30 DAYS', '90 DAYS', '1 YEAR'].map((tf) {
                      final isSelected = _selectedTrendTimeframe == tf;
                      return Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: InkWell(
                          onTap: () => setState(() => _selectedTrendTimeframe = tf),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? GovtColors.brand : GovtColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tf,
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : GovtColors.textSecondary),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _TwelveWeekEpidemicPainter(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _chartLegend('FMD', GovtColors.riskCritical),
                  const SizedBox(width: 14),
                  _chartLegend('PPR', GovtColors.riskHigh),
                  const SizedBox(width: 14),
                  _chartLegend('LSD', GovtColors.riskModerate),
                  const SizedBox(width: 14),
                  _chartLegend('Anthrax', Colors.black87),
                ],
              ),
            ],
          ),
        );

        final distCard = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: GovtRadius.mdRadius,
            border: Border.all(color: GovtColors.border),
            boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOP DISEASES THIS MONTH', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textPrimary)),
                  Text('Proportionate Prevalence', style: TextStyle(fontSize: 10, color: GovtColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 14),
              _diseaseDistBar('Foot-and-Mouth Disease (FMD)', 42, GovtColors.riskCritical),
              _diseaseDistBar('Peste des Petits Ruminants (PPR)', 21, GovtColors.riskHigh),
              _diseaseDistBar('Lumpy Skin Disease (LSD)', 16, GovtColors.riskModerate),
              _diseaseDistBar('Anthrax (Spore)', 9, Colors.black87),
              _diseaseDistBar('Other / Unknown Syndromes', 12, GovtColors.brand),
            ],
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 60, child: trendCard),
              const SizedBox(width: 16),
              Expanded(flex: 40, child: distCard),
            ],
          );
        } else {
          return Column(
            children: [
              trendCard,
              const SizedBox(height: 14),
              distCard,
            ],
          );
        }
      },
    );
  }

  Widget _diseaseDistBar(String name, int percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GovtColors.textPrimary)),
              Text('$percent%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: percent / 100.0,
              minHeight: 6,
              backgroundColor: GovtColors.surfaceSubtle,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 6. Weather Correlation & Vaccination Intelligence ──────────────────

  Widget _buildWeatherCorrelationAndVaccination() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;

        final weatherCard = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: GovtRadius.mdRadius,
            border: Border.all(color: GovtColors.border),
            boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cloud_sync_rounded, size: 18, color: GovtColors.brand),
                      SizedBox(width: 8),
                      Text('WEATHER & DISEASE RISK', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textPrimary)),
                    ],
                  ),
                  Text('Environmental Surveillance Signal', style: TextStyle(fontSize: 10, color: GovtColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _weatherPill('Rainfall', '↑ 28%', 'Pasture stagnation', GovtColors.riskHigh)),
                  const SizedBox(width: 8),
                  Expanded(child: _weatherPill('Humidity', '↑ 16%', 'Aerosol persistence', GovtColors.warning)),
                  const SizedBox(width: 8),
                  Expanded(child: _weatherPill('Disease Reports', '↑ 23%', 'Western Corridor', GovtColors.riskCritical)),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: GovtColors.surfaceSubtle, borderRadius: BorderRadius.circular(6)),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: GovtColors.textSecondary),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Recent rainfall and humidity conditions correlate with increased disease reports in selected districts.',
                        style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: GovtColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        final vaccCard = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: GovtRadius.mdRadius,
            border: Border.all(color: GovtColors.border),
            boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('VACCINATION INTELLIGENCE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textPrimary)),
                  Text('Coverage: 76.4% • Target: 90%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: GovtColors.brand)),
                ],
              ),
              const SizedBox(height: 12),
              _vaccDistrictRow('Erode District', '61%', 'HIGH RISK • Priority vaccination zone', GovtColors.riskCritical),
              _vaccDistrictRow('Salem District', '84%', 'MEDIUM RISK • Active ring coverage', GovtColors.warning),
              _vaccDistrictRow('Coimbatore District', '92%', 'LOW RISK • Target achieved', GovtColors.riskLow),
            ],
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: weatherCard),
              const SizedBox(width: 16),
              Expanded(child: vaccCard),
            ],
          );
        } else {
          return Column(
            children: [
              weatherCard,
              const SizedBox(height: 14),
              vaccCard,
            ],
          );
        }
      },
    );
  }

  Widget _vaccDistrictRow(String district, String coverage, String note, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: GovtColors.surfaceSubtle, borderRadius: BorderRadius.circular(6), border: Border.all(color: GovtColors.border)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(district, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.textPrimary)),
                Text(note, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
              ],
            ),
            Text(coverage, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }

  // ─── 7. Laboratory Monitoring & Field Response Telemetry ─────────────────

  Widget _buildLaboratoryAndFieldResponse() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;

        final labCard = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: GovtRadius.mdRadius,
            border: Border.all(color: GovtColors.border),
            boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('LABORATORY MONITORING PIPELINE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textPrimary)),
                  Text('Avg Turnaround: 18 hrs', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: GovtColors.brand)),
                ],
              ),
              const SizedBox(height: 12),
              // Lab Pipeline Counts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _labStatChip('Collected', '128', GovtColors.brand),
                  _labStatChip('In Transit', '23', GovtColors.info),
                  _labStatChip('Testing', '41', GovtColors.warning),
                  _labStatChip('Positive', '18', GovtColors.riskCritical),
                  _labStatChip('Negative', '46', GovtColors.riskLow),
                ],
              ),
              const SizedBox(height: 14),
              // Visual Flow
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: GovtColors.surfaceSubtle, borderRadius: BorderRadius.circular(6)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('SUSPECTED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: GovtColors.textSecondary)),
                    Icon(Icons.arrow_forward, size: 10, color: GovtColors.textSecondary),
                    Text('COLLECTED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: GovtColors.brand)),
                    Icon(Icons.arrow_forward, size: 10, color: GovtColors.textSecondary),
                    Text('LAB RCVD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: GovtColors.info)),
                    Icon(Icons.arrow_forward, size: 10, color: GovtColors.textSecondary),
                    Text('TESTING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: GovtColors.warning)),
                    Icon(Icons.arrow_forward, size: 10, color: GovtColors.textSecondary),
                    Text('RESULT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: GovtColors.riskCritical)),
                    Icon(Icons.arrow_forward, size: 10, color: GovtColors.textSecondary),
                    Text('ACTION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: GovtColors.brandDark)),
                  ],
                ),
              ),
            ],
          ),
        );

        final fieldCard = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: GovtRadius.mdRadius,
            border: Border.all(color: GovtColors.border),
            boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('FIELD RESPONSE — VETERINARY SQUADS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textPrimary)),
                  Text('63 Total Personnel', style: TextStyle(fontSize: 10, color: GovtColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _labStatChip('Available', '12', GovtColors.brand),
                  _labStatChip('Deployed', '28', GovtColors.info),
                  _labStatChip('Investigating', '09', GovtColors.riskCritical),
                  _labStatChip('Vaccinating', '14', GovtColors.warning),
                ],
              ),
              const SizedBox(height: 12),
              _teamStatusRow('Team V-024 (Dr. Rajesh Kumar)', 'Erode', 'Investigating', GovtColors.riskCritical),
              _teamStatusRow('Team V-011 (Dr. Priya S.)', 'Salem', 'Vaccination Drive', GovtColors.warning),
            ],
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: labCard),
              const SizedBox(width: 16),
              Expanded(child: fieldCard),
            ],
          );
        } else {
          return Column(
            children: [
              labCard,
              const SizedBox(height: 14),
              fieldCard,
            ],
          );
        }
      },
    );
  }

  Widget _labStatChip(String title, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: GovtColors.textSecondary)),
      ],
    );
  }

  Widget _teamStatusRow(String team, String loc, String role, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: GovtColors.surfaceSubtle, borderRadius: BorderRadius.circular(4)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(team, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
            Text(loc, style: const TextStyle(fontSize: 10, color: GovtColors.textSecondary)),
            Row(
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(role, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── 8. Early Warning System & Government Alert Center ───────────────────

  Widget _buildEarlyWarningAndAlertsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;

        final earlyWarningCard = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: GovtRadius.mdRadius,
            border: Border.all(color: GovtColors.warning.withValues(alpha: 0.4)),
            boxShadow: const [BoxShadow(color: Color(0x0DD98B00), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: GovtColors.warningLight, borderRadius: BorderRadius.circular(4)),
                    child: const Text('⚠ EARLY WARNING #EW-018', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GovtColors.warning)),
                  ),
                  const Text('Detected 2 hours ago', style: TextStyle(fontSize: 10, color: GovtColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Emerging cluster detected: Erode — 7 villages (FMD suspected, Risk 87%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GovtColors.textPrimary)),
              const SizedBox(height: 6),
              const Text('Evidence Signals:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: GovtColors.textSecondary)),
              const Text('• +31% symptom reports in past 48h across 3 adjacent taluks', style: TextStyle(fontSize: 11)),
              const Text('• +18% adult dairy cow mortality logged in field registry', style: TextStyle(fontSize: 11)),
              const Text('• -14% vaccination coverage deficit against district mandate', style: TextStyle(fontSize: 11)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Field squad dispatched for #EW-018 investigation.')));
                    },
                    child: const Text('Investigate', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: GovtColors.brand, foregroundColor: Colors.white, visualDensity: VisualDensity.compact),
                    onPressed: () {
                      _showOutbreakDrawer(_outbreaks.first);
                    },
                    child: const Text('View Cluster', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        );

        final alertInboxCard = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: GovtRadius.mdRadius,
            border: Border.all(color: GovtColors.border),
            boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('GOVERNMENT ALERT CENTER', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textPrimary)),
                  Text('Active Feeds', style: TextStyle(fontSize: 10, color: GovtColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _alertBadge('Critical', '6', GovtColors.riskCritical),
                  _alertBadge('Warning', '14', GovtColors.warning),
                  _alertBadge('Information', '28', GovtColors.info),
                ],
              ),
              const SizedBox(height: 12),
              _alertRow('CRITICAL', 'Erode District', 'FMD cluster detected in Perundurai East', GovtColors.riskCritical),
              _alertRow('WARNING', 'Salem District', 'Vaccination coverage below 70% threshold', GovtColors.warning),
              _alertRow('INFO', 'Coimbatore', 'Laboratory results ready at TANUVAS unit', GovtColors.info),
            ],
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: earlyWarningCard),
              const SizedBox(width: 16),
              Expanded(child: alertInboxCard),
            ],
          );
        } else {
          return Column(
            children: [
              earlyWarningCard,
              const SizedBox(height: 14),
              alertInboxCard,
            ],
          );
        }
      },
    );
  }

  Widget _alertBadge(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _alertRow(String badge, String loc, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: GovtColors.surfaceSubtle, borderRadius: BorderRadius.circular(4)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
              child: Text(badge, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
            const SizedBox(width: 8),
            Text(loc, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 10, color: GovtColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  // ─── 9. Decision Support Engine & Government Reporting ───────────────────

  Widget _buildDecisionSupportAndReporting() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;

        final decisionSupportCard = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: GovtRadius.mdRadius,
            border: Border.all(color: GovtColors.brand.withValues(alpha: 0.4)),
            boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('RISK INTELLIGENCE ENGINE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textPrimary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: GovtColors.brandLight, borderRadius: BorderRadius.circular(4)),
                    child: const Text('CONFIDENCE 91%', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: GovtColors.brandDark)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Text('OVERALL RISK: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GovtColors.textSecondary)),
                  Text('87% — CRITICAL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GovtColors.riskCritical)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('KEY SIGNALS EVALUATED:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: GovtColors.textSecondary)),
              const Text('• Rising symptom reports (+31%)', style: TextStyle(fontSize: 10)),
              const Text('• Mortality elevation in adult herd (+18%)', style: TextStyle(fontSize: 10)),
              const Text('• Low vaccination coverage in buffer (61%)', style: TextStyle(fontSize: 10)),
              const Text('• Weather anomaly (precipitation +28%)', style: TextStyle(fontSize: 10)),
              const Text('• Historical recurrence cycle verified', style: TextStyle(fontSize: 10)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: GovtColors.surfaceSubtle, borderRadius: BorderRadius.circular(6)),
                child: const Text(
                  'LIMITATION: Risk score is a decision-support indicator and does not replace veterinary or laboratory confirmation.',
                  style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: GovtColors.textSecondary),
                ),
              ),
            ],
          ),
        );

        final reportsCard = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: GovtRadius.mdRadius,
            border: Border.all(color: GovtColors.border),
            boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('GOVERNMENT REPORTING CENTER', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textPrimary)),
                  Text('Surveillance Exports', style: TextStyle(fontSize: 10, color: GovtColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Available Official Formats:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: GovtColors.textSecondary)),
              const SizedBox(height: 4),
              const Text('• Daily Surveillance • Weekly Disease Summary • District Risk Report • Vaccination Coverage • Mortality Report • Laboratory Report • Outbreak Investigation', style: TextStyle(fontSize: 10, color: GovtColors.textPrimary)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: GovtColors.brand, foregroundColor: Colors.white, visualDensity: VisualDensity.compact),
                    icon: const Icon(Icons.summarize_outlined, size: 14),
                    label: const Text('Generate Report', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                    onPressed: () => _handleReportAction('Daily Surveillance Dossier generated.'),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 14, color: GovtColors.riskCritical),
                    label: const Text('Export PDF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                    onPressed: () => _handleReportAction('Official PDF report downloaded.'),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                    icon: const Icon(Icons.table_chart_outlined, size: 14, color: GovtColors.riskLow),
                    label: const Text('Export Excel', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                    onPressed: () => _handleReportAction('Surveillance Excel spreadsheet exported.'),
                  ),
                ],
              ),
            ],
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: decisionSupportCard),
              const SizedBox(width: 16),
              Expanded(child: reportsCard),
            ],
          );
        } else {
          return Column(
            children: [
              decisionSupportCard,
              const SizedBox(height: 14),
              reportsCard,
            ],
          );
        }
      },
    );
  }

  void _handleReportAction(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: GovtColors.brandDark, content: Text('✓ $msg')),
    );
  }

  Widget _weatherPill(String title, String val, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: GovtColors.surfaceSubtle, borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: GovtColors.textSecondary)),
          const SizedBox(height: 2),
          Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 9, color: GovtColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _chartLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: GovtColors.textSecondary)),
      ],
    );
  }
}

// ─── Multi-Line Epidemic Painter ──────────────────────────────────────────────

class _TwelveWeekEpidemicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final padding = const EdgeInsets.fromLTRB(25, 8, 15, 20);
    final chartW = size.width - padding.left - padding.right;
    final chartH = size.height - padding.top - padding.bottom;

    final weeks = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8', 'W9', 'W10', 'W11', 'W12'];
    final fmd = [14, 18, 22, 38, 56, 72, 85, 92, 74, 52, 36, 28];
    final ppr = [8, 10, 12, 19, 25, 34, 42, 48, 39, 28, 21, 16];
    final lsd = [4, 6, 9, 14, 18, 22, 26, 29, 24, 18, 14, 10];
    final anthrax = [2, 2, 3, 5, 6, 8, 9, 10, 8, 5, 4, 3];

    const maxVal = 100.0;

    // Grid lines
    final gridPaint = Paint()
      ..color = GovtColors.divider
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = padding.top + chartH * (1 - i / 4);
      canvas.drawLine(Offset(padding.left, y), Offset(padding.left + chartW, y), gridPaint);
      final tp = TextPainter(
        text: TextSpan(text: '${(maxVal * i / 4).round()}', style: const TextStyle(fontSize: 8, color: GovtColors.textSecondary)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(padding.left - tp.width - 4, y - tp.height / 2));
    }

    final stepX = chartW / (weeks.length - 1);

    for (int i = 0; i < weeks.length; i++) {
      final x = padding.left + i * stepX;
      final tp = TextPainter(
        text: TextSpan(text: weeks[i], style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: GovtColors.textSecondary)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, padding.top + chartH + 4));
    }

    _drawLine(canvas, fmd, maxVal, stepX, padding, chartH, GovtColors.riskCritical);
    _drawLine(canvas, ppr, maxVal, stepX, padding, chartH, GovtColors.riskHigh);
    _drawLine(canvas, lsd, maxVal, stepX, padding, chartH, GovtColors.riskModerate);
    _drawLine(canvas, anthrax, maxVal, stepX, padding, chartH, Colors.black87);
  }

  void _drawLine(Canvas canvas, List<int> data, double maxVal, double stepX, EdgeInsets padding, double chartH, Color color) {
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = padding.left + i * stepX;
      final y = padding.top + chartH * (1 - data[i] / maxVal);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, strokePaint);

    final dotPaint = Paint()..color = color;
    for (int i = 0; i < data.length; i++) {
      final x = padding.left + i * stepX;
      final y = padding.top + chartH * (1 - data[i] / maxVal);
      canvas.drawCircle(Offset(x, y), 2.5, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
