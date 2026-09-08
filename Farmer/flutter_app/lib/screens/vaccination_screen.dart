// Vaccination Screen

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../models/vaccination_record.dart';
import '../models/animal.dart';

class VaccinationScreen extends StatefulWidget {
  final FarmerDataService dataService;

  const VaccinationScreen({super.key, required this.dataService});

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    widget.dataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    widget.dataService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => setState(() {});

  Color _statusColor(VaccinationStatus s) {
    switch (s) {
      case VaccinationStatus.due:
        return Colors.orange;
      case VaccinationStatus.upcoming:
        return Colors.blue;
      case VaccinationStatus.completed:
        return Colors.green;
      case VaccinationStatus.overdue:
        return Colors.red;
    }
  }

  void _showAddVaccinationDialog() {
    final animals = widget.dataService.getAnimals();
    if (animals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add animals first.')),
      );
      return;
    }

    Animal? selectedAnimal;
    final vaccineCtrl = TextEditingController();
    final vetCtrl = TextEditingController();
    VaccinationStatus status = VaccinationStatus.completed;
    DateTime? date = DateTime.now();


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Vaccination Record',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Animal>(
                initialValue: selectedAnimal,
                decoration: InputDecoration(
                  labelText: 'Select Animal *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: animals
                    .map((a) => DropdownMenuItem(
                          value: a,
                          child: Text(
                              '${a.species.displayName} — ${a.earTag}'),
                        ))
                    .toList(),
                onChanged: (a) => setSheetState(() => selectedAnimal = a),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: vaccineCtrl,
                decoration: InputDecoration(
                  labelText: 'Vaccine Name *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: vetCtrl,
                decoration: InputDecoration(
                  labelText: 'Veterinarian (optional)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<VaccinationStatus>(
                initialValue: status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: VaccinationStatus.values
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.displayName),
                        ))
                    .toList(),
                onChanged: (s) => setSheetState(() => status = s!),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedAnimal == null ||
                        vaccineCtrl.text.trim().isEmpty) {
                      return;
                    }
                    final record = VaccinationRecord(
                      id: widget.dataService.generateVaccinationId(),
                      animalId: selectedAnimal!.id,
                      animalTag: selectedAnimal!.earTag,
                      vaccineName: vaccineCtrl.text.trim(),
                      date: date,
                      status: status,
                      veterinarian: vetCtrl.text.trim().isEmpty
                          ? null
                          : vetCtrl.text.trim(),
                    );
                    widget.dataService.addVaccination(record);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Record'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vaccinations = widget.dataService.getVaccinations();
    final upcoming = vaccinations
        .where((v) =>
            v.status == VaccinationStatus.due ||
            v.status == VaccinationStatus.overdue ||
            v.status == VaccinationStatus.upcoming)
        .toList();
    final completed =
        vaccinations.where((v) => v.status == VaccinationStatus.completed).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vaccination Records',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Upcoming (${upcoming.length})'),
            Tab(text: 'History (${completed.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVaccinationDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Upcoming
          upcoming.isEmpty
              ? _emptyState('No upcoming vaccinations.')
              : _buildList(upcoming),

          // History
          completed.isEmpty
              ? _emptyState('No vaccination history.')
              : _buildList(completed),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.vaccines, size: 56, color: Colors.grey),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildList(List<VaccinationRecord> records) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: records.length,
      itemBuilder: (ctx, i) {
        final v = records[i];
        final color = _statusColor(v.status);
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(Icons.vaccines, color: color),
            ),
            title: Text(
              v.vaccineName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Animal: ${v.animalTag}'),
                if (v.date != null)
                  Text(
                      'Date: ${v.date!.day}/${v.date!.month}/${v.date!.year}'),
                if (v.veterinarian != null) Text('Vet: ${v.veterinarian}'),
                if (v.isVerified)
                  const Text('✓ Verified',
                      style: TextStyle(color: Colors.green)),
              ],
            ),
            trailing: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                v.status.displayName,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }
}
