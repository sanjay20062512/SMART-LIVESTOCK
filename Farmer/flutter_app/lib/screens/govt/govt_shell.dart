// Government Module Shell — National Surveillance Command Center
// Implements 13-Section Left Navigation, Jurisdiction Selector, and Desktop Right Intelligence Panel.

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import 'govt_theme.dart';
import 'govt_models.dart';
import 'govt_mock_data.dart';
import 'govt_dashboard_screen.dart';
import 'govt_surveillance_screen.dart';
import 'govt_cluster_screen.dart';
import 'govt_analytics_screen.dart';
import 'govt_vaccination_screen.dart';
import 'govt_lab_screen.dart';
import 'govt_field_ops_screen.dart';
import 'govt_reports_screen.dart';
import 'govt_settings_screen.dart';
import 'govt_resources_screen.dart';
import 'govt_live_map_screen.dart';

class GovtShell extends StatefulWidget {
  final FarmerDataService dataService;
  const GovtShell({super.key, required this.dataService});

  @override
  State<GovtShell> createState() => _GovtShellState();
}

class _GovtShellState extends State<GovtShell> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _showRightPanel = true;
  DateTime _lastSync = DateTime.now().subtract(const Duration(minutes: 2));
  late final AnimationController _pulseController;

  late final List<Widget> _pages;
  late final List<_NavSectionItem> _navItems;
  final List<GovernmentAlert> _alerts = GovtMockData.getGovernmentAlerts();
  final List<EarlyWarningNotice> _warnings = GovtMockData.getEarlyWarnings();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pages = [
      GovtDashboardScreen(
        dataService: widget.dataService,
        onNavigateToSection: (idx) => setState(() => _selectedIndex = idx),
      ),
      GovtLiveMapScreen(dataService: widget.dataService),
      GovtClusterScreen(dataService: widget.dataService),
      GovtSurveillanceScreen(dataService: widget.dataService),
      GovtVaccinationScreen(dataService: widget.dataService),
      GovtLabScreen(dataService: widget.dataService),
      GovtFieldOpsScreen(dataService: widget.dataService),
      GovtAnalyticsScreen(dataService: widget.dataService),
      GovtReportsScreen(dataService: widget.dataService),
      GovtSettingsScreen(dataService: widget.dataService),
      GovtResourcesScreen(dataService: widget.dataService),
    ];

    _navItems = const [
      _NavSectionItem(Icons.dashboard_outlined, Icons.dashboard_rounded, '01 Overview'),
      _NavSectionItem(Icons.map_outlined, Icons.map_rounded, '02 Disease Heatmap'),
      _NavSectionItem(Icons.hub_outlined, Icons.hub_rounded, '03 Outbreaks'),
      _NavSectionItem(Icons.insights_outlined, Icons.insights_rounded, '04 Surveillance'),
      _NavSectionItem(Icons.vaccines_outlined, Icons.vaccines_rounded, '05 Vaccination'),
      _NavSectionItem(Icons.science_outlined, Icons.science_rounded, '06 Laboratory'),
      _NavSectionItem(Icons.groups_outlined, Icons.groups_rounded, '07 Field Response'),
      _NavSectionItem(Icons.bar_chart_outlined, Icons.bar_chart_rounded, '08 Analytics'),
      _NavSectionItem(Icons.description_outlined, Icons.description_rounded, '09 Reports'),
    ];
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _syncData() {
    setState(() => _lastSync = DateTime.now());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: GovtColors.navyDark,
        content: Text('✓ Central surveillance sync complete. 0 packet drops.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1050;
        final showRightDrawer = isDesktop && _showRightPanel && constraints.maxWidth >= 1260;

        if (isDesktop) {
          // ── Desktop 3-Column Command Center Layout ──────────────────────
          return Scaffold(
            backgroundColor: GovtColors.pageBackground,
            body: Row(
              children: [
                // 1. Left Institutional Sidebar (Navy)
                _buildDesktopSidebar(),

                // 2. Center Workspace with Top Command Header
                Expanded(
                  child: Column(
                    children: [
                      _buildTopCommandHeader(isDesktop: true),
                      Expanded(
                        child: IndexedStack(
                          index: _selectedIndex,
                          children: _pages,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Right Intelligence Panel (Collapsible)
                if (showRightDrawer)
                  _buildRightIntelligencePanel(),
              ],
            ),
          );
        } else {
          // ── Mobile / Tablet Layout ─────────────────────────────────────
          return Scaffold(
            backgroundColor: GovtColors.pageBackground,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: _buildTopCommandHeader(isDesktop: false),
            ),
            drawer: Drawer(child: _buildDrawerContent()),
            body: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
            bottomNavigationBar: _buildMobileBottomNav(),
          );
        }
      },
    );
  }

  // ─── Left Sidebar (Government Command Theme) ────────────────────────────

  Widget _buildDesktopSidebar() {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: GovtColors.navyPrimary,
        border: Border(right: BorderSide(color: GovtColors.navyBorder)),
      ),
      child: Column(
        children: [
          // Logo & Emblem Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: GovtColors.navyBorder)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: GovtColors.brand,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6)],
                  ),
                  child: const Center(
                    child: Icon(Icons.shield_rounded, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ANIMAL HEALTH',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'AHS Surveillance Grid',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: GovtColors.brandLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items (13 Sections)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: _navItems.length,
              itemBuilder: (context, i) {
                final item = _navItems[i];
                final isSelected = _selectedIndex == i;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => setState(() => _selectedIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? GovtColors.brand : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              size: 16,
                              color: isSelected ? Colors.white : const Color(0xFF90A4AE),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : const Color(0xFFCFD8DC),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Administration Profile
          // Bottom Administration Settings & Profile
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: const BoxDecoration(
              color: GovtColors.navyDark,
              border: Border(top: BorderSide(color: GovtColors.navyBorder)),
            ),
            child: Column(
              children: [
                _sidebarSecondaryItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  isSelected: _selectedIndex == 9,
                  onTap: () => setState(() => _selectedIndex = 9),
                ),
                const SizedBox(height: 2),
                _sidebarSecondaryItem(
                  icon: Icons.account_circle_outlined,
                  label: 'Profile',
                  isSelected: false,
                  onTap: _showProfileDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarSecondaryItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? GovtColors.brand : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF90A4AE)),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFFCFD8DC),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.badge_rounded, color: GovtColors.brand, size: 22),
            SizedBox(width: 8),
            Text('Official Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GovtColors.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dr. Rajesh Kumar, MVSc (Epidemiology)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: GovtColors.textPrimary)),
            const SizedBox(height: 2),
            const Text('District Surveillance Officer (DSO)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GovtColors.brand)),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 8),
            _profileRow('Jurisdiction', 'Erode District, Tamil Nadu'),
            _profileRow('Department', 'Animal Husbandry & Dairying (DAHD)'),
            _profileRow('Cadre ID', 'IN-TN-AHS-0842'),
            _profileRow('Surveillance Clearance', 'National Tier-2 Command'),
            _profileRow('Current Session', 'Secure GovNet SSL Encrypted'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: GovtColors.brand, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text('$label:', style: const TextStyle(fontSize: 11, color: GovtColors.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GovtColors.textPrimary))),
        ],
      ),
    );
  }

  // ─── Top Command Header ──────────────────────────────────────────────────

  Widget _buildTopCommandHeader({required bool isDesktop}) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: GovtColors.border)),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: GovtColors.textPrimary),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),

          // LEFT: Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Animal Health Intelligence',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isDesktop ? 15 : 13,
                    fontWeight: FontWeight.w800,
                    color: GovtColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const Text(
                  'Government Surveillance & Decision Support',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: GovtColors.textSecondary),
                ),
              ],
            ),
          ),

          // CENTER: Global Search Bar
          if (isDesktop)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: Container(
                    height: 38,
                    constraints: const BoxConstraints(maxWidth: 420),
                    decoration: BoxDecoration(
                      color: GovtColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GovtColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 16, color: GovtColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search district, village, disease, outbreak ID...',
                              hintStyle: TextStyle(fontSize: 11, color: GovtColors.textSecondary),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(fontSize: 11, color: GovtColors.textPrimary),
                            onSubmitted: (val) {
                              if (val.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: GovtColors.navyDark,
                                    content: Text('Surveillance Query "$val": 1 active cluster matched.'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // RIGHT: Live Data indicator, Sync info, Notifications, Official Profile
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDesktop) ...[
                _buildLiveIndicator(),
                const SizedBox(width: 10),
                Text(
                  'Last synchronized: ${_formatSyncTime()}',
                  style: const TextStyle(fontSize: 11, color: GovtColors.textSecondary),
                ),
                const SizedBox(width: 10),
              ] else ...[
                _buildLiveIndicator(),
                const SizedBox(width: 4),
              ],

              // Notification icon with badge
              IconButton(
                icon: Badge(
                  label: const Text('6', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                  backgroundColor: GovtColors.riskCritical,
                  child: const Icon(Icons.notifications_outlined, size: 20, color: GovtColors.textPrimary),
                ),
                onPressed: () => setState(() => _showRightPanel = !_showRightPanel),
                tooltip: '6 Critical Alerts',
              ),
              const SizedBox(width: 4),

              // Government Official profile
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _showProfileDialog,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 10 : 4, vertical: 5),
                  decoration: BoxDecoration(
                    color: GovtColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: GovtColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: GovtColors.brand.withValues(alpha: 0.2),
                        child: const Text('DSO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: GovtColors.brandDark)),
                      ),
                      if (isDesktop) ...[
                        const SizedBox(width: 8),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Dr. Rajesh Kumar',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.textPrimary),
                            ),
                            Text(
                              'District Surveillance Officer',
                              style: TextStyle(fontSize: 9, color: GovtColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              if (isDesktop) ...[
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Toggle Command Center Intelligence Panel',
                  child: IconButton(
                    icon: Icon(
                      _showRightPanel ? Icons.view_sidebar_rounded : Icons.view_sidebar_outlined,
                      color: _showRightPanel ? GovtColors.brand : GovtColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _showRightPanel = !_showRightPanel),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        return Tooltip(
          message: 'Real-time telemetry connected. Click to refresh sync.',
          child: InkWell(
            onTap: _syncData,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: GovtColors.riskLow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: GovtColors.riskLow.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: GovtColors.riskLow,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: GovtColors.riskLow.withValues(alpha: 0.6 * _pulseController.value), blurRadius: 4, spreadRadius: 1),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('● LIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: GovtColors.riskLow)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatSyncTime() {
    final diff = DateTime.now().difference(_lastSync);
    if (diff.inSeconds < 60) return 'just now';
    return '${diff.inMinutes}m ago';
  }

  // ─── Right Intelligence Panel (Section 27: Command Center Right Drawer) ─

  Widget _buildRightIntelligencePanel() {
    return Container(
      width: 290,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: GovtColors.border)),
      ),
      child: Column(
        children: [
          // Panel Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFBFB),
              border: Border(bottom: BorderSide(color: GovtColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.dashboard_customize_rounded, size: 14, color: GovtColors.brand),
                    SizedBox(width: 6),
                    Text('SITUATION COMMAND', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
                  ],
                ),
                InkWell(
                  onTap: () => setState(() => _showRightPanel = false),
                  child: const Icon(Icons.close, size: 14, color: GovtColors.textSecondary),
                ),
              ],
            ),
          ),

          // Scrollable Intelligence Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // 1. LIVE ALERTS
                const Text('LIVE ALERTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textSecondary)),
                const SizedBox(height: 6),
                ..._alerts.take(3).map((a) {
                  final color = a.category == 'CRITICAL'
                      ? GovtColors.riskCritical
                      : (a.category == 'HIGH' ? GovtColors.riskHigh : GovtColors.warning);
                  final prefix = a.category == 'CRITICAL' ? '🔴' : (a.category == 'HIGH' ? '🟠' : '🟡');
                  return _rightAlertItem('$prefix ${a.id}', a.title, '${a.location} • ${a.timeAgo}', color);
                }),
                const Divider(height: 20),

                // 2. PRIORITY ACTIONS ("WHAT SHOULD I DO NOW?")
                const Text('PRIORITY ACTIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textSecondary)),
                const SizedBox(height: 6),
                _rightActionItem('1. 🔴 Investigate Erode cluster', 'Deploy Team 04 with viral kits'),
                _rightActionItem('2. 🟠 Review vaccination gap', 'Seal Perundurai 61% deficit'),
                _rightActionItem('3. 🟠 12 lab samples pending', 'Expedite overdue HS smears'),
                _rightActionItem('4. 🟡 Monitor 4 river hotspots', 'Flood stagnation vector check'),
                const Divider(height: 20),

                // 3. EARLY WARNINGS
                const Text('EARLY WARNINGS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textSecondary)),
                const SizedBox(height: 6),
                ..._warnings.take(2).map((w) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: GovtColors.warningLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: GovtColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${w.id} • ${w.confidence} Confidence',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GovtColors.warning)),
                      const SizedBox(height: 2),
                      Text(w.headline, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(w.recommendedAction, style: const TextStyle(fontSize: 9, color: GovtColors.textSecondary)),
                    ],
                  ),
                )),
                const Divider(height: 20),

                // 4. TEAM STATUS
                const Text('FIELD TEAM STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textSecondary)),
                const SizedBox(height: 6),
                _rightTeamStatus('Team 04 (Dr. Rajesh)', 'ACTIVE', 'Perundurai OB-024', GovtColors.riskLow),
                _rightTeamStatus('Team 02 (Dr. Priya)', 'EN ROUTE', 'Bhavani Sector C', GovtColors.warning),
                _rightTeamStatus('Team 08 (Dr. Anand)', 'AVAILABLE', 'District HQ Standby', GovtColors.brand),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rightAlertItem(String code, String title, String sub, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withValues(alpha: 0.25))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(code, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.textPrimary)),
            Text(sub, style: const TextStyle(fontSize: 9, color: GovtColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _rightActionItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: GovtColors.surfaceSubtle, borderRadius: BorderRadius.circular(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.textPrimary)),
            Text(desc, style: const TextStyle(fontSize: 9, color: GovtColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _rightTeamStatus(String team, String status, String task, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(team, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                Text(task, style: const TextStyle(fontSize: 9, color: GovtColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
            child: Text(status, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: color)),
          ),
        ],
      ),
    );
  }

  // ─── Drawer Content (Mobile) ────────────────────────────────────────────

  Widget _buildDrawerContent() {
    return Container(
      color: GovtColors.navyPrimary,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 44, 16, 16),
            color: GovtColors.navyDark,
            child: const Row(
              children: [
                Icon(Icons.shield_rounded, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ANIMAL HEALTH INTELLIGENCE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                    Text('National Surveillance Grid', style: TextStyle(color: GovtColors.brandLight, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, i) {
                final item = _navItems[i];
                final isSelected = _selectedIndex == i;
                return ListTile(
                  dense: true,
                  leading: Icon(isSelected ? item.selectedIcon : item.icon, color: isSelected ? Colors.white : const Color(0xFF90A4AE)),
                  title: Text(item.label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFFCFD8DC), fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal)),
                  selected: isSelected,
                  selectedTileColor: GovtColors.brand,
                  onTap: () {
                    setState(() => _selectedIndex = i);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Mobile Bottom Nav ──────────────────────────────────────────────────

  Widget _buildMobileBottomNav() {
    final primary = _navItems.sublist(0, 4);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: GovtColors.border)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              ...primary.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final isSelected = _selectedIndex == i;
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedIndex = i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isSelected ? item.selectedIcon : item.icon, size: 20, color: isSelected ? GovtColors.brand : GovtColors.textSecondary),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isSelected ? GovtColors.brand : GovtColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              Expanded(
                child: InkWell(
                  onTap: () => _showMoreSheet(context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.grid_view_rounded, size: 20, color: _selectedIndex >= 4 ? GovtColors.brand : GovtColors.textSecondary),
                      const SizedBox(height: 2),
                      Text(
                        (_selectedIndex >= 4 && _selectedIndex < _navItems.length) ? _navItems[_selectedIndex].label : 'More',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: _selectedIndex >= 4 ? FontWeight.w800 : FontWeight.w500,
                          color: _selectedIndex >= 4 ? GovtColors.brand : GovtColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: GovtColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 12),
            const Text('National Surveillance Sections', style: GovtTypography.sectionTitle),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.25,
              physics: const NeverScrollableScrollPhysics(),
              children: _navItems.sublist(4).asMap().entries.map((entry) {
                final i = entry.key + 4;
                final item = entry.value;
                final isSelected = _selectedIndex == i;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedIndex = i);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? GovtColors.brandLight : GovtColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? GovtColors.brand : GovtColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.selectedIcon, size: 22, color: isSelected ? GovtColors.brand : GovtColors.textSecondary),
                        const SizedBox(height: 4),
                        Text(item.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? GovtColors.brand : GovtColors.textPrimary), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavSectionItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavSectionItem(this.icon, this.selectedIcon, this.label);
}
