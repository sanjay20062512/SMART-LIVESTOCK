// Add Animal Screen — form with full validation, saves to FarmerDataService.

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../models/animal.dart';

class AddAnimalScreen extends StatefulWidget {
  final FarmerDataService dataService;
  final Animal? existingAnimal; // non-null = edit mode

  const AddAnimalScreen({
    super.key,
    required this.dataService,
    this.existingAnimal,
  });

  @override
  State<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();

  final _earTagCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  AnimalSpecies _species = AnimalSpecies.cow;
  AnimalGender _gender = AnimalGender.female;
  HealthStatus _healthStatus = HealthStatus.healthy;

  bool get _isEdit => widget.existingAnimal != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final a = widget.existingAnimal!;
      _earTagCtrl.text = a.earTag;
      _breedCtrl.text = a.breed;
      _ageCtrl.text = a.age;
      _locationCtrl.text = a.location ?? '';
      _species = a.species;
      _gender = a.gender;
      _healthStatus = a.healthStatus;
    }
  }

  @override
  void dispose() {
    _earTagCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final earTag = _earTagCtrl.text.trim();

    // Check for duplicate ear tag (skip own tag in edit mode)
    if (!_isEdit && widget.dataService.animalIdExists(earTag)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Animal ID / Ear Tag already exists.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isEdit) {
      final updated = widget.existingAnimal!.copyWith(
        earTag: earTag,
        species: _species,
        breed: _breedCtrl.text.trim(),
        gender: _gender,
        age: _ageCtrl.text.trim(),
        healthStatus: _healthStatus,
        location: _locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim(),
      );
      widget.dataService.updateAnimal(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal updated successfully.')),
      );
    } else {
      final animal = Animal(
        id: widget.dataService.generateAnimalId(),
        earTag: earTag,
        species: _species,
        breed: _breedCtrl.text.trim(),
        gender: _gender,
        age: _ageCtrl.text.trim(),
        healthStatus: _healthStatus,
        location: _locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim(),
      );
      widget.dataService.addAnimal(animal);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${animal.species.displayName} ${animal.earTag} added successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Animal' : 'Add New Animal',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo placeholder
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt,
                          size: 32, color: Colors.grey),
                      const SizedBox(height: 4),
                      Text(
                        'Add Photo',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  '(Photo upload available in full version)',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
              const SizedBox(height: 20),

              _sectionLabel('Animal Identification'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _earTagCtrl,
                decoration: _inputDeco(
                  'Animal ID / Ear Tag *',
                  icon: Icons.tag,
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter the Animal ID or Ear Tag.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _sectionLabel('Species'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AnimalSpecies.values.map((s) {
                  final selected = _species == s;
                  return ChoiceChip(
                    label: Text(s.displayName),
                    selected: selected,
                    onSelected: (_) => setState(() => _species = s),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _breedCtrl,
                decoration: _inputDeco('Breed *', icon: Icons.category),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter the breed.'
                    : null,
              ),
              const SizedBox(height: 16),
              _sectionLabel('Gender'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: AnimalGender.values.map((g) {
                  return ChoiceChip(
                    label: Text(g.displayName),
                    selected: _gender == g,
                    onSelected: (_) => setState(() => _gender = g),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageCtrl,
                decoration: _inputDeco(
                  'Age (e.g. 4 years, 6 months) *',
                  icon: Icons.calendar_today,
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter the age.'
                    : null,
              ),
              const SizedBox(height: 16),
              _sectionLabel('Health Status'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: HealthStatus.values.map((s) {
                  return ChoiceChip(
                    label: Text(s.displayName),
                    selected: _healthStatus == s,
                    onSelected: (_) => setState(() => _healthStatus = s),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationCtrl,
                decoration:
                    _inputDeco('Location (optional)', icon: Icons.location_on),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: Icon(_isEdit ? Icons.save : Icons.add),
                  label: Text(
                    _isEdit ? 'Save Changes' : 'Add Animal',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  InputDecoration _inputDeco(String label, {required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
