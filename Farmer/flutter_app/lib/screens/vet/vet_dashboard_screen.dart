// Veterinary Dashboard Screen

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../models/case.dart';
import '../../models/alert.dart';
import '../../theme/app_theme.dart';
import 'vet_case_detail_screen.dart';
import 'vet_case_queue_screen.dart';

class VetDashboardScreen extends StatelessWidget {
  final FarmerDataService dataService;

  const VetDashboardScreen({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        final cases = dataService.getAllCases();
        final critical = cases.where((c) => c.riskLevel == 'CRITICAL').toList();
        final high = cases.where((c) => c.riskLevel == 'HIGH').toList();
        final pending = cases
            .where((c) =>
                c.status == FullCaseStatus.submitted ||
                c.status == FullCaseStatus.underReview)
            .toList();
        final clusters = dataService.getAllClusters();
        final visits = dataService.getAllVisits()
            .where((v) => !v.isCompleted)
            .toList();
        final unreadAlerts = dataService.unreadVetAlertCount;
        final vetAlerts = dataService.getVetAlerts();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 130,
                pinned: true,
                backgroundColor: AppColors.primaryDark,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.medical_services, color: Colors.white70, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Dr. Rajesh Kumar · Veterinary Officer',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Veterinary Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  if (clusters.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Chip(
                        avatar: const Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                        label: Text('${clusters.length} Cluster${clusters.length > 1 ? 's' : ''}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.orange.shade100,
                      ),
                    ),
                  IconButton(
                    tooltip: 'Notifications',
                    icon: Badge(
                      isLabelVisible: unreadAlerts > 0,
                      label: Text('$unreadAlerts', style: const TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.redAccent,
                      child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
                    ),
                    onPressed: () => _showNotificationsSheet(context),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Urgent notification banner if there are new unread farmer reports
                    if (unreadAlerts > 0 && vetAlerts.isNotEmpty)
                      _urgentNotificationBanner(context, unreadAlerts, vetAlerts.first),

                    // Stat cards
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        _statCard('CRITICAL', critical.length.toString(),
                            Icons.emergency_rounded, const Color(0xFFB71C1C), Colors.red.shade50),
                        _statCard('HIGH RISK', high.length.toString(),
                            Icons.warning_rounded, const Color(0xFFE65100), Colors.orange.shade50),
                        _statCard('Pending Review', pending.length.toString(),
                            Icons.inbox_rounded, const Color(0xFF1565C0), Colors.blue.shade50),
                        _statCard('Visits Due', visits.length.toString(),
                            Icons.directions_car_rounded, const Color(0xFF2E7D32), Colors.green.shade50),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Priority case queue header
                    Row(
                      children: [
                        const Text(
                          'Priority Case Queue',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => VetCaseQueueScreen(dataService: dataService)),
                            );
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Cases sorted by priority
                    ..._buildPriorityCases(context, cases),

                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _urgentNotificationBanner(BuildContext context, int count, AppAlert latest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.red.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showNotificationsSheet(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notification_important_rounded, color: Colors.red, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$count New Farmer Report${count > 1 ? 's' : ''} Received',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFB71C1C)),
                          ),
                          const Spacer(),
                          const Text('View', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        latest.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ListenableBuilder(
          listenable: dataService,
          builder: (context, _) {
            final alerts = dataService.getVetAlerts();
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active_rounded, color: Color(0xFF1565C0)),
                        const SizedBox(width: 10),
                        const Text(
                          'Vet Notifications',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (alerts.any((a) => !a.isRead))
                          TextButton(
                            onPressed: () => dataService.markAllVetAlertsRead(),
                            child: const Text('Mark all read'),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: alerts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_none_rounded, size: 54, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                const Text('No notifications yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: alerts.length,
                            separatorBuilder: (ctx, index) => const SizedBox(height: 10),
                            itemBuilder: (ctx, i) {
                              final a = alerts[i];
                              final isCrit = a.severity == AlertSeverity.critical;
                              final isHigh = a.severity == AlertSeverity.high;
                              final borderCol = isCrit
                                  ? Colors.red.shade300
                                  : (isHigh ? Colors.orange.shade300 : Colors.grey.shade200);
                              final bgCol = !a.isRead
                                  ? (isCrit
                                      ? Colors.red.shade50
                                      : (isHigh ? Colors.orange.shade50 : const Color(0xFFF0F4FF)))
                                  : Colors.white;

                              return InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  dataService.markAlertRead(a.id);
                                  if (a.relatedId != null) {
                                    final c = dataService.getCaseById(a.relatedId!);
                                    if (c != null) {
                                      Navigator.pop(ctx);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => VetCaseDetailScreen(dataService: dataService, lcase: c),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: bgCol,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: borderCol, width: !a.isRead ? 1.5 : 1),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isCrit
                                              ? Colors.red.shade100
                                              : (isHigh ? Colors.orange.shade100 : Colors.blue.shade100),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isCrit
                                              ? Icons.emergency_rounded
                                              : (isHigh ? Icons.warning_rounded : Icons.info_outline_rounded),
                                          color: isCrit
                                              ? Colors.red.shade800
                                              : (isHigh ? Colors.orange.shade800 : Colors.blue.shade800),
                                          size: 20,
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
                                                    a.title,
                                                    style: TextStyle(
                                                      fontWeight: !a.isRead ? FontWeight.bold : FontWeight.w600,
                                                      fontSize: 14,
                                                      color: isCrit ? const Color(0xFFB71C1C) : const Color(0xFF1A237E),
                                                    ),
                                                  ),
                                                ),
                                                if (!a.isRead)
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration:
                                                        const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(a.message,
                                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.3)),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  _formatTime(a.date),
                                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                                ),
                                                if (a.relatedId != null)
                                                  const Text(
                                                    'Tap to view case →',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF1565C0)),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _statCard(String label, String value, IconData icon, Color color, Color bg) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 26),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Text(label,
                  style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPriorityCases(BuildContext context, List<LivestockCase> cases) {
    final sorted = [...cases]..sort((a, b) {
        const order = {'CRITICAL': 0, 'HIGH': 1, 'MEDIUM': 2, 'LOW': 3};
        return (order[a.riskLevel] ?? 3).compareTo(order[b.riskLevel] ?? 3);
      });

    if (sorted.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text('No cases yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ),
        ),
      ];
    }

    return sorted.take(5).map((c) => _caseCard(context, c)).toList();
  }

  Widget _caseCard(BuildContext context, LivestockCase c) {
    final (color, bg, icon) = switch (c.riskLevel) {
      'CRITICAL' => (const Color(0xFFB71C1C), Colors.red.shade50, Icons.emergency_rounded),
      'HIGH' => (const Color(0xFFE65100), Colors.orange.shade50, Icons.warning_rounded),
      'MEDIUM' => (const Color(0xFFF57F17), Colors.yellow.shade50, Icons.info_rounded),
      _ => (const Color(0xFF2E7D32), Colors.green.shade50, Icons.check_circle_outline),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          '${c.caseId} · ${c.species} · ${c.animalTag}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.symptoms.take(2).join(', '),
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Colors.grey),
                const SizedBox(width: 2),
                Text('${c.village}, ${c.district}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const Spacer(),
                _statusChip(c.status.displayName),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VetCaseDetailScreen(dataService: dataService, lcase: c),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
    );
  }
}
