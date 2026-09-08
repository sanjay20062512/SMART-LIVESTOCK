// Government Module — India National Livestock Disease Intelligence Map
// Real-time geographic distribution of reported and suspected animal-health events.
// Supports national state heatmaps, multi-layer GIS filters, and district drill-down.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../govt_theme.dart';
import '../govt_models.dart';
import '../govt_mock_data.dart';
import 'govt_map_widget.dart';

class IndiaDiseaseIntelligenceMap extends StatefulWidget {
  final String currentJurisdictionState;
  final String currentJurisdictionDistrict;
  final ValueChanged<String>? onStateSelected;
  final ValueChanged<String>? onDistrictSelected;
  final VoidCallback? onBackToNational;
  final bool isExpanded;
  final double? mapHeight;

  const IndiaDiseaseIntelligenceMap({
    super.key,
    this.currentJurisdictionState = 'TAMIL NADU',
    this.currentJurisdictionDistrict = 'ERODE',
    this.onStateSelected,
    this.onDistrictSelected,
    this.onBackToNational,
    this.isExpanded = false,
    this.mapHeight,
  });

  @override
  State<IndiaDiseaseIntelligenceMap> createState() => _IndiaDiseaseIntelligenceMapState();
}

class _IndiaDiseaseIntelligenceMapState extends State<IndiaDiseaseIntelligenceMap>
    with SingleTickerProviderStateMixin {
  late final List<StateRiskProfile> _states;
  late final AnimationController _pulseController;

  bool _isNationalView = true;
  StateRiskProfile? _selectedState;
  String _activeDisease = 'All Diseases';
  String _activeAnimal = 'All';
  String _activeTimeframe = '7 Days';
  String _activeRiskFilter = 'All';
  String _activeLayer = 'Disease Cases';

  double _zoomLevel = 1.0;
  Offset _panOffset = Offset.zero;

  final List<String> _layers = [
    'Disease Cases',
    'Mortality',
    'Outbreak Clusters',
    'Vaccination Coverage',
    'Livestock Density',
    'Veterinary Facilities',
    'Laboratories',
    'Weather Risk',
    'Movement Risk',
  ];

  @override
  void initState() {
    super.initState();
    _states = GovtMockData.getIndiaStatesRiskProfiles();
    _selectedState = _states.firstWhere((s) => s.code == 'TN', orElse: () => _states.first);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _drillDownToDistrict(StateRiskProfile state) {
    setState(() {
      _selectedState = state;
      _isNationalView = false;
    });
    widget.onStateSelected?.call(state.name.toUpperCase());
  }

  void _returnToNational() {
    setState(() {
      _isNationalView = true;
      _zoomLevel = 1.0;
      _panOffset = Offset.zero;
    });
    widget.onBackToNational?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: GovtColors.border),
        boxShadow: const [
          BoxShadow(color: GovtColors.shadow, blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Map Title & Institutional Surveillance Header ─────────
          _buildHeaderBar(),

          // ── 2. Comprehensive Map Filter Bar ──────────────────────────
          _buildFilterBar(),

          // ── 3. Interactive GIS Map Workspace ─────────────────────────
          widget.isExpanded
              ? Expanded(
                  child: _isNationalView ? _buildNationalMapStack() : _buildDistrictDrillDownStack(),
                )
              : SizedBox(
                  height: widget.mapHeight ?? 480,
                  child: _isNationalView ? _buildNationalMapStack() : _buildDistrictDrillDownStack(),
                ),
        ],
      ),
    );
  }

  // ─── Header Bar ─────────────────────────────────────────────────────────

  Widget _buildHeaderBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: GovtColors.navyPrimary,
        border: Border(bottom: BorderSide(color: GovtColors.navyBorder)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: GovtColors.brand.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: GovtColors.brand.withValues(alpha: 0.5)),
            ),
            child: const Icon(Icons.public_rounded, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'INDIA LIVESTOCK DISEASE INTELLIGENCE MAP',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: GovtColors.riskHigh.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: GovtColors.riskHigh),
                      ),
                      child: const Text(
                        'NATIONAL GIS LEVEL 1',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.orangeAccent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Real-time geographic distribution of reported and suspected animal-health events',
                  style: TextStyle(fontSize: 11, color: Color(0xFFB0BEC5)),
                ),
              ],
            ),
          ),

          // Breadcrumb Trail / Switcher
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: GovtColors.navyCard,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: GovtColors.navyBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: _returnToNational,
                  child: Text(
                    'INDIA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _isNationalView ? GovtColors.brandLight : const Color(0xFF90A4AE),
                    ),
                  ),
                ),
                const Text(' / ', style: TextStyle(color: Color(0xFF546E7A), fontSize: 11)),
                InkWell(
                  onTap: () {
                    if (_selectedState != null) _drillDownToDistrict(_selectedState!);
                  },
                  child: Text(
                    _selectedState?.name.toUpperCase() ?? 'TAMIL NADU',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: !_isNationalView ? Colors.white : const Color(0xFF90A4AE),
                    ),
                  ),
                ),
                if (!_isNationalView) ...[
                  const Text(' / ', style: TextStyle(color: Color(0xFF546E7A), fontSize: 11)),
                  Text(
                    widget.currentJurisdictionDistrict,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: GovtColors.brandLight),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Filter Bar ─────────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFBFB),
        border: Border(bottom: BorderSide(color: GovtColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Disease Filter
            _buildFilterDropdown(
              label: 'Disease',
              value: _activeDisease,
              items: ['All Diseases', 'FMD', 'Anthrax', 'Brucellosis', 'PPR', 'HS', 'LSD', 'Other'],
              onChanged: (v) => setState(() => _activeDisease = v),
            ),
            const SizedBox(width: 8),

            // Animal Species Filter
            _buildFilterDropdown(
              label: 'Animal',
              value: _activeAnimal,
              items: ['All', 'Cattle', 'Buffalo', 'Goat', 'Sheep', 'Pig', 'Poultry'],
              onChanged: (v) => setState(() => _activeAnimal = v),
            ),
            const SizedBox(width: 8),

            // Timeframe Filter
            _buildFilterDropdown(
              label: 'Time',
              value: _activeTimeframe,
              items: ['Today', '7 Days', '30 Days', '3 Months', '1 Year'],
              onChanged: (v) => setState(() => _activeTimeframe = v),
            ),
            const SizedBox(width: 8),

            // Risk Severity Filter
            _buildFilterDropdown(
              label: 'Risk',
              value: _activeRiskFilter,
              items: ['All', 'Low', 'Moderate', 'High', 'Critical'],
              onChanged: (v) => setState(() => _activeRiskFilter = v),
            ),
            const SizedBox(width: 14),

            // Vertical divider
            Container(width: 1, height: 20, color: GovtColors.border),
            const SizedBox(width: 14),

            // Active Layer Pills
            const Text(
              'LAYERS:',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textSecondary),
            ),
            const SizedBox(width: 6),
            ..._layers.take(5).map((l) {
              final isSelected = _activeLayer == l;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => setState(() => _activeLayer = l),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSelected ? GovtColors.brand : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isSelected ? GovtColors.brandDark : GovtColors.border),
                    ),
                    child: Text(
                      l,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : GovtColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: GovtColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 10, color: GovtColors.textSecondary, fontWeight: FontWeight.w600)),
          DropdownButton<String>(
            value: value,
            isDense: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, size: 16, color: GovtColors.textPrimary),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.textPrimary),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
          ),
        ],
      ),
    );
  }

  // ─── National Map Stack ─────────────────────────────────────────────────

  Widget _buildNationalMapStack() {
    return Stack(
      children: [
        // Interactive India Map Painter
        GestureDetector(
          onPanUpdate: (d) => setState(() => _panOffset += d.delta),
          onTapUp: _handleNationalTap,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return CustomPaint(
                size: Size.infinite,
                painter: _IndiaNationalMapPainter(
                  states: _states,
                  selectedState: _selectedState,
                  zoomLevel: _zoomLevel,
                  panOffset: _panOffset,
                  pulseValue: _pulseController.value,
                  activeLayer: _activeLayer,
                ),
              );
            },
          ),
        ),

        // Controls Top-Right
        Positioned(
          top: 12,
          right: 12,
          child: _buildControlsHUD(),
        ),

        // National Status Watermark Badge
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: GovtColors.border),
              boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 4)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: GovtColors.riskCritical, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text(
                  'INDIA NATIONAL SURVEILLANCE • 10 STATES ACTIVE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GovtColors.textPrimary, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ),

        // Floating State Tooltip Panel
        if (_selectedState != null)
          Positioned(
            left: 14,
            bottom: 36,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 270, maxWidth: 300),
              child: _buildStateTooltipCard(_selectedState!),
            ),
          ),

        // Bottom National Legend
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildNationalLegend(),
        ),
      ],
    );
  }

  // ─── District Drill Down Stack (Zoomed into Tamil Nadu / Erode) ─────────

  Widget _buildDistrictDrillDownStack() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight.isFinite && constraints.maxHeight > 0 ? constraints.maxHeight : 480.0;
        return Stack(
          children: [
            GovernmentGeospatialMap(
              district: widget.currentJurisdictionDistrict,
              height: h,
              onZoneSelected: (zone) {
                // Zone clicked
              },
            ),

            // Back to National Button
            Positioned(
              top: 50,
              left: 12,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GovtColors.navyPrimary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 14),
                label: const Text('ZOOM OUT TO NATIONAL VIEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                onPressed: _returnToNational,
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Controls HUD ───────────────────────────────────────────────────────

  Widget _buildControlsHUD() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: GovtColors.border),
        boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 6)],
      ),
      child: Column(
        children: [
          _hudBtn(Icons.add, 'Zoom in', () => setState(() => _zoomLevel = (_zoomLevel + 0.2).clamp(0.8, 2.5))),
          Container(width: 24, height: 1, color: GovtColors.border),
          _hudBtn(Icons.remove, 'Zoom out', () => setState(() => _zoomLevel = (_zoomLevel - 0.2).clamp(0.8, 2.5))),
          Container(width: 24, height: 1, color: GovtColors.border),
          _hudBtn(Icons.my_location, 'Reset center', () => setState(() {
            _zoomLevel = 1.0;
            _panOffset = Offset.zero;
          })),
        ],
      ),
    );
  }

  Widget _hudBtn(IconData icon, String tip, VoidCallback onTap) {
    return Tooltip(
      message: tip,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 16, color: GovtColors.textPrimary),
        ),
      ),
    );
  }

  // ─── State Tooltip Card (Exact Section Specification) ───────────────────

  Widget _buildStateTooltipCard(StateRiskProfile state) {
    final riskColor = _getRiskColor(state.riskLevel);

    return Container(
      width: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: riskColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x220B192C), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // State title, risk pill, and dismiss button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'STATE: ${state.name.toUpperCase()}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GovtColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: riskColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'RISK: ${state.riskLevel}',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: riskColor),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => setState(() => _selectedState = null),
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(Icons.close_rounded, size: 14, color: GovtColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Key metrics row
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: GovtColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  _tooltipRow('Active Cases', '${state.activeCases}', riskColor),
                  _tooltipRow('Suspected Outbreaks', '${state.suspectedOutbreaks}', GovtColors.riskHigh),
                  _tooltipRow('Confirmed Outbreaks', '${state.confirmedOutbreaks}', GovtColors.riskCritical),
                  _tooltipRow('Mortality', '${state.mortality} head', GovtColors.riskCritical),
                  _tooltipRow('Vaccination Coverage', '${state.vaccinationCoverage}%', GovtColors.brand),
                  _tooltipRow('Dominant Disease', state.dominantDisease, GovtColors.textPrimary),
                  _tooltipRow('Trend', '↑ ${state.trendPercent}% vs prev period', riskColor),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Risk Drivers
            const Text('Risk Drivers:', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: GovtColors.textSecondary)),
            const SizedBox(height: 2),
            ...state.riskDrivers.map((d) => Text('• $d', style: const TextStyle(fontSize: 9, color: GovtColors.textPrimary))),
            const SizedBox(height: 6),

            // Action Directive & Drill-down Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: GovtColors.brandLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Action: ${state.recommendedAction}',
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: GovtColors.brandDark),
              ),
            ),
            const SizedBox(height: 6),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GovtColors.brand,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.zoom_in_rounded, size: 13),
                label: Text('DRILL DOWN INTO ${state.name.toUpperCase()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                onPressed: () => _drillDownToDistrict(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tooltipRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: GovtColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  // ─── National Legend ────────────────────────────────────────────────────

  Widget _buildNationalLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: const Border(top: BorderSide(color: GovtColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem('LOW', GovtColors.riskLow),
          _legendItem('MODERATE', GovtColors.riskModerate),
          _legendItem('HIGH', GovtColors.riskHigh),
          _legendItem('CRITICAL', GovtColors.riskCritical),
          _legendItem('SEVERE OUTBREAK', GovtColors.riskSevere),
          const Text('• Tap state for telemetry & district drilldown', style: TextStyle(fontSize: 10, color: GovtColors.textSecondary, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: GovtColors.textSecondary)),
      ],
    );
  }

  // ─── Tap Handler ────────────────────────────────────────────────────────

  void _handleNationalTap(TapUpDetails details) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final size = box?.size ?? const Size(800, 480);

    final local = details.localPosition - _panOffset;
    final normX = (local.dx / size.width) / _zoomLevel;
    final normY = (local.dy / size.height) / _zoomLevel;

    StateRiskProfile? closest;
    double minDist = double.infinity;

    for (final s in _states) {
      final dx = s.normX - normX;
      final dy = s.normY - normY;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist < minDist) {
        minDist = dist;
        closest = s;
      }
    }

    if (closest != null && minDist < 0.18) {
      setState(() {
        _selectedState = closest;
      });
    }
  }

  Color _getRiskColor(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL':
        return GovtColors.riskCritical;
      case 'HIGH':
        return GovtColors.riskHigh;
      case 'MODERATE':
        return GovtColors.riskModerate;
      case 'LOW':
      default:
        return GovtColors.riskLow;
    }
  }
}

// ─── India National Map Custom Painter ───────────────────────────────────────

class _IndiaNationalMapPainter extends CustomPainter {
  final List<StateRiskProfile> states;
  final StateRiskProfile? selectedState;
  final double zoomLevel;
  final Offset panOffset;
  final double pulseValue;
  final String activeLayer;

  _IndiaNationalMapPainter({
    required this.states,
    required this.selectedState,
    required this.zoomLevel,
    required this.panOffset,
    required this.pulseValue,
    required this.activeLayer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Canvas background
    final bgPaint = Paint()..color = const Color(0xFFF1F5F4);
    canvas.drawRect(Offset.zero & size, bgPaint);

    canvas.save();
    canvas.translate(panOffset.dx, panOffset.dy);
    canvas.scale(zoomLevel);

    final w = size.width;
    final h = size.height;

    // ── 1. Coordinate Grid Lines ─────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = const Color(0xFFDFE7E5)
      ..strokeWidth = 0.7;

    for (double x = 0; x < w * 1.5; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, h * 1.5), gridPaint);
    }
    for (double y = 0; y < h * 1.5; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(w * 1.5, y), gridPaint);
    }

    // ── 2. India National Perimeter Vector Polygon ───────────────────────────
    final indiaBoundary = Path()
      // Kashmir / Ladakh North
      ..moveTo(w * 0.38, h * 0.12)
      ..lineTo(w * 0.44, h * 0.10)
      ..lineTo(w * 0.50, h * 0.16)
      ..lineTo(w * 0.48, h * 0.22)
      // Gangetic / Nepal border
      ..lineTo(w * 0.62, h * 0.28)
      // Northeast corridor (Chicken neck to Assam/Arunachal)
      ..lineTo(w * 0.72, h * 0.32)
      ..lineTo(w * 0.88, h * 0.35)
      ..lineTo(w * 0.86, h * 0.48)
      ..lineTo(w * 0.75, h * 0.48)
      // Bengal Delta & East Coast
      ..lineTo(w * 0.72, h * 0.55)
      ..lineTo(w * 0.60, h * 0.68)
      ..lineTo(w * 0.52, h * 0.80)
      // Kanyakumari South Tip
      ..lineTo(w * 0.44, h * 0.94)
      // West Coast (Kerala, Karnataka, Goa, Maharashtra)
      ..lineTo(w * 0.38, h * 0.86)
      ..lineTo(w * 0.34, h * 0.68)
      ..lineTo(w * 0.30, h * 0.55)
      // Gujarat Rann of Kutch
      ..lineTo(w * 0.16, h * 0.50)
      ..lineTo(w * 0.18, h * 0.40)
      // Rajasthan border
      ..lineTo(w * 0.28, h * 0.28)
      ..close();

    // Fill India Territory
    final indiaFill = Paint()..color = const Color(0xFFFAFCFB);
    canvas.drawPath(indiaBoundary, indiaFill);

    final indiaStroke = Paint()
      ..color = GovtColors.navyBorder.withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(indiaBoundary, indiaStroke);

    // ── 3. Heatmap Radial Risk Zones for States ──────────────────────────────
    for (final s in states) {
      final center = Offset(s.normX * w, s.normY * h);
      final riskColor = _getRiskColor(s.riskLevel);
      final radius = 55.0 * (s.riskScore / 100.0) * zoomLevel;

      final gradient = RadialGradient(
        colors: [
          riskColor.withValues(alpha: 0.45),
          riskColor.withValues(alpha: 0.18),
          riskColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      );

      final heatPaint = Paint()
        ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, heatPaint);
    }

    // ── 4. Major Livestock Movement Corridors (NH-44 / Central) ─────────────
    final corridorPaint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.35)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final nh44 = Path()
      ..moveTo(w * 0.40, h * 0.20)
      ..lineTo(w * 0.42, h * 0.38)
      ..lineTo(w * 0.40, h * 0.55)
      ..lineTo(w * 0.42, h * 0.72)
      ..lineTo(w * 0.44, h * 0.88);
    canvas.drawPath(nh44, corridorPaint);

    // ── 5. State Hub Nodes & Interactive Markers ─────────────────────────────
    for (final s in states) {
      final center = Offset(s.normX * w, s.normY * h);
      final riskColor = _getRiskColor(s.riskLevel);
      final isSelected = selectedState?.code == s.code;

      // Pulse ring for Critical & High states
      if (s.riskLevel == 'CRITICAL' || s.riskLevel == 'HIGH') {
        final pulseRadius = (16.0 + (s.riskScore * 0.12)) * (isSelected ? 1.3 : pulseValue);
        final pulsePaint = Paint()
          ..color = riskColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(center, pulseRadius, pulsePaint);
      }

      // Hub Circle
      final nodeRadius = isSelected ? 12.0 : 9.0;
      canvas.drawCircle(center, nodeRadius, Paint()..color = Colors.white);
      canvas.drawCircle(center, nodeRadius - 2.5, Paint()..color = riskColor);
      canvas.drawCircle(
        center,
        nodeRadius,
        Paint()
          ..color = isSelected ? GovtColors.navyPrimary : riskColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 2.5 : 1.5,
      );

      // Label Text: Code & Cases
      final span = TextSpan(
        text: '${s.name} (${s.activeCases})',
        style: TextStyle(
          fontSize: 9,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: GovtColors.textPrimary,
          backgroundColor: Colors.white.withValues(alpha: 0.9),
        ),
      );
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + nodeRadius + 3));
    }

    canvas.restore();
  }

  Color _getRiskColor(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL':
        return GovtColors.riskCritical;
      case 'HIGH':
        return GovtColors.riskHigh;
      case 'MODERATE':
        return GovtColors.riskModerate;
      case 'LOW':
      default:
        return GovtColors.riskLow;
    }
  }

  @override
  bool shouldRepaint(covariant _IndiaNationalMapPainter oldDelegate) {
    return oldDelegate.zoomLevel != zoomLevel ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.selectedState != selectedState ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.activeLayer != activeLayer;
  }
}
