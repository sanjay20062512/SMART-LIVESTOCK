// Veterinary Shell — bottom navigation for the Veterinary module

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../theme/app_theme.dart';
import 'vet_dashboard_screen.dart';
import 'vet_case_queue_screen.dart';
import 'vet_cluster_screen.dart';
import 'vet_vaccination_screen.dart';

class VetShell extends StatefulWidget {
  final FarmerDataService dataService;

  const VetShell({super.key, required this.dataService});

  @override
  State<VetShell> createState() => _VetShellState();
}

class _VetShellState extends State<VetShell> {
  int _selectedIndex = 0;
  bool _refreshing = false;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      VetDashboardScreen(dataService: widget.dataService),
      VetCaseQueueScreen(dataService: widget.dataService),
      VetClusterScreen(dataService: widget.dataService),
      VetVaccinationScreen(dataService: widget.dataService),
    ];
    // Auto-refresh on shell load
    _refresh();
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      await Future.wait([
        widget.dataService.fetchCases(role: 'veterinarian'),
        widget.dataService.fetchAlerts(role: 'veterinarian'),
      ]);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: _refreshing
          ? FloatingActionButton(
              onPressed: null,
              backgroundColor: AppColors.primary,
              child: const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            )
          : FloatingActionButton(
              onPressed: _refresh,
              backgroundColor: AppColors.primary,
              tooltip: 'Refresh cases & alerts',
              child: const Icon(Icons.refresh_rounded, color: Colors.white),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
        elevation: 3,
        shadowColor: AppColors.border,
        surfaceTintColor: Colors.transparent,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.queue_outlined),
            selectedIcon: Icon(Icons.queue_rounded, color: AppColors.primary),
            label: 'Cases',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_amber_outlined),
            selectedIcon: Icon(Icons.warning_amber_rounded, color: AppColors.primary),
            label: 'Clusters',
          ),
          NavigationDestination(
            icon: Icon(Icons.vaccines_outlined),
            selectedIcon: Icon(Icons.vaccines_rounded, color: AppColors.primary),
            label: 'Vaccination',
          ),
        ],
      ),
    );
  }
}
