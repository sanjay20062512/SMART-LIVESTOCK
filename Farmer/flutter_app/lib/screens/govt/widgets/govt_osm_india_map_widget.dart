// Government Module — Real-Time OSM India Disease Intelligence Map Widget
// Uses flutter_map + OpenStreetMap tiles for live interactive national GIS.
// Shows state-level risk markers and drill-down to district view.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../govt_theme.dart';
import '../govt_models.dart';
import '../govt_mock_data.dart';

// ignore_for_file: deprecated_member_use

// ─── Accurate lat/lng for Indian state capitals / centres ────────────────────
final Map<String, LatLng> _stateCoords = {
  'TN': LatLng(11.1271, 78.6569),  // Tamil Nadu
  'KA': LatLng(15.3173, 75.7139),  // Karnataka
  'AP': LatLng(15.9129, 79.7400),  // Andhra Pradesh
  'KL': LatLng(10.8505, 76.2711),  // Kerala
  'MH': LatLng(19.7515, 75.7139),  // Maharashtra
  'UP': LatLng(26.8467, 80.9462),  // Uttar Pradesh
  'GJ': LatLng(22.2587, 71.1924),  // Gujarat
  'WB': LatLng(22.9868, 87.8550),  // West Bengal
  'MP': LatLng(22.9734, 78.6569),  // Madhya Pradesh
  'RJ': LatLng(27.0238, 74.2179),  // Rajasthan
  'HR': LatLng(29.0588, 76.0856),  // Haryana
  'PB': LatLng(31.1471, 75.3412),  // Punjab
  'BR': LatLng(25.0961, 85.3131),  // Bihar
  'OR': LatLng(20.9517, 85.0985),  // Odisha
  'AS': LatLng(26.2006, 92.9376),  // Assam
};

Color _stateRiskColor(StateRiskProfile s) {
  if (s.riskScore >= 80) return const Color(0xFFB91C1C);
  if (s.riskScore >= 65) return const Color(0xFFEA580C);
  if (s.riskScore >= 50) return const Color(0xFFCA8A04);
  return const Color(0xFF16A34A);
}

// ─── Main Widget ─────────────────────────────────────────────────────────────
class GovtOsmIndiaDiseaseMap extends StatefulWidget {
  final bool isExpanded;
  final String currentJurisdictionState;
  final String currentJurisdictionDistrict;
  final ValueChanged<String>? onStateSelected;
  final ValueChanged<String>? onDistrictSelected;

  const GovtOsmIndiaDiseaseMap({
    super.key,
    this.isExpanded = false,
    this.currentJurisdictionState = 'MAHARASHTRA',
    this.currentJurisdictionDistrict = 'PUNE',
    this.onStateSelected,
    this.onDistrictSelected,
  });

  @override
  State<GovtOsmIndiaDiseaseMap> createState() => _GovtOsmIndiaDiseaseMapState();
}

class _GovtOsmIndiaDiseaseMapState extends State<GovtOsmIndiaDiseaseMap>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseCtrl;

  late final List<StateRiskProfile> _states;
  StateRiskProfile? _selectedState;
  String _activeLayer = 'Disease Cases';

  static final LatLng _indiaCentre = LatLng(20.5937, 78.9629);

  static const _layers = [
    'Disease Cases', 'Mortality', 'Vaccination Coverage',
    'Livestock Density', 'Outbreak Clusters',
  ];

  @override
  void initState() {
    super.initState();
    _states = GovtMockData.getIndiaStatesRiskProfiles();
    _selectedState = _states.isNotEmpty ? _states.first : null;

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  List<Marker> _buildStateMarkers() {
    return _states.map((s) {
      final coords = _stateCoords[s.code];
      if (coords == null) return null;

      final color = _stateRiskColor(s);
      final isSelected = _selectedState?.code == s.code;
      final r = 18.0 + (s.activeCases.clamp(0, 400) / 400.0) * 16.0;

      return Marker(
        point: coords,
        width: isSelected ? r * 3.2 : r * 2.4,
        height: isSelected ? r * 3.2 : r * 2.4,
        child: GestureDetector(
          onTap: () {
            setState(() => _selectedState = s);
            widget.onStateSelected?.call(s.name);
          },
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
                        color: color.withValues(alpha: 0.15 + pulse * 0.1),
                      ),
                    ),
                  Container(
                    width: r * (isSelected ? 1.5 : 1.0),
                    height: r * (isSelected ? 1.5 : 1.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.85),
                      border: Border.all(
                        color: isSelected ? Colors.white : color.withValues(alpha: 0.45),
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

  Widget _buildCommandBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        border: Border(bottom: BorderSide(color: GovtColors.border)),
      ),
      child: Row(
        children: [
          // Live badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF16A34A))),
                const SizedBox(width: 5),
                const Text('LIVE OSM', style: TextStyle(color: Color(0xFF16A34A), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Text('National Disease Intelligence', style: TextStyle(color: GovtColors.textSecondary, fontSize: 12)),
          const Spacer(),
          // Layer selector
          SizedBox(
            width: 160,
            child: DropdownButton<String>(
              value: _activeLayer,
              isDense: true,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: GovtColors.surface,
              style: const TextStyle(color: GovtColors.textPrimary, fontSize: 12),
              icon: const Icon(Icons.arrow_drop_down, color: GovtColors.textSecondary, size: 18),
              items: _layers.map((l) => DropdownMenuItem(value: l, child: Text(l, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) => setState(() => _activeLayer = v!),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.my_location_rounded, size: 18, color: GovtColors.textSecondary),
            tooltip: 'Reset to India view',
            onPressed: () => _mapController.move(_indiaCentre, 5.0),
          ),
        ],
      ),
    );
  }

  Widget _buildStateInfoCard() {
    final s = _selectedState;
    if (s == null) return const SizedBox.shrink();
    final color = _stateRiskColor(s);

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1.5),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.18), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Text(s.riskLevel, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(s.name, style: const TextStyle(color: GovtColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis)),
              Text('Risk: ${s.riskScore}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _chip(Icons.coronavirus_rounded, '${s.activeCases} Cases', Colors.orange),
              _chip(Icons.report_rounded, '${s.confirmedOutbreaks} Outbreaks', Colors.red),
              _chip(Icons.vaccines_rounded, '${s.vaccinationCoverage}% Vacc', Colors.blue),
            ],
          ),
          const SizedBox(height: 4),
          Text('🦠 ${s.dominantDisease}  ${s.trendDirection == 'up' ? '↑' : s.trendDirection == 'down' ? '↓' : '→'} ${s.trendPercent}%',
              style: const TextStyle(color: GovtColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      );

  Widget _buildLegend() {
    const items = [
      (Color(0xFFB91C1C), 'Critical >=80'),
      (Color(0xFFEA580C), 'High 65-79'),
      (Color(0xFFCA8A04), 'Medium 50-64'),
      (Color(0xFF16A34A), 'Low <50'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: GovtColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GovtColors.border),
        boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 6)],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 4,
        children: items.map((i) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: i.$1)),
                const SizedBox(width: 4),
                Text(i.$2, style: const TextStyle(color: GovtColors.textSecondary, fontSize: 11)),
              ],
            )).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = _buildStateMarkers();

    return Container(
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: GovtColors.border),
        boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: GovtRadius.mdRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCommandBar(),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _indiaCentre,
                      initialZoom: 5.0,
                      minZoom: 3.5,
                      maxZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.smartlivestock.flutter_app',
                        maxZoom: 18,
                      ),
                      MarkerLayer(markers: markers),
                    ],
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(4)),
                      child: const Text('(c) OpenStreetMap contributors', style: TextStyle(fontSize: 9, color: Colors.black87)),
                    ),
                  ),
                  Positioned(bottom: 24, left: 12, child: _buildLegend()),
                ],
              ),
            ),
            _buildStateInfoCard(),
          ],
        ),
      ),
    );
  }
}
