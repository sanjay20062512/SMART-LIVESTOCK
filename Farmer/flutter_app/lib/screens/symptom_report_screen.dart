// Report Animal Problem — Step-by-Step Wizard for Livestock Farmers.
// Prioritizes voice, icons, large buttons, simple words, dropdowns, and minimum typing.

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../services/localization_service.dart';
import '../services/triage_service.dart';
import '../models/animal.dart';
import '../models/health_report.dart';
import 'vet_request_screen.dart';
import 'assessment_result_screen.dart';

class SymptomReportScreen extends StatefulWidget {
  final FarmerDataService dataService;
  final String? preselectedAnimalId;

  const SymptomReportScreen({
    super.key,
    required this.dataService,
    this.preselectedAnimalId,
  });

  @override
  State<SymptomReportScreen> createState() => _SymptomReportScreenState();
}

class _SymptomReportScreenState extends State<SymptomReportScreen> {
  final PageController _pageController = PageController();
  int _step = 0;

  // Step 1: Species & Selected Animal
  AnimalSpecies _selectedSpecies = AnimalSpecies.cow;
  Animal? _existingAnimal;

  // Step 2: Animal Details
  final _earTagCtrl = TextEditingController();
  String _selectedBreed = 'Jersey';
  AnimalGender _selectedGender = AnimalGender.female;
  String _selectedAge = '2–5 years';

  // Step 3: Symptoms (Multi-select)
  final Set<String> _selectedSymptoms = {};

  // Step 4: Duration (Since when)
  String _duration = '2–3 days';

  // Step 5: Eating & Drinking
  String _eatingStatus = 'Less than usual';
  String _drinkingStatus = 'Yes';

  // Step 6: How many animals affected
  String _affectedCount = '1';

  // Step 7: Pregnancy & Lactation (conditional)
  String _pregnantStatus = 'No';
  String _lactatingStatus = 'Yes';

  // Step 8: Evidence & Voice
  bool _isRecordingVoice = false;
  bool _hasVoiceRecorded = false;
  bool _isPlayingVoice = false;
  bool _hasPhotoAdded = false;
  bool _hasVideoAdded = false;
  final _descCtrl = TextEditingController();

  // Step 9: Location
  String _locationMode = '📍 Use Farm Location';
  final _manualLocationCtrl = TextEditingController();

  // Step 11: Result
  TriageResult? _triageResult;
  String? _submittedReportId;
  bool _isSpeakingAdvice = false;

  final List<Map<String, dynamic>> _symptomList = [
    {'label': 'sym_fever', 'text': 'Fever', 'icon': Icons.thermostat_rounded, 'color': Colors.red},
    {'label': 'sym_not_eating', 'text': 'Not eating', 'icon': Icons.no_food_rounded, 'color': Colors.orange},
    {'label': 'sym_breathing', 'text': 'Breathing problem', 'icon': Icons.air_rounded, 'color': Colors.deepOrange},
    {'label': 'sym_walking', 'text': 'Difficulty walking', 'icon': Icons.directions_walk_rounded, 'color': Colors.brown},
    {'label': 'sym_diarrhea', 'text': 'Diarrhea', 'icon': Icons.water_drop_rounded, 'color': Colors.amber.shade900},
    {'label': 'sym_salivation', 'text': 'Excessive salivation', 'icon': Icons.opacity_rounded, 'color': Colors.teal},
    {'label': 'sym_weakness', 'text': 'Weakness', 'icon': Icons.battery_alert_rounded, 'color': Colors.purple},
    {'label': 'sym_skin_lesions', 'text': 'Skin lesions', 'icon': Icons.healing_rounded, 'color': Colors.red.shade700},
    {'label': 'sym_vomiting', 'text': 'Vomiting', 'icon': Icons.sick_rounded, 'color': Colors.deepOrange.shade800},
    {'label': 'sym_nasal_discharge', 'text': 'Nasal discharge', 'icon': Icons.cleaning_services_rounded, 'color': Colors.blueGrey},
    {'label': 'sym_eye_problem', 'text': 'Eye problem', 'icon': Icons.visibility_off_rounded, 'color': Colors.indigo},
    {'label': 'sym_bleeding', 'text': 'Bleeding', 'icon': Icons.bloodtype_rounded, 'color': Colors.red.shade900},
    {'label': 'sym_milk_reduced', 'text': 'Milk production reduced', 'icon': Icons.water_damage_rounded, 'color': Colors.blue},
    {'label': 'sym_pregnancy_problem', 'text': 'Pregnancy/birth problem', 'icon': Icons.child_care_rounded, 'color': Colors.pink},
    {'label': 'sym_other', 'text': 'Other', 'icon': Icons.more_horiz_rounded, 'color': Colors.grey},
  ];

  final List<String> _durationOptions = [
    'Today',
    'Yesterday',
    '2–3 days',
    '4–7 days',
    'More than a week',
    'Not sure',
  ];

  final List<String> _eatingOptions = [
    'Yes',
    'Less than usual',
    'No',
    'Not sure',
  ];

  final List<String> _affectedOptions = [
    '1',
    '2–5',
    '6–10',
    'More than 10',
    'Not sure',
  ];

  final List<String> _ageOptions = [
    'Below 1 year',
    '1–2 years',
    '2–5 years',
    '5–10 years',
    'Above 10 years',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.preselectedAnimalId != null) {
      final a = widget.dataService.getAnimalById(widget.preselectedAnimalId!);
      if (a != null) {
        _existingAnimal = a;
        _selectedSpecies = a.species;
        _selectedBreed = a.breed;
        _selectedGender = a.gender;
        _selectedAge = a.age;
        _earTagCtrl.text = a.earTag;
      }
    } else {
      _selectedBreed = _selectedSpecies.predefinedBreeds.first;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _earTagCtrl.dispose();
    _descCtrl.dispose();
    _manualLocationCtrl.dispose();
    super.dispose();
  }

  bool get _isFemaleRuminant {
    return _selectedGender == AnimalGender.female &&
        (_selectedSpecies == AnimalSpecies.cow ||
         _selectedSpecies == AnimalSpecies.buffalo ||
         _selectedSpecies == AnimalSpecies.goat ||
         _selectedSpecies == AnimalSpecies.sheep);
  }

  void _goToStep(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    if (_step == 0) {
      // Step 0: Animal Type
      _goToStep(1);
    } else if (_step == 1) {
      // Step 1: Animal Details
      _goToStep(2);
    } else if (_step == 2) {
      // Step 2: Symptoms
      if (_selectedSymptoms.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one problem / symptom.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      _goToStep(3);
    } else if (_step == 3) {
      // Step 3: Duration
      _goToStep(4);
    } else if (_step == 4) {
      // Step 4: Eating & Drinking
      _goToStep(5);
    } else if (_step == 5) {
      // Step 5: Affected Count
      if (_isFemaleRuminant) {
        _goToStep(6);
      } else {
        _goToStep(7);
      }
    } else if (_step == 6) {
      // Step 6: Pregnancy (Female ruminants only)
      _goToStep(7);
    } else if (_step == 7) {
      // Step 7: Evidence
      _goToStep(8);
    } else if (_step == 8) {
      // Step 8: Location
      _goToStep(9);
    } else if (_step == 9) {
      // Step 9: Summary -> Submit
      _submitReport();
    }
  }

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
    } else if (_step == 7 && !_isFemaleRuminant) {
      _goToStep(5);
    } else {
      _goToStep(_step - 1);
    }
  }

  void _simulateVoiceRecording() {
    setState(() => _isRecordingVoice = true);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() {
        _isRecordingVoice = false;
        _hasVoiceRecorded = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Voice note recorded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _simulateVoicePlayback() {
    setState(() => _isPlayingVoice = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isPlayingVoice = false);
    });
  }

  void _simulateReadAloudAdvice(String text) {
    setState(() => _isSpeakingAdvice = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text('🔊 Reading advice aloud: "$text"')),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 4),
      ),
    );
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _isSpeakingAdvice = false);
    });
  }

  void _submitReport() {
    final result = TriageService.assess(
      symptoms: _selectedSymptoms.toList(),
      affectedCount: _affectedCount,
      notEating: _eatingStatus == 'No',
      notDrinking: _drinkingStatus == 'No',
    );

    final reportId = widget.dataService.generateReportId();
    final animalTag = _earTagCtrl.text.trim().isNotEmpty
        ? _earTagCtrl.text.trim()
        : (_existingAnimal?.earTag ?? '${_selectedSpecies.displayName[0]}${DateTime.now().millisecondsSinceEpoch % 1000}');

    final animalId = _existingAnimal?.id ?? widget.dataService.generateAnimalId();

    final reportLocation = _locationMode == '📍 Use Farm Location'
        ? '${widget.dataService.profile.farmName ?? "Farm"}, ${widget.dataService.profile.village}'
        : (_manualLocationCtrl.text.trim().isNotEmpty ? _manualLocationCtrl.text.trim() : 'Farm Location');

    final report = HealthReport(
      id: reportId,
      animalId: animalId,
      animalTag: animalTag,
      species: _selectedSpecies.displayName,
      breed: _selectedBreed,
      age: _selectedAge,
      symptoms: _selectedSymptoms.toList(),
      duration: _duration,
      eatingStatus: _eatingStatus,
      drinkingStatus: _drinkingStatus,
      affectedCount: _affectedCount,
      isPregnant: _isFemaleRuminant ? (_pregnantStatus == 'Yes') : null,
      isLactating: _isFemaleRuminant ? (_lactatingStatus == 'Yes') : null,
      riskLevel: result.riskLevel,
      title: result.title,
      advice: result.advice,
      recommendedAction: result.recommendedAction,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      hasVoiceNote: _hasVoiceRecorded,
      hasPhoto: _hasPhotoAdded,
      hasVideo: _hasVideoAdded,
      location: reportLocation,
    );

    widget.dataService.addHealthReport(report);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AssessmentResultScreen(
          dataService: widget.dataService,
          reportId: reportId,
          triageResult: result,
          animalId: animalId,
          animalTag: animalTag,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _step < 10
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _back,
              )
            : IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          _step < 10 ? 'Report Issue (Step ${_step + 1})' : 'Assessment Result',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: _step >= 10 && _triageResult != null
          ? _buildStep11Result()
          : Column(
              children: [
                SizedBox(
                  height: 4,
                  child: LinearProgressIndicator(
                    value: (_step + 1) / 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    minHeight: 4,
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1Species(),
                      _buildStep2Details(),
                      _buildStep3Symptoms(),
                      _buildStep4Duration(),
                      _buildStep5EatingDrinking(),
                      _buildStep6AffectedCount(),
                      _buildStep7Pregnancy(),
                      _buildStep8Evidence(),
                      _buildStep9Location(),
                      _buildStep10Summary(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ─── Step 1: Select Animal Type ──────────────────────────────────────────────
  Widget _buildStep1Species() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('what_animal_problem'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Tap the animal that needs attention.', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.15,
            children: AnimalSpecies.values.map((species) {
              final isSelected = _selectedSpecies == species;
              final primary = Theme.of(context).colorScheme.primary;

              return Card(
                elevation: isSelected ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected ? primary : Colors.grey.shade300,
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
                color: isSelected ? primary.withValues(alpha: 0.08) : Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    setState(() {
                      _selectedSpecies = species;
                      _selectedBreed = species.predefinedBreeds.first;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(species.emoji, style: const TextStyle(fontSize: 44)),
                        const SizedBox(height: 8),
                        Text(
                          species.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? primary : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          _buildNextButton(onPressed: _next),
        ],
      ),
    );
  }

  // ─── Step 2: Animal Details (Predefined Breed Dropdown) ──────────────────────
  Widget _buildStep2Details() {
    final breeds = _selectedSpecies.predefinedBreeds;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('tell_about_animal'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            '${_selectedSpecies.emoji} ${_selectedSpecies.displayName} Details',
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),

          // Ear Tag / Animal ID (Optional)
          TextField(
            controller: _earTagCtrl,
            decoration: InputDecoration(
              labelText: context.tr('animal_id_tag'),
              prefixIcon: const Icon(Icons.tag_rounded),
              hintText: 'e.g. C001, Ear Tag 42',
            ),
          ),
          const SizedBox(height: 20),

          // PREDEFINED BREED DROPDOWN (Strictly NOT free-text!)
          Text(
            '${context.tr('select_breed')} *',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: breeds.contains(_selectedBreed) ? _selectedBreed : breeds.first,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.category_rounded),
            ),
            items: breeds.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
            onChanged: (v) => setState(() => _selectedBreed = v!),
          ),
          const SizedBox(height: 20),

          // Gender
          Text('${context.tr('gender')} *', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildChoiceChip(
                  label: '👩 ${context.tr('female')}',
                  selected: _selectedGender == AnimalGender.female,
                  onTap: () => setState(() => _selectedGender = AnimalGender.female),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildChoiceChip(
                  label: '👨 ${context.tr('male')}',
                  selected: _selectedGender == AnimalGender.male,
                  onTap: () => setState(() => _selectedGender = AnimalGender.male),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Age
          Text('${context.tr('age')} *', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ageOptions.map((age) {
              final isSelected = _selectedAge == age;
              return ChoiceChip(
                label: Text(age),
                selected: isSelected,
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                onSelected: (val) {
                  if (val) setState(() => _selectedAge = age);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          _buildNextButton(onPressed: _next),
        ],
      ),
    );
  }

  // ─── Step 3: What is Wrong? (Layman Symptom Grid) ────────────────────────────
  Widget _buildStep3Symptoms() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('what_is_wrong'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Select all problems you observe in the animal.', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.85,
            children: _symptomList.map((sym) {
              final labelKey = sym['label'] as String;
              final localizedText = context.tr(labelKey);
              final icon = sym['icon'] as IconData;
              final color = sym['color'] as Color;
              final isSelected = _selectedSymptoms.contains(localizedText);
              final primary = Theme.of(context).colorScheme.primary;

              return Card(
                elevation: isSelected ? 3 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isSelected ? primary : Colors.grey.shade300,
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
                color: isSelected ? primary.withValues(alpha: 0.12) : Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedSymptoms.remove(localizedText);
                      } else {
                        _selectedSymptoms.add(localizedText);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: color.withValues(alpha: isSelected ? 0.3 : 0.12),
                          child: Icon(icon, color: isSelected ? primary : color, size: 20),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          localizedText,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? primary : Colors.black87,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          if (_selectedSymptoms.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_selectedSymptoms.length} symptom(s) selected: ${_selectedSymptoms.join(", ")}',
                      style: TextStyle(color: Colors.green.shade900, fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),

          _buildNextButton(onPressed: _next),
        ],
      ),
    );
  }

  // ─── Step 4: Since When? ─────────────────────────────────────────────────────
  Widget _buildStep4Duration() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('since_when'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('How long has the animal shown these signs?', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 24),

          ..._durationOptions.map((opt) {
            final isSelected = _duration == opt;
            final primary = Theme.of(context).colorScheme.primary;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected ? primary : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              color: isSelected ? primary.withValues(alpha: 0.08) : Colors.white,
              child: ListTile(
                leading: Icon(
                  Icons.access_time_filled_rounded,
                  color: isSelected ? primary : Colors.grey.shade400,
                ),
                title: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? primary : Colors.black87,
                  ),
                ),
                trailing: isSelected ? Icon(Icons.check_circle_rounded, color: primary) : null,
                onTap: () => setState(() => _duration = opt),
              ),
            );
          }),
          const SizedBox(height: 28),

          _buildNextButton(onPressed: _next),
        ],
      ),
    );
  }

  // ─── Step 5: Eating & Drinking ───────────────────────────────────────────────
  Widget _buildStep5EatingDrinking() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('is_animal_eating'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _eatingOptions.map((opt) {
              final isSelected = _eatingStatus == opt;
              return ChoiceChip(
                label: Text(opt, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                selected: isSelected,
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                onSelected: (val) {
                  if (val) setState(() => _eatingStatus = opt);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          Text(
            context.tr('is_animal_drinking'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _eatingOptions.map((opt) {
              final isSelected = _drinkingStatus == opt;
              return ChoiceChip(
                label: Text(opt, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                selected: isSelected,
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                onSelected: (val) {
                  if (val) setState(() => _drinkingStatus = opt);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 36),

          _buildNextButton(onPressed: _next),
        ],
      ),
    );
  }

  // ─── Step 6: How many animals affected? ──────────────────────────────────────
  Widget _buildStep6AffectedCount() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('how_many_affected'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('If multiple animals are sick, isolation is critical.', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 24),

          ..._affectedOptions.map((opt) {
            final isSelected = _affectedCount == opt;
            final primary = Theme.of(context).colorScheme.primary;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected ? primary : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              color: isSelected ? primary.withValues(alpha: 0.08) : Colors.white,
              child: ListTile(
                leading: Icon(
                  Icons.pets_rounded,
                  color: isSelected ? primary : Colors.grey.shade400,
                ),
                title: Text(
                  opt == '1' ? '1 animal' : '$opt animals',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? primary : Colors.black87,
                  ),
                ),
                trailing: isSelected ? Icon(Icons.check_circle_rounded, color: primary) : null,
                onTap: () => setState(() => _affectedCount = opt),
              ),
            );
          }),
          const SizedBox(height: 28),

          _buildNextButton(onPressed: _next),
        ],
      ),
    );
  }

  // ─── Step 7: Pregnancy & Lactation (Conditional) ─────────────────────────────
  Widget _buildStep7Pregnancy() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('is_pregnant'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: ['Yes', 'No', 'Not sure'].map((opt) {
              final isSelected = _pregnantStatus == opt;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(opt),
                  selected: isSelected,
                  onSelected: (v) {
                    if (v) setState(() => _pregnantStatus = opt);
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          Text(
            context.tr('is_lactating'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: ['Yes', 'No'].map((opt) {
              final isSelected = _lactatingStatus == opt;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(opt),
                  selected: isSelected,
                  onSelected: (v) {
                    if (v) setState(() => _lactatingStatus = opt);
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 36),

          _buildNextButton(onPressed: _next),
        ],
      ),
    );
  }

  // ─── Step 8: Evidence & Voice Description ────────────────────────────────────
  Widget _buildStep8Evidence() {
    final primary = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('show_us_problem'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Voice and photo help the veterinarian diagnose faster.', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 20),

          // Voice Recorder UI Box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade200, width: 1.5),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.mic_rounded, color: Colors.orange.shade800, size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.tr('tell_what_happened'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('speak_in_language'),
                  style: TextStyle(fontSize: 12.5, color: Colors.orange.shade800),
                ),
                const SizedBox(height: 16),

                // Voice status / recorder button
                if (_isRecordingVoice) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fiber_manual_record_rounded, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('recording'),
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ] else if (_hasVoiceRecorded) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          context.tr('voice_recorded'),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: primary),
                        icon: Icon(_isPlayingVoice ? Icons.stop_rounded : Icons.play_arrow_rounded),
                        label: Text(_isPlayingVoice ? 'Playing...' : context.tr('play')),
                        onPressed: _simulateVoicePlayback,
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.orange.shade900),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(context.tr('record_again')),
                        onPressed: _simulateVoiceRecording,
                      ),
                    ],
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade800,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.mic_rounded, size: 24),
                      label: Text(
                        context.tr('tap_and_speak'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _simulateVoiceRecording,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Photo & Video Placeholders
          Row(
            children: [
              Expanded(
                child: _buildEvidenceCard(
                  icon: Icons.camera_alt_rounded,
                  label: _hasPhotoAdded ? context.tr('photo_added') : context.tr('take_photo'),
                  color: Colors.blue,
                  isSelected: _hasPhotoAdded,
                  onTap: () {
                    setState(() => _hasPhotoAdded = !_hasPhotoAdded);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_hasPhotoAdded ? 'Photo captured (Demo)' : 'Photo removed')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEvidenceCard(
                  icon: Icons.videocam_rounded,
                  label: _hasVideoAdded ? context.tr('video_added') : context.tr('record_video'),
                  color: Colors.teal,
                  isSelected: _hasVideoAdded,
                  onTap: () {
                    setState(() => _hasVideoAdded = !_hasVideoAdded);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_hasVideoAdded ? 'Video recorded (Demo)' : 'Video removed')),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Written Description
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: context.tr('write_description'),
              hintText: 'Any extra notes for the vet...',
            ),
          ),
          const SizedBox(height: 28),

          _buildNextButton(onPressed: _next),
        ],
      ),
    );
  }

  // ─── Step 9: Location ────────────────────────────────────────────────────────
  Widget _buildStep9Location() {
    final profile = widget.dataService.profile;
    final primary = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('where_is_animal'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Confirm the animal location for vet dispatch.', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 24),

          // Saved Farm Location Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: _locationMode == '📍 Use Farm Location' ? primary : Colors.grey.shade300,
                width: _locationMode == '📍 Use Farm Location' ? 2 : 1,
              ),
            ),
            color: _locationMode == '📍 Use Farm Location' ? primary.withValues(alpha: 0.08) : Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _locationMode = '📍 Use Farm Location'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: primary.withValues(alpha: 0.15),
                      child: Icon(Icons.location_on_rounded, color: primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('use_farm_location'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _locationMode == '📍 Use Farm Location' ? primary : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${profile.farmName ?? "Farm"} · ${profile.village}, ${profile.district}',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (_locationMode == '📍 Use Farm Location')
                      Icon(Icons.check_circle_rounded, color: primary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Enter Manually
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: _locationMode == 'Manual' ? primary : Colors.grey.shade300,
                width: _locationMode == 'Manual' ? 2 : 1,
              ),
            ),
            color: _locationMode == 'Manual' ? primary.withValues(alpha: 0.08) : Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _locationMode = 'Manual'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.withValues(alpha: 0.15),
                          child: const Icon(Icons.edit_location_alt_rounded, color: Colors.blue),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            context.tr('enter_location_manually'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        if (_locationMode == 'Manual')
                          Icon(Icons.check_circle_rounded, color: primary),
                      ],
                    ),
                    if (_locationMode == 'Manual') ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: _manualLocationCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Enter Village, Block, or Landmark',
                          prefixIcon: Icon(Icons.pin_drop_rounded),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),

          _buildNextButton(onPressed: _next),
        ],
      ),
    );
  }

  // ─── Step 10: Report Summary ─────────────────────────────────────────────────
  Widget _buildStep10Summary() {
    final primary = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('report_summary'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Please review the details before submitting.', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 20),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _buildSummaryRow('Animal', '${_selectedSpecies.emoji} ${_selectedSpecies.displayName}'),
                  const Divider(height: 20),
                  _buildSummaryRow('Breed', _selectedBreed),
                  const Divider(height: 20),
                  _buildSummaryRow('Age', _selectedAge),
                  const Divider(height: 20),
                  _buildSummaryRow('Problem(s)', _selectedSymptoms.join(', ')),
                  const Divider(height: 20),
                  _buildSummaryRow('Since', _duration),
                  const Divider(height: 20),
                  _buildSummaryRow('Animals affected', _affectedCount),
                  const Divider(height: 20),
                  _buildSummaryRow('Voice note', _hasVoiceRecorded ? '✓ Added' : 'None'),
                  const Divider(height: 20),
                  _buildSummaryRow('Photo', _hasPhotoAdded ? '✓ Added' : 'None'),
                  const Divider(height: 20),
                  _buildSummaryRow(
                    'Location',
                    _locationMode == '📍 Use Farm Location'
                        ? (widget.dataService.profile.farmName ?? "Farm")
                        : (_manualLocationCtrl.text.isNotEmpty ? _manualLocationCtrl.text : 'Manual location'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _goToStep(0),
                  child: Text(context.tr('edit')),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _submitReport,
                  child: Text(
                    context.tr('submit_report'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Step 11: Health Risk Assessment Result ──────────────────────────────────
  Widget _buildStep11Result() {
    final result = _triageResult!;
    Color riskColor;
    IconData riskIcon;

    switch (result.riskLevel) {
      case RiskLevel.low:
        riskColor = const Color(0xFF2E7D32);
        riskIcon = Icons.check_circle_rounded;
        break;
      case RiskLevel.medium:
        riskColor = Colors.orange.shade800;
        riskIcon = Icons.info_rounded;
        break;
      case RiskLevel.high:
        riskColor = Colors.deepOrange.shade700;
        riskIcon = Icons.warning_rounded;
        break;
      case RiskLevel.critical:
        riskColor = Colors.red.shade900;
        riskIcon = Icons.emergency_rounded;
        break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: riskColor.withValues(alpha: 0.4), width: 2),
            ),
            child: Column(
              children: [
                Icon(riskIcon, size: 64, color: riskColor),
                const SizedBox(height: 12),
                Text(
                  result.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Case ID: #$_submittedReportId',
                  style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Simple Advice Card with Read Aloud (TTS) Button
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Recommended Action',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade50,
                          foregroundColor: Colors.green.shade900,
                          elevation: 0,
                          minimumSize: const Size(0, 36),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        icon: Icon(
                          _isSpeakingAdvice ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                          size: 18,
                        ),
                        label: Text(context.tr('listen')),
                        onPressed: () => _simulateReadAloudAdvice(result.advice),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.advice,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    result.recommendedAction,
                    style: const TextStyle(color: Colors.grey, fontSize: 13.5, height: 1.3),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Request Veterinarian Button (Prominent for High/Critical)
          if (result.riskLevel == RiskLevel.high || result.riskLevel == RiskLevel.critical) ...[
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.local_hospital_rounded, size: 24),
                label: Text(
                  context.tr('request_veterinarian'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VetRequestScreen(
                        dataService: widget.dataService,
                        preselectedAnimalId: _existingAnimal?.id,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Back to Home Button
          SizedBox(
            height: 54,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.tr('back_to_home'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton({required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.tr('next'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? primary : Colors.grey.shade300, width: selected ? 2 : 1),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? primary : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEvidenceCard({
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
      color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13.5)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
