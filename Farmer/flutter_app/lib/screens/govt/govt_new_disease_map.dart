// Smart Livestock — Government Disease Intelligence Map (Tab 2)
// High-Performance Native OpenStreetMap GIS Command Center
// Fully integrated with Maharashtra 36 Districts, National Surveillance, and the Government Workflow.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'govt_theme.dart';
import 'govt_new_data.dart';
import 'govt_models.dart';
import 'govt_mock_data.dart';
import '../../services/farmer_data_service.dart';

// ─── GIS Geographic Data ───────────────────────────────────────────────────────

final Map<String, LatLng> _districtCoordinates = {
  'Nagpur': LatLng(21.1458, 79.0882),
  'Amravati': LatLng(20.9374, 77.7796),
  'Nashik': LatLng(19.9975, 73.7898),
  'Jalgaon': LatLng(21.0077, 75.5626),
  'Chhatrapati Sambhajinagar': LatLng(19.8762, 75.3433),
  'Nanded': LatLng(19.1383, 77.3210),
  'Solapur': LatLng(17.6868, 75.9010),
  'Pune': LatLng(18.5204, 73.8567),
  'Latur': LatLng(18.4088, 76.5604),
  'Kolhapur': LatLng(16.7050, 74.2433),
  'Sangli': LatLng(16.8524, 74.5815),
  'Satara': LatLng(17.6805, 74.0183),
  'Raigad': LatLng(18.5145, 73.1801),
  'Ratnagiri': LatLng(16.9944, 73.3001),
  'Sindhudurg': LatLng(16.3524, 73.8637),
  'Thane': LatLng(19.2183, 72.9781),
  'Mumbai': LatLng(19.0760, 72.8777),
  'Mumbai Suburban': LatLng(19.1300, 72.8800),
  'Palghar': LatLng(19.6967, 72.7656),
  'Dhule': LatLng(20.9042, 74.7749),
  'Nandurbar': LatLng(21.3658, 74.2438),
  'Ahmednagar': LatLng(19.0952, 74.7480),
  'Ahilyanagar': LatLng(19.0952, 74.7480),
  'Beed': LatLng(18.9891, 75.7601),
  'Osmanabad': LatLng(18.1860, 76.0408),
  'Dharashiv': LatLng(18.1860, 76.0408),
  'Hingoli': LatLng(19.7173, 77.1494),
  'Parbhani': LatLng(19.2704, 76.7746),
  'Jalna': LatLng(19.8347, 75.8816),
  'Yavatmal': LatLng(20.3888, 78.1204),
  'Wardha': LatLng(20.7453, 78.6022),
  'Bhandara': LatLng(21.1702, 79.6481),
  'Gondia': LatLng(21.4617, 80.1961),
  'Chandrapur': LatLng(19.9615, 79.2961),
  'Gadchiroli': LatLng(20.1809, 80.0017),
  'Washim': LatLng(20.1119, 77.1297),
  'Akola': LatLng(20.7002, 77.0082),
  'Buldhana': LatLng(20.5292, 76.1842),
};

final Map<String, LatLng> _stateCoordinates = {
  'TN': LatLng(11.1271, 78.6569),
  'KA': LatLng(15.3173, 75.7139),
  'AP': LatLng(15.9129, 79.7400),
  'KL': LatLng(10.8505, 76.2711),
  'MH': LatLng(19.7515, 75.7139),
  'UP': LatLng(26.8467, 80.9462),
  'GJ': LatLng(22.2587, 71.1924),
  'WB': LatLng(22.9868, 87.8550),
  'MP': LatLng(22.9734, 78.6569),
  'RJ': LatLng(27.0238, 74.2179),
  'HR': LatLng(29.0588, 76.0856),
  'PB': LatLng(31.1471, 75.3412),
  'BR': LatLng(25.0961, 85.3131),
  'OR': LatLng(20.9517, 85.0985),
  'AS': LatLng(26.2006, 92.9376),
};

enum MapScope { maharashtra, national }

// ─── Main Widget ─────────────────────────────────────────────────────────────

class GovtNewDiseaseMap extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;
  final FarmerDataService? dataService;

  const GovtNewDiseaseMap({
    super.key,
    this.onNavigateTab,
    this.dataService,
  });

  @override
  State<GovtNewDiseaseMap> createState() => _GovtNewDiseaseMapState();
}

class _GovtNewDiseaseMapState extends State<GovtNewDiseaseMap>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();
  late AnimationController _pulseCtrl;

  MapScope _scope = MapScope.maharashtra;
  String _activeLayer = 'Disease Risk';
  String _selectedDisease = 'All';
  String _searchQuery = '';

  DistrictData? _selectedDistrict;
  StateRiskProfile? _selectedState;

  late final List<StateRiskProfile> _nationalStates;

  static final LatLng _mhCentre = LatLng(19.25, 76.5);
  static final LatLng _indiaCentre = LatLng(20.5937, 78.9629);

  static const _layers = [
    'Disease Risk',
    'Vaccination Deficit',
    'Active Cases',
    'Mortality',
  ];

  static const _diseases = [
    'All',
    'Foot-and-Mouth Disease (FMD)',
    'Lumpy Skin Disease (LSD)',
    'Brucellosis',
    'Anthrax',
    'Haemorrhagic Septicaemia (HS)',
    'Peste des Petits Ruminants (PPR)',
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _nationalStates = GovtMockData.getIndiaStatesRiskProfiles();

    // Select Pune or first high-risk district by default
    final initial = maharashtraDistricts.firstWhere(
      (d) => d.id == 'pune',
      orElse: () => maharashtraDistricts.first,
    );
    _selectedDistrict = initial;
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── Filtered Districts ────────────────────────────────────────────────────

  List<DistrictData> get _filteredDistricts {
    return maharashtraDistricts.where((d) {
      final matchesSearch = _searchQuery.isEmpty ||
          d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.marathiName.contains(_searchQuery) ||
          d.division.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesDisease = _selectedDisease == 'All' ||
          d.suspectedDisease.toLowerCase().contains(_selectedDisease.toLowerCase()) ||
          (_selectedDisease.contains('FMD') && d.suspectedDisease.contains('FMD')) ||
          (_selectedDisease.contains('LSD') && d.suspectedDisease.contains('LSD')) ||
          (_selectedDisease.contains('Anthrax') && d.suspectedDisease.contains('Anthrax')) ||
          (_selectedDisease.contains('Brucellosis') && d.suspectedDisease.contains('Brucellosis')) ||
          (_selectedDisease.contains('HS') && d.suspectedDisease.contains('HS')) ||
          (_selectedDisease.contains('PPR') && d.suspectedDisease.contains('PPR'));

      return matchesSearch && matchesDisease;
    }).toList();
  }

  // ─── Color Helpers ─────────────────────────────────────────────────────────

  Color _getDistrictColor(DistrictData d) {
    if (_activeLayer == 'Vaccination Deficit') {
      if (d.vaccinationCoverage < 65) return const Color(0xFFB91C1C);
      if (d.vaccinationCoverage < 75) return const Color(0xFFEA580C);
      if (d.vaccinationCoverage < 85) return const Color(0xFFCA8A04);
      return const Color(0xFF16A34A);
    }
    if (_activeLayer == 'Active Cases') {
      if (d.activeCases >= 50) return const Color(0xFFB91C1C);
      if (d.activeCases >= 35) return const Color(0xFFEA580C);
      if (d.activeCases >= 20) return const Color(0xFFCA8A04);
      return const Color(0xFF16A34A);
    }
    if (_activeLayer == 'Mortality') {
      if (d.mortality >= 6) return const Color(0xFFB91C1C);
      if (d.mortality >= 4) return const Color(0xFFEA580C);
      if (d.mortality >= 2) return const Color(0xFFCA8A04);
      return const Color(0xFF16A34A);
    }
    // Default: Disease Risk
    switch (d.riskLevel) {
      case RiskLevel.critical:
        return const Color(0xFFB91C1C);
      case RiskLevel.high:
        return const Color(0xFFEA580C);
      case RiskLevel.moderate:
        return const Color(0xFFCA8A04);
      case RiskLevel.low:
        return const Color(0xFF16A34A);
    }
  }

  Color _getStateColor(StateRiskProfile s) {
    if (s.riskScore >= 80) return const Color(0xFFB91C1C);
    if (s.riskScore >= 65) return const Color(0xFFEA580C);
    if (s.riskScore >= 50) return const Color(0xFFCA8A04);
    return const Color(0xFF16A34A);
  }

  void _selectAndCenterDistrict(DistrictData d) {
    setState(() => _selectedDistrict = d);
    final coords = _districtCoordinates[d.name];
    if (coords != null) {
      _mapController.move(coords, 8.5);
    }
  }

  // ─── Markers ───────────────────────────────────────────────────────────────

  List<Marker> _buildMaharashtraMarkers() {
    return _filteredDistricts.map((d) {
      final coords = _districtCoordinates[d.name];
      if (coords == null) return null;

      final isSelected = _selectedDistrict?.id == d.id;
      final color = _getDistrictColor(d);
      final r = 16.0 + (d.riskScore / 100.0) * 14.0;

      return Marker(
        point: coords,
        width: isSelected ? r * 3.4 : r * 2.5,
        height: isSelected ? r * 3.4 : r * 2.5,
        child: GestureDetector(
          onTap: () => _selectAndCenterDistrict(d),
          child: AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, _) {
              final pulse = (isSelected || d.riskScore >= 70) ? _pulseCtrl.value : 0.0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected || d.riskScore >= 70)
                    Container(
                      width: r * 2.2 + pulse * 12,
                      height: r * 2.2 + pulse * 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.18 + pulse * 0.12),
                      ),
                    ),
                  Container(
                    width: r * (isSelected ? 1.6 : 1.1),
                    height: r * (isSelected ? 1.6 : 1.1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.92),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.85),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: isSelected ? 10 : 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _activeLayer == 'Vaccination Deficit'
                            ? '${d.vaccinationCoverage.toInt()}%'
                            : _activeLayer == 'Active Cases'
                                ? '${d.activeCases}'
                                : '${d.riskScore}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSelected ? 11 : 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }).whereType<Marker>().toList();
  }

  List<Marker> _buildNationalMarkers() {
    return _nationalStates.map((s) {
      final coords = _stateCoordinates[s.code];
      if (coords == null) return null;

      final isSelected = _selectedState?.code == s.code;
      final color = _getStateColor(s);
      final r = 18.0 + (s.activeCases.clamp(0, 400) / 400.0) * 14.0;

      return Marker(
        point: coords,
        width: isSelected ? r * 3.2 : r * 2.4,
        height: isSelected ? r * 3.2 : r * 2.4,
        child: GestureDetector(
          onTap: () => setState(() => _selectedState = s),
          child: AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, _) {
              final pulse = isSelected ? _pulseCtrl.value : 0.0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected || s.riskScore >= 75)
                    Container(
                      width: r * 2.0 + pulse * 10,
                      height: r * 2.0 + pulse * 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.2 + pulse * 0.1),
                      ),
                    ),
                  Container(
                    width: r * (isSelected ? 1.5 : 1.0),
                    height: r * (isSelected ? 1.5 : 1.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.9),
                      border: Border.all(
                        color: isSelected ? Colors.white : color.withValues(alpha: 0.5),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        s.code,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: r * 0.38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }).whereType<Marker>().toList();
  }

  // ─── Header & Command Bar ──────────────────────────────────────────────────

  Widget _buildCommandBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: GovtColors.surface,
        border: Border(bottom: BorderSide(color: Color(0xFFE4EAF0))),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          // Title + Live GIS badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'LIVE GIS MAP',
                      style: TextStyle(
                        color: Color(0xFF16A34A),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _scope == MapScope.maharashtra
                    ? 'Maharashtra Epidemiological Surveillance'
                    : 'All-India National Disease Surveillance',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF18232B),
                ),
              ),
            ],
          ),

          // Action controls
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Scope toggle: Maharashtra vs India
              SegmentedButton<MapScope>(
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                segments: const [
                  ButtonSegment(
                    value: MapScope.maharashtra,
                    label: Text('Maharashtra (36)', style: TextStyle(fontSize: 11)),
                  ),
                  ButtonSegment(
                    value: MapScope.national,
                    label: Text('National India', style: TextStyle(fontSize: 11)),
                  ),
                ],
                selected: {_scope},
                onSelectionChanged: (set) {
                  final s = set.first;
                  setState(() => _scope = s);
                  if (s == MapScope.maharashtra) {
                    _mapController.move(_mhCentre, 7.0);
                  } else {
                    _mapController.move(_indiaCentre, 5.0);
                  }
                },
              ),

              // Layer selector
              Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE4EAF0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _activeLayer,
                    isDense: true,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF18232B)),
                    icon: const Icon(Icons.layers_outlined, size: 16, color: Color(0xFF667482)),
                    items: _layers.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _activeLayer = v);
                    },
                  ),
                ),
              ),

              // Disease selector
              if (_scope == MapScope.maharashtra)
                Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE4EAF0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDisease,
                      isDense: true,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF18232B)),
                      icon: const Icon(Icons.coronavirus_outlined, size: 16, color: Color(0xFF667482)),
                      items: _diseases.map((d) {
                        final label = d == 'All' ? 'All Diseases' : d.split('(').first.trim();
                        return DropdownMenuItem(value: d, child: Text(label));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedDisease = v);
                      },
                    ),
                  ),
                ),

              // Reset Camera
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.my_location_rounded, size: 18, color: Color(0xFF1769AA)),
                tooltip: 'Recenter View',
                onPressed: () {
                  if (_scope == MapScope.maharashtra) {
                    _mapController.move(_mhCentre, 7.0);
                  } else {
                    _mapController.move(_indiaCentre, 5.0);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Search Bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: GovtColors.surface,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE4EAF0)),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(fontSize: 12.5),
                decoration: InputDecoration(
                  hintText: 'Search Maharashtra district (e.g. Pune, Nagpur, Nashik, Amravati)...',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF667482)),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF667482)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 9),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${_filteredDistricts.length} / ${maharashtraDistricts.length} Districts',
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF667482)),
          ),
        ],
      ),
    );
  }

  // ─── Map Viewport ──────────────────────────────────────────────────────────

  Widget _buildMap() {
    final markers = _scope == MapScope.maharashtra
        ? _buildMaharashtraMarkers()
        : _buildNationalMarkers();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _mhCentre,
            initialZoom: 7.0,
            minZoom: 4.0,
            maxZoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.smartlivestock.flutter_app',
              maxZoom: 19,
            ),
            MarkerLayer(markers: markers),
          ],
        ),

        // Attribution
        Positioned(
          bottom: 6,
          right: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black12),
            ),
            child: const Text(
              '© OpenStreetMap contributors',
              style: TextStyle(fontSize: 9, color: Colors.black87),
            ),
          ),
        ),

        // Floating Legend
        Positioned(
          bottom: 12,
          left: 12,
          child: _buildLegend(),
        ),
      ],
    );
  }

  // ─── Floating Legend ───────────────────────────────────────────────────────

  Widget _buildLegend() {
    final items = [
      (const Color(0xFFB91C1C), 'Critical (≥75%)'),
      (const Color(0xFFEA580C), 'High (60–74%)'),
      (const Color(0xFFCA8A04), 'Moderate (45–59%)'),
      (const Color(0xFF16A34A), 'Low (<45%)'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE4EAF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _activeLayer.toUpperCase(),
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF667482), letterSpacing: 0.5),
          ),
          const SizedBox(height: 5),
          ...items.map(
            (it) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: it.$1),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    it.$2,
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: Color(0xFF18232B)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── District Inspector (Dossier) ──────────────────────────────────────────

  Widget _buildDistrictInspector(DistrictData d) {
    final color = _getDistrictColor(d);

    // Check FarmerDataService live reports for this district
    final liveReportsCount = widget.dataService
            ?.getHealthReports()
            .where((r) => (r.location ?? '').toLowerCase().contains(d.name.toLowerCase()))
            .length ??
        0;

    return Container(
      color: GovtColors.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge + Risk Level
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '${riskLevelLabel(d.riskLevel).toUpperCase()} RISK • ${d.riskScore}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FB),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE4EAF0)),
                  ),
                  child: Text(
                    '${d.division} Division',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF667482)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // District Name in English + Marathi
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  d.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF18232B),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${d.marathiName})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667482),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              d.suspectedDisease,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1769AA),
              ),
            ),
            const SizedBox(height: 14),

            // 4 KPI Grid
            Row(
              children: [
                Expanded(child: _metricBox('Active Cases', '${d.activeCases}', const Color(0xFFC94343))),
                const SizedBox(width: 8),
                Expanded(child: _metricBox('Mortality', '${d.mortality}', const Color(0xFF18232B))),
                const SizedBox(width: 8),
                Expanded(child: _metricBox('Vaccination', '${d.vaccinationCoverage.toStringAsFixed(1)}%', const Color(0xFF087F73))),
                const SizedBox(width: 8),
                Expanded(child: _metricBox('Trend', d.trend, d.trend.startsWith('+') ? const Color(0xFFC94343) : const Color(0xFF087F73))),
              ],
            ),
            const SizedBox(height: 14),

            // Live Farmer Connection Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4F1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF087F73).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sync_alt_rounded, size: 16, color: Color(0xFF087F73)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      liveReportsCount > 0
                          ? '$liveReportsCount live syndromic report(s) active from ${d.name} farmers.'
                          : 'Real-time Farmer -> Vet -> Government data pipeline synchronized.',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF087F73)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Clinical Summary
            const Text('Epidemiological Summary', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF18232B))),
            const SizedBox(height: 4),
            Text(
              d.riskSummary,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF4A5568), height: 1.45),
            ),
            const SizedBox(height: 12),

            // Why at risk bullets
            const Text('Primary Drivers of Transmission', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF18232B))),
            const SizedBox(height: 6),
            ...d.whyAtRisk.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 13, color: Color(0xFFC94343), fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        reason,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF4A5568), height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Vaccination Gap alert
            if (d.vaccinationGap.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5D6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD99A18).withValues(alpha: 0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.vaccines_rounded, size: 16, color: Color(0xFFB87A04)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Vaccination Gap Detected', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFB87A04))),
                          const SizedBox(height: 2),
                          Text(d.vaccinationGap, style: const TextStyle(fontSize: 10.5, color: Color(0xFF5A4100))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Assigned Veterinary Response Teams
            if (d.assignedTeams.isNotEmpty) ...[
              const Text('Assigned Veterinary Response Team', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF18232B))),
              const SizedBox(height: 6),
              ...d.assignedTeams.map(
                (tm) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE4EAF0)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFFEAF3FB),
                        child: Icon(Icons.medical_services_outlined, size: 14, color: Color(0xFF1769AA)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tm.leadVet, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF18232B))),
                            Text('${tm.mobileUnit} • ${tm.contact}', style: const TextStyle(fontSize: 10, color: Color(0xFF667482))),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F4F1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tm.status,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF087F73)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // ── Connect All Things: Government Action Bar ─────────────────────
            const Text('Government Direct Action Dispatch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF18232B))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // 1. Launch Campaign -> Tab 2
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF087F73),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.vaccines_rounded, size: 15),
                  label: const Text('Launch Campaign', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  onPressed: () {
                    widget.onNavigateTab?.call(2); // Navigate to Campaigns tab
                  },
                ),

                // 2. Outbreak Signals -> Tab 3
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC94343),
                    side: const BorderSide(color: Color(0xFFC94343)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.monitor_heart_rounded, size: 15),
                  label: const Text('Outbreak Signals', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  onPressed: () {
                    widget.onNavigateTab?.call(3); // Navigate to Outbreak tab
                  },
                ),

                // 3. Issue Containment Alert -> Tab 4
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD99A18),
                    side: const BorderSide(color: Color(0xFFD99A18)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.notifications_active_rounded, size: 15),
                  label: const Text('Issue Alert', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  onPressed: () {
                    widget.onNavigateTab?.call(4); // Navigate to Alerts tab
                  },
                ),

                // 4. Deploy Mobile Unit -> Tab 6
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1769AA),
                    side: const BorderSide(color: Color(0xFF1769AA)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.shield_rounded, size: 15),
                  label: const Text('Deploy Vet Unit', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  onPressed: () {
                    widget.onNavigateTab?.call(6); // Navigate to Response tab
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricBox(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE4EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 9.5, color: Color(0xFF667482)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ─── Build Screen ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      body: Column(
        children: [
          _buildCommandBar(),
          _buildSearchBar(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                final selected = _selectedDistrict;

                if (isWide && selected != null) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildMap(),
                      ),
                      Container(
                        width: 1,
                        color: const Color(0xFFE4EAF0),
                      ),
                      SizedBox(
                        width: 380,
                        child: _buildDistrictInspector(selected),
                      ),
                    ],
                  );
                }

                // Narrow / Mobile Layout
                return Column(
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildMap(),
                    ),
                    if (selected != null)
                      Expanded(
                        flex: 4,
                        child: _buildDistrictInspector(selected),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
