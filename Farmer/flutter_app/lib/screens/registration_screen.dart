// Registration Screen — Simple Multi-Page Flow (6 Pages).
// Page 1: Basic Details (About You + Voice Name)
// Page 2: Farmer Location (Predefined State, District, Block, Village)
// Page 3: Farm Details (Size, Unit, Location Toggle, Multi-Select Livestock)
// Page 4: Language & Preferences (Preferred Language & Communication Mode)
// Page 5: OTP Verification (Demo 123456)
// Page 6: Create Password & Success -> Farmer Home

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../services/localization_service.dart';
import '../services/media_service.dart';
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

  // Page 2 - Location (locked to Maharashtra)
  final String _selectedState = 'Maharashtra';
  String _selectedDistrict = 'Pune';
  String _selectedBlock = 'Haveli';
  final _villageCtrl = TextEditingController(text: '');

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

  // Maharashtra — all 36 districts
  final List<String> _maharashtraDistricts = [
    'Ahmednagar', 'Akola', 'Amravati', 'Aurangabad', 'Beed', 'Bhandara',
    'Buldhana', 'Chandrapur', 'Dhule', 'Gadchiroli', 'Gondia', 'Hingoli',
    'Jalgaon', 'Jalna', 'Kolhapur', 'Latur', 'Mumbai City', 'Mumbai Suburban',
    'Nagpur', 'Nanded', 'Nandurbar', 'Nashik', 'Osmanabad', 'Palghar',
    'Parbhani', 'Pune', 'Raigad', 'Ratnagiri', 'Sangli', 'Satara',
    'Sindhudurg', 'Solapur', 'Thane', 'Wardha', 'Washim', 'Yavatmal',
  ];

  // Talukas for each Maharashtra district
  final Map<String, List<String>> _districtBlocks = {
    'Ahmednagar': ['Ahmednagar', 'Akole', 'Jamkhed', 'Karjat', 'Kopargaon', 'Nagar', 'Nevasa', 'Parner', 'Pathardi', 'Rahata', 'Rahuri', 'Sangamner', 'Shevgaon', 'Shrigonda', 'Shrirampur'],
    'Akola': ['Akola', 'Akot', 'Balapur', 'Barshitakli', 'Murtizapur', 'Patur', 'Telhara'],
    'Amravati': ['Achalpur', 'Amravati', 'Anjangaon Surji', 'Chandur Bazar', 'Chandurbazar', 'Chikhaldara', 'Daryapur', 'Dhamangaon Rly', 'Morshi', 'Nandgaon Khandeshwar', 'Teosa', 'Warud'],
    'Aurangabad': ['Aurangabad', 'Gangapur', 'Kannad', 'Khuldabad', 'Paithan', 'Phulambri', 'Silod', 'Soegaon', 'Soyegaon', 'Vaijapur'],
    'Beed': ['Ambajogai', 'Ashti', 'Beed', 'Dharur', 'Georai', 'Kaij', 'Manjlegaon', 'Parli', 'Patoda', 'Shirur Kasar', 'Wadwani'],
    'Bhandara': ['Bhandara', 'Lakhandur', 'Lakhani', 'Mohadi', 'Pauni', 'Sakoli', 'Tumsar'],
    'Buldhana': ['Buldhana', 'Chikhli', 'Deolgaon Raja', 'Jalgaon Jamod', 'Khamgaon', 'Lonar', 'Malkapur', 'Mehkar', 'Motala', 'Nandura', 'Sangrampur', 'Shegaon', 'Sindkhed Raja'],
    'Chandrapur': ['Ballarpur', 'Bhadravati', 'Brahmapuri', 'Chandrapur', 'Chimur', 'Gondpipri', 'Jiwati', 'Korpana', 'Mul', 'Nagbhid', 'Pombhurna', 'Rajura', 'Sawali', 'Sindewahi', 'Warora'],
    'Dhule': ['Dhule', 'Sakri', 'Shirpur', 'Sindkheda'],
    'Gadchiroli': ['Aheri', 'Armori', 'Bhamragad', 'Chamorshi', 'Dhanora', 'Desaiganj', 'Etapalli', 'Gadchiroli', 'Korchi', 'Kurkheda', 'Mulchera', 'Sironcha'],
    'Gondia': ['Amgaon', 'Arjuni Morgaon', 'Deori', 'Gondia', 'Goregaon', 'Salekasa', 'Sadak Arjuni', 'Tirora'],
    'Hingoli': ['Aundha Nagnath', 'Basmath', 'Hingoli', 'Kalamnuri', 'Sengaon'],
    'Jalgaon': ['Amalner', 'Bhadgaon', 'Bhusawal', 'Bodwad', 'Chalisgaon', 'Chopda', 'Dharangaon', 'Erandol', 'Jalgaon', 'Jamner', 'Muktainagar', 'Pachora', 'Parola', 'Raver', 'Yawal'],
    'Jalna': ['Ambad', 'Badnapur', 'Bhokardan', 'Ghansawangi', 'Jafrabad', 'Jalna', 'Mantha', 'Partur'],
    'Kolhapur': ['Ajra', 'Bavada', 'Bhudargad', 'Chandgad', 'Gadhinglaj', 'Hatkanangle', 'Kagal', 'Karvir', 'Panhala', 'Radhanagari', 'Shahuwadi', 'Shirol'],
    'Latur': ['Ahmedpur', 'Ausa', 'Chakur', 'Deoni', 'Jalkot', 'Latur', 'Nilanga', 'Renapur', 'Shirur Anantpal', 'Udgir'],
    'Mumbai City': ['Mumbai City'],
    'Mumbai Suburban': ['Andheri', 'Borivali', 'Kurla'],
    'Nagpur': ['Bhiwapur', 'Hingna', 'Kadpar', 'Kamthi', 'Katol', 'Kuhi', 'Mauda', 'Nagpur Rural', 'Nagpur Urban', 'Narkhed', 'Parseoni', 'Ramtek', 'Savner', 'Umred'],
    'Nanded': ['Ardhapur', 'Biloli', 'Bhokar', 'Deglur', 'Dharmabad', 'Hadgaon', 'Himayatnagar', 'Kandhar', 'Kinwat', 'Loha', 'Mahur', 'Mudkhed', 'Mukhed', 'Naigaon', 'Nanded', 'Nandgaon', 'Umri'],
    'Nandurbar': ['Akkalkuwa', 'Akrani', 'Nandurbar', 'Nawapur', 'Shahada', 'Talode'],
    'Nashik': ['Baglan', 'Chandwad', 'Deola', 'Dindori', 'Igatpuri', 'Kalwan', 'Malegaon', 'Nandgaon', 'Nashik', 'Niphad', 'Peint', 'Sinnar', 'Surgana', 'Trimbakeshwar', 'Yeola'],
    'Osmanabad': ['Bhum', 'Kalamb', 'Lohara', 'Osmanabad', 'Paranda', 'Tuljapur', 'Umarga', 'Washi'],
    'Palghar': ['Dahanu', 'Jawhar', 'Mokhada', 'Palghar', 'Talasari', 'Vasai', 'Vikramgad', 'Wada'],
    'Parbhani': ['Gangakhed', 'Jintur', 'Manwath', 'Palam', 'Parbhani', 'Pathri', 'Purna', 'Selu', 'Sonpeth'],
    'Pune': ['Ambegaon', 'Baramati', 'Bhor', 'Daund', 'Haveli', 'Indapur', 'Junnar', 'Khed', 'Mawal', 'Mulshi', 'Purandar', 'Shirur', 'Velhe'],
    'Raigad': ['Alibag', 'Karjat', 'Khalapur', 'Mahad', 'Mangaon', 'Mhasla', 'Murud', 'Panvel', 'Pen', 'Poladpur', 'Roha', 'Shriwardhan', 'Sudhagad', 'Tala', 'Uran'],
    'Ratnagiri': ['Chiplun', 'Dapoli', 'Guhagar', 'Khed', 'Lanja', 'Mandangad', 'Rajapur', 'Ratnagiri', 'Sangameshwar'],
    'Sangli': ['Atpadi', 'Jat', 'Kadegaon', 'Kavathemahankal', 'Khanapur', 'Miraj', 'Palus', 'Shirala', 'Tasgaon', 'Valva', 'Waltepattan'],
    'Satara': ['Jaoli', 'Karad', 'Khandala', 'Khatav', 'Koregaon', 'Mahabaleshwar', 'Man', 'Patan', 'Phaltan', 'Satara', 'Wai'],
    'Sindhudurg': ['Deogad', 'Dodamarg', 'Kankavli', 'Kudal', 'Malvan', 'Sawantwadi', 'Vaibhavvadi', 'Vengurla'],
    'Solapur': ['Akkalkot', 'Barshi', 'Karmala', 'Madha', 'Malshiras', 'Mangalvedhe', 'Mohol', 'Pandharpur', 'Sangola', 'Solapur North', 'Solapur South'],
    'Thane': ['Ambarnath', 'Bhiwandi', 'Kalyan', 'Murbad', 'Shahapur', 'Thane', 'Ulhasnagar'],
    'Wardha': ['Arvi', 'Ashti', 'Deoli', 'Hinganghat', 'Karanja', 'Samudrapur', 'Seloo', 'Wardha'],
    'Washim': ['Karanja', 'Malegaon', 'Mangrulpir', 'Manora', 'Risod', 'Washim'],
    'Yavatmal': ['Arni', 'Babhulgaon', 'Darwha', 'Digras', 'Ghatanji', 'Kalamb', 'Kelapur', 'Mahagaon', 'Maregaon', 'Ner', 'Pusad', 'Ralegaon', 'Umarkhed', 'Wani', 'Yavatmal', 'Zari Jamni'],
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
    MediaService.instance.stopListening();
    MediaService.instance.stopRecording();
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

  Future<void> _toggleVoiceNameInput() async {
    if (_isSpeakingName) {
      await _stopVoiceNameInput();
    } else {
      await _startVoiceNameInput();
    }
  }

  Future<void> _startVoiceNameInput() async {
    final lang = LocalizationService.instance.currentLanguage;
    if (_nameCtrl.text == 'Sanjay Kumar') {
      _nameCtrl.clear();
    }

    setState(() {
      _isSpeakingName = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.mic_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Listening... Speak your name clearly [${lang.label}]'),
          ],
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF0D9488),
      ),
    );

    // Start native audio recorder
    await MediaService.instance.startRecording();

    // Start live speech-to-text recognition
    await MediaService.instance.startListening(
      localeId: lang.voiceLocaleCode,
      onResult: (words) {
        if (!mounted) return;
        if (words.trim().isNotEmpty) {
          final formatted = _capitalizeWords(words.trim());
          setState(() {
            _nameCtrl.text = formatted;
          });
        }
      },
    );
  }

  Future<void> _stopVoiceNameInput() async {
    final recordedPath = await MediaService.instance.stopRecording();
    await MediaService.instance.stopListening();

    if (!mounted) return;
    setState(() {
      _isSpeakingName = false;
    });

    final lang = LocalizationService.instance.currentLanguage;

    // If local STT produced no transcript (e.g. on Windows desktop),
    // transcribe the recorded audio via backend API
    if (_nameCtrl.text.trim().isEmpty && recordedPath != null && !kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 10),
              Text('Transcribing spoken name...'),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF0D9488),
        ),
      );

      try {
        final res = await widget.dataService.apiService.uploadMultipart(
          '/cases/media/transcribe',
          fields: {'language': lang.voiceLocaleCode},
          filePaths: {'audio_file': recordedPath},
        );
        if (res != null && res['transcript'] != null && res['transcript'].toString().trim().isNotEmpty) {
          if (!mounted) return;
          final transcript = res['transcript'].toString().trim();
          final formatted = _capitalizeWords(transcript);
          setState(() {
            _nameCtrl.text = formatted;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Voice captured: "$formatted"'),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
          return;
        }
      } catch (e) {
        debugPrint('[RegistrationScreen] Backend voice transcription notice: $e');
      }
    }

    if (!mounted) return;
    if (_nameCtrl.text.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Voice captured: "${_nameCtrl.text.trim()}"'),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No speech detected. Please speak louder or type your name.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _capitalizeWords(String input) {
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
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
      ),
      body: Column(
        children: [
          SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              minHeight: 4,
            ),
          ),
          Expanded(
            child: PageView(
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
          ),
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
              hintText: 'e.g. Ramesh Patil (or speak)',
              prefixIcon: const Icon(Icons.person_rounded),
              suffixIcon: IconButton(
                tooltip: _isSpeakingName ? 'Stop listening' : 'Speak your name',
                icon: _isSpeakingName
                    ? const Icon(Icons.stop_circle_rounded, color: Colors.red, size: 28)
                    : const Icon(Icons.mic_rounded, color: Color(0xFF0D9488), size: 28),
                onPressed: _toggleVoiceNameInput,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Speak name interactive card
          InkWell(
            onTap: _toggleVoiceNameInput,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _isSpeakingName ? Colors.red.shade50 : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSpeakingName ? Colors.red.shade400 : const Color(0xFF16A34A),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isSpeakingName ? Icons.stop_circle_rounded : Icons.mic_rounded,
                    size: 22,
                    color: _isSpeakingName ? Colors.red.shade700 : const Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isSpeakingName ? 'Listening... Tap to Stop & Save' : 'Tap to speak your name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _isSpeakingName ? Colors.red.shade800 : const Color(0xFF16A34A),
                      ),
                    ),
                  ),
                  if (_isSpeakingName) ...[
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.red),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF16A34A).withAlpha(77)),
                      ),
                      child: Text(
                        LocalizationService.instance.currentLanguage.label,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                    ),
                  ],
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
    final districts = _maharashtraDistricts;
    final talukas = _districtBlocks[_selectedDistrict] ?? ['Other'];

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

          // State — Static (Maharashtra only)
          Text('${context.tr('state')} *', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.map_rounded, color: Color(0xFF64748B), size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Maharashtra',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Fixed',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // District Dropdown — all 36 Maharashtra districts
          Text('${context.tr('district')} *', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: districts.contains(_selectedDistrict) ? _selectedDistrict : districts.first,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.location_city_rounded)),
            isExpanded: true,
            items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (val) {
              setState(() {
                _selectedDistrict = val!;
                _selectedBlock = _districtBlocks[_selectedDistrict]?.first ?? 'Other';
              });
            },
          ),
          const SizedBox(height: 16),

          // Taluk Dropdown — based on selected district
          Text('Taluk *', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: talukas.contains(_selectedBlock) ? _selectedBlock : talukas.first,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.apartment_rounded)),
            isExpanded: true,
            items: talukas.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
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
              hintText: 'Enter your village name',
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
          const SizedBox(height: 24),

          // Enter OTP
          Text(
            context.tr('enter_otp'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

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
