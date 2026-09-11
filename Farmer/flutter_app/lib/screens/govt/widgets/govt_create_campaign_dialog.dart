// Smart Livestock — Government Create Campaign Wizard
// Simple 4-step campaign creation flow connected directly to Disease Risk intelligence.

import 'package:flutter/material.dart';
import '../govt_theme.dart';
import '../govt_models.dart';
import '../govt_campaign_engine.dart';

class GovtCreateCampaignDialog extends StatefulWidget {
  final String? initialDistrict;
  final String? initialDisease;
  final CampaignPriority? initialPriority;
  final ValueChanged<VaccinationCampaign>? onCampaignCreated;

  const GovtCreateCampaignDialog({
    super.key,
    this.initialDistrict,
    this.initialDisease,
    this.initialPriority,
    this.onCampaignCreated,
  });

  static Future<VaccinationCampaign?> show(
    BuildContext context, {
    String? initialDistrict,
    String? initialDisease,
    CampaignPriority? initialPriority,
    ValueChanged<VaccinationCampaign>? onCampaignCreated,
  }) {
    return showModalBottomSheet<VaccinationCampaign>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GovtCreateCampaignDialog(
        initialDistrict: initialDistrict,
        initialDisease: initialDisease,
        initialPriority: initialPriority,
        onCampaignCreated: onCampaignCreated,
      ),
    );
  }

  @override
  State<GovtCreateCampaignDialog> createState() => _GovtCreateCampaignDialogState();
}

class _GovtCreateCampaignDialogState extends State<GovtCreateCampaignDialog> {
  int _currentStep = 1;

  // Step 1: Area Selection
  late String _selectedDistrict;
  late String _selectedBlock;
  final Set<String> _selectedVillages = {};

  final List<String> _districts = [
    'Pune',
    'Nashik',
    'Nagpur',
    'Amravati',
    'Jalgaon',
    'Satara',
    'Solapur',
    'Kolhapur',
    'Chhatrapati Sambhajinagar',
  ];

  final Map<String, List<String>> _blocksByDistrict = {
    'Pune': ['Haveli', 'Shirur', 'Baramati', 'Khed', 'Mulshi'],
    'Nashik': ['Niphad', 'Sinnar', 'Dindori', 'Malegaon'],
    'Nagpur': ['Nagpur Rural', 'Kamptee', 'Katol', 'Umred'],
    'Amravati': ['Achalpur', 'Chandur', 'Morshi'],
    'Jalgaon': ['Bhusawal', 'Raver', 'Yawal'],
    'Satara': ['Karad', 'Wai', 'Phaltan'],
    'Solapur': ['Pandharpur', 'Sangola', 'Barshi'],
    'Kolhapur': ['Karveer', 'Shirol', 'Hatkanangle'],
    'Chhatrapati Sambhajinagar': ['Aurangabad Rural', 'Paithan', 'Gangapur'],
  };

  final Map<String, List<String>> _villagesByBlock = {
    'Haveli': [
      'Khadakwasla', 'Wagholi', 'Saswad Road', 'Manchar Pocket', 'Jejuri Border',
      'Loni Kalbhor', 'Uruli Kanchan', 'Dhadawadi', 'Khed Shivapur', 'Donje',
      'Khanapur', 'Gorhe Budruk', 'Sinhagad Foothills', 'Kalyan Gaon', 'Wanjale',
      'Arvi', 'Kondanpur', 'Malegaon Khurd'
    ],
    'Shirur': ['Ranjangaon', 'Shikrapur', 'Nhavare', 'Koregaon Bhima', 'Talegaon Dhamdhere', 'Pabal'],
    'Baramati': ['Malegaon', 'Dorlewadi', 'Gunawadi', 'Songaon', 'Katewadi'],
    'Niphad': ['Pimpalgaon Baswant', 'Lasalgaon', 'Ozar', 'Kunderwadi', 'Suket'],
    'Sinnar': ['Wavi', 'Musalgoan', 'Pangri', 'Dahiwadi'],
  };

  // Step 2: Disease & Vaccine
  late String _selectedDisease;
  String _selectedVaccine = 'Raksha-Ovac Trivalent (FMD)';
  final Set<String> _selectedSpecies = {'Cattle', 'Buffalo'};

  final List<String> _diseases = ['FMD', 'Anthrax', 'Brucellosis', 'Other'];

  final Map<String, List<String>> _vaccinesByDisease = {
    'FMD': ['Raksha-Ovac Trivalent (FMD)', 'BioFMD Oil Adjuvanted', 'Aftovaxpur Quadrivalent'],
    'Anthrax': ['Anthrax Spore Vaccine (Sterne 34F2)', 'Raksha-Anthrax Living'],
    'Brucellosis': ['Brucella Abortus S19 Living', 'Rev-1 (Small Ruminants)'],
    'Other': ['Raksha-HS (Haemorrhagic Septicaemia)', 'PPR Alive Vaccine'],
  };

  final List<String> _speciesList = ['Cattle', 'Buffalo', 'Goat', 'Sheep', 'Other'];

  // Step 3: Targets & Dates
  late TextEditingController _targetAnimalsCtrl;
  late TextEditingController _campaignNameCtrl;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  late CampaignPriority _selectedPriority;

  @override
  void initState() {
    super.initState();
    _selectedDistrict = widget.initialDistrict ?? 'Pune';
    final blocks = _blocksByDistrict[_selectedDistrict] ?? ['All Blocks'];
    _selectedBlock = blocks.first;

    // Default select 18 villages if Pune
    final defaultVillages = _villagesByBlock[_selectedBlock] ?? ['Village 1', 'Village 2'];
    _selectedVillages.addAll(defaultVillages.take(18));

    _selectedDisease = widget.initialDisease ?? 'FMD';
    _updateVaccineChoices();

    _selectedPriority = widget.initialPriority ??
        (widget.initialDistrict?.toLowerCase() == 'pune' ? CampaignPriority.critical : CampaignPriority.high);

    final defaultTarget = _selectedDistrict == 'Pune' ? 8500 : 6200;
    _targetAnimalsCtrl = TextEditingController(text: defaultTarget.toString());
    _campaignNameCtrl = TextEditingController(text: '$_selectedDisease Prevention Drive — $_selectedDistrict');
  }

  void _updateVaccineChoices() {
    final list = _vaccinesByDisease[_selectedDisease] ?? ['Standard Veterinary Vaccine'];
    _selectedVaccine = list.first;
  }

  @override
  void dispose() {
    _targetAnimalsCtrl.dispose();
    _campaignNameCtrl.dispose();
    super.dispose();
  }

  void _onDistrictChanged(String newDist) {
    setState(() {
      _selectedDistrict = newDist;
      final blocks = _blocksByDistrict[newDist] ?? ['Central Block'];
      _selectedBlock = blocks.first;
      _selectedVillages.clear();
      final vList = _villagesByBlock[_selectedBlock] ?? ['Central Village 01', 'East Hamlet 02'];
      _selectedVillages.addAll(vList.take(6));
      _campaignNameCtrl.text = '$_selectedDisease Prevention Drive — $_selectedDistrict';
    });
  }

  void _onBlockChanged(String newBlock) {
    setState(() {
      _selectedBlock = newBlock;
      _selectedVillages.clear();
      final vList = _villagesByBlock[newBlock] ?? ['Village A', 'Village B', 'Village C'];
      _selectedVillages.addAll(vList);
    });
  }

  void _submitLaunch() {
    final targetNum = int.tryParse(_targetAnimalsCtrl.text) ?? 8500;
    final campaign = VaccinationCampaign(
      campaignId: 'CAMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      name: _campaignNameCtrl.text.trim().isNotEmpty
          ? _campaignNameCtrl.text.trim()
          : '$_selectedDisease Control Drive — $_selectedDistrict',
      disease: _selectedDisease,
      targetDistrict: _selectedDistrict,
      targetBlock: _selectedBlock,
      targetVillages: '${_selectedVillages.length} villages',
      animalSpecies: _selectedSpecies.join(', '),
      startDate: _startDate,
      endDate: _endDate,
      targetAnimals: targetNum,
      vaccinatedAnimals: 0,
      assignedTeams: ['Rapid Response Unit 01 (Pending Assignment)'],
      status: CampaignStatus.active,
      priority: _selectedPriority,
      targetVillagesCount: _selectedVillages.length,
      completedVillagesCount: 0,
      pendingVillagesCount: _selectedVillages.length,
      villages: _selectedVillages.map((v) => VillageCampaignData(
        name: v,
        target: (targetNum / (_selectedVillages.isEmpty ? 1 : _selectedVillages.length)).round(),
        vaccinated: 0,
        status: 'Pending',
        recommendedAction: 'Deploy primary vaccination team.',
      )).toList(),
      timelinePoints: const [
        CampaignProgressPoint(dayLabel: 'Day 1', coverage: 0.0),
      ],
    );

    widget.onCampaignCreated?.call(campaign);
    Navigator.pop(context, campaign);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: GovtColors.brandDark,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: GovtColors.riskLow, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '✓ Campaign Launched: ${campaign.name} (${campaign.targetAnimals} animals across ${campaign.targetVillagesCount} villages)',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: GovtColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: GovtColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: GovtColors.brandLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.vaccines_rounded, size: 20, color: GovtColors.brandDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CREATE VACCINATION CAMPAIGN',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: GovtColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Text(
                        'Step 0$_currentStep of 04 — ${_stepTitle(_currentStep)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: GovtColors.brand,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: GovtColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Stepper Indicator Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(4, (index) {
                final stepNum = index + 1;
                final isDone = stepNum < _currentStep;
                final isCurrent = stepNum == _currentStep;

                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isDone || isCurrent ? GovtColors.brand : GovtColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: GovtColors.border),

          // Step Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: _buildCurrentStepContent(),
            ),
          ),

          // Bottom Step Controls
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: const BoxDecoration(
              color: GovtColors.surfaceSubtle,
              border: Border(top: BorderSide(color: GovtColors.border)),
            ),
            child: Row(
              children: [
                if (_currentStep > 1) ...[
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      side: const BorderSide(color: GovtColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => setState(() => _currentStep--),
                    child: const Text('BACK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GovtColors.textSecondary)),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentStep == 4 ? GovtColors.brandDark : GovtColors.brand,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (_currentStep < 4) {
                        setState(() => _currentStep++);
                      } else {
                        _submitLaunch();
                      }
                    },
                    child: Text(
                      _currentStep == 4 ? 'LAUNCH CAMPAIGN' : 'CONTINUE →',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _stepTitle(int step) {
    switch (step) {
      case 1:
        return 'Select Target Area';
      case 2:
        return 'Select Disease & Vaccine';
      case 3:
        return 'Campaign Targets & Timeline';
      case 4:
        return 'Review & Confirm Launch';
      default:
        return '';
    }
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Area();
      case 2:
        return _buildStep2Disease();
      case 3:
        return _buildStep3Target();
      case 4:
        return _buildStep4Review();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── STEP 01: SELECT AREA ───────────────────────────────────────────────────

  Widget _buildStep1Area() {
    final blocks = _blocksByDistrict[_selectedDistrict] ?? ['Default Block'];
    final availableVillages = _villagesByBlock[_selectedBlock] ?? [
      'Central Village 01', 'North Hamlet 02', 'East Gaon 03', 'South Cluster 04', 'West Wadi 05',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('STATE'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: GovtColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: GovtColors.border),
          ),
          child: Row(
            children: const [
              Icon(Icons.location_city_rounded, size: 16, color: GovtColors.textMuted),
              SizedBox(width: 8),
              Text('Maharashtra', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: GovtColors.textPrimary)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        _sectionLabel('DISTRICT'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: GovtColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: GovtColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _districts.contains(_selectedDistrict) ? _selectedDistrict : _districts.first,
              items: _districts.map((d) => DropdownMenuItem(
                value: d,
                child: Text(d, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              )).toList(),
              onChanged: (val) {
                if (val != null) _onDistrictChanged(val);
              },
            ),
          ),
        ),
        const SizedBox(height: 14),

        _sectionLabel('BLOCK / TALUKA'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: GovtColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: GovtColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: blocks.contains(_selectedBlock) ? _selectedBlock : blocks.first,
              items: blocks.map((b) => DropdownMenuItem(
                value: b,
                child: Text(b, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              )).toList(),
              onChanged: (val) {
                if (val != null) _onBlockChanged(val);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Multi-village selector header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('TARGET VILLAGES'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: GovtColors.brandLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Selected villages: ${_selectedVillages.length}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: GovtColors.brandDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Select All / Deselect All
        Row(
          children: [
            TextButton.icon(
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              icon: const Icon(Icons.select_all_rounded, size: 15, color: GovtColors.brand),
              label: const Text('Select All', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: GovtColors.brand)),
              onPressed: () {
                setState(() => _selectedVillages.addAll(availableVillages));
              },
            ),
            const SizedBox(width: 8),
            TextButton(
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: const Text('Clear All', style: TextStyle(fontSize: 11.5, color: GovtColors.textMuted)),
              onPressed: () {
                setState(() => _selectedVillages.clear());
              },
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Village Checkbox List
        Container(
          constraints: const BoxConstraints(maxHeight: 220),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: GovtColors.border),
          ),
          child: Material(
            color: Colors.transparent,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: availableVillages.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: GovtColors.border),
              itemBuilder: (context, i) {
                final v = availableVillages[i];
                final isChecked = _selectedVillages.contains(v);

                return CheckboxListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(v, style: TextStyle(fontSize: 12.5, fontWeight: isChecked ? FontWeight.w700 : FontWeight.w500)),
                  value: isChecked,
                  activeColor: GovtColors.brand,
                  onChanged: (bool? val) {
                    setState(() {
                      if (val == true) {
                        _selectedVillages.add(v);
                      } else {
                        _selectedVillages.remove(v);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ─── STEP 02: SELECT DISEASE / VACCINE ──────────────────────────────────────

  Widget _buildStep2Disease() {
    final vaccines = _vaccinesByDisease[_selectedDisease] ?? ['Standard Vaccine'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('TARGET DISEASE'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _diseases.map((d) {
            final isSel = _selectedDisease == d;
            return ChoiceChip(
              label: Text(d, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.w800 : FontWeight.w600, color: isSel ? Colors.white : GovtColors.textPrimary)),
              selected: isSel,
              selectedColor: GovtColors.brand,
              backgroundColor: GovtColors.surfaceSubtle,
              onSelected: (_) {
                setState(() {
                  _selectedDisease = d;
                  _updateVaccineChoices();
                  _campaignNameCtrl.text = '$_selectedDisease Prevention Drive — $_selectedDistrict';
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        _sectionLabel('AUTHORIZED VACCINE FORMULATION'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: GovtColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: GovtColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: vaccines.contains(_selectedVaccine) ? _selectedVaccine : vaccines.first,
              items: vaccines.map((v) => DropdownMenuItem(
                value: v,
                child: Text(v, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              )).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedVaccine = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 18),

        _sectionLabel('TARGET ANIMAL SPECIES'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _speciesList.map((sp) {
            final isChecked = _selectedSpecies.contains(sp);
            return FilterChip(
              label: Text(sp, style: TextStyle(fontSize: 12, fontWeight: isChecked ? FontWeight.w700 : FontWeight.w500, color: isChecked ? GovtColors.brandDark : GovtColors.textPrimary)),
              selected: isChecked,
              selectedColor: GovtColors.brandLight,
              checkmarkColor: GovtColors.brandDark,
              backgroundColor: GovtColors.surfaceSubtle,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(color: isChecked ? GovtColors.brand : GovtColors.border),
              ),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedSpecies.add(sp);
                  } else {
                    if (_selectedSpecies.length > 1) {
                      _selectedSpecies.remove(sp);
                    }
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── STEP 03: CAMPAIGN TARGET ───────────────────────────────────────────────

  Widget _buildStep3Target() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('CAMPAIGN NAME'),
        TextField(
          controller: _campaignNameCtrl,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'e.g. FMD Prevention Drive — Pune',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: GovtColors.border)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 14),

        _sectionLabel('TARGET ANIMALS (HEADCOUNT)'),
        TextField(
          controller: _targetAnimalsCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: '8,500',
            prefixIcon: const Icon(Icons.pets_rounded, size: 18, color: GovtColors.brand),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: GovtColors.border)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('CAMPAIGN START'),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _startDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: GovtColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 14, color: GovtColors.brand),
                          const SizedBox(width: 6),
                          Text('${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('CAMPAIGN END'),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: _startDate,
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _endDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: GovtColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_available_rounded, size: 14, color: GovtColors.brand),
                          const SizedBox(width: 6),
                          Text('${_endDate.day.toString().padLeft(2, '0')}/${_endDate.month.toString().padLeft(2, '0')}/${_endDate.year}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _sectionLabel('CAMPAIGN PRIORITY'),
        Row(
          children: [
            _priorityOption(CampaignPriority.critical, GovtColors.critical),
            const SizedBox(width: 8),
            _priorityOption(CampaignPriority.high, GovtColors.warning),
            const SizedBox(width: 8),
            _priorityOption(CampaignPriority.normal, GovtColors.brand),
          ],
        ),
      ],
    );
  }

  Widget _priorityOption(CampaignPriority priority, Color color) {
    final isSel = _selectedPriority == priority;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _selectedPriority = priority),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? color.withValues(alpha: 0.12) : GovtColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSel ? color : GovtColors.border, width: isSel ? 1.8 : 1.0),
          ),
          child: Column(
            children: [
              Text(
                priority.shortLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                  color: isSel ? color : GovtColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── STEP 04: REVIEW & CONFIRM ──────────────────────────────────────────────

  Widget _buildStep4Review() {
    final targetNum = int.tryParse(_targetAnimalsCtrl.text) ?? 8500;
    final durationDays = _endDate.difference(_startDate).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: GovtColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: GovtColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _campaignNameCtrl.text.trim().isNotEmpty ? _campaignNameCtrl.text.trim() : 'Vaccination Campaign',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GovtColors.textPrimary),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _priorityColor(_selectedPriority).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _priorityColor(_selectedPriority)),
                    ),
                    child: Text(
                      _selectedPriority.label,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _priorityColor(_selectedPriority)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: GovtColors.border),
              const SizedBox(height: 12),

              _reviewRow('Target Area', '$_selectedDistrict District ($_selectedBlock)'),
              _reviewRow('Target Villages', '${_selectedVillages.length} selected villages'),
              _reviewRow('Target Disease', _selectedDisease),
              _reviewRow('Vaccine', _selectedVaccine),
              _reviewRow('Target Animals', '$targetNum animals (${_selectedSpecies.join(', ')})'),
              _reviewRow('Duration', '$durationDays days (${_startDate.day}/${_startDate.month} – ${_endDate.day}/${_endDate.month})'),
              _reviewRow('Priority Level', _selectedPriority.shortLabel),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: GovtColors.brandLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: GovtColors.brand.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: const [
              Icon(Icons.verified_outlined, size: 18, color: GovtColors.brandDark),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ready to deploy. Immediate field alerts will be scheduled for designated veterinary units.',
                  style: TextStyle(fontSize: 11.5, color: GovtColors.brandDark, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 11.5, color: GovtColors.textMuted, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GovtColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: GovtColors.textSecondary,
        ),
      ),
    );
  }

  Color _priorityColor(CampaignPriority p) {
    switch (p) {
      case CampaignPriority.critical:
        return GovtColors.critical;
      case CampaignPriority.high:
        return GovtColors.warning;
      case CampaignPriority.normal:
      case CampaignPriority.monitoring:
        return GovtColors.brand;
    }
  }
}
