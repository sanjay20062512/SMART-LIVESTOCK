// Add Animal Screen — form with full validation, saves to FarmerDataService.

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../services/localization_service.dart';
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
        SnackBar(
          content: Text(context.tr('ear_tag_exists')),
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
        SnackBar(content: Text(context.tr('animal_updated'))),
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
            '${animal.species.displayName} ${animal.earTag} ${context.tr("added_successfully")}.',
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
          _isEdit ? context.tr('edit_animal') : context.tr('add_new_animal'),
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
                        context.tr('add_photo'),
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  context.tr('photo_upload_placeholder'),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
              const SizedBox(height: 20),

              _sectionLabel(context.tr('animal_identification')),
              const SizedBox(height: 12),
              TextFormField(
                controller: _earTagCtrl,
                decoration: _inputDeco(
                  '${context.tr("animal_id_tag")} *',
                  icon: Icons.tag,
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return context.tr('please_enter_animal_id');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _sectionLabel(context.tr('species')),
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
                decoration: _inputDeco('${context.tr("breed")} *', icon: Icons.category),
                validator: (v) => v == null || v.trim().isEmpty
                    ? context.tr('please_enter_breed')
                    : null,
              ),
              const SizedBox(height: 16),
              _sectionLabel(context.tr('gender')),
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
                  '${context.tr("age")} *',
                  icon: Icons.calendar_today,
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? context.tr('please_enter_age')
                    : null,
              ),
              const SizedBox(height: 16),
              _sectionLabel(context.tr('health_status')),
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
                    _inputDeco('${context.tr("location")} (${context.tr("optional")})', icon: Icons.location_on),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: Icon(_isEdit ? Icons.save : Icons.add),
                  label: Text(
                    _isEdit ? context.tr('save_changes') : context.tr('add_animal'),
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
