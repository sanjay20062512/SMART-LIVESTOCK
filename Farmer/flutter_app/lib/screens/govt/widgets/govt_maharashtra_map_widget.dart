// Smart Livestock — Maharashtra Disease Risk & Vaccination Coverage Map Widget
// Realistic, interactive geographic visualization for district-level surveillance and campaigns.

import 'package:flutter/material.dart';
import '../govt_theme.dart';
import '../govt_models.dart';

enum MapDisplayMode {
  diseaseRisk,
  vaccinationCoverage,
}

class GovtMaharashtraMapWidget extends StatefulWidget {
  final List<DistrictRiskProfile> districts;
  final DistrictRiskProfile selectedDistrict;
  final ValueChanged<DistrictRiskProfile> onSelectDistrict;
  final String selectedDisease;
  final ValueChanged<String> onDiseaseChanged;
  final String selectedTimeframe;
  final ValueChanged<String> onTimeframeChanged;
  final MapDisplayMode mode;

  const GovtMaharashtraMapWidget({
    super.key,
    required this.districts,
    required this.selectedDistrict,
    required this.onSelectDistrict,
    this.selectedDisease = 'All',
    required this.onDiseaseChanged,
    this.selectedTimeframe = '7 Days',
    required this.onTimeframeChanged,
    this.mode = MapDisplayMode.diseaseRisk,
  });

  static Color getDistrictColor(DistrictRiskProfile d, MapDisplayMode mode) {
    if (mode == MapDisplayMode.vaccinationCoverage) {
      if (d.vaccinationCoverage >= 80) return const Color(0xFF16A34A); // Green: 80-100% Good
      if (d.vaccinationCoverage >= 50) return const Color(0xFFCA8A04); // Yellow: 50-79% Needs attention
      return const Color(0xFFDC2626); // Red: 0-49% Critical gap
    }
    return GovtColors.getHeatmapColor(d.riskScore);
  }

  @override
  State<GovtMaharashtraMapWidget> createState() => _GovtMaharashtraMapWidgetState();
}

class _GovtMaharashtraMapWidgetState extends State<GovtMaharashtraMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: GovtColors.border),
        boxShadow: const [
          BoxShadow(color: GovtColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: GovtRadius.mdRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Controls Bar (Disease & Time Filters)
            _buildMapFilterBar(),

            // Interactive Map Canvas Area
            AspectRatio(
              aspectRatio: 1.35,
              child: Stack(
                children: [
                  // Map Canvas (Background, State Outline & District Nodes)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _MaharashtraMapPainter(
                            districts: widget.districts,
                            selectedDistrict: widget.selectedDistrict,
                            pulseValue: _pulseCtrl.value,
                            mode: widget.mode,
                          ),
                        );
                      },
                    ),
                  ),

                  // Interactive Tap Overlays for each district
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;

                      return Stack(
                        children: widget.districts.map((d) {
                          final isSelected = d.name == widget.selectedDistrict.name;
                          final left = d.normX * w - 38;
                          final top = d.normY * h - 22;
                          final color = GovtMaharashtraMapWidget.getDistrictColor(d, widget.mode);

                          return Positioned(
                            left: left.clamp(4.0, w - 80.0),
                            top: top.clamp(4.0, h - 48.0),
                            child: GestureDetector(
                              onTap: () => widget.onSelectDistrict(d),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? color
                                      : Colors.white.withValues(alpha: 0.94),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSelected ? Colors.white : color,
                                    width: isSelected ? 2.0 : 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: isSelected ? 0.35 : 0.15),
                                      blurRadius: isSelected ? 8 : 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white : color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          d.name,
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                            color: isSelected ? Colors.white : GovtColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          widget.mode == MapDisplayMode.vaccinationCoverage
                                              ? '${d.vaccinationCoverage}%'
                                              : '${d.riskScore}%',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: isSelected ? Colors.white70 : color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  // State Watermark & Scope Badge
                  Positioned(
                    top: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: GovtColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.mode == MapDisplayMode.vaccinationCoverage ? Icons.vaccines_outlined : Icons.shield_outlined,
                            size: 12,
                            color: GovtColors.brand,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.mode == MapDisplayMode.vaccinationCoverage
                                ? 'MAHARASHTRA VACCINATION CAMPAIGN COVERAGE'
                                : 'MAHARASHTRA EPIDEMIOLOGICAL SURVEILLANCE',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: GovtColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Embedded Compact Map Legend
                  Positioned(
                    bottom: 8,
                    left: 10,
                    right: 10,
                    child: _buildCompactLegend(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapFilterBar() {
    final diseases = ['All', 'FMD', 'Anthrax', 'Brucellosis', 'Other'];
    final timeframes = ['7 Days', '30 Days', '90 Days'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: GovtColors.surfaceSubtle,
        border: Border(bottom: BorderSide(color: GovtColors.border)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 6,
        children: [
          // Disease filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: diseases.map((d) {
                final isSelected = widget.selectedDisease == d;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => widget.onDiseaseChanged(d),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? GovtColors.brand : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected ? GovtColors.brand : GovtColors.border,
                        ),
                      ),
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : GovtColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Timeframe toggle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: timeframes.map((t) {
              final isSelected = widget.selectedTimeframe == t;
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => widget.onTimeframeChanged(t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: isSelected ? GovtColors.brandLight : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? GovtColors.brandDark : GovtColors.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLegend() {
    final isVaccination = widget.mode == MapDisplayMode.vaccinationCoverage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: GovtColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: isVaccination
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Coverage: ',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: GovtColors.textPrimary),
                  ),
                  const SizedBox(width: 6),
                  _legendItem(const Color(0xFF16A34A), '80–100% Good'),
                  const SizedBox(width: 10),
                  _legendItem(const Color(0xFFCA8A04), '50–79% Needs attention'),
                  const SizedBox(width: 10),
                  _legendItem(const Color(0xFFDC2626), '0–49% Critical gap'),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Risk Level: ',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: GovtColors.textPrimary),
                  ),
                  const SizedBox(width: 6),
                  _legendItem(GovtColors.riskLow, '0–30% Low'),
                  const SizedBox(width: 10),
                  _legendItem(GovtColors.riskMedium, '31–55% Medium'),
                  const SizedBox(width: 10),
                  _legendItem(GovtColors.riskHigh, '56–75% High'),
                  const SizedBox(width: 10),
                  _legendItem(GovtColors.riskCritical, '76–100% Critical'),
                ],
              ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
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
          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

// ─── Custom Painter for Maharashtra Outline & Regional Zones ─────────────────

class _MaharashtraMapPainter extends CustomPainter {
  final List<DistrictRiskProfile> districts;
  final DistrictRiskProfile selectedDistrict;
  final double pulseValue;
  final MapDisplayMode mode;

  _MaharashtraMapPainter({
    required this.districts,
    required this.selectedDistrict,
    required this.pulseValue,
    required this.mode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background subtle grid
    final gridPaint = Paint()
      ..color = GovtColors.border.withValues(alpha: 0.35)
      ..strokeWidth = 0.6;
    for (double x = 0; x < w; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Simplified polygon of Maharashtra's geographic shape
    final path = Path();
    // West coastal border & Deccan plateau outline
    path.moveTo(w * 0.12, h * 0.28); // Dahanu / Palghar
    path.lineTo(w * 0.24, h * 0.20); // Nandurbar / Dhule
    path.lineTo(w * 0.45, h * 0.14); // Jalgaon / Tapi border
    path.lineTo(w * 0.68, h * 0.12); // Amravati / Melghat
    path.lineTo(w * 0.88, h * 0.15); // Nagpur / Bhandara / Gondia
    path.lineTo(w * 0.94, h * 0.38); // Gadchiroli east
    path.lineTo(w * 0.82, h * 0.62); // Chandrapur south
    path.lineTo(w * 0.68, h * 0.68); // Nanded / Godavari
    path.lineTo(w * 0.54, h * 0.84); // Solapur south
    path.lineTo(w * 0.32, h * 0.94); // Kolhapur south / Sindhudurg
    path.lineTo(w * 0.16, h * 0.86); // Ratnagiri coast
    path.lineTo(w * 0.14, h * 0.60); // Raigad / Alibag
    path.lineTo(w * 0.11, h * 0.44); // Mumbai / Thane coast
    path.close();

    // Fill state territory with gentle tint
    final territoryPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, territoryPaint);

    // Border stroke
    final borderPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawPath(path, borderPaint);

    // Draw connecting regional corridors between districts
    final corridorPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final connections = [
      ['Thane', 'Nashik'],
      ['Nashik', 'Jalgaon'],
      ['Jalgaon', 'Amravati'],
      ['Amravati', 'Nagpur'],
      ['Nashik', 'Chhatrapati Sambhajinagar'],
      ['Chhatrapati Sambhajinagar', 'Nanded'],
      ['Thane', 'Pune'],
      ['Pune', 'Satara'],
      ['Satara', 'Kolhapur'],
      ['Pune', 'Solapur'],
      ['Chhatrapati Sambhajinagar', 'Latur'],
      ['Solapur', 'Latur'],
      ['Latur', 'Nanded'],
    ];

    final districtMap = {for (var d in districts) d.name: d};

    for (final conn in connections) {
      final d1 = districtMap[conn[0]];
      final d2 = districtMap[conn[1]];
      if (d1 != null && d2 != null) {
        canvas.drawLine(
          Offset(d1.normX * w, d1.normY * h),
          Offset(d2.normX * w, d2.normY * h),
          corridorPaint,
        );
      }
    }

    // Draw Heat Radii / Concentric Zones for each district
    for (final d in districts) {
      final center = Offset(d.normX * w, d.normY * h);
      final color = GovtMaharashtraMapWidget.getDistrictColor(d, mode);
      final isSelected = d.name == selectedDistrict.name;

      // Base radius scaled by risk score or coverage gap
      final baseRadius = mode == MapDisplayMode.vaccinationCoverage
          ? 14.0 + ((100 - d.vaccinationCoverage) / 100.0) * 14.0
          : 14.0 + (d.riskScore / 100.0) * 16.0;

      // Outer heat halo
      final haloPaint = Paint()
        ..color = color.withValues(alpha: isSelected ? 0.28 : 0.14)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, baseRadius, haloPaint);

      // Inner heat core
      final corePaint = Paint()
        ..color = color.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, baseRadius * 0.55, corePaint);

      // Center anchor dot
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 3.5, dotPaint);

      // Pulsing beacon ring for selected district
      if (isSelected) {
        final ringRadius = baseRadius + (pulseValue * 12.0);
        final ringPaint = Paint()
          ..color = color.withValues(alpha: 0.75 * (1.0 - pulseValue))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2;
        canvas.drawCircle(center, ringRadius, ringPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MaharashtraMapPainter oldDelegate) {
    return oldDelegate.selectedDistrict.name != selectedDistrict.name ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.districts != districts ||
        oldDelegate.mode != mode;
  }
}
