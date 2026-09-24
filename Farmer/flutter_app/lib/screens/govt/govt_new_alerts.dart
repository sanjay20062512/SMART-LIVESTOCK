// Smart Livestock — NEW Government Alerts Screen
// Ports React AlertsView: filterable alert list, mark-read, resolve actions.
// Fully connected to FarmerDataService across Farmer, Vet, and Government modules.

import 'package:flutter/material.dart';
import 'govt_theme.dart';
import 'govt_new_data.dart';
import '../../services/farmer_data_service.dart';

class GovtNewAlerts extends StatefulWidget {
  final FarmerDataService? dataService;
  final ValueChanged<int>? onNavigateTab;

  const GovtNewAlerts({
    super.key,
    this.dataService,
    this.onNavigateTab,
  });

  @override
  State<GovtNewAlerts> createState() => _GovtNewAlertsState();
}

class _GovtNewAlertsState extends State<GovtNewAlerts> {
  String _filter = 'All';

  List<GovtAlert> _getAlerts() {
    if (widget.dataService != null) {
      return widget.dataService!.getGovtAlertsList();
    }
    return getInitialAlerts();
  }

  List<GovtAlert> _filterAlerts(List<GovtAlert> alerts) {
    switch (_filter) {
      case 'Critical':
        return alerts.where((a) => a.priority == 'Critical').toList();
      case 'High':
        return alerts.where((a) => a.priority == 'High').toList();
      case 'Unread':
        return alerts.where((a) => !a.isRead).toList();
      case 'Resolved':
        return alerts.where((a) => a.resolved).toList();
      default:
        return alerts;
    }
  }

  int _filterCount(List<GovtAlert> alerts, String f) {
    switch (f) {
      case 'Critical':
        return alerts.where((a) => a.priority == 'Critical').length;
      case 'High':
        return alerts.where((a) => a.priority == 'High').length;
      case 'Unread':
        return alerts.where((a) => !a.isRead).length;
      case 'Resolved':
        return alerts.where((a) => a.resolved).length;
      default:
        return alerts.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allAlerts = _getAlerts();
    final filtered = _filterAlerts(allAlerts);

    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDECEC),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Surveillance Dispatch',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFC94343),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('•', style: TextStyle(color: Color(0xFF667482), fontSize: 11)),
                            const SizedBox(width: 6),
                            const Text(
                              'Real-Time Vet & Field Signals',
                              style: TextStyle(fontSize: 11, color: Color(0xFF667482)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Urgent Disease Alerts & Advisories',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF18232B),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Real-time epidemiological surge signals and veterinary escalations.',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF667482)),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        if (widget.dataService != null) {
                          widget.dataService!.markAllGovtAlertsRead();
                        } else {
                          setState(() {
                            for (final a in allAlerts) {
                              a.isRead = true;
                            }
                          });
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text(
                        'Mark All Read',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF667482),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ── Filter Tabs ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Critical', 'High', 'Unread', 'Resolved'].map((f) {
                  final isActive = _filter == f;
                  final count = _filterCount(allAlerts, f);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF12304A) : GovtColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isActive ? const Color(0xFF12304A) : const Color(0xFFE4EAF0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              f,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isActive ? Colors.white : const Color(0xFF667482),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : const Color(0xFFEAF3FB),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: isActive ? Colors.white : const Color(0xFF1769AA),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ── Alerts List ──────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? _emptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _alertCard(filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 40, color: Color(0xFF16845B)),
          SizedBox(height: 12),
          Text(
            'No alerts matching this filter',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF18232B)),
          ),
          SizedBox(height: 4),
          Text(
            'All high-priority signals in this category have been acknowledged.',
            style: TextStyle(fontSize: 11, color: Color(0xFF667482)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _alertCard(GovtAlert alert) {
    final priorityColor = alert.priority == 'Critical'
        ? const Color(0xFFC94343)
        : alert.priority == 'High'
            ? const Color(0xFFD99A18)
            : const Color(0xFF1769AA);
    final priorityBg = alert.priority == 'Critical'
        ? const Color(0xFFFDECEC)
        : alert.priority == 'High'
            ? const Color(0xFFFFF5D6)
            : const Color(0xFFEAF3FB);
    final typeIcon = _typeIcon(alert.type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: !alert.isRead
              ? const Color(0xFF1769AA).withValues(alpha: 0.4)
              : const Color(0xFFE4EAF0),
          width: !alert.isRead ? 1.5 : 1,
        ),
        boxShadow: !alert.isRead
            ? [
                BoxShadow(
                  color: const Color(0xFF1769AA).withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FB),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: const Color(0xFFE4EAF0)),
                  ),
                  child: Icon(typeIcon, size: 16, color: priorityColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alert.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF18232B),
                              ),
                              maxLines: 2,
                            ),
                          ),
                          if (!alert.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 6, top: 2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1769AA),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.description,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF667482),
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: priorityBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        alert.priority,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: priorityColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.time,
                      style: const TextStyle(fontSize: 9, color: Color(0xFF667482)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFE4EAF0)),
            const SizedBox(height: 10),
            // Bottom row
            Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF1769AA)),
                    const SizedBox(width: 2),
                    Text(
                      alert.district,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1769AA),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (!alert.isRead)
                  GestureDetector(
                    onTap: () {
                      if (widget.dataService != null) {
                        widget.dataService!.markGovtAlertRead(alert.id);
                      } else {
                        setState(() => alert.isRead = true);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: const Text(
                        'Mark Read',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF667482),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (!alert.resolved) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      if (widget.dataService != null) {
                        widget.dataService!.resolveGovtAlert(alert.id);
                      } else {
                        setState(() {
                          alert.resolved = true;
                          alert.isRead = true;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_rounded, size: 12, color: Color(0xFF16845B)),
                          SizedBox(width: 3),
                          Text(
                            'Resolve',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF16845B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else
                  const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF16845B)),
                      SizedBox(width: 3),
                      Text(
                        'Resolved',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16845B),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _handleAlertAction(alert),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12304A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Text(
                          alert.actionText,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(Icons.arrow_forward_rounded, size: 12, color: Colors.white),
                      ],
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

  void _handleAlertAction(GovtAlert alert) {
    if (alert.type == 'Outbreak' && widget.onNavigateTab != null) {
      widget.onNavigateTab!(3); // Outbreak tab
    } else if (alert.type == 'Risk Escalation' && widget.onNavigateTab != null) {
      widget.onNavigateTab!(1); // Disease Map tab
    } else if (alert.type == 'Campaign Due' && widget.onNavigateTab != null) {
      widget.onNavigateTab!(2); // Campaigns tab
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _buildAlertDetailSheet(alert),
      );
    }
  }

  Widget _buildAlertDetailSheet(GovtAlert alert) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: alert.priority == 'Critical' ? const Color(0xFFFDECEC) : const Color(0xFFFFF5D6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  alert.priority.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: alert.priority == 'Critical' ? const Color(0xFFC94343) : const Color(0xFFD99A18),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                alert.type,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF667482)),
              ),
              const Spacer(),
              Text(alert.time, style: const TextStyle(fontSize: 11, color: Color(0xFF667482))),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            alert.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF18232B)),
          ),
          const SizedBox(height: 8),
          Text(
            alert.description,
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.45),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_city_rounded, color: Color(0xFF1769AA), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Surveillance Jurisdiction: ${alert.district} District',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (widget.dataService != null) {
                      widget.dataService!.acknowledgeGovtAlert(alert.id);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✓ Acknowledged & Logged: ${alert.title}'),
                        backgroundColor: const Color(0xFF12304A),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF12304A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Acknowledge'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Outbreak':
        return Icons.shield_outlined;
      case 'Risk Escalation':
        return Icons.warning_amber_rounded;
      case 'Lab Confirmation':
        return Icons.science_outlined;
      case 'Campaign Due':
        return Icons.vaccines_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
}
