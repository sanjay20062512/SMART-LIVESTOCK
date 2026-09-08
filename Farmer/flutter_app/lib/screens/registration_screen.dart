// Registration Screen — Simple Multi-Page Flow (6 Pages).
// Page 1: Basic Details (About You + Voice Name)
// Page 2: Farmer Location (Predefined State, District, Block, Village)
// Page 3: Farm Details (Size, Unit, Location Toggle, Multi-Select Livestock)
// Page 4: Language & Preferences (Preferred Language & Communication Mode)
// Page 5: OTP Verification (Demo 123456)
// Page 6: Create Password & Success -> Farmer Home

import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../services/localization_service.dart';
import '../models/farmer_profile.dart';
import '../widgets/farmer_shell.dart';

class RegistrationScreen extends StatefulWidget {
  final FarmerDataService dataService;

  const RegistrationScreen({super.key, required this.dataService});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Page 1
  final _nameCtrl = TextEditingController(text: 'Sanjay Kumar');
  final _mobileCtrl = TextEditingController(text: '9876543210');
  final _emailCtrl = TextEditingController();
  bool _isSpeakingName = false;

  // Page 2 - Location
  String _selectedState = 'Tamil Nadu';
  String _selectedDistrict = 'Coimbatore';
  String _selectedBlock = 'Mettupalayam';
  final _villageCtrl = TextEditingController(text: 'Karunaigoundenpudur');

  // Page 3 - Farm Details
  final _farmNameCtrl = TextEditingController(text: 'Green Meadows Farm');
  final _farmSizeCtrl = TextEditingController(text: '5');
  String _farmSizeUnit = 'Acres';
  String _locationMode = '📍 Current Location';
  final Set<String> _selectedLivestock = {'Cow', 'Goat'};

  // Page 4 - Preferences
  String _preferredLang = 'English';
  String _commPref = 'Both';

  // Page 5 - OTP
  final _otpCtrl = TextEditingController();
  String? _otpError;
  bool _otpVerifying = false;

  // Page 6 - Password
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Predefined Location catalogues
  final Map<String, List<String>> _stateDistricts = {
    'Tamil Nadu': [
      'Coimbatore',
      'Erode',
      'Tiruppur',
      'Salem',
      'Madurai',
      'Thanjavur',
      'Dindigul',
      'Namakkal',
      'Other',
    ],
    'Karnataka': [
      'Bengaluru Rural',
      'Mysuru',
      'Mandya',
      'Hassan',
      'Tumakuru',
      'Other',
    ],
    'Andhra Pradesh': [
      'Chittoor',
      'Anantapur',
      'Guntur',
      'Krishna',
      'Kurnool',
      'Other',
    ],
    'Kerala': [
      'Palakkad',
      'Wayanad',
      'Thrissur',
      'Kozhikode',
      'Idukki',
      'Other',
    ],
    'Maharashtra': [
      'Pune',
      'Nashik',
      'Kolhapur',
      'Ahmednagar',
      'Satara',
      'Other',
    ],
    'Uttar Pradesh': [
      'Varanasi',
      'Prayagraj',
      'Meerut',
      'Bareilly',
      'Gorakhpur',
      'Other',
    ],
  };

  final Map<String, List<String>> _districtBlocks = {
    'Coimbatore': [
      'Mettupalayam',
      'Pollachi North',
      'Pollachi South',
      'Sulur',
      'Thondamuthur',
      'Annur',
      'Karamadai',
      'Other',
    ],
    'Erode': ['Bhavani', 'Gobichettipalayam', 'Perundurai', 'Sathyamangalam', 'Other'],
    'Tiruppur': ['Avinashi', 'Dharapuram', 'Kangeyam', 'Udumalaipettai', 'Other'],
    'Salem': ['Attur', 'Omalur', 'Mettur', 'Sankari', 'Other'],
    'Madurai': ['Melur', 'Vadipatti', 'Usilampatti', 'Thirumangalam', 'Other'],
  };

  final List<Map<String, String>> _livestockOptions = [
    {'label': 'Cow', 'emoji': '🐄'},
    {'label': 'Buffalo', 'emoji': '🐃'},
    {'label': 'Goat', 'emoji': '🐐'},
    {'label': 'Sheep', 'emoji': '🐑'},
    {'label': 'Pig', 'emoji': '🐖'},
    {'label': 'Poultry', 'emoji': '🐔'},
    {'label': 'Other', 'emoji': '🐾'},
  ];

  @override
  void initState() {
    super.initState();
    _preferredLang = LocalizationService.instance.currentLanguage.label;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _villageCtrl.dispose();
    _farmNameCtrl.dispose();
    _farmSizeCtrl.dispose();
    _otpCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    // Validations per page
    if (_currentPage == 0) {
      if (_nameCtrl.text.trim().isEmpty) {
        _showError('Please enter your full name.');
        return;
      }
      if (_mobileCtrl.text.trim().length != 10) {
        _showError('Please enter a valid 10-digit mobile number.');
        return;
      }
    } else if (_currentPage == 1) {
      if (_villageCtrl.text.trim().isEmpty) {
        _showError('Please enter your village name.');
        return;
      }
    } else if (_currentPage == 2) {
      if (_selectedLivestock.isEmpty) {
        _showError('Please select at least one livestock type.');
        return;
      }
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _simulateVoiceNameInput() {
    setState(() => _isSpeakingName = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _isSpeakingName = false;
        _nameCtrl.text = 'Sanjay Kumar';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Voice captured: "Sanjay Kumar"'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _verifyOtp() {
    final code = _otpCtrl.text.trim();
    if (code != '123456') {
      setState(() => _otpError = 'Incorrect OTP. Use 123456 for demo.');
      return;
    }

    setState(() {
      _otpVerifying = true;
      _otpError = null;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _otpVerifying = false);
      _nextPage();
    });
  }

  void _createAccount() {
    if (_passwordCtrl.text.length < 4) {
      _showError('Password must be at least 4 characters.');
      return;
    }
    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      _showError('Passwords do not match.');
      return;
    }

    final newProfile = FarmerProfile(
      fullName: _nameCtrl.text.trim(),
      mobileNumber: _mobileCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      preferredLanguage: _preferredLang,
      state: _selectedState,
      district: _selectedDistrict,
      block: _selectedBlock,
      village: _villageCtrl.text.trim(),
      farmName: _farmNameCtrl.text.trim().isEmpty ? null : _farmNameCtrl.text.trim(),
      farmSize: _farmSizeCtrl.text.trim(),
      farmSizeUnit: _farmSizeUnit,
      farmLocationMode: _locationMode,
      livestockType: _selectedLivestock.join(', '),
      communicationPref: _commPref,
    );

    widget.dataService.updateProfile(newProfile);

    // Show Success Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.check_circle_rounded, size: 54, color: Color(0xFF2E7D32)),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('account_created_success'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome, ${newProfile.fullName}! You are ready to manage your farm.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => FarmerShell(dataService: widget.dataService),
                    ),
                    (route) => false,
                  );
                },
                child: Text(
                  context.tr('continue'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _prevPage,
              )
            : IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          'Step ${_currentPage + 1} of 6',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _currentPage = i),
        children: [
          _buildPage1AboutYou(),
          _buildPage2Location(),
          _buildPage3FarmDetails(),
          _buildPage4Preferences(),
          _buildPage5Otp(),
          _buildPage6Password(),
        ],
      ),
    );
  }

  // ─── Page 1: About You ───────────────────────────────────────────────────────
  Widget _buildPage1AboutYou() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('about_you'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Please provide your basic contact information.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 28),

          // Full Name with microphone speak button
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(fontSize: 17),
            decoration: InputDecoration(
              labelText: '${context.tr('full_name')} *',
              prefixIcon: const Icon(Icons.person_rounded),
              suffixIcon: IconButton(
                tooltip: 'Speak your name',
                icon: _isSpeakingName
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                      )
                    : const Icon(Icons.mic_rounded, color: Color(0xFF2E7D32), size: 28),
                onPressed: _simulateVoiceNameInput,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Speak name button badge
          InkWell(
            onTap: _simulateVoiceNameInput,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic_rounded, size: 18, color: Colors.green.shade800),
                  const SizedBox(width: 6),
                  Text(
                    context.tr('speak_name'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Mobile Number
          TextField(
            controller: _mobileCtrl,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            style: const TextStyle(fontSize: 17),
            decoration: InputDecoration(
              labelText: '${context.tr('mobile_number')} *',
              prefixIcon: const Icon(Icons.phone_android_rounded),
              counterText: '',
            ),
          ),
          const SizedBox(height: 18),

          // Email (Optional)
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 17),
            decoration: InputDecoration(
              labelText: context.tr('email_optional'),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 36),

          _buildContinueButton(onPressed: _nextPage),
        ],
      ),
    );
  }

  // ─── Page 2: Farmer Location ─────────────────────────────────────────────────
  Widget _buildPage2Location() {
    final districts = _stateDistricts[_selectedState] ?? ['Other'];
    final blocks = _districtBlocks[_selectedDistrict] ?? ['Default Block', 'Other'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('where_is_farm'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Select your location details from dropdowns.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),

          // State Dropdown
          Text('${context.tr('state')} *', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedState,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.map_rounded)),
            items: _stateDistricts.keys.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) {
              setState(() {
                _selectedState = val!;
                _selectedDistrict = _stateDistricts[_selectedState]!.first;
                _selectedBlock = _districtBlocks[_selectedDistrict]?.first ?? 'General';
              });
            },
          ),
          const SizedBox(height: 16),

          // District Dropdown
          Text('${context.tr('district')} *', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: districts.contains(_selectedDistrict) ? _selectedDistrict : districts.first,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.location_city_rounded)),
            items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (val) {
              setState(() {
                _selectedDistrict = val!;
                _selectedBlock = _districtBlocks[_selectedDistrict]?.first ?? 'General';
              });
            },
          ),
          const SizedBox(height: 16),

          // Block / Taluk Dropdown
          Text('${context.tr('block_taluk')} *', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: blocks.contains(_selectedBlock) ? _selectedBlock : blocks.first,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.apartment_rounded)),
            items: blocks.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
            onChanged: (val) => setState(() => _selectedBlock = val!),
          ),
          const SizedBox(height: 16),

          // Village Input
          Text('${context.tr('village')} *', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          TextField(
            controller: _villageCtrl,
            style: const TextStyle(fontSize: 16),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.villa_rounded),
              hintText: 'Enter village name',
            ),
          ),
          const SizedBox(height: 36),

          _buildContinueButton(onPressed: _nextPage),
        ],
      ),
    );
  }

  // ─── Page 3: Farm Details ────────────────────────────────────────────────────
  Widget _buildPage3FarmDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('about_farm'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Enter farm size and select your livestock.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),

          // Farm Name (Optional)
          TextField(
            controller: _farmNameCtrl,
            decoration: InputDecoration(
              labelText: context.tr('farm_name_optional'),
              prefixIcon: const Icon(Icons.agriculture_rounded),
            ),
          ),
          const SizedBox(height: 16),

          // Farm Size & Unit
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _farmSizeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context.tr('farm_size'),
                    prefixIcon: const Icon(Icons.square_foot_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _farmSizeUnit,
                  decoration: InputDecoration(
                    labelText: context.tr('farm_size_unit'),
                  ),
                  items: ['Acres', 'Hectares', 'Cent']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (val) => setState(() => _farmSizeUnit = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Farm Location Mode
          Text(context.tr('farm_location'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildChoiceChip(
                  label: context.tr('use_current_location'),
                  selected: _locationMode == '📍 Current Location',
                  onTap: () {
                    setState(() => _locationMode = '📍 Current Location');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Using current location (Frontend placeholder)')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildChoiceChip(
                  label: context.tr('enter_location_manually'),
                  selected: _locationMode == '📝 Enter Location Manually',
                  onTap: () => setState(() => _locationMode = '📝 Enter Location Manually'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Livestock Multi-Select
          Text(
            '${context.tr('livestock_type')} (Select all that apply) *',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _livestockOptions.map((opt) {
              final label = opt['label']!;
              final emoji = opt['emoji']!;
              final isSelected = _selectedLivestock.contains(label);
              return FilterChip(
                selected: isSelected,
                avatar: Text(emoji, style: const TextStyle(fontSize: 18)),
                label: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                checkmarkColor: Theme.of(context).colorScheme.primary,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedLivestock.add(label);
                    } else {
                      _selectedLivestock.remove(label);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 36),

          _buildContinueButton(onPressed: _nextPage),
        ],
      ),
    );
  }

  // ─── Page 4: Language & Preferences ──────────────────────────────────────────
  Widget _buildPage4Preferences() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('language_preferences'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Choose how you want to interact with the app.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),

          // Language Selector
          Text(context.tr('preferred_language'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          ...AppLanguage.values.map((lang) {
            final isSelected = _preferredLang == lang.label;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                title: Text(lang.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  setState(() => _preferredLang = lang.label);
                  LocalizationService.instance.setLanguage(lang);
                },
              ),
            );
          }),
          const SizedBox(height: 20),

          // Communication Preference
          Text(context.tr('communication_preference'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildChoiceChip(
                  label: context.tr('comm_voice'),
                  selected: _commPref == 'Voice',
                  onTap: () => setState(() => _commPref = 'Voice'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildChoiceChip(
                  label: context.tr('comm_text'),
                  selected: _commPref == 'Text',
                  onTap: () => setState(() => _commPref = 'Text'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildChoiceChip(
                  label: 'Both',
                  selected: _commPref == 'Both',
                  onTap: () => setState(() => _commPref = 'Both'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),

          _buildContinueButton(
            label: context.tr('create_farmer_profile'),
            onPressed: _nextPage,
          ),
        ],
      ),
    );
  }

  // ─── Page 5: OTP ─────────────────────────────────────────────────────────────
  Widget _buildPage5Otp() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.mark_email_read_rounded, size: 54, color: Color(0xFF2E7D32)),
          const SizedBox(height: 16),
          Text(
            context.tr('verify_mobile'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'We sent a verification code to ${_mobileCtrl.text.trim()}.',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Prototype OTP Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.amber.shade900),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.tr('demo_otp_notice'),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // OTP Input
          TextField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30, letterSpacing: 10, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '123456',
              errorText: _otpError,
              counterText: '',
            ),
          ),
          const SizedBox(height: 28),

          // Auto-fill button for fast testing
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.flash_on_rounded, size: 18),
              label: const Text('Auto-fill Demo OTP (123456)'),
              onPressed: () {
                _otpCtrl.text = '123456';
                _verifyOtp();
              },
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _otpVerifying ? null : _verifyOtp,
              child: _otpVerifying
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'VERIFY & CONTINUE',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 6: Password ────────────────────────────────────────────────────────
  Widget _buildPage6Password() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_rounded, size: 54, color: Color(0xFF2E7D32)),
          const SizedBox(height: 16),
          Text(
            context.tr('create_password_title'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Create a password for ${ _nameCtrl.text.trim()} to log in easily.',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Password
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: '${context.tr('password')} *',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Confirm Password
          TextField(
            controller: _confirmPasswordCtrl,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              labelText: '${context.tr('confirm_password')} *',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
          ),
          const SizedBox(height: 36),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _createAccount,
              child: Text(
                context.tr('create_account_btn'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton({VoidCallback? onPressed, String? label}) {
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
              label ?? context.tr('continue'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? primary : Colors.grey.shade300, width: selected ? 2 : 1),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? primary : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
