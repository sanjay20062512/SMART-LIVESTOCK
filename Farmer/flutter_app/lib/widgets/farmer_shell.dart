import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../screens/farmer_dashboard.dart';
import '../screens/my_reports_screen.dart';
import '../screens/report_hub_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/profile_screen.dart';
import '../theme/app_theme.dart';

class FarmerShell extends StatefulWidget {
  final FarmerDataService dataService;
  final int initialIndex;

  const FarmerShell({
    super.key,
    required this.dataService,
    this.initialIndex = 0,
  });

  @override
  State<FarmerShell> createState() => _FarmerShellState();
}

class _FarmerShellState extends State<FarmerShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    widget.dataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    widget.dataService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => setState(() {});

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final ds = widget.dataService;
    final unread = ds.unreadAlertCount;

    final List<Widget> tabs = [
      FarmerDashboard(
        dataService: ds,
        onNavigateToTab: _navigateToTab,
      ),
      MyReportsScreen(dataService: ds),
      ReportHubScreen(dataService: ds),
      AlertsScreen(dataService: ds),
      ProfileScreen(dataService: ds),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryLight,
          elevation: 3,
          shadowColor: AppColors.border,
          surfaceTintColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.folder_shared_outlined),
              selectedIcon: Icon(Icons.folder_shared_rounded, color: AppColors.primary),
              label: 'My Cases',
            ),
            const NavigationDestination(
              icon: Icon(Icons.add_circle_outline_rounded),
              selectedIcon: Icon(Icons.add_circle_rounded, color: AppColors.primary),
              label: 'Report',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: unread > 0,
                label: Text('$unread'),
                backgroundColor: AppColors.error,
                child: const Icon(Icons.notifications_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: unread > 0,
                label: Text('$unread'),
                backgroundColor: AppColors.error,
                child: const Icon(Icons.notifications_rounded, color: AppColors.primary),
              ),
              label: 'Alerts',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
    );
  }
}
