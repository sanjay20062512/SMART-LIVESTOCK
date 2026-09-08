// Government Module — Geospatial Risk Intelligence Map
// Production-grade interactive GIS command map for animal health surveillance.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../govt_theme.dart';
import '../govt_models.dart';
import '../govt_mock_data.dart';

enum MapLayer {
  diseaseCases,
  mortality,
  vaccination,
  vetCenters,
  laboratories,
  weather,
  livestockDensity,
  outbreakClusters,
}

extension MapLayerExtension on MapLayer {
  String get label {
    switch (this) {
      case MapLayer.diseaseCases:
        return 'Disease Cases';
      case MapLayer.mortality:
        return 'Mortality';
      case MapLayer.vaccination:
        return 'Vaccination';
      case MapLayer.vetCenters:
        return 'Veterinary Centers';
      case MapLayer.laboratories:
        return 'Laboratories';
      case MapLayer.weather:
        return 'Weather';
      case MapLayer.livestockDensity:
        return 'Livestock Density';
      case MapLayer.outbreakClusters:
        return 'Outbreak Clusters';
    }
  }

  IconData get icon {
    switch (this) {
      case MapLayer.diseaseCases:
        return Icons.coronavirus_rounded;
      case MapLayer.mortality:
        return Icons.warning_amber_rounded;
      case MapLayer.vaccination:
        return Icons.vaccines_rounded;
      case MapLayer.vetCenters:
        return Icons.local_hospital_rounded;
      case MapLayer.laboratories:
        return Icons.science_rounded;
      case MapLayer.weather:
        return Icons.cloud_queue_rounded;
      case MapLayer.livestockDensity:
        return Icons.pets_rounded;
      case MapLayer.outbreakClusters:
        return Icons.hub_rounded;
    }
  }
}

class GovernmentGeospatialMap extends StatefulWidget {
  final List<RiskZone>? riskZones;
  final String district;
  final double height;
  final ValueChanged<RiskZone>? onZoneSelected;
  final VoidCallback? onAssignTeam;
  final VoidCallback? onIssueAlert;

  const GovernmentGeospatialMap({
    super.key,
    this.riskZones,
    this.district = 'ERODE',
    this.height = 360,
    this.onZoneSelected,
    this.onAssignTeam,
    this.onIssueAlert,
  });

  @override
  State<GovernmentGeospatialMap> createState() => _GovernmentGeospatialMapState();
}

class _GovernmentGeospatialMapState extends State<GovernmentGeospatialMap>
    with SingleTickerProviderStateMixin {
  late final List<RiskZone> _zones;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  double _zoomLevel = 1.0;
  Offset _panOffset = Offset.zero;
  bool _isFullscreen = false;
  MapLayer _activeLayer = MapLayer.diseaseCases;
  RiskZone? _selectedZone;

  @override
  void initState() {
    super.initState();
    _zones = widget.riskZones ?? GovtMockData.getRiskZonesList();
    // Default select Perundurai (Village A) for immediate intelligence view
    _selectedZone = _zones.isNotEmpty ? _zones.first : null;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 0.25).clamp(0.8, 2.5);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 0.25).clamp(0.8, 2.5);
    });
  }

  void _resetView() {
    setState(() {
      _zoomLevel = 1.0;
      _panOffset = Offset.zero;
      _selectedZone = _zones.first;
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = _isFullscreen ? 540.0 : widget.height;

    return Container(
      decoration: BoxDecoration(
        color: GovtColors.surface,
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
          // ── Map Header & Command Bar ────────────────────────────────────
          _buildMapHeader(),

          // ── Layer Ribbon Bar ───────────────────────────────────────────
          _buildLayerRibbon(),

          // ── Interactive Map Canvas & Overlays ───────────────────────────
          SizedBox(
            height: effectiveHeight,
            child: Stack(
              children: [
                // GIS Canvas with pan/zoom gestures
                GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _panOffset += details.delta;
                    });
                  },
                  onTapUp: (details) => _handleMapTap(details, context),
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, _) {
                      return CustomPaint(
                        size: Size.infinite,
                        painter: _GISMapPainter(
                          district: widget.district,
                          zones: _zones,
                          selectedZone: _selectedZone,
                          activeLayer: _activeLayer,
                          zoomLevel: _zoomLevel,
                          panOffset: _panOffset,
                          pulseValue: _pulseAnimation.value,
                        ),
                      );
                    },
                  ),
                ),

                // Map HUD Controls: Zoom, Locate, Layers, Fullscreen
                Positioned(
                  top: 12,
                  right: 12,
                  child: _buildMapControls(),
                ),

                // District / Sector Watermark Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildDistrictBadge(),
                ),

                // Floating Intelligence Panel (Tapped region info)
                if (_selectedZone != null)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 38,
                    child: _buildFloatingInfoPanel(_selectedZone!),
                  ),

                // Bottom Map Legend
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildMapLegend(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Map Header ─────────────────────────────────────────────────────────

  Widget _buildMapHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: GovtColors.surface,
        border: Border(bottom: BorderSide(color: GovtColors.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: GovtColors.brandLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.satellite_alt_rounded, size: 16, color: GovtColors.brand),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GEOSPATIAL RISK INTELLIGENCE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: GovtColors.textPrimary,
                ),
              ),
              Text(
                'Live district telemetry, transmission corridors & risk clusters',
                style: TextStyle(
                  fontSize: 11,
                  color: GovtColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: GovtColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: GovtColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: GovtColors.riskLow,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'GEO-ENGINE ACTIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: GovtColors.textSecondary,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Layer Ribbon Bar ───────────────────────────────────────────────────

  Widget _buildLayerRibbon() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFBFB),
        border: Border(bottom: BorderSide(color: GovtColors.border)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: MapLayer.values.map((layer) {
          final isSelected = _activeLayer == layer;
          return Padding(
            padding: const EdgeInsets.only(right: 6, top: 4, bottom: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => setState(() => _activeLayer = layer),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected ? GovtColors.brand : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? GovtColors.brandDark : GovtColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      layer.icon,
                      size: 13,
                      color: isSelected ? Colors.white : GovtColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      layer.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : GovtColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Map Controls HUD ───────────────────────────────────────────────────

  Widget _buildMapControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: GovtRadius.smRadius,
        border: Border.all(color: GovtColors.border),
        boxShadow: const [
          BoxShadow(color: GovtColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _controlButton(Icons.add, 'Zoom in', _zoomIn),
          _controlDivider(),
          _controlButton(Icons.remove, 'Zoom out', _zoomOut),
          _controlDivider(),
          _controlButton(Icons.my_location_rounded, 'Locate district center', _resetView),
          _controlDivider(),
          _controlButton(
            _isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
            'Fullscreen',
            _toggleFullscreen,
          ),
        ],
      ),
    );
  }

  Widget _controlButton(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 16, color: GovtColors.textPrimary),
        ),
      ),
    );
  }

  Widget _controlDivider() {
    return Container(width: 24, height: 1, color: GovtColors.border);
  }

  // ─── District Badge ─────────────────────────────────────────────────────

  Widget _buildDistrictBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: GovtColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_city_rounded, size: 13, color: GovtColors.brand),
          const SizedBox(width: 5),
          Text(
            '${widget.district} SECTOR • ${_zones.length} ZONES MONITORED',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: GovtColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Floating Info Panel (Tapped Village) ────────────────────────────────

  Widget _buildFloatingInfoPanel(RiskZone zone) {
    final riskColor = _getRiskColor(zone.riskLevel);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: riskColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A087F73),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Village Name & Risk Badge & Close
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: riskColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'VILLAGE: ${zone.village.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: GovtColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: riskColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'RISK: ${zone.riskLevel}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: riskColor,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => setState(() => _selectedZone = null),
                child: const Icon(Icons.close, size: 16, color: GovtColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 4-Column Key Metrics Row
          Row(
            children: [
              _metricCell('Active Cases', '${zone.activeCases}', riskColor),
              _metricCell('Mortality', '${zone.mortality}', GovtColors.critical),
              _metricCell('Vaccination', '${zone.vaccinationCoverage}%', GovtColors.brand),
              _metricCell('Last Report', zone.lastReportAgo, GovtColors.textSecondary),
              _metricCell('Disease', zone.possibleDisease, GovtColors.textPrimary),
            ],
          ),
          const SizedBox(height: 10),

          // Action Buttons: VIEW CASES, ASSIGN TEAM, ISSUE ALERT
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    side: const BorderSide(color: GovtColors.brand),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    _showCasesDialog(context, zone);
                  },
                  child: const Text(
                    'VIEW CASES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: GovtColors.brand,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GovtColors.brand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    _showAssignTeamDialog(context, zone);
                  },
                  child: const Text(
                    'ASSIGN TEAM',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GovtColors.riskHigh,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    _showIssueAlertDialog(context, zone);
                  },
                  child: const Text(
                    'ISSUE ALERT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCell(String title, String value, Color valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: GovtColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─── Map Legend ─────────────────────────────────────────────────────────

  Widget _buildMapLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          _legendItemIcon('CLUSTER', Icons.hub_rounded, GovtColors.brand),
          _legendItemIcon('LAB / VET', Icons.medical_services_rounded, GovtColors.info),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: GovtColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _legendItemIcon(String label, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: GovtColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ─── Tap Detection ──────────────────────────────────────────────────────

  void _handleMapTap(TapUpDetails details, BuildContext context) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final size = box?.size ?? const Size(800, 360);

    // Map tap point to normalized space
    final local = details.localPosition - _panOffset;
    final normX = (local.dx / size.width) / _zoomLevel;
    final normY = (local.dy / size.height) / _zoomLevel;

    RiskZone? closest;
    double minDistance = double.infinity;

    for (final zone in _zones) {
      final dx = zone.normX - normX;
      final dy = zone.normY - normY;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist < minDistance) {
        minDistance = dist;
        closest = zone;
      }
    }

    if (closest != null && minDistance < 0.15) {
      setState(() {
        _selectedZone = closest;
      });
      widget.onZoneSelected?.call(closest);
    }
  }

  Color _getRiskColor(String risk) {
    switch (risk.toUpperCase()) {
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

  // ─── Institutional Action Dialogs ────────────────────────────────────────

  void _showCasesDialog(BuildContext context, RiskZone zone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GovtColors.surface,
        title: Row(
          children: [
            const Icon(Icons.folder_shared_rounded, color: GovtColors.brand, size: 20),
            const SizedBox(width: 8),
            Text('Active Case Manifest — ${zone.village}', style: GovtTypography.cardTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${zone.activeCases} active reported cases under surveillance in this sector.',
              style: GovtTypography.body,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: GovtColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GovtColors.border),
              ),
              child: Column(
                children: [
                  _dialogRow('Suspected Disease', zone.possibleDisease),
                  const Divider(height: 12),
                  _dialogRow('Confirmed Mortalities', '${zone.mortality} head of cattle'),
                  const Divider(height: 12),
                  _dialogRow('Transmission Risk', '${zone.trendPercent}% ${zone.trendDirection}ward'),
                  const Divider(height: 12),
                  _dialogRow('Vaccination Coverage', '${zone.vaccinationCoverage}% against 90% mandate'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('DISMISS', style: TextStyle(color: GovtColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovtColors.brand, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: GovtColors.brandDark,
                  content: Text('Transferred case manifest for ${zone.village} to Surveillance Desk.'),
                ),
              );
            },
            child: const Text('OPEN CASE DOSSIER'),
          ),
        ],
      ),
    );
  }

  void _showAssignTeamDialog(BuildContext context, RiskZone zone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GovtColors.surface,
        title: Row(
          children: [
            const Icon(Icons.groups_rounded, color: GovtColors.brand, size: 20),
            const SizedBox(width: 8),
            Text('Deploy Field Response — ${zone.village}', style: GovtTypography.cardTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a response unit for immediate priority assignment:',
              style: GovtTypography.body,
            ),
            const SizedBox(height: 12),
            _teamOption('VT-01: Team Alpha (Surveillance & Cordon)', 'Status: Active in sector (18 min ETA)'),
            const SizedBox(height: 8),
            _teamOption('VT-02: Team Bravo (Sample Collection)', 'Status: En Route (25 min ETA)'),
            const SizedBox(height: 8),
            _teamOption('VT-03: Team Charlie (Ring Vaccination Unit)', 'Status: Standby at District HQ'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: GovtColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovtColors.brand, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: GovtColors.brandDark,
                  content: Text('Dispatched Team Alpha to ${zone.village}. Alert beacon active.'),
                ),
              );
            },
            child: const Text('CONFIRM DISPATCH'),
          ),
        ],
      ),
    );
  }

  void _showIssueAlertDialog(BuildContext context, RiskZone zone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GovtColors.surface,
        title: Row(
          children: [
            const Icon(Icons.campaign_rounded, color: GovtColors.riskCritical, size: 20),
            const SizedBox(width: 8),
            Text('Issue Emergency Advisory', style: GovtTypography.cardTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Broadcasting tier-1 health advisory for ${zone.village} across SMS, Mobile App, and Field Workers.',
              style: GovtTypography.body,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: GovtColors.criticalLight,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: GovtColors.critical.withValues(alpha: 0.3)),
              ),
              child: Text(
                'WARNING: Suspected ${zone.possibleDisease} transmission cluster detected. Restrict cattle movement within 5 km radius and report sudden salivation.',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GovtColors.critical),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: GovtColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovtColors.critical, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: GovtColors.critical,
                  content: Text('EMERGENCY ADVISORY BROADCASTED FOR ${zone.village.toUpperCase()}'),
                ),
              );
            },
            child: const Text('BROADCAST ADVISORY'),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: GovtColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GovtColors.textPrimary)),
      ],
    );
  }

  Widget _teamOption(String name, String sub) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: GovtColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.radio_button_checked, size: 16, color: GovtColors.brand),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                Text(sub, style: const TextStyle(fontSize: 11, color: GovtColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Custom GIS Map Painter ──────────────────────────────────────────────────

class _GISMapPainter extends CustomPainter {
  final String district;
  final List<RiskZone> zones;
  final RiskZone? selectedZone;
  final MapLayer activeLayer;
  final double zoomLevel;
  final Offset panOffset;
  final double pulseValue;

  _GISMapPainter({
    required this.district,
    required this.zones,
    required this.selectedZone,
    required this.activeLayer,
    required this.zoomLevel,
    required this.panOffset,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background terrain
    final bgPaint = Paint()..color = const Color(0xFFEDF3F1);
    canvas.drawRect(Offset.zero & size, bgPaint);

    canvas.save();
    canvas.translate(panOffset.dx, panOffset.dy);
    canvas.scale(zoomLevel);

    final w = size.width;
    final h = size.height;

    // ── 1. Coordinate Grid Lines (Institutional Lat/Long Grid) ───────────────
    final gridPaint = Paint()
      ..color = const Color(0xFFD6E3DE)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (double x = 0; x < w * 1.5; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, h * 1.5), gridPaint);
    }
    for (double y = 0; y < h * 1.5; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(w * 1.5, y), gridPaint);
    }

    // ── 2. District Geographic Perimeter ────────────────────────────────────
    final boundaryPath = Path()
      ..moveTo(w * 0.10, h * 0.18)
      ..cubicTo(w * 0.25, h * 0.08, w * 0.60, h * 0.06, w * 0.84, h * 0.15)
      ..cubicTo(w * 0.95, h * 0.35, w * 0.92, h * 0.65, w * 0.88, h * 0.82)
      ..cubicTo(w * 0.70, h * 0.95, w * 0.40, h * 0.94, w * 0.18, h * 0.86)
      ..cubicTo(w * 0.04, h * 0.60, w * 0.05, h * 0.32, w * 0.10, h * 0.18)
      ..close();

    // District fill
    final distFillPaint = Paint()
      ..color = const Color(0xFFF4F8F6)
      ..style = PaintingStyle.fill;
    canvas.drawPath(boundaryPath, distFillPaint);

    // District border
    final distBorderPaint = Paint()
      ..color = GovtColors.brand.withValues(alpha: 0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(boundaryPath, distBorderPaint);

    // ── 3. Bhavani River & Transit Corridors ────────────────────────────────
    final riverPaint = Paint()
      ..color = const Color(0xFF90CAF9)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(w * 0.12, h * 0.40)
      ..quadraticBezierTo(w * 0.35, h * 0.42, w * 0.52, h * 0.32)
      ..quadraticBezierTo(w * 0.70, h * 0.22, w * 0.88, h * 0.30);
    canvas.drawPath(riverPath, riverPaint);

    // Transit Highway NH-544
    final roadPaint = Paint()
      ..color = const Color(0xFFB0BEC5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final roadPath = Path()
      ..moveTo(w * 0.08, h * 0.68)
      ..quadraticBezierTo(w * 0.40, h * 0.50, w * 0.86, h * 0.45);
    canvas.drawPath(roadPath, roadPaint);

    // ── 4. Heatmap Radial Risk Fields ───────────────────────────────────────
    for (final zone in zones) {
      final center = Offset(zone.normX * w, zone.normY * h);
      final riskColor = _getRiskColor(zone.riskLevel);
      final caseFactor = (zone.activeCases / 12.0).clamp(0.2, 1.0);
      final heatRadius = 35.0 * caseFactor * zoomLevel;

      final gradient = RadialGradient(
        colors: [
          riskColor.withValues(alpha: 0.45 * caseFactor),
          riskColor.withValues(alpha: 0.20 * caseFactor),
          riskColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      );

      final heatPaint = Paint()
        ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: heatRadius));
      canvas.drawCircle(center, heatRadius, heatPaint);
    }

    // ── 5. Transmission Cluster Vectors (Connection arcs) ───────────────────
    if (activeLayer == MapLayer.diseaseCases || activeLayer == MapLayer.outbreakClusters) {
      final clusterVectorPaint = Paint()
        ..color = GovtColors.critical.withValues(alpha: 0.4)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      // Link Perundurai (RZ-01) -> Bhavani (RZ-02) -> Anthiyur (RZ-05)
      final p1 = Offset(zones[0].normX * w, zones[0].normY * h);
      final p2 = Offset(zones[1].normX * w, zones[1].normY * h);
      final p3 = Offset(zones[4].normX * w, zones[4].normY * h);

      canvas.drawLine(p1, p2, clusterVectorPaint);
      canvas.drawLine(p2, p3, clusterVectorPaint);
    }

    // ── 6. Cluster Pins & Animated Hotspots ─────────────────────────────────
    for (final zone in zones) {
      final center = Offset(zone.normX * w, zone.normY * h);
      final riskColor = _getRiskColor(zone.riskLevel);
      final isSelected = selectedZone?.id == zone.id;

      // Outer pulse ring
      if (zone.riskLevel == 'CRITICAL' || zone.riskLevel == 'HIGH') {
        final pulseRadius = (16.0 + (zone.activeCases * 1.2)) * (isSelected ? 1.4 : pulseValue);
        final pulsePaint = Paint()
          ..color = riskColor.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(center, pulseRadius, pulsePaint);
      }

      // Marker circle fill
      final baseRadius = isSelected ? 12.0 : 9.0;
      final nodePaint = Paint()..color = Colors.white;
      canvas.drawCircle(center, baseRadius, nodePaint);

      final corePaint = Paint()..color = riskColor;
      canvas.drawCircle(center, baseRadius - 2.5, corePaint);

      // Border outline
      final borderPaint = Paint()
        ..color = isSelected ? GovtColors.textPrimary : riskColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2.5 : 1.5;
      canvas.drawCircle(center, baseRadius, borderPaint);

      // Label text
      final labelSpan = TextSpan(
        text: zone.village.split(' ')[0], // First word e.g. Perundurai
        style: TextStyle(
          fontSize: 10,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: GovtColors.textPrimary,
          backgroundColor: Colors.white.withValues(alpha: 0.85),
        ),
      );
      final tp = TextPainter(text: labelSpan, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + baseRadius + 3));
    }

    canvas.restore();
  }

  Color _getRiskColor(String risk) {
    switch (risk.toUpperCase()) {
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
  bool shouldRepaint(covariant _GISMapPainter oldDelegate) {
    return oldDelegate.zoomLevel != zoomLevel ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.selectedZone != selectedZone ||
        oldDelegate.activeLayer != activeLayer ||
        oldDelegate.pulseValue != pulseValue;
  }
}
