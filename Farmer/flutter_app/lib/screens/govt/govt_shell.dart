// Smart Livestock — Government Shell
// Streamlined 4-tab light navigation matching Farmer & Veterinary design system.

import 'package:flutter/material.dart';
import 'govt_theme.dart';
import 'govt_dashboard_screen.dart';
import 'govt_disease_map_screen.dart';
import 'govt_alerts_screen.dart';
import 'govt_reports_screen.dart';
import '../../services/farmer_data_service.dart';

class GovtShell extends StatefulWidget {
  final FarmerDataService dataService;

  const GovtShell({
    super.key,
    required this.dataService,
  });

  @override
  State<GovtShell> createState() => _GovtShellState();
}

class _GovtShellState extends State<GovtShell> {
  int _selectedIndex = 0;
  final bool _isConnected = true;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      GovtDashboardScreen(
        dataService: widget.dataService,
        onNavigateTab: (index) => setState(() => _selectedIndex = index),
      ),
      GovtDiseaseMapScreen(dataService: widget.dataService),
      GovtAlertsScreen(dataService: widget.dataService),
      GovtReportsScreen(dataService: widget.dataService),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
  }

  // ─── Top Command Header ─────────────────────────────────────────────────────

  PreferredSizeWidget _buildTopHeader() {
    return AppBar(
      backgroundColor: GovtColors.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: GovtColors.brandLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.account_balance_rounded, size: 18, color: GovtColors.brandDark),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Government Animal Health',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: GovtColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Maharashtra Surveillance',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: GovtColors.brandDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Small Connection Indicator: ● Connected
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _isConnected ? GovtColors.riskLowLight : GovtColors.warningLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _isConnected ? GovtColors.riskLow : GovtColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _isConnected ? 'Connected' : 'Sync pending',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: _isConnected ? GovtColors.riskLow : GovtColors.warning,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Notification Icon
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, size: 20, color: GovtColors.textPrimary),
              onPressed: () => setState(() => _selectedIndex = 2), // Jump to Alerts
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: GovtColors.critical,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),

        // Official Profile Chip
        Padding(
          padding: const EdgeInsets.only(right: 12),
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
                    'DAHO',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: GovtColors.border),
      ),
    );
  }

  // ─── Mobile Bottom NavigationBar (4 Clean Tabs) ─────────────────────────────

  Widget _buildMobileBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: GovtColors.surface,
        border: Border(top: BorderSide(color: GovtColors.border)),
      ),
      child: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: GovtColors.surface,
        indicatorColor: GovtColors.brandLight,
        elevation: 0,
        height: 62,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, size: 20, color: GovtColors.textMuted),
            selectedIcon: Icon(Icons.dashboard_rounded, size: 20, color: GovtColors.brand),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined, size: 20, color: GovtColors.textMuted),
            selectedIcon: Icon(Icons.map_rounded, size: 20, color: GovtColors.brand),
            label: 'Disease Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded, size: 20, color: GovtColors.textMuted),
            selectedIcon: Icon(Icons.notifications_active_rounded, size: 20, color: GovtColors.brand),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined, size: 20, color: GovtColors.textMuted),
            selectedIcon: Icon(Icons.assessment_rounded, size: 20, color: GovtColors.brand),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  // ─── Desktop Sidebar (Light Theme) ──────────────────────────────────────────

  Widget _buildDesktopSidebar() {
    final navItems = [
      {'title': 'Dashboard', 'icon': Icons.dashboard_rounded},
      {'title': 'Disease Map', 'icon': Icons.map_rounded},
      {'title': 'Alerts', 'icon': Icons.notifications_active_rounded},
      {'title': 'Reports', 'icon': Icons.assessment_rounded},
    ];

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
          const SizedBox(height: 10),
          ...navItems.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isSel = _selectedIndex == idx;

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
                    item['icon'] as IconData,
                    size: 18,
                    color: isSel ? GovtColors.brand : GovtColors.textMuted,
                  ),
                  title: Text(
                    item['title'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel ? GovtColors.brandDark : GovtColors.textPrimary,
                    ),
                  ),
                  onTap: () => setState(() => _selectedIndex = idx),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
