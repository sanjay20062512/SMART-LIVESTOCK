// Smart Livestock — Government Shell (UPDATED)
// Fully connected across Farmer, Vet, and Government modules via FarmerDataService.
// Navigation: Dashboard · Disease Map · Campaigns · Outbreak · Alerts · Reports · Response

import 'package:flutter/material.dart';
import 'govt_theme.dart';
import 'govt_new_dashboard.dart';
import 'govt_new_disease_map.dart';
import 'govt_new_campaigns.dart';
import 'govt_new_outbreak.dart';
import 'govt_new_alerts.dart';
import 'govt_new_reports.dart';
import 'govt_new_response.dart';
import '../../services/farmer_data_service.dart';
import '../../widgets/brand_logo.dart';

class GovtShell extends StatefulWidget {
  final FarmerDataService dataService;
  final VoidCallback? onSwitchRole;

  const GovtShell({
    super.key,
    required this.dataService,
    this.onSwitchRole,
  });

  @override
  State<GovtShell> createState() => _GovtShellState();
}

class _GovtShellState extends State<GovtShell> {
  int _selectedIndex = 0;

  // All 7 tabs matching the React Government module's navigation
  static const List<_NavItem> _navItems = [
    _NavItem('Dashboard',   Icons.dashboard_outlined,           Icons.dashboard_rounded),
    _NavItem('Disease Map', Icons.map_outlined,                  Icons.map_rounded),
    _NavItem('Campaigns',   Icons.vaccines_outlined,             Icons.vaccines_rounded),
    _NavItem('Outbreak',    Icons.monitor_heart_outlined,        Icons.monitor_heart_rounded),
    _NavItem('Alerts',      Icons.notifications_none_rounded,    Icons.notifications_active_rounded),
    _NavItem('Reports',     Icons.assessment_outlined,           Icons.assessment_rounded),
    _NavItem('Response',    Icons.shield_outlined,               Icons.shield_rounded),
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      GovtNewDashboard(
        onNavigateTab: (i) => setState(() => _selectedIndex = i),
        dataService: widget.dataService,
      ),
      GovtNewDiseaseMap(
        onNavigateTab: (i) => setState(() => _selectedIndex = i),
        dataService: widget.dataService,
      ),
      GovtNewCampaigns(dataService: widget.dataService),
      GovtNewOutbreakMonitoring(dataService: widget.dataService),
      GovtNewAlerts(
        dataService: widget.dataService,
        onNavigateTab: (i) => setState(() => _selectedIndex = i),
      ),
      GovtNewReports(dataService: widget.dataService),
      GovtNewResponseTasks(dataService: widget.dataService),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.dataService,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;

            return Scaffold(
              backgroundColor: GovtColors.pageBackground,
              appBar: _buildTopHeader(),
              body: isDesktop
                  ? Row(
                      children: [
                        _buildDesktopSidebar(),
                        Expanded(
                          child: IndexedStack(
                            index: _selectedIndex,
                            children: _pages,
                          ),
                        ),
                      ],
                    )
                  : IndexedStack(
                      index: _selectedIndex,
                      children: _pages,
                    ),
              bottomNavigationBar: isDesktop ? null : _buildMobileBottomNav(),
            );
          },
        );
      },
    );
  }

  // ─── Top Command Header ──────────────────────────────────────────────────────

  PreferredSizeWidget _buildTopHeader() {
    final unreadAlerts = widget.dataService.unreadGovtAlertCount;

    return AppBar(
      backgroundColor: GovtColors.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          const BrandLogo.small(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Government Health Command Center',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: GovtColors.textPrimary, letterSpacing: -0.2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Maharashtra Animal Health Surveillance',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: GovtColors.brandDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Live status indicator
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: GovtColors.riskLowLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: GovtColors.riskLow, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              const Text(
                'Live',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: GovtColors.riskLow),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),

        // Alerts bell — taps to alerts tab
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, size: 20, color: GovtColors.textPrimary),
              tooltip: 'Surveillance Alerts',
              onPressed: () => setState(() => _selectedIndex = 4),
            ),
            if (unreadAlerts > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: GovtColors.critical,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    unreadAlerts > 99 ? '99+' : '$unreadAlerts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),

        // Officer profile chip
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dr. K. Murugan • District Animal Husbandry Officer (DAHO)'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: GovtColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GovtColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: GovtColors.brandLight,
                    child: Text('KM', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: GovtColors.brandDark)),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'DAHO Pune',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Switch Role icon button (quick exit)
        IconButton(
          icon: const Icon(Icons.swap_horiz_rounded, color: GovtColors.textPrimary, size: 20),
          tooltip: 'Switch Role',
          onPressed: () {
            if (widget.onSwitchRole != null) {
              widget.onSwitchRole!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ─── Mobile Bottom Navigation Bar (5 Primary Items) ─────────────────────────

  Widget _buildMobileBottomNav() {
    // 5 primary items for mobile: Dashboard(0), Disease Map(1), Campaigns(2), Outbreak(3), Alerts(4)
    final mobileIdx = _selectedIndex > 4 ? 0 : _selectedIndex;
    final unreadAlerts = widget.dataService.unreadGovtAlertCount;

    return Container(
      decoration: const BoxDecoration(
        color: GovtColors.surface,
        border: Border(top: BorderSide(color: GovtColors.border, width: 0.8)),
      ),
      child: NavigationBar(
        selectedIndex: mobileIdx,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: GovtColors.surface,
        indicatorColor: GovtColors.brandLight,
        elevation: 0,
        height: 62,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, size: 20, color: GovtColors.textMuted),
            selectedIcon: Icon(Icons.dashboard_rounded, size: 20, color: GovtColors.brand),
            label: 'Dashboard',
          ),
          const NavigationDestination(
            icon: Icon(Icons.map_outlined, size: 20, color: GovtColors.textMuted),
            selectedIcon: Icon(Icons.map_rounded, size: 20, color: GovtColors.brand),
            label: 'Disease Map',
          ),
          const NavigationDestination(
            icon: Icon(Icons.vaccines_outlined, size: 20, color: GovtColors.textMuted),
            selectedIcon: Icon(Icons.vaccines_rounded, size: 20, color: GovtColors.brand),
            label: 'Campaigns',
          ),
          const NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined, size: 20, color: GovtColors.textMuted),
            selectedIcon: Icon(Icons.monitor_heart_rounded, size: 20, color: GovtColors.brand),
            label: 'Outbreak',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unreadAlerts > 0,
              label: Text('$unreadAlerts', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
              backgroundColor: GovtColors.critical,
              child: const Icon(Icons.notifications_none_rounded, size: 20, color: GovtColors.textMuted),
            ),
            selectedIcon: Badge(
              isLabelVisible: unreadAlerts > 0,
              label: Text('$unreadAlerts', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
              backgroundColor: GovtColors.critical,
              child: const Icon(Icons.notifications_active_rounded, size: 20, color: GovtColors.brand),
            ),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }

  // ─── Desktop Sidebar (Light Theme, Full 7 Tabs) ──────────────────────────────

  Widget _buildDesktopSidebar() {
    final unreadAlerts = widget.dataService.unreadGovtAlertCount;

    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: GovtColors.surface,
        border: Border(right: BorderSide(color: GovtColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'NAVIGATION',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: GovtColors.textMuted),
            ),
          ),
          const SizedBox(height: 8),
          ..._navItems.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isSel = _selectedIndex == idx;
            final isAlertTab = idx == 4;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  dense: true,
                  selected: isSel,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  selectedTileColor: GovtColors.brandLight,
                  leading: Icon(
                    isSel ? item.selectedIcon : item.icon,
                    size: 18,
                    color: isSel ? GovtColors.brand : GovtColors.textMuted,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? GovtColors.brandDark : GovtColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isAlertTab && unreadAlerts > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: GovtColors.critical,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unreadAlerts',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () => setState(() => _selectedIndex = idx),
                ),
              ),
            );
          }),

          const Spacer(),

          // Switch Role tile in sidebar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                dense: true,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                leading: const Icon(Icons.swap_horiz_rounded, size: 18, color: GovtColors.brandDark),
                title: const Text('Switch Role', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GovtColors.brandDark)),
                onTap: () {
                  if (widget.onSwitchRole != null) {
                    widget.onSwitchRole!();
                  } else if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Bottom section: State info
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE4EAF0)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Maharashtra', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF18232B))),
                SizedBox(height: 2),
                Text('36 Districts  •  Q3 2026', style: TextStyle(fontSize: 9.5, color: Color(0xFF667482))),
                SizedBox(height: 6),
                Row(
                  children: [
                    _StatusDot(color: Color(0xFFC94343)),
                    SizedBox(width: 4),
                    Text('Surveillance Live Link Active', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFFC94343))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Helper Classes ────────────────────────────────────────────────────────────

class _NavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  const _NavItem(this.label, this.icon, this.selectedIcon);
}

class _StatusDot extends StatelessWidget {
  final Color color;
  const _StatusDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
