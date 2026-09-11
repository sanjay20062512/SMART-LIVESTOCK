// Smart Livestock — Government Alerts Screen (Tab 3)
// Streamlined early warning alert center categorized by Critical, Warning, and Information.

import 'package:flutter/material.dart';
import 'govt_theme.dart';
import 'govt_mock_data.dart';
import '../../services/farmer_data_service.dart';

class GovtAlertsScreen extends StatefulWidget {
  final FarmerDataService dataService;

  const GovtAlertsScreen({
    super.key,
    required this.dataService,
  });

  @override
  State<GovtAlertsScreen> createState() => _GovtAlertsScreenState();
}

class _GovtAlertsScreenState extends State<GovtAlertsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    widget.dataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    widget.dataService.removeListener(_onDataChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  void _showReviewModal(Map<String, dynamic> alert) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GovtColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(alert['title'] ?? 'Alert Review', style: GovtTypography.sectionTitle),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 4),
              Text('${alert['location']} • ${alert['time']}', style: GovtTypography.caption),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GovtColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: GovtColors.border),
                ),
                child: Text(
                  alert['issue'] ?? '',
                  style: const TextStyle(fontSize: 13, color: GovtColors.textPrimary, height: 1.4),
                ),
              ),
              const SizedBox(height: 12),
              const Text('RECOMMENDED PROTOCOL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: GovtColors.textPrimary)),
              const SizedBox(height: 4),
              Text(
                alert['action'] ?? 'Maintain continuous field surveillance.',
                style: const TextStyle(fontSize: 12.5, color: GovtColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: GovtColors.textSecondary,
                        side: const BorderSide(color: GovtColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Alert dismissed.')),
                        );
                      },
                      child: const Text('DISMISS'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GovtColors.brand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: GovtColors.brandDark,
                            content: Text('Action initiated for ${alert['location']} alert.'),
                          ),
                        );
                      },
                      child: const Text('TAKE ACTION', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      appBar: AppBar(
        backgroundColor: GovtColors.surface,
        foregroundColor: GovtColors.textPrimary,
        elevation: 0,
        title: Text('Surveillance Alerts', style: GovtTypography.sectionTitle),
        bottom: TabBar(
          controller: _tabController,
          labelColor: GovtColors.brand,
          unselectedLabelColor: GovtColors.textMuted,
          indicatorColor: GovtColors.brand,
          indicatorWeight: 2.5,
          tabs: const [
            Tab(text: 'Critical'),
            Tab(text: 'Warning'),
            Tab(text: 'Information'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAlertList('Critical'),
          _buildAlertList('Warning'),
          _buildAlertList('Information'),
        ],
      ),
    );
  }

  Widget _buildAlertList(String category) {
    final List<Map<String, dynamic>> alerts = [];

    if (category == 'Critical') {
      final liveGovtAlerts = widget.dataService.getGovernmentAlerts().map((a) => {
        'severity': 'critical',
        'title': a.title,
        'location': a.district.isNotEmpty ? a.district : a.location,
        'time': 'Just now',
        'issue': '${a.title} - ${a.suspectedDisease} (${a.species}, ${a.animalCount} affected)',
        'action': 'Deploy Rapid Response Team & Ring Vaccination',
      }).toList();
      alerts.addAll(liveGovtAlerts);
    }

    alerts.addAll(GovtMockData.getAlertsByCategory(category));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final a = alerts[index];
        final color = category == 'Critical'
            ? GovtColors.critical
            : (category == 'Warning' ? GovtColors.warning : GovtColors.info);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: GovtColors.surface,
              borderRadius: GovtRadius.mdRadius,
              border: Border.all(color: GovtColors.border),
              boxShadow: const [
                BoxShadow(color: GovtColors.shadow, blurRadius: 4, offset: Offset(0, 1)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      a['location'] ?? '',
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: GovtColors.textPrimary),
                    ),
                    const Spacer(),
                    Text(a['time'] ?? '', style: GovtTypography.caption),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  a['issue'] ?? '',
                  style: const TextStyle(fontSize: 12.5, color: GovtColors.textSecondary, height: 1.35),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: GovtColors.brand,
                        side: const BorderSide(color: GovtColors.brand),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () => _showReviewModal(a),
                      child: const Text('Review', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
