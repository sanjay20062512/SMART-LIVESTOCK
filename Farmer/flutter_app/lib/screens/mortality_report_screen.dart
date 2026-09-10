// Mortality Report Screen — Simplified step-by-step reporting for livestock farmers.
// Automatically creates a critical case, mortality record, and high-priority alert.

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../services/localization_service.dart';
import '../models/animal.dart';
import '../models/mortality_report.dart';

class MortalityReportScreen extends StatefulWidget {
  final FarmerDataService dataService;

  const MortalityReportScreen({super.key, required this.dataService});

  @override
  State<MortalityReportScreen> createState() => _MortalityReportScreenState();
}

class _MortalityReportScreenState extends State<MortalityReportScreen> {
  final PageController _pageController = PageController();
  int _step = 0;

  // Step 1: Species
  AnimalSpecies _species = AnimalSpecies.cow;

  // Step 2: Count
  String _diedCount = '1';

  // Step 3: When
  String _when = 'Today';

  // Step 4: Symptoms before death
  final Set<String> _symptomsBeforeDeath = {};

  // Step 5: Evidence
  bool _hasPhoto = false;
  bool _hasVoice = false;
  final _descCtrl = TextEditingController();

  // Step 6: Location
  final String _location = '📍 Use Farm Location';

  // Result
  bool _submitted = false;
  String? _reportId;

  final List<String> _countOptions = ['1', '2–5', '6–10', 'More than 10'];
  final List<String> _whenOptions = ['Today', 'Yesterday', '2–3 days ago', 'Not sure'];

  final List<Map<String, dynamic>> _symptomOptions = [
    {'name': 'Fever', 'icon': Icons.thermostat_rounded, 'color': Colors.red},
    {'name': 'Not eating', 'icon': Icons.no_food_rounded, 'color': Colors.orange},
    {'name': 'Breathing problem', 'icon': Icons.air_rounded, 'color': Colors.deepOrange},
    {'name': 'Weakness / Collapse', 'icon': Icons.battery_alert_rounded, 'color': Colors.purple},
    {'name': 'Diarrhea', 'icon': Icons.water_drop_rounded, 'color': Colors.brown},
    {'name': 'Excessive salivation', 'icon': Icons.opacity_rounded, 'color': Colors.teal},
    {'name': 'Bleeding', 'icon': Icons.bloodtype_rounded, 'color': Colors.red.shade900},
    {'name': 'Skin lesions / Blisters', 'icon': Icons.healing_rounded, 'color': Colors.redAccent},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 5) {
      setState(() => _step++);
      _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _submit() {
    final count = int.tryParse(_diedCount.replaceAll(RegExp(r'[^\d]'), '')) ?? 1;
    final reportId = widget.dataService.generateMortalityId();

    final locationStr = _location == '📍 Use Farm Location'
        ? '${widget.dataService.profile.farmName ?? "Farm"}, ${widget.dataService.profile.village}'
        : 'Manual Farm Location';

    final report = MortalityReport(
      id: reportId,
      animalTag: '${_species.emoji} ${_species.displayName}',
      date: DateTime.now(),
      time: '${DateTime.now().hour.toString().padLeft(2, "0")}:${DateTime.now().minute.toString().padLeft(2, "0")}',
      location: locationStr,
      symptomsBeforeDeath: _symptomsBeforeDeath.toList(),
      numberAffected: count,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    );

    widget.dataService.addMortalityReport(report);

    setState(() {
      _submitted = true;
      _reportId = reportId;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _buildConfirmationView();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _back,
        ),
        title: Text(
          context.tr('report_animal_death'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: (_step + 1) / 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              minHeight: 4,
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1AnimalType(),
                _buildStep2Count(),
                _buildStep3When(),
                _buildStep4Symptoms(),
                _buildStep5Evidence(),
                _buildStep6LocationAndSubmit(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 1: Animal Type ─────────────────────────────────────────────────────
  Widget _buildStep1AnimalType() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Step 1 of 6', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(context.tr('what_animal_problem'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: AnimalSpecies.values.map((s) {
              final isSelected = _species == s;
              return Card(
                elevation: isSelected ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: isSelected ? Colors.red : Colors.grey.shade300, width: isSelected ? 2.5 : 1),
                ),
                color: isSelected ? Colors.red.shade50 : Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() => _species = s),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(s.emoji, style: const TextStyle(fontSize: 40)),
                      const SizedBox(height: 6),
                      Text(s.displayName, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.red : Colors.black87)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          _buildContinueButton(),
        ],
      ),
    );
  }

  // ─── Step 2: How many died? ──────────────────────────────────────────────────
  Widget _buildStep2Count() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Step 2 of 6', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(context.tr('how_many_died'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ..._countOptions.map((opt) {
            final isSelected = _diedCount == opt;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: isSelected ? Colors.red : Colors.grey.shade300, width: isSelected ? 2 : 1),
              ),
              color: isSelected ? Colors.red.shade50 : Colors.white,
              child: ListTile(
                title: Text(opt == '1' ? '1 animal' : '$opt animals', style: TextStyle(fontSize: 17, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Colors.red) : null,
                onTap: () => setState(() => _diedCount = opt),
              ),
            );
          }),
          const SizedBox(height: 28),
          _buildContinueButton(),
        ],
      ),
    );
  }

  // ─── Step 3: When? ───────────────────────────────────────────────────────────
  Widget _buildStep3When() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Step 3 of 6', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(context.tr('when_happened'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ..._whenOptions.map((opt) {
            final isSelected = _when == opt;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: isSelected ? Colors.red : Colors.grey.shade300, width: isSelected ? 2 : 1),
              ),
              color: isSelected ? Colors.red.shade50 : Colors.white,
              child: ListTile(
                title: Text(opt, style: TextStyle(fontSize: 17, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Colors.red) : null,
                onTap: () => setState(() => _when = opt),
              ),
            );
          }),
          const SizedBox(height: 28),
          _buildContinueButton(),
        ],
      ),
    );
  }

  // ─── Step 4: Symptoms Before Death ───────────────────────────────────────────
  Widget _buildStep4Symptoms() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Step 4 of 6', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(context.tr('problems_before_death'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: _symptomOptions.map((sym) {
              final name = sym['name'] as String;
              final icon = sym['icon'] as IconData;
              final isSelected = _symptomsBeforeDeath.contains(name);

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isSelected ? Colors.red : Colors.grey.shade300, width: isSelected ? 2 : 1),
                ),
                color: isSelected ? Colors.red.shade50 : Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _symptomsBeforeDeath.remove(name);
                      } else {
                        _symptomsBeforeDeath.add(name);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      children: [
                        Icon(icon, color: isSelected ? Colors.red : Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(child: Text(name, style: TextStyle(fontSize: 12.5, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          _buildContinueButton(),
        ],
      ),
    );
  }

  // ─── Step 5: Evidence ────────────────────────────────────────────────────────
  Widget _buildStep5Evidence() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Step 5 of 6', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(context.tr('show_us_problem'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildEvidenceButton(
                  icon: Icons.camera_alt_rounded,
                  label: _hasPhoto ? '✓ Photo Added' : '📷 Take Photo',
                  color: Colors.blue,
                  isSelected: _hasPhoto,
                  onTap: () => setState(() => _hasPhoto = !_hasPhoto),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEvidenceButton(
                  icon: Icons.mic_rounded,
                  label: _hasVoice ? '✓ Voice Added' : '🎤 Record Voice',
                  color: Colors.orange,
                  isSelected: _hasVoice,
                  onTap: () => setState(() => _hasVoice = !_hasVoice),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: context.tr('write_description'),
              hintText: 'Additional details...',
            ),
          ),
          const SizedBox(height: 28),
          _buildContinueButton(),
        ],
      ),
    );
  }

  // ─── Step 6: Location & Submit ───────────────────────────────────────────────
  Widget _buildStep6LocationAndSubmit() {
    final profile = widget.dataService.profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Step 6 of 6', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(context.tr('where_is_animal'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Colors.red, width: 2)),
            color: Colors.red.shade50,
            child: ListTile(
              leading: const Icon(Icons.location_on_rounded, color: Colors.red),
              title: Text(context.tr('use_farm_location'), style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${profile.farmName ?? "Farm"} · ${profile.village}'),
              trailing: const Icon(Icons.check_circle_rounded, color: Colors.red),
            ),
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.warning_rounded, size: 24),
              label: Text(
                'SUBMIT MORTALITY REPORT',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Confirmation Screen ────────────────────────────────────────────────────
  Widget _buildConfirmationView() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.shade300, width: 2),
                ),
                child: const Icon(Icons.emergency_rounded, size: 64, color: Colors.red),
              ),
              const SizedBox(height: 20),
              Text(
                context.tr('death_reported_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 6),
              Text(
                'Case ID: #$_reportId',
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Text(
                  context.tr('death_reported_msg'),
                  style: const TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.tr('done'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade800,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: _next,
        child: Text(context.tr('continue'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEvidenceButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 2 : 1),
      ),
      color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
