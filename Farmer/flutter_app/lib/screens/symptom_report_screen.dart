// Report Animal Problem — Step-by-Step Wizard for Livestock Farmers.
// Prioritizes voice, icons, large buttons, simple words, dropdowns, and minimum typing.

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../services/localization_service.dart';
import '../services/triage_service.dart';
import '../models/animal.dart';
import '../models/health_report.dart';
import '../widgets/language_selector_button.dart';
import '../services/media_service.dart';
import '../services/location_service.dart';
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
  final _customBreedCtrl = TextEditingController();
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
  String? _voicePath;
  String? _voiceTranscript;
  bool _hasPhotoAdded = false;
  String? _photoPath;
  String? _photoName;
  Uint8List? _photoBytes;
  bool _hasVideoAdded = false;
  String? _videoPath;
  String? _videoName;
  final _descCtrl = TextEditingController();

  // Step 9: Location & GPS
  String _locationMode = '📍 Use Farm Location';
  final _manualLocationCtrl = TextEditingController();
  LocationResult? _gpsLocationResult;
  bool _isAcquiringGps = false;

  Future<void> _acquireGpsCoordinates() async {
    if (_isAcquiringGps || _gpsLocationResult?.isGpsAcquired == true) return;
    setState(() => _isAcquiringGps = true);
    try {
      final result = await LocationService.instance.getCurrentLocation();
      if (mounted) {
        setState(() {
          _gpsLocationResult = result;
          _isAcquiringGps = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isAcquiringGps = false);
      }
    }
  }

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
    _acquireGpsCoordinates();
  }

  @override
  void dispose() {
    MediaService.instance.stopAudio();
    MediaService.instance.stopListening();
    _pageController.dispose();
    _earTagCtrl.dispose();
    _customBreedCtrl.dispose();
    _descCtrl.dispose();
    _manualLocationCtrl.dispose();
    super.dispose();
  }

  bool get _isFemaleRuminant {
    return (_selectedGender == AnimalGender.female || _selectedGender == AnimalGender.both) &&
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

  /// Returns a localized label for a breed string.
  /// Returns Hindi/Marathi transliterations for all known breeds;
  /// falls back to the original English string for unknown breeds.
  String _localizeBreed(BuildContext context, String breed) {
    final lang = LocalizationService.instance.currentLanguage;
    if (lang == AppLanguage.english) return breed;
    final bool isHindi = lang == AppLanguage.hindi;

    switch (breed) {
      // Special values
      case 'Other':
        return context.tr('other');
      case 'General / Mixed Breed':
        return context.tr('general_mixed_breed');

      // ── Cow breeds ──────────────────────────────────
      case 'Jersey':
        return 'जर्सी';
      case 'Holstein Friesian (HF)':
        return isHindi ? 'होल्सटीन फ्रीजियन (HF)' : 'होल्सटीन फ्रिजियन (HF)';
      case 'Sahiwal':
        return isHindi ? 'साहीवाल' : 'साहिवाल';
      case 'Gir':
        return isHindi ? 'गिर' : 'गीर';
      case 'Red Sindhi':
        return isHindi ? 'लाल सिंधी' : 'लाल सिंधी';
      case 'Kangayam':
        return isHindi ? 'कांगयम' : 'कांगयम';

      // ── Buffalo breeds ────────────────────────────────
      case 'Murrah':
        return isHindi ? 'मुर्रा' : 'मुऱ्हा';
      case 'Jaffarabadi':
        return isHindi ? 'जाफराबादी' : 'जाफराबादी';
      case 'Surti':
        return isHindi ? 'सूरती' : 'सुरती';
      case 'Mehsana':
        return isHindi ? 'मेहसाना' : 'मेहसाणा';

      // ── Goat breeds ───────────────────────────────────
      case 'Boer':
        return isHindi ? 'बोअर' : 'बोअर';
      case 'Saanen':
        return isHindi ? 'सानेन' : 'सानेन';
      case 'Jamunapari':
        return isHindi ? 'जमुनापारी' : 'जमनापारी';
      case 'Malabari':
        return isHindi ? 'मालाबारी' : 'मालाबारी';
      case 'Kanni Adu':
        return isHindi ? 'कन्नी अडु' : 'कन्नी अडु';

      // ── Sheep breeds ───────────────────────────────────
      case 'Mecheri':
        return isHindi ? 'मेचेरी' : 'मेचेरी';
      case 'Vembur':
        return isHindi ? 'वेम्बूर' : 'वेंबूर';
      case 'Madras Red':
        return isHindi ? 'मद्रास लाल' : 'मद्रास लाल';
      case 'Ramanadhapuram White':
        return isHindi ? 'रामनाथपुरम सफेद' : 'रामनाथपुरम पांढरी';

      // ── Poultry ────────────────────────────────────────
      case 'Broiler':
        return isHindi ? 'ब्रॉयलर' : 'ब्रॉयलर';
      case 'Layer':
        return isHindi ? 'लेयर' : 'लेयर';
      case 'Country Chicken':
        return isHindi ? 'देसी मुर्गी' : 'देशी कोंबडी';

      // ── Pig breeds ─────────────────────────────────────
      case 'Large White Yorkshire':
        return isHindi ? 'लार्ज व्हाइट यॉर्कशायर' : 'लार्ज व्हाइट यॉर्कशायर';
      case 'Landrace':
        return isHindi ? 'लैंड्रेस' : 'लँड्रेस';
      case 'Duroc':
        return isHindi ? 'डूरोक' : 'ड्युरोक';

      default:
        return breed;
    }
  }

  String _localizeDuration(BuildContext context, String opt) {
    switch (opt) {
      case 'Today': return context.tr('today');
      case 'Yesterday': return context.tr('yesterday');
      case '2–3 days': return context.tr('2_3_days');
      case '4–7 days': return context.tr('4_7_days');
      case 'More than a week': return context.tr('more_than_week');
      case 'Not sure': return context.tr('not_sure');
      default: return opt;
    }
  }

  String _localizeEating(BuildContext context, String opt) {
    switch (opt) {
      case 'Yes': return context.tr('yes');
      case 'Less than usual': return context.tr('less_than_usual');
      case 'No': return context.tr('no');
      case 'Not sure': return context.tr('not_sure');
      default: return opt;
    }
  }

  String _localizeAge(BuildContext context, String age) {
    switch (age) {
      case 'Below 1 year':
        final t = context.tr('age_below_1');
        return t != 'age_below_1' ? t : (context.tr('age_below_1_year') != 'age_below_1_year' ? context.tr('age_below_1_year') : age);
      case '1–2 years':
        final t = context.tr('age_1_2');
        return t != 'age_1_2' ? t : (context.tr('age_1_2_years') != 'age_1_2_years' ? context.tr('age_1_2_years') : age);
      case '2–5 years':
        final t = context.tr('age_2_5');
        return t != 'age_2_5' ? t : (context.tr('age_2_5_years') != 'age_2_5_years' ? context.tr('age_2_5_years') : age);
      case '5–10 years':
        final t = context.tr('age_5_10');
        return t != 'age_5_10' ? t : (context.tr('age_5_10_years') != 'age_5_10_years' ? context.tr('age_5_10_years') : age);
      case 'Above 10 years':
        final t = context.tr('age_above_10');
        return t != 'age_above_10' ? t : (context.tr('age_above_10_years') != 'age_above_10_years' ? context.tr('age_above_10_years') : age);
      default:
        return age;
    }
  }

  String _localizeAffected(BuildContext context, String count) {
    switch (count) {
      case '1':       return '1 ${context.tr("animal")}';
      case '2–5':     return context.tr('affected_2_5');
      case '6–10':    return context.tr('affected_6_10');
      case 'More than 10': return context.tr('more_than_10');
      case 'Not sure':    return context.tr('not_sure');
      default:        return count;
    }
  }

  Future<void> _startRealVoiceRecording() async {
    final lang = LocalizationService.instance.currentLanguage;
    if (_isPlayingVoice) {
      await MediaService.instance.stopAudio();
      setState(() => _isPlayingVoice = false);
    }
    final path = await MediaService.instance.startRecording();
    if (path == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not access microphone. Please check permissions.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isRecordingVoice = true;
      _voicePath = path;
    });

    // Start live speech-to-text recognition
    await MediaService.instance.startListening(
      localeId: lang.voiceLocaleCode,
      onResult: (text) {
        if (!mounted) return;
        setState(() {
          _voiceTranscript = text;
          if (_descCtrl.text.isEmpty || _descCtrl.text == text) {
            _descCtrl.text = text;
          }
        });
      },
    );
  }

  Future<void> _stopRealVoiceRecording() async {
    final recordedPath = await MediaService.instance.stopRecording();
    await MediaService.instance.stopListening();

    if (!mounted) return;
    setState(() {
      _isRecordingVoice = false;
      _hasVoiceRecorded = true;
      if (recordedPath != null && recordedPath.isNotEmpty) {
        _voicePath = recordedPath;
      }
    });

    final lang = LocalizationService.instance.currentLanguage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('✓ ${context.tr('voice_recorded')} [${lang.voiceLocaleCode}]')),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );

    // If local STT did not populate a transcript, request server-side transcription
    if ((_voiceTranscript == null || _voiceTranscript!.isEmpty) && _voicePath != null) {
      _transcribeAudioViaBackend(_voicePath!, lang.voiceLocaleCode);
    }
  }

  Future<void> _transcribeAudioViaBackend(String audioPath, String languageCode) async {
    try {
      final res = await widget.dataService.apiService.uploadMultipart(
        '/cases/media/transcribe',
        fields: {'language': languageCode},
        filePaths: {'audio_file': audioPath},
      );
      if (res != null && res['transcript'] != null && res['transcript'].toString().trim().isNotEmpty) {
        if (!mounted) return;
        final transcript = res['transcript'].toString().trim();
        setState(() {
          _voiceTranscript = transcript;
          if (_descCtrl.text.isEmpty) {
            _descCtrl.text = transcript;
          }
        });
      }
    } catch (e) {
      debugPrint('[SymptomReportScreen] Backend transcription notice: $e');
    }
  }

  Future<void> _playVoiceRecording() async {
    if (_voicePath == null || _voicePath!.isEmpty) return;
    if (_isPlayingVoice) {
      await MediaService.instance.stopAudio();
      if (mounted) setState(() => _isPlayingVoice = false);
      return;
    }

    setState(() => _isPlayingVoice = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.volume_up_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Playing voice recording...'),
          ],
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF0D9488),
      ),
    );

    await MediaService.instance.playAudio(
      _voicePath!,
      onComplete: () {
        if (mounted) {
          setState(() => _isPlayingVoice = false);
        }
      },
    );
  }

  Future<void> _captureRealPhoto() async {
    final photo = await MediaService.instance.capturePhoto();
    if (photo != null) {
      Uint8List? bytes;
      try {
        bytes = await photo.readAsBytes();
      } catch (_) {}
      setState(() {
        _photoPath = photo.path;
        _photoName = photo.name;
        _photoBytes = bytes ?? MediaService.instance.lastPhotoBytes;
        _hasPhotoAdded = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(context.tr('photo_added')),
              ],
            ),
            backgroundColor: Colors.blue.shade700,
          ),
        );
      }
    }
  }

  Future<void> _captureRealVideo() async {
    final video = await MediaService.instance.recordVideo();
    if (video != null) {
      setState(() {
        _videoPath = video.path;
        _videoName = video.name;
        _hasVideoAdded = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.videocam_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(context.tr('video_added')),
              ],
            ),
            backgroundColor: Colors.teal.shade700,
          ),
        );
      }
    }
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
    final currentLang = LocalizationService.instance.currentLanguage;
    final result = TriageService.assess(
      symptoms: _selectedSymptoms.toList(),
      affectedCount: _affectedCount,
      notEating: _eatingStatus == 'No',
      notDrinking: _drinkingStatus == 'No',
      language: currentLang,
    );

    // Also fire off background request to FastAPI backend with language parameter
    try {
      widget.dataService.apiService.post('/triage', {
        'species': _selectedSpecies.displayName,
        'symptoms': _selectedSymptoms.toList(),
        'affected_count': _affectedCount,
        'not_eating': _eatingStatus == 'No',
        'not_drinking': _drinkingStatus == 'No',
        'is_mortality_related': false,
        'language': currentLang.code,
      }).catchError((_) => null);
    } catch (_) {}

    final reportId = widget.dataService.generateReportId();
    final animalTag = _earTagCtrl.text.trim().isNotEmpty
        ? _earTagCtrl.text.trim()
        : (_existingAnimal?.earTag ?? '${_selectedSpecies.displayName[0]}${DateTime.now().millisecondsSinceEpoch % 1000}');

    final animalId = _existingAnimal?.id ?? widget.dataService.generateAnimalId();

    final reportLocation = _locationMode == '📍 Use Farm Location'
        ? '${widget.dataService.profile.farmName ?? "Farm"}, ${widget.dataService.profile.village}'
        : (_manualLocationCtrl.text.trim().isNotEmpty ? _manualLocationCtrl.text.trim() : 'Farm Location');

    final double reportLatitude = _gpsLocationResult?.latitude ?? LocationService.defaultFarmLat;
    final double reportLongitude = _gpsLocationResult?.longitude ?? LocationService.defaultFarmLon;

    final report = HealthReport(
      id: reportId,
      animalId: animalId,
      animalTag: animalTag,
      species: _selectedSpecies.displayName,
      breed: (_selectedBreed == 'Other' && _customBreedCtrl.text.trim().isNotEmpty)
          ? _customBreedCtrl.text.trim()
          : _selectedBreed,
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
      voicePath: _voicePath,
      voiceTranscript: _voiceTranscript,
      hasPhoto: _hasPhotoAdded,
      photoPath: _photoPath,
      hasVideo: _hasVideoAdded,
      videoPath: _videoPath,
      location: reportLocation,
      latitude: reportLatitude,
      longitude: reportLongitude,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF6),
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
          _step < 10
              ? '${context.tr("report_an_issue")} (${context.tr("step")} ${_step + 1})'
              : context.tr('assessment_result'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: LanguageSelectorButton(),
          ),
        ],
      ),
      body: _step >= 10 && _triageResult != null
          ? _buildStep11Result()
          : Column(
              children: [
                SizedBox(
                  height: 5,
                  child: LinearProgressIndicator(
                    value: (_step + 1) / 10,
                    backgroundColor: const Color(0xFFE8F5E9),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF16A34A)),
                    minHeight: 5,
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

  // ─── Step 1 Visual Metadata ──────────────────────────────────────────────────
  static const Map<AnimalSpecies, _SpeciesVisualInfo> _speciesVisuals = {
    AnimalSpecies.cow: _SpeciesVisualInfo(
      emoji: '🐮',
      tint: Color(0xFFE8F5E9),
      icon: Icons.agriculture_rounded,
    ),
    AnimalSpecies.buffalo: _SpeciesVisualInfo(
      emoji: '🐃',
      tint: Color(0xFFE0F2F1),
      icon: Icons.agriculture_rounded,
    ),
    AnimalSpecies.goat: _SpeciesVisualInfo(
      emoji: '🐐',
      tint: Color(0xFFFFF8E1),
      icon: Icons.pets_rounded,
    ),
    AnimalSpecies.sheep: _SpeciesVisualInfo(
      emoji: '🐑',
      tint: Color(0xFFF3E5F5),
      icon: Icons.pets_rounded,
    ),
    AnimalSpecies.poultry: _SpeciesVisualInfo(
      emoji: '🐔',
      tint: Color(0xFFFFF3E0),
      icon: Icons.egg_rounded,
    ),
    AnimalSpecies.pig: _SpeciesVisualInfo(
      emoji: '🐷',
      tint: Color(0xFFFCE4EC),
      icon: Icons.cruelty_free_rounded,
    ),
    AnimalSpecies.other: _SpeciesVisualInfo(
      emoji: '🐾',
      tint: Color(0xFFEDE7F6),
      icon: Icons.pets_rounded,
    ),
  };

  // ─── Step 1: Select Animal Type (Farmer-Friendly Redesign) ───────────────────
  Widget _buildStep1Species() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFC8E6C9)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.grass_rounded, size: 15, color: Color(0xFF16A34A)),
                SizedBox(width: 5),
                Text(
                  'STEP 1 OF 10 • SELECT ANIMAL',
                  style: TextStyle(
                    color: Color(0xFF15803D),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Main Headline (High Contrast, Simple English)
          Text(
            context.tr('what_animal_problem'),
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: Color(0xFF122812),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),

          // Minimal, clear instruction
          const Text(
            'Tap your animal below to choose it.',
            style: TextStyle(
              color: Color(0xFF385538),
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // Selected animal reassurance banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFA5D6A7), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: '${context.tr("selected")}: ',
                      style: const TextStyle(
                        color: Color(0xFF15803D),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                          text: '${_speciesVisuals[_selectedSpecies]?.emoji ?? _selectedSpecies.emoji} ${_selectedSpecies.displayName}',
                          style: const TextStyle(
                            color: Color(0xFF15803D),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 2-Column Grid with Large, Touch-Friendly Cards
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.98,
            children: AnimalSpecies.values.map((species) {
              final isSelected = _selectedSpecies == species;
              final visual = _speciesVisuals[species] ??
                  _SpeciesVisualInfo(
                    emoji: species.emoji,
                    tint: const Color(0xFFE8F5E9),
                    icon: species.icon,
                  );

              const selectedGreen = Color(0xFF16A34A);
              const lightGreenBg = Color(0xFFE8F5E9);
              const unselectedBorder = Color(0xFFDDE6DC);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected ? lightGreenBg : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? selectedGreen : unselectedBorder,
                    width: isSelected ? 3.2 : 1.5,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: selectedGreen.withValues(alpha: 0.24),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() {
                        _selectedSpecies = species;
                        _selectedBreed = species.predefinedBreeds.first;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top selection checkmark status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: selectedGreen,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_rounded, color: Colors.white, size: 14),
                                      SizedBox(width: 3),
                                      Text(
                                        'SELECTED',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFCFD8CE), width: 1.8),
                                    color: const Color(0xFFF9FBF9),
                                  ),
                                ),
                            ],
                          ),

                          // Large animal image / icon badge
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? const Color(0xFFDCEDC8) : visual.tint,
                              border: Border.all(
                                color: isSelected ? const Color(0xFFAED581) : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              visual.emoji,
                              style: const TextStyle(fontSize: 42),
                            ),
                          ),

                          // Main Animal Label
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: selectedGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                species.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                species.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1C2C1C),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Big, Touch-Friendly Primary CTA
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: const Color(0x500D9488),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _next,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      '${context.tr("continue_with")} ${_selectedSpecies.displayName}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('next'),
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 22),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
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
            '${_selectedSpecies.emoji} ${_selectedSpecies.displayName} ${context.tr("details")}',
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),

          // Ear Tag / Animal ID (Optional)
          TextField(
            controller: _earTagCtrl,
            decoration: InputDecoration(
              labelText: context.tr('animal_id_tag'),
              prefixIcon: const Icon(Icons.tag_rounded),
              hintText: context.tr('animal_id_hint'),
            ),
          ),
          const SizedBox(height: 20),

          // PREDEFINED BREED DROPDOWN
          Text(
            '${context.tr('select_breed')} *',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          // ignore: deprecated_member_use
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: breeds.contains(_selectedBreed) ? _selectedBreed : breeds.first,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.category_rounded),
            ),
            items: breeds
                .map((b) => DropdownMenuItem(
                      value: b,
                      child: Text(_localizeBreed(context, b)),
                    ))
                .toList(),
            onChanged: (v) {
              setState(() {
                _selectedBreed = v!;
                if (_selectedBreed != 'Other') {
                  _customBreedCtrl.clear();
                }
              });
            },
          ),
          // Show free-text field when "Other" is selected
          if (_selectedBreed == 'Other') ...
            [
              const SizedBox(height: 10),
              TextField(
                controller: _customBreedCtrl,
                decoration: InputDecoration(
                  labelText: context.tr('enter_breed_name'),
                  prefixIcon: const Icon(Icons.edit_rounded),
                  hintText: context.tr('enter_breed_name'),
                ),
              ),
            ],
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
              const SizedBox(width: 8),
              Expanded(
                child: _buildChoiceChip(
                  label: '👨 ${context.tr('male')}',
                  selected: _selectedGender == AnimalGender.male,
                  onTap: () => setState(() => _selectedGender = AnimalGender.male),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildChoiceChip(
                  label: '👫 ${context.tr('both_male_female')}',
                  selected: _selectedGender == AnimalGender.both,
                  onTap: () => setState(() => _selectedGender = AnimalGender.both),
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
                label: Text(_localizeAge(context, age)),
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
          Text(context.tr('select_all_problems'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
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
          Text(context.tr('duration_subtitle'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
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
                  _localizeDuration(context, opt),
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
                label: Text(_localizeEating(context, opt), style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
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
                label: Text(_localizeEating(context, opt), style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
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
          Text(context.tr('affected_count_subtitle'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
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
                  _localizeAffected(context, opt),
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
                  label: Text(_localizeEating(context, opt)),
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
                  label: Text(_localizeEating(context, opt)),
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
          Text(
            context.tr('voice_photo_help_diag'),
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.mic_rounded, color: Colors.orange.shade900, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('speak_in_language'),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr('tell_what_happened'),
                            style: TextStyle(fontSize: 13, color: Colors.orange.shade800),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language_rounded, size: 14, color: Colors.deepOrange),
                          const SizedBox(width: 4),
                          Text(
                            LocalizationService.instance.currentLanguage.label,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Voice status / recorder button
                if (_isRecordingVoice) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
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
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 1,
                      ),
                      icon: const Icon(Icons.stop_circle_rounded, size: 26),
                      label: Text(
                        context.tr('stop'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _stopRealVoiceRecording,
                    ),
                  ),
                ] else if (_hasVoiceRecorded) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          context.tr('voice_recorded'),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  if (_voiceTranscript != null && _voiceTranscript!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.format_quote_rounded, size: 20, color: Colors.orange.shade800),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '"$_voiceTranscript"',
                              style: TextStyle(fontSize: 13.5, color: Colors.grey.shade900, fontStyle: FontStyle.italic),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isPlayingVoice ? Colors.orange.shade800 : Colors.white,
                              foregroundColor: _isPlayingVoice ? Colors.white : primary,
                              side: BorderSide(color: primary, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: Icon(
                              _isPlayingVoice ? Icons.stop_rounded : Icons.volume_up_rounded,
                              size: 24,
                            ),
                            label: Text(
                              _isPlayingVoice ? context.tr('stop') : context.tr('listen'),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            onPressed: _playVoiceRecording,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange.shade900,
                              side: BorderSide(color: Colors.orange.shade400, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 22),
                            label: Text(
                              context.tr('record_again'),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            onPressed: _startRealVoiceRecording,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade800,
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.mic_rounded, size: 26),
                      label: Text(
                        context.tr('tap_and_speak'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      onPressed: _startRealVoiceRecording,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Photo & Video Evidence Cards
          if (_hasPhotoAdded) ...[
            _buildPhotoPreviewCard(),
            const SizedBox(height: 14),
          ],
          if (_hasVideoAdded) ...[
            _buildVideoPreviewCard(),
            const SizedBox(height: 14),
          ],

          if (!_hasPhotoAdded || !_hasVideoAdded)
            Row(
              children: [
                if (!_hasPhotoAdded)
                  Expanded(
                    child: _buildEvidenceCard(
                      icon: Icons.camera_alt_rounded,
                      label: context.tr('take_photo'),
                      color: Colors.blue,
                      isSelected: false,
                      onTap: _captureRealPhoto,
                    ),
                  ),
                if (!_hasPhotoAdded && !_hasVideoAdded) const SizedBox(width: 12),
                if (!_hasVideoAdded)
                  Expanded(
                    child: _buildEvidenceCard(
                      icon: Icons.videocam_rounded,
                      label: context.tr('record_video'),
                      color: Colors.teal,
                      isSelected: false,
                      onTap: _captureRealVideo,
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
              hintText: context.tr('extra_notes_vet_hint'),
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
          Text(
            context.tr('confirm_animal_location_diag'),
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
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
                          const SizedBox(height: 4),
                          if (_isAcquiringGps)
                            Row(
                              children: [
                                Icon(Icons.gps_not_fixed_rounded, size: 14, color: primary),
                                const SizedBox(width: 4),
                                Text(
                                  context.tr('acquiring_device_gps'),
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            )
                          else if (_gpsLocationResult != null && _gpsLocationResult!.isGpsAcquired)
                            Row(
                              children: [
                                const Icon(Icons.gps_fixed_rounded, size: 13, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  'GPS: ${_gpsLocationResult!.latitude.toStringAsFixed(4)}° N, ${_gpsLocationResult!.longitude.toStringAsFixed(4)}° E',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Icon(Icons.pin_drop_outlined, size: 13, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  'GPS: ${LocationService.defaultFarmLat}° N, ${LocationService.defaultFarmLon}° E (Default)',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
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
                  _buildSummaryRow(context.tr('animal'), '${_selectedSpecies.emoji} ${_selectedSpecies.displayName}'),
                  const Divider(height: 20),
                  _buildSummaryRow(context.tr('breed'), _selectedBreed),
                  const Divider(height: 20),
                  _buildSummaryRow(context.tr('age'), _localizeAge(context, _selectedAge)),
                  const Divider(height: 20),
                  _buildSummaryRow(context.tr('problems'), _selectedSymptoms.join(', ')),
                  const Divider(height: 20),
                  _buildSummaryRow(context.tr('since_when'), _localizeDuration(context, _duration)),
                  const Divider(height: 20),
                  _buildSummaryRow(context.tr('animals_affected'), _localizeAffected(context, _affectedCount)),
                  const Divider(height: 20),
                  _buildSummaryRow(context.tr('voice_note'), _hasVoiceRecorded ? (_voiceTranscript != null && _voiceTranscript!.isNotEmpty ? '✓ ${context.tr("recorded")} ("$_voiceTranscript")' : '✓ ${context.tr("added")}') : context.tr('none')),
                  const Divider(height: 20),
                  _buildSummaryRow(context.tr('photo'), _hasPhotoAdded ? context.tr('added') : context.tr('none')),
                  const Divider(height: 20),
                  _buildSummaryRow(context.tr('video'), _hasVideoAdded ? context.tr('added') : context.tr('none')),
                  const Divider(height: 20),
                  _buildSummaryRow(
                    context.tr('location'),
                    _locationMode == '📍 Use Farm Location'
                        ? (widget.dataService.profile.farmName ?? context.tr('farm_details'))
                        : (_manualLocationCtrl.text.isNotEmpty ? _manualLocationCtrl.text : context.tr('manual_location')),
                  ),
                  const Divider(height: 20),
                  _buildSummaryRow(
                    'GPS Fix',
                    _gpsLocationResult != null && _gpsLocationResult!.isGpsAcquired
                        ? '${_gpsLocationResult!.latitude.toStringAsFixed(4)}° N, ${_gpsLocationResult!.longitude.toStringAsFixed(4)}° E'
                        : 'Farm Registered (${LocationService.defaultFarmLat}, ${LocationService.defaultFarmLon})',
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? primary : Colors.grey.shade300, width: selected ? 2 : 1),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? primary : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.blue, size: 20),
              const SizedBox(width: 6),
              Text(
                context.tr('photo_added'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue.shade900),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Remove photo',
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                onPressed: () => setState(() {
                  _hasPhotoAdded = false;
                  _photoPath = null;
                  _photoBytes = null;
                  _photoName = null;
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.blue.shade100,
                  child: _photoBytes != null
                      ? Image.memory(
                          _photoBytes!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image_rounded, color: Colors.blue, size: 36),
                          ),
                        )
                      : (_photoPath != null && (_photoPath!.startsWith('http') || _photoPath!.startsWith('blob:'))
                          ? Image.network(
                              _photoPath!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.photo_library_rounded, color: Colors.blue, size: 36),
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.photo_rounded, color: Colors.blue, size: 38),
                            )),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _photoName ?? 'evidence_photo.jpg',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Symptom image ready for diagnosis',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: const Size(0, 32),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.fullscreen_rounded, size: 16),
                          label: const Text('View', style: TextStyle(fontSize: 12)),
                          onPressed: _showFullImageDialog,
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: const Size(0, 32),
                          ),
                          icon: const Icon(Icons.replay_rounded, size: 15),
                          label: const Text('Retake', style: TextStyle(fontSize: 12)),
                          onPressed: _captureRealPhoto,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.teal, size: 20),
              const SizedBox(width: 6),
              Text(
                context.tr('video_added'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal.shade900),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Remove video',
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                onPressed: () => setState(() {
                  _hasVideoAdded = false;
                  _videoPath = null;
                  _videoName = null;
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: _showVideoPlayerDialog,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade900, Colors.black87],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _videoName ?? 'symptom_video.mp4',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Recorded video · Ready for Vet review',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: const Size(0, 32),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 16),
                          label: const Text('Play', style: TextStyle(fontSize: 12)),
                          onPressed: _showVideoPlayerDialog,
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: const Size(0, 32),
                          ),
                          icon: const Icon(Icons.replay_rounded, size: 15),
                          label: const Text('Re-record', style: TextStyle(fontSize: 12)),
                          onPressed: _captureRealVideo,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFullImageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.image_rounded, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text('Photo Evidence Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: _photoBytes != null
                  ? Image.memory(_photoBytes!, fit: BoxFit.contain)
                  : Container(
                      height: 250,
                      color: Colors.blue.shade50,
                      child: const Center(
                        child: Icon(Icons.photo_rounded, size: 80, color: Colors.blue),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoPlayerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.videocam_rounded, color: Colors.tealAccent),
                  const SizedBox(width: 8),
                  const Text('Video Evidence Preview', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade700),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.teal,
                        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                      ),
                      SizedBox(height: 10),
                      Text('Recorded Clinical Video Evidence', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      SizedBox(height: 4),
                      Text('Duration: 0:15 · 1080p', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
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

class _SpeciesVisualInfo {
  final String emoji;
  final Color tint;
  final IconData icon;

  const _SpeciesVisualInfo({
    required this.emoji,
    required this.tint,
    required this.icon,
  });
}

