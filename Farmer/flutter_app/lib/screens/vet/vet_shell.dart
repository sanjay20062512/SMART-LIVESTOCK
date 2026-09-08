// Veterinary Shell — bottom navigation for the Veterinary module

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
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
            icon: Icon(Icons.queue_outlined),
            selectedIcon: Icon(Icons.queue),
            label: 'Cases',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_amber_outlined),
            selectedIcon: Icon(Icons.warning_amber),
            label: 'Clusters',
          ),
          NavigationDestination(
            icon: Icon(Icons.vaccines_outlined),
            selectedIcon: Icon(Icons.vaccines),
            label: 'Vaccination',
          ),
        ],
      ),
    );
  }
}
