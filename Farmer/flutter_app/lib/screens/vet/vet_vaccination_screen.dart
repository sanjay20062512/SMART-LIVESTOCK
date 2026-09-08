// Veterinary Vaccination Screen — view and record vaccinations

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../models/vaccination_record.dart';

class VetVaccinationScreen extends StatelessWidget {
  final FarmerDataService dataService;
  const VetVaccinationScreen({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        final vaccinations = dataService.getVaccinations();
        final due = vaccinations.where((v) =>
            v.status == VaccinationStatus.due ||
            v.status == VaccinationStatus.overdue).toList();
        final upcoming = vaccinations.where((v) => v.status == VaccinationStatus.upcoming).toList();
        final completed = vaccinations.where((v) => v.status == VaccinationStatus.completed).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF0F4FF),
          appBar: AppBar(
            title: const Text('Vaccination', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats
              Row(
                children: [
                  _statChip('Due / Overdue', due.length.toString(), Colors.red),
                  const SizedBox(width: 10),
                  _statChip('Upcoming', upcoming.length.toString(), Colors.orange),
                  const SizedBox(width: 10),
                  _statChip('Completed', completed.length.toString(), Colors.green),
                ],
              ),
              const SizedBox(height: 20),

              if (due.isNotEmpty) ...[
                _sectionHeader('⚠️ Due / Overdue', Colors.red),
                ...due.map((v) => _vaccinationCard(v)),
                const SizedBox(height: 12),
              ],

              if (upcoming.isNotEmpty) ...[
                _sectionHeader('📅 Upcoming', Colors.orange),
                ...upcoming.map((v) => _vaccinationCard(v)),
                const SizedBox(height: 12),
              ],

              if (completed.isNotEmpty) ...[
                _sectionHeader('✅ Completed', Colors.green),
                ...completed.map((v) => _vaccinationCard(v)),
              ],

              if (vaccinations.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text('No vaccination records.',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ),
                ),

              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(width: 4, height: 18,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
        ],
      ),
    );
  }

  Widget _vaccinationCard(VaccinationRecord v) {
    final statusColor = switch (v.status) {
      VaccinationStatus.overdue => Colors.red,
      VaccinationStatus.due => Colors.orange,
      VaccinationStatus.upcoming => Colors.blue,
      VaccinationStatus.completed => Colors.green,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 5)],
      ),
      child: Row(
        children: [
          const Icon(Icons.vaccines, color: Color(0xFF2E7D32), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v.vaccineName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Animal: ${v.animalTag}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                if (v.nextDueDate != null)
                  Text(
                    'Due: ${v.nextDueDate!.day}/${v.nextDueDate!.month}/${v.nextDueDate!.year}',
                    style: TextStyle(
                      color: v.status == VaccinationStatus.overdue ? Colors.red : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                if (v.veterinarian != null)
                  Text('Vet: ${v.veterinarian}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              v.status.name.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
