// Government Module Shell

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import 'govt_dashboard_screen.dart';
import 'govt_cluster_screen.dart';
import 'govt_advisory_screen.dart';
import 'govt_surveillance_screen.dart';

class GovtShell extends StatefulWidget {
  final FarmerDataService dataService;
  const GovtShell({super.key, required this.dataService});

  @override
  State<GovtShell> createState() => _GovtShellState();
}

class _GovtShellState extends State<GovtShell> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      GovtDashboardScreen(dataService: widget.dataService),
      GovtSurveillanceScreen(dataService: widget.dataService),
      GovtClusterScreen(dataService: widget.dataService),
      GovtAdvisoryScreen(dataService: widget.dataService),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Surveillance',
          ),
          NavigationDestination(
            icon: Icon(Icons.hub_outlined),
            selectedIcon: Icon(Icons.hub),
            label: 'Clusters',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: 'Advisories',
          ),
        ],
      ),
    );
  }
}
