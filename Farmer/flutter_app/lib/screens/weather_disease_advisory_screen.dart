// Weather & Maharashtra District-Wise Livestock Seasonal Disease Advisory Screen
// Features real-time weather metrics, livestock THI (Heat Stress Index),
// Maharashtra district intelligence, seasonal disease epidemiology, and live Groq AI veterinary assistant.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/groq_weather_service.dart';
import '../services/localization_service.dart';
import '../services/location_service.dart';

class WeatherDiseaseAdvisoryScreen extends StatefulWidget {
  final String? initialDistrict;

  const WeatherDiseaseAdvisoryScreen({
    super.key,
    this.initialDistrict,
  });

  @override
  State<WeatherDiseaseAdvisoryScreen> createState() => _WeatherDiseaseAdvisoryScreenState();
}

class _WeatherDiseaseAdvisoryScreenState extends State<WeatherDiseaseAdvisoryScreen> with SingleTickerProviderStateMixin {
  bool get isMr => LocalizationService.instance.currentLanguage.code == 'mr';
  bool get isHi => LocalizationService.instance.currentLanguage.code == 'hi';

  final GroqWeatherService _weatherService = GroqWeatherService.instance;
  late String _selectedDistrict;
  late String _selectedSeason;
  late TabController _seasonTabController;

  DistrictWeatherData? _currentWeather;
  bool _isLoadingWeather = true;
  bool _isLoadingGroqAi = false;
  String? _groqAiResponse;
  String? _selectedDiseaseDetailId;

  final TextEditingController _customQuestionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _seasons = ['Monsoon', 'Winter', 'Summer'];

  @override
  void initState() {
    super.initState();
    _selectedDistrict = widget.initialDistrict ?? 'Pune';
    _selectedSeason = GroqWeatherService.getCurrentMaharashtraSeason();

    final seasonIndex = _seasons.indexOf(_selectedSeason);
    _seasonTabController = TabController(
      length: _seasons.length,
      vsync: this,
      initialIndex: seasonIndex != -1 ? seasonIndex : 0,
    );

    _seasonTabController.addListener(() {
      if (!_seasonTabController.indexIsChanging) {
        setState(() {
          _selectedSeason = _seasons[_seasonTabController.index];
        });
      }
    });

    _fetchData();

    // Re-fetch advisory whenever the user switches language
    LocalizationService.instance.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    // Re-fetch AI advisory in the newly selected language
    if (_currentWeather != null && !_isLoadingGroqAi) {
      _fetchGroqAdvisory();
    }
  }

  @override
  void dispose() {
    LocalizationService.instance.removeListener(_onLanguageChanged);
    _seasonTabController.dispose();
    _customQuestionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoadingWeather = true;
      _groqAiResponse = null;
    });

    final weather = await _weatherService.fetchDistrictWeather(_selectedDistrict);
    if (!mounted) return;

    setState(() {
      _currentWeather = weather;
      _isLoadingWeather = false;
    });

    // Auto-fetch Groq AI Advisory for the current weather & district
    _fetchGroqAdvisory();
  }

  Future<void> _fetchGroqAdvisory({String? customQuestion}) async {
    if (_currentWeather == null) return;

    setState(() {
      _isLoadingGroqAi = true;
    });

    final lang = LocalizationService.instance.currentLanguage.code;
    final advisory = await _weatherService.fetchGroqAdvisory(
      districtName: _selectedDistrict,
      weather: _currentWeather!,
      season: _selectedSeason,
      customQuestion: customQuestion,
      language: lang,
    );

    if (!mounted) return;
    setState(() {
      _groqAiResponse = advisory;
      _isLoadingGroqAi = false;
    });
  }

  Future<void> _autoDetectGpsDistrict() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📍 Detecting location via GPS...'),
        duration: Duration(seconds: 2),
      ),
    );

    final locResult = await LocationService.instance.getCurrentLocation();
    if (locResult.isGpsAcquired) {
      // Find closest Maharashtra district
      MaharashtraDistrict? closest;
      double minDistance = double.infinity;

      for (final d in GroqWeatherService.maharashtraDistricts) {
        final dist = LocationService.haversineDistance(
          locResult.latitude,
          locResult.longitude,
          d.latitude,
          d.longitude,
        );
        if (dist < minDistance) {
          minDistance = dist;
          closest = d;
        }
      }

      if (closest != null) {
        setState(() {
          _selectedDistrict = closest!.name;
        });
        _fetchData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Location matched to ${closest.name} (${closest.marathiName})'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        return;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Using standard Maharashtra district profile.'),
          backgroundColor: AppColors.info,
        ),
      );
    }
  }

  void _showDistrictSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String query = '';
        String? selectedZone;
        final zones = ['All', 'Western Maharashtra', 'Marathwada', 'Vidarbha', 'North Maharashtra', 'Konkan'];

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final filtered = GroqWeatherService.maharashtraDistricts.where((d) {
              final matchesQuery = query.isEmpty ||
                  d.name.toLowerCase().contains(query.toLowerCase()) ||
                  d.marathiName.toLowerCase().contains(query.toLowerCase()) ||
                  d.hindiName.toLowerCase().contains(query.toLowerCase());
              final matchesZone = selectedZone == null || selectedZone == 'All' || d.zone == selectedZone;
              return matchesQuery && matchesZone;
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollCtrl) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.location_city_rounded, color: AppColors.primary, size: 24),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Maharashtra District',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              ),
                              Text(
                                'महाराष्ट्र राज्य जिल्हा निवडा (३६ जिल्हे)',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Search field
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search district (e.g. Pune, Kolhapur, नाशिक)...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        filled: true,
                        fillColor: AppColors.surfaceSubtle,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: (val) => setModalState(() => query = val),
                    ),
                    const SizedBox(height: 10),

                    // Zone Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: zones.map((z) {
                          final isSel = (selectedZone == null && z == 'All') || selectedZone == z;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(z, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSel ? Colors.white : AppColors.textPrimary)),
                              selected: isSel,
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.surfaceSubtle,
                              checkmarkColor: Colors.white,
                              showCheckmark: false,
                              onSelected: (_) => setModalState(() => selectedZone = z == 'All' ? null : z),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1),

                    // District list
                    Expanded(
                      child: ListView.builder(
                        controller: scrollCtrl,
                        itemCount: filtered.length,
                        itemBuilder: (c, idx) {
                          final d = filtered[idx];
                          final isCurrent = d.name.toLowerCase() == _selectedDistrict.toLowerCase();
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isCurrent ? AppColors.primary : AppColors.primaryLight.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  d.name.substring(0, 1),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: isCurrent ? Colors.white : AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              '${d.name} (${d.marathiName})',
                              style: TextStyle(
                                fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                                color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text('${d.zone} • ${d.latitude.toStringAsFixed(2)}°N, ${d.longitude.toStringAsFixed(2)}°E', style: const TextStyle(fontSize: 11)),
                            trailing: isCurrent ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                            onTap: () {
                              Navigator.pop(ctx);
                              setState(() {
                                _selectedDistrict = d.name;
                              });
                              _fetchData();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final distObj = _weatherService.getDistrict(_selectedDistrict);
    final seasonalDiseases = _weatherService.getSeasonalDiseases(
      districtName: _selectedDistrict,
      season: _selectedSeason,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMr ? 'हवामान व पशुआरोग्य सल्ला' : (isHi ? 'मौसम एवं पशु स्वास्थ्य सलाह' : 'Weather & Livestock Health'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
            Text(
              '${distObj.name} (${distObj.marathiName}) • ${distObj.zone}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: AppColors.primary),
            tooltip: 'Auto-detect GPS District',
            onPressed: _autoDetectGpsDistrict,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Refresh Weather & AI Advisory',
            onPressed: _fetchData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── District Picker Bar ──────────────────────────────────────────
            _buildDistrictBar(distObj),
            const SizedBox(height: 14),

            // ── Live Weather & THI Index Card ───────────────────────────────
            _buildLiveWeatherCard(distObj),
            const SizedBox(height: 16),

            // ── Season Tabs (Monsoon, Winter, Summer) ────────────────────────
            _buildSeasonSelectorTabs(),
            const SizedBox(height: 16),

            // ── Groq AI Veterinary Advisory Card ─────────────────────────────
            _buildGroqAiAdvisoryCard(),
            const SizedBox(height: 18),

            // ── District-Wise Seasonal Disease Matrix ────────────────────────
            Row(
              children: [
                const Icon(Icons.coronavirus_rounded, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isMr
                        ? '⚠️ $selectedSeasonMarathi ऋतूतील मुख्य रोग (${distObj.marathiName})'
                        : (isHi
                            ? '⚠️ $selectedSeasonHindi मौसम के मुख्य रोग (${distObj.hindiName})'
                            : '⚠️ Seasonal Livestock Diseases (${distObj.name})'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${seasonalDiseases.length} Alerts',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildDiseaseList(seasonalDiseases),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String get selectedSeasonMarathi {
    if (_selectedSeason == 'Monsoon') return 'पावसाळा';
    if (_selectedSeason == 'Winter') return 'हिवाळा';
    return 'उन्हाळा';
  }

  String get selectedSeasonHindi {
    if (_selectedSeason == 'Monsoon') return 'मानसून';
    if (_selectedSeason == 'Winter') return 'सर्दी';
    return 'गर्मी';
  }

  Widget _buildDistrictBar(MaharashtraDistrict distObj) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      distObj.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${distObj.marathiName})',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                    ),
                  ],
                ),
                Text(
                  'Zone: ${distObj.zone}, Maharashtra',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.tune_rounded, size: 14),
            label: const Text('Change', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
            onPressed: _showDistrictSelector,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveWeatherCard(MaharashtraDistrict distObj) {
    if (_isLoadingWeather) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: 2.5),
              SizedBox(height: 12),
              Text('Fetching live weather for Maharashtra...', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    final weather = _currentWeather!;
    final thi = weather.thiIndex;

    Color thiColor = AppColors.success;
    IconData thiIcon = Icons.sentiment_very_satisfied_rounded;
    if (thi >= 88.0) {
      thiColor = AppColors.error;
      thiIcon = Icons.warning_rounded;
    } else if (thi >= 78.0) {
      thiColor = const Color(0xFFE65100);
      thiIcon = Icons.sentiment_dissatisfied_rounded;
    } else if (thi >= 72.0) {
      thiColor = const Color(0xFFF57C00);
      thiIcon = Icons.sentiment_neutral_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004D40), Color(0xFF00796B), Color(0xFF00897B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.primaryShadow(const Color(0xFF004D40)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: District & Weather condition
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.wb_sunny_rounded, color: Colors.amberAccent, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    isMr ? weather.conditionMarathi : (isHi ? weather.conditionHindi : weather.conditionName),
                    style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_rounded, color: Colors.white70, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '${isMr ? 'थेट' : (isHi ? 'लाइव' : 'Live')} • ${_formatTime(weather.timestamp)}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Temperature & Metrics Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${weather.temperature.toStringAsFixed(1)}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('C', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              _buildWeatherMetricBadge(Icons.water_drop_rounded, '${weather.humidity}%', isMr ? 'आर्द्रता' : (isHi ? 'नमी' : 'Humidity')),
              const SizedBox(width: 12),
              _buildWeatherMetricBadge(Icons.air_rounded, '${weather.windSpeed} km/h', isMr ? 'वारा' : (isHi ? 'हवा' : 'Wind')),
              const SizedBox(width: 12),
              _buildWeatherMetricBadge(Icons.grain_rounded, '${weather.precipitation} mm', isMr ? 'पाऊस' : (isHi ? 'बारिश' : 'Rain')),
            ],
          ),
          const SizedBox(height: 14),

          // Livestock Comfort Index / THI Meter Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(thiIcon, color: Colors.amberAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      isMr ? 'पशु आराम (THI इंडेक्स):' : (isHi ? 'पशु आराम (THI इंडेक्स):' : 'LIVESTOCK COMFORT (THI INDEX):'),
                      style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: thiColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'THI ${weather.thiIndex}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isMr ? weather.thiCategoryMarathi : (isHi ? weather.thiCategoryHindi : weather.thiCategory),
                  style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  isMr ? weather.thiAdviceMarathi : (isHi ? weather.thiAdviceHindi : weather.thiAdvice),
                  style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherMetricBadge(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
        Text(label.split(' ')[0], style: const TextStyle(color: Colors.white60, fontSize: 9)),
      ],
    );
  }

  Widget _buildSeasonSelectorTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _seasonTabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: isMr ? '🌧️ पावसाळा' : (isHi ? '🌧️ मानसून' : '🌧️ Monsoon')),
          Tab(text: isMr ? '❄️ हिवाळा' : (isHi ? '❄️ सर्दी' : '❄️ Winter')),
          Tab(text: isMr ? '☀️ उन्हाळा' : (isHi ? '☀️ गर्मी' : '☀️ Summer')),
        ],
      ),
    );
  }

  Widget _buildGroqAiAdvisoryCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF673AB7).withValues(alpha: 0.35)),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF512DA8), Color(0xFF673AB7)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.amberAccent, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMr ? 'पशुवैद्यकीय बुद्धिमत्ता' : (isHi ? 'पशु चिकित्सा इंटेलिजेंस' : 'Veterinary Intelligence'),
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        isMr ? 'AI-आधारित पशु आरोग्य सल्ला' : (isHi ? 'AI-आधारित पशु स्वास्थ्य सलाह' : 'AI-powered livestock health advisory'),
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                  tooltip: 'Regenerate Advisory',
                  onPressed: _isLoadingGroqAi ? null : () => _fetchGroqAdvisory(),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoadingGroqAi) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: Color(0xFF673AB7), strokeWidth: 2.5),
                          SizedBox(height: 12),
                          Text(
                            'Fetching veterinary advisory for current weather & district...',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (_groqAiResponse != null) ...[
                  // Render AI response
                  SelectableText(
                    _groqAiResponse!,
                    style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.copy_rounded, size: 14),
                        label: const Text('Copy Advice', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _groqAiResponse!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✓ AI advisory copied to clipboard'), duration: Duration(seconds: 2)),
                          );
                        },
                      ),
                    ],
                  ),
                ],

                const Divider(height: 20),

                // Quick Ask Chips
                Text(
                  isMr ? '💡 जलद पशुवैद्यकीय प्रश्न:' : (isHi ? '💡 त्वरित पशु चिकित्सा प्रश्न:' : '💡 Quick Veterinary Questions:'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildPromptChip(isMr ? '🌧️ पावसात गाईंना सडदाहापासून कसे वाचवावे?' : (isHi ? '🌧️ बारिश में गायों को थनैला से कैसे बचाएं?' : '🌧️ How to protect cows from mastitis in rain?')),
                    _buildPromptChip(isMr ? '💉 सध्या $_selectedDistrict मध्ये कोणती लस द्यावी?' : (isHi ? '💉 अभी $_selectedDistrict में कौन सी वैक्सीन दें?' : '💉 What vaccines to give in $_selectedDistrict right now?')),
                    _buildPromptChip(isMr ? '☀️ उन्हाळ्यात म्हशींच्या दुधातील घट कशी रोखावी?' : (isHi ? '☀️ गर्मी में भैंस के दूध की कमी कैसे रोकें?' : '☀️ How to prevent buffalo milk drop in heat?')),
                    _buildPromptChip(isMr ? '🩹 जनावरांच्या खुरांच्या जखमांसाठी प्रथमोपचार?' : (isHi ? '🩹 पशुओं के खुर के घावों के लिए प्राथमिक उपचार?' : '🩹 First aid for animal foot sores and limping?')),
                  ],
                ),
                const SizedBox(height: 12),

                // Ask custom query input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customQuestionController,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: isMr 
                              ? '$_selectedDistrict मधील पशु आरोग्याबद्दल विचारा...' 
                              : (isHi ? '$_selectedDistrict में पशु स्वास्थ्य के बारे में पूछें...' : 'Ask about livestock health in $_selectedDistrict...'),
                          hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: AppColors.surfaceSubtle,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                        ),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            _fetchGroqAdvisory(customQuestion: val.trim());
                            _customQuestionController.clear();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF512DA8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        final val = _customQuestionController.text.trim();
                        if (val.isNotEmpty) {
                          _fetchGroqAdvisory(customQuestion: val);
                          _customQuestionController.clear();
                        }
                      },
                      child: const Icon(Icons.send_rounded, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String prompt) {
    return ActionChip(
      label: Text(prompt, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF512DA8))),
      backgroundColor: const Color(0xFFEDE7F6),
      side: const BorderSide(color: Color(0xFFD1C4E9)),
      onPressed: () => _fetchGroqAdvisory(customQuestion: prompt),
    );
  }

  Widget _buildDiseaseList(List<SeasonalDiseaseInfo> diseases) {
    if (diseases.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            isMr ? 'या ऋतूसाठी कोणतेही मुख्य रोग नोंदवलेले नाहीत.' : (isHi ? 'इस मौसम के लिए कोई प्रमुख रोग दर्ज नहीं हैं।' : 'No high-risk diseases recorded for this season.'),
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return Column(
      children: diseases.map((d) {
        final isExpanded = _selectedDiseaseDetailId == d.id;
        final isCritical = d.riskLevel == 'Critical';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCritical
                  ? AppColors.error.withValues(alpha: 0.4)
                  : (isExpanded ? AppColors.primary : AppColors.border),
              width: isExpanded || isCritical ? 1.5 : 1.0,
            ),
            boxShadow: AppShadows.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Disease Header Tile
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() {
                    _selectedDiseaseDetailId = isExpanded ? null : d.id;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isCritical
                              ? AppColors.error.withValues(alpha: 0.12)
                              : AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            isCritical ? Icons.emergency_rounded : Icons.shield_outlined,
                            color: isCritical ? AppColors.error : AppColors.warning,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isMr ? d.marathiName : (isHi ? d.hindiName : d.name),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14.5,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isCritical ? AppColors.error : const Color(0xFFF57C00),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    d.riskLevel.toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                            if (!isMr && !isHi) ...[
                              const SizedBox(height: 2),
                              Text(
                                d.marathiName,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _buildTag(Icons.bug_report_rounded, d.pathogenType, Colors.purple),
                                ...d.affectedAnimals.map((a) => _buildTag(Icons.pets_rounded, a, AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded Details Panel
              if (isExpanded) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Why it spreads in this season
                      _buildDetailSection(
                        '🌦️ Seasonal Trigger (हवामानामुळे प्रसार):',
                        d.transmissionTrigger,
                        const Color(0xFF0277BD),
                      ),
                      const SizedBox(height: 12),

                      // Symptoms
                      const Text(
                        '🔍 Key Symptoms to Watch For (लक्षणे):',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      ...d.symptoms.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                              Expanded(child: Text(s, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Preventive Farm Management
                      const Text(
                        '🛡️ Preventive Measures (प्रतिबंधात्मक उपाय):',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.successDark),
                      ),
                      const SizedBox(height: 4),
                      ...d.preventiveActions.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('✓ ', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                              Expanded(child: Text(p, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Vaccination
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCE93D8)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.vaccines_rounded, color: Color(0xFF7B1FA2), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'VACCINATION SCHEDULE (लसीकरण):',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF7B1FA2)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(d.vaccinationInfo, style: const TextStyle(fontSize: 11.5, color: Color(0xFF4A148C))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Emergency First Aid
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFB74D)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.medical_services_rounded, color: Color(0xFFE65100), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'EMERGENCY FIRST AID (प्रथमोपचार):',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFE65100)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(d.emergencyFirstAid, style: const TextStyle(fontSize: 11.5, color: Color(0xFFBF360C))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTag(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, Color titleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: titleColor)),
        const SizedBox(height: 2),
        Text(content, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3)),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
