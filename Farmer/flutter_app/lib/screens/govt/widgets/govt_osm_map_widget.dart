// Government Module — Real-Time OSM Disease Map Widget
// Uses flutter_map + OpenStreetMap tiles for live interactive GIS.
// Displays colour-coded risk markers for Maharashtra districts with popups.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../govt_theme.dart';
import '../govt_models.dart';

/// Map modes — toggle between disease risk heatmap and vaccination coverage.
enum OsmMapDisplayMode { diseaseRisk, vaccinationCoverage }

// ignore_for_file: deprecated_member_use

// ─── Precise lat/lng coordinates for Maharashtra's 36 districts ──────────────
final Map<String, LatLng> _districtCoords = {
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
  'Palghar': LatLng(19.6967, 72.7656),
  'Dhule': LatLng(20.9042, 74.7749),
  'Nandurbar': LatLng(21.3658, 74.2438),
  'Ahmednagar': LatLng(19.0952, 74.7480),
  'Beed': LatLng(18.9891, 75.7601),
  'Osmanabad': LatLng(18.1860, 76.0408),
  'Hingoli': LatLng(19.7173, 77.1494),
  'Parbhani': LatLng(19.2704, 76.7746),
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

Color _riskColor(DistrictRiskProfile d, OsmMapDisplayMode mode) {
  if (mode == OsmMapDisplayMode.vaccinationCoverage) {
    if (d.vaccinationCoverage >= 80) return const Color(0xFF16A34A);
    if (d.vaccinationCoverage >= 60) return const Color(0xFFCA8A04);
    return const Color(0xFFDC2626);
  }
  if (d.riskScore >= 80) return const Color(0xFFB91C1C);
  if (d.riskScore >= 65) return const Color(0xFFEA580C);
  if (d.riskScore >= 50) return const Color(0xFFCA8A04);
  return const Color(0xFF16A34A);
}

double _markerRadius(DistrictRiskProfile d) =>
    18.0 + (d.cases.clamp(0, 70) / 70.0) * 16.0;

class GovtOsmMapWidget extends StatefulWidget {
  final List<DistrictRiskProfile> districts;
  final DistrictRiskProfile selectedDistrict;
  final ValueChanged<DistrictRiskProfile> onSelectDistrict;
  final String selectedDisease;
  final ValueChanged<String> onDiseaseChanged;
  final String selectedTimeframe;
  final ValueChanged<String> onTimeframeChanged;
  final OsmMapDisplayMode mode;

  const GovtOsmMapWidget({
    super.key,
    required this.districts,
    required this.selectedDistrict,
    required this.onSelectDistrict,
    this.selectedDisease = 'All',
    required this.onDiseaseChanged,
    this.selectedTimeframe = '7 Days',
    required this.onTimeframeChanged,
    this.mode = OsmMapDisplayMode.diseaseRisk,
  });

  @override
  State<GovtOsmMapWidget> createState() => _GovtOsmMapWidgetState();
}

class _GovtOsmMapWidgetState extends State<GovtOsmMapWidget>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseCtrl;

  static const _diseases = ['All', 'FMD', 'Brucellosis', 'PPR', 'Haemorrhagic Septicaemia (HS)'];
  static const _timeframes = ['24 Hours', '7 Days', '30 Days', '90 Days'];
  static final LatLng _centre = LatLng(19.6634, 75.3119);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  List<DistrictRiskProfile> get _filtered {
    return widget.districts.where((d) {
      return widget.selectedDisease == 'All' || d.primaryDisease == widget.selectedDisease;
    }).toList();
  }

  List<Marker> _buildMarkers(List<DistrictRiskProfile> districts) {
    return districts.map((d) {
      final coords = _districtCoords[d.name];
      if (coords == null) return null;
      final color = _riskColor(d, widget.mode);
      final radius = _markerRadius(d);
      final isSelected = d.name == widget.selectedDistrict.name;

      return Marker(
        point: coords,
        width: isSelected ? radius * 2.8 : radius * 2.2,
        height: isSelected ? radius * 2.8 : radius * 2.2,
        child: GestureDetector(
          onTap: () => widget.onSelectDistrict(d),
          child: AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, _) {
              final pulse = isSelected ? _pulseCtrl.value : 0.0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected || d.riskScore >= 75)
                    Container(
                      width: radius * 2.0 + pulse * 8,
                      height: radius * 2.0 + pulse * 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.18 + pulse * 0.12),
                      ),
                    ),
                  Container(
                    width: radius * (isSelected ? 1.4 : 1.0),
                    height: radius * (isSelected ? 1.4 : 1.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.88),
                      border: Border.all(
                        color: isSelected ? Colors.white : color.withValues(alpha: 0.5),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6, spreadRadius: 1),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        d.riskScore.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: radius * 0.44,
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

  Widget _buildInfoCard(DistrictRiskProfile d) {
    final color = _riskColor(d, widget.mode);
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))],
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
                child: Text(d.riskLevel, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(d.name, style: const TextStyle(color: GovtColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
              ),
              Text('Risk: ${d.riskScore}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _chip(Icons.coronavirus_rounded, '${d.cases} Cases', Colors.orange),
              _chip(Icons.vaccines_rounded, '${d.vaccinationCoverage}% Vacc', Colors.blue),
              _chip(Icons.trending_up, d.trend, d.trend.startsWith('↑') ? Colors.red : Colors.green),
            ],
          ),
          const SizedBox(height: 4),
          Text('🦠 ${d.primaryDisease}', style: const TextStyle(color: GovtColors.textSecondary, fontSize: 12)),
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

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        border: Border(bottom: BorderSide(color: GovtColors.border)),
      ),
      child: Row(
        children: [
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
          Flexible(
            child: DropdownButton<String>(
              value: widget.selectedDisease,
              isDense: true,
              underline: const SizedBox(),
              dropdownColor: GovtColors.surface,
              style: const TextStyle(color: GovtColors.textPrimary, fontSize: 12),
              icon: const Icon(Icons.arrow_drop_down, color: GovtColors.textSecondary, size: 18),
              items: _diseases.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => widget.onDiseaseChanged(v!),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: DropdownButton<String>(
              value: widget.selectedTimeframe,
              isDense: true,
              underline: const SizedBox(),
              dropdownColor: GovtColors.surface,
              style: const TextStyle(color: GovtColors.textPrimary, fontSize: 12),
              icon: const Icon(Icons.arrow_drop_down, color: GovtColors.textSecondary, size: 18),
              items: _timeframes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => widget.onTimeframeChanged(v!),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.my_location_rounded, size: 18, color: GovtColors.textSecondary),
            tooltip: 'Reset to Maharashtra',
            onPressed: () => _mapController.move(_centre, 7.0),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final items = widget.mode == OsmMapDisplayMode.vaccinationCoverage
        ? [(const Color(0xFF16A34A), '>=80% Good'), (const Color(0xFFCA8A04), '60-79%'), (const Color(0xFFDC2626), '<60% Critical')]
        : [(const Color(0xFFB91C1C), 'Critical >=80'), (const Color(0xFFEA580C), 'High 65-79'), (const Color(0xFFCA8A04), 'Medium 50-64'), (const Color(0xFF16A34A), 'Low <50')];

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
        children: items
            .map((i) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: i.$1)),
                    const SizedBox(width: 4),
                    Text(i.$2, style: const TextStyle(color: GovtColors.textSecondary, fontSize: 11)),
                  ],
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = _buildMarkers(_filtered);

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
            _buildFilterBar(),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _centre,
                      initialZoom: 7.0,
                      minZoom: 5.0,
                      maxZoom: 14.0,
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
                  Positioned(
                    bottom: 24,
                    left: 12,
                    child: _buildLegend(),
                  ),
                ],
              ),
            ),
            _buildInfoCard(widget.selectedDistrict),
          ],
        ),
      ),
    );
  }
}
