// Government Module — Reusable Widget Library
// All shared UI components used across government screens.

import 'package:flutter/material.dart';
import '../govt_theme.dart';

// ─── GovernmentMetricCard ──────────────────────────────────────────────────────

class GovernmentMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? change;
  final IconData icon;
  final Color color;
  final Color? bgColor;
  final VoidCallback? onTap;

  const GovernmentMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.change,
    required this.icon,
    required this.color,
    this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: GovtColors.surface,
          borderRadius: GovtRadius.lgRadius,
          border: Border.all(color: GovtColors.border),
          boxShadow: const [
            BoxShadow(color: GovtColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (bgColor ?? color).withValues(alpha: 0.12),
                    borderRadius: GovtRadius.smRadius,
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                if (change != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: change!.startsWith('+')
                          ? GovtColors.criticalLight
                          : GovtColors.successLight,
                      borderRadius: GovtRadius.smRadius,
                    ),
                    child: Text(
                      change!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: change!.startsWith('+')
                            ? GovtColors.critical
                            : GovtColors.success,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                value,
                style: GovtTypography.metricValue.copyWith(color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GovtTypography.metricLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── RiskBadge ────────────────────────────────────────────────────────────────

class RiskBadge extends StatelessWidget {
  final String level;
  final bool compact;

  const RiskBadge({super.key, required this.level, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = level.riskColor;
    final bg = level.riskBgColor;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: GovtRadius.smRadius,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: compact ? 4 : 5),
          Text(
            level,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── StatusChip ───────────────────────────────────────────────────────────────

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: GovtRadius.smRadius,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SectionHeader ────────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GovtTypography.sectionTitle),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: GovtTypography.caption),
                ],
              ],
            ),
          ),
          // ignore: use_null_aware_elements
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── AlertBanner ──────────────────────────────────────────────────────────────

class AlertBanner extends StatelessWidget {
  final String message;
  final String? subMessage;
  final Color color;
  final IconData icon;
  final Widget? action;

  const AlertBanner({
    super.key,
    required this.message,
    this.subMessage,
    required this.color,
    required this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: GovtRadius.mdRadius,
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                if (subMessage != null)
                  Text(
                    subMessage!,
                    style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
                  ),
              ],
            ),
          ),
          // ignore: use_null_aware_elements
          if (action != null) action!,
        ],
      ),
    );
  }
}

// ─── OperationalStatusStrip ───────────────────────────────────────────────────

class OperationalStatusStrip extends StatelessWidget {
  const OperationalStatusStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: GovtColors.surface,
        border: Border(bottom: BorderSide(color: GovtColors.border)),
      ),
      child: Row(
        children: [
          _statusItem(
            icon: Icons.circle,
            iconColor: GovtColors.success,
            label: 'SYSTEM',
            value: 'Operational',
          ),
          _divider(),
          _statusItem(
            icon: Icons.sync_rounded,
            iconColor: GovtColors.brand,
            label: 'LAST SYNC',
            value: '2 min ago',
          ),
          _divider(),
          _statusItem(
            icon: Icons.location_on_rounded,
            iconColor: GovtColors.brand,
            label: 'JURISDICTION',
            value: 'Erode District',
          ),
        ],
      ),
    );
  }

  Widget _statusItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 8, color: iconColor),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: GovtColors.textDisabled, letterSpacing: 0.5)),
                Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GovtColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 28,
        color: GovtColors.border,
        margin: const EdgeInsets.symmetric(horizontal: 10),
      );
}

// ─── ThreatCard ───────────────────────────────────────────────────────────────

class ThreatCard extends StatelessWidget {
  final String location;
  final String suspectedDisease;
  final int affectedAnimals;
  final String detectedAgo;
  final String riskLevel;
  final String responseStatus;
  final VoidCallback? onViewIncident;

  const ThreatCard({
    super.key,
    required this.location,
    required this.suspectedDisease,
    required this.affectedAnimals,
    required this.detectedAgo,
    required this.riskLevel,
    required this.responseStatus,
    this.onViewIncident,
  });

  @override
  Widget build(BuildContext context) {
    final color = riskLevel.riskColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: GovtRadius.mdRadius,
        border: Border(left: BorderSide(color: color, width: 3)),
        boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RiskBadge(level: riskLevel, compact: true),
                const Spacer(),
                Text(detectedAgo, style: GovtTypography.caption),
              ],
            ),
            const SizedBox(height: 6),
            Text(location, style: GovtTypography.bodyMedium),
            const SizedBox(height: 2),
            Text(
              'Suspected $suspectedDisease · $affectedAnimals animals',
              style: GovtTypography.caption,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                StatusChip(
                  label: responseStatus,
                  color: responseStatus == 'Unassigned' ? GovtColors.critical : GovtColors.brand,
                  icon: responseStatus == 'Unassigned' ? Icons.priority_high : Icons.assignment_ind,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onViewIncident,
                  child: Text(
                    'VIEW INCIDENT →',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── GovtTimeline ─────────────────────────────────────────────────────────────

class GovtTimeline extends StatelessWidget {
  final List<GovtTimelineEvent> events;

  const GovtTimeline({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: events.asMap().entries.map((entry) {
        final i = entry.key;
        final e = entry.value;
        final isLast = i == events.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: e.isCompleted ? GovtColors.brand : GovtColors.border,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: e.isCompleted ? GovtColors.brand : GovtColors.textDisabled,
                          width: 2,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(width: 2, color: GovtColors.border, margin: const EdgeInsets.symmetric(vertical: 2)),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.title, style: GovtTypography.bodyMedium),
                      if (e.description != null) ...[
                        const SizedBox(height: 2),
                        Text(e.description!, style: GovtTypography.caption),
                      ],
                      if (e.timestamp != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          _formatTime(e.timestamp!),
                          style: const TextStyle(fontSize: 10, color: GovtColors.textDisabled),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}

class GovtTimelineEvent {
  final String title;
  final String? description;
  final DateTime? timestamp;
  final bool isCompleted;

  const GovtTimelineEvent({
    required this.title,
    this.description,
    this.timestamp,
    this.isCompleted = true,
  });
}

// ─── OutbreakTrendPainter (CustomPaint line chart) ────────────────────────────

class OutbreakTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const OutbreakTrendChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: CustomPaint(
        painter: _TrendChartPainter(data: data),
        size: Size.infinite,
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  _TrendChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    const padding = EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 24);
    final chartW = size.width - padding.left - padding.right;
    final chartH = size.height - padding.top - padding.bottom;

    final maxVal = data
        .expand((d) => [d['current'] as int, d['previous'] as int])
        .fold(0, (a, b) => a > b ? a : b)
        .toDouble();

    final stepX = chartW / (data.length - 1);

    Offset mkPt(int idx, int val) => Offset(
          padding.left + idx * stepX,
          padding.top + chartH - (val / (maxVal == 0 ? 1 : maxVal)) * chartH,
        );

    // Grid lines
    final gridPaint = Paint()
      ..color = GovtColors.border
      ..strokeWidth = 1;
    for (int i = 0; i <= 3; i++) {
      final y = padding.top + chartH * i / 3;
      canvas.drawLine(Offset(padding.left, y), Offset(size.width - padding.right, y), gridPaint);
    }

    // Previous week line
    final prevPaint = Paint()
      ..color = GovtColors.textDisabled
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final prevPath = Path();
    for (int i = 0; i < data.length; i++) {
      final p = mkPt(i, data[i]['previous'] as int);
      if (i == 0) {
        prevPath.moveTo(p.dx, p.dy);
      } else {
        prevPath.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(prevPath, prevPaint);

    // Current week line
    final currPaint = Paint()
      ..color = GovtColors.brand
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Fill area under current
    final fillPath = Path();
    for (int i = 0; i < data.length; i++) {
      final p = mkPt(i, data[i]['current'] as int);
      if (i == 0) {
        fillPath.moveTo(p.dx, p.dy);
      } else {
        fillPath.lineTo(p.dx, p.dy);
      }
    }
    fillPath.lineTo(padding.left + (data.length - 1) * stepX, padding.top + chartH);
    fillPath.lineTo(padding.left, padding.top + chartH);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [GovtColors.brand.withValues(alpha: 0.15), GovtColors.brand.withValues(alpha: 0.01)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    final currPath = Path();
    for (int i = 0; i < data.length; i++) {
      final p = mkPt(i, data[i]['current'] as int);
      if (i == 0) {
        currPath.moveTo(p.dx, p.dy);
      } else {
        currPath.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(currPath, currPaint);

    // Dots
    final dotPaint = Paint()..color = GovtColors.brand;
    for (int i = 0; i < data.length; i++) {
      canvas.drawCircle(mkPt(i, data[i]['current'] as int), 3, dotPaint);
    }

    // Day labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < data.length; i++) {
      tp.text = TextSpan(
        text: data[i]['day'] as String,
        style: const TextStyle(color: GovtColors.textDisabled, fontSize: 9),
      );
      tp.layout();
      tp.paint(canvas, Offset(padding.left + i * stepX - tp.width / 2, size.height - 16));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── VaccinationRingChart ─────────────────────────────────────────────────────

class VaccinationRingChart extends StatelessWidget {
  final double percent;
  final String label;
  final Color color;

  const VaccinationRingChart({
    super.key,
    required this.percent,
    required this.label,
    this.color = GovtColors.brand,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(
        painter: _RingPainter(percent: percent, color: color),
        child: Center(
          child: Text(
            '${percent.round()}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final Color color;

  _RingPainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    final bgPaint = Paint()
      ..color = GovtColors.border
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // -90 degrees (start at top)
      2 * 3.14159 * (percent / 100),
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── MapCanvas (District risk map visualization) ──────────────────────────────

class DistrictRiskMapCanvas extends StatelessWidget {
  final List<Map<String, dynamic>> riskZones;
  final String district;

  const DistrictRiskMapCanvas({
    super.key,
    required this.riskZones,
    required this.district,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: GovtRadius.mdRadius,
      child: Container(
        height: 220,
        color: const Color(0xFFEDF4F2),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _MapPainter(riskZones: riskZones),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _mapLegend(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: GovtColors.surface.withValues(alpha: 0.9),
        border: const Border(top: BorderSide(color: GovtColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _legendItem('Low', GovtColors.riskLow),
          _legendItem('Moderate', GovtColors.riskModerate),
          _legendItem('High', GovtColors.riskHigh),
          _legendItem('Critical', GovtColors.riskCritical),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: GovtColors.textSecondary)),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  final List<Map<String, dynamic>> riskZones;

  _MapPainter({required this.riskZones});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = <String, Offset>{};
    // Fixed positions for demo villages (normalized 0..1)
    final positions = [
      const Offset(0.25, 0.20),
      const Offset(0.60, 0.18),
      const Offset(0.45, 0.42),
      const Offset(0.20, 0.58),
      const Offset(0.72, 0.55),
      const Offset(0.38, 0.72),
      const Offset(0.65, 0.75),
    ];

    for (int i = 0; i < riskZones.length && i < positions.length; i++) {
      rand[riskZones[i]['name'] as String] = positions[i];
    }

    // Draw district boundary (simplified polygon)
    final boundaryPaint = Paint()
      ..color = GovtColors.brand.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = GovtColors.brand.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final boundary = Path()
      ..moveTo(size.width * 0.08, size.height * 0.12)
      ..lineTo(size.width * 0.85, size.height * 0.10)
      ..lineTo(size.width * 0.92, size.height * 0.85)
      ..lineTo(size.width * 0.55, size.height * 0.93)
      ..lineTo(size.width * 0.12, size.height * 0.88)
      ..close();
    canvas.drawPath(boundary, boundaryPaint);
    canvas.drawPath(boundary, strokePaint);

    // Draw road-like lines
    final roadPaint = Paint()
      ..color = GovtColors.border
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.5), Offset(size.width * 0.9, size.height * 0.5), roadPaint);
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.1), Offset(size.width * 0.5, size.height * 0.9), roadPaint);

    // Draw zone circles
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < riskZones.length && i < positions.length; i++) {
      final zone = riskZones[i];
      final pos = positions[i];
      final offset = Offset(pos.dx * size.width, pos.dy * (size.height - 30));
      final riskColor = (zone['risk'] as String).riskColor;
      final cases = zone['cases'] as int;
      final radius = 8.0 + (cases * 1.5).clamp(0, 20);

      // Zone halo
      canvas.drawCircle(offset, radius + 6, Paint()..color = riskColor.withValues(alpha: 0.12));
      // Zone fill
      canvas.drawCircle(offset, radius, Paint()..color = riskColor.withValues(alpha: 0.7));
      // Zone border
      canvas.drawCircle(offset, radius, Paint()..color = riskColor..style = PaintingStyle.stroke..strokeWidth = 1.5);

      // Label
      tp.text = TextSpan(
        text: (zone['name'] as String).split(' ').first,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: riskColor),
      );
      tp.layout();
      tp.paint(canvas, Offset(offset.dx - tp.width / 2, offset.dy + radius + 3));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── GovtProgressBar ─────────────────────────────────────────────────────────

class GovtProgressBar extends StatelessWidget {
  final double value; // 0.0 – 1.0
  final Color color;
  final double height;

  const GovtProgressBar({
    super.key,
    required this.value,
    this.color = GovtColors.brand,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        backgroundColor: GovtColors.border,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: height,
      ),
    );
  }
}

// ─── GovtButton ────────────────────────────────────────────────────────────────

class GovtButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;
  final Color? color;
  final bool compact;

  const GovtButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.outlined = false,
    this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? GovtColors.brand;
    if (outlined) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: c,
          side: BorderSide(color: c),
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: compact ? 8 : 10),
          shape: RoundedRectangleBorder(borderRadius: GovtRadius.smRadius),
        ),
        onPressed: onPressed,
        child: _child(c),
      );
    }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: c,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: compact ? 8 : 10),
        shape: RoundedRectangleBorder(borderRadius: GovtRadius.smRadius),
      ),
      onPressed: onPressed,
      child: _child(Colors.white),
    );
  }

  Widget _child(Color c) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: c),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: GovtTypography.buttonText.copyWith(color: c),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    }
    return Text(label, style: GovtTypography.buttonText.copyWith(color: c), overflow: TextOverflow.ellipsis, maxLines: 1);
  }
}

// ─── GovtSectionCard ─────────────────────────────────────────────────────────

class GovtSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GovtSectionCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? GovtSpacing.cardPadding,
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: GovtRadius.lgRadius,
        border: Border.all(color: GovtColors.border),
        boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}
