// Outbreak Management Screen — professional incident management interface

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../models/cluster.dart';
import 'govt_theme.dart';
import 'widgets/govt_widgets.dart';

class GovtClusterScreen extends StatefulWidget {
  final FarmerDataService dataService;
  const GovtClusterScreen({super.key, required this.dataService});

  @override
  State<GovtClusterScreen> createState() => _GovtClusterScreenState();
}

class _GovtClusterScreenState extends State<GovtClusterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.dataService,
      builder: (context, _) {
        final clusters = widget.dataService.getAllClusters();
        final active = clusters.where((c) => c.status == ClusterStatus.monitoring || c.status == ClusterStatus.escalated).toList();
        final investigating = clusters.where((c) => c.status == ClusterStatus.investigation).toList();
        final contained = clusters.where((c) => c.status == ClusterStatus.contained).toList();

        return Scaffold(
          backgroundColor: GovtColors.pageBackground,
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                pinned: true,
                backgroundColor: GovtColors.brandDark,
                foregroundColor: Colors.white,
                automaticallyImplyLeading: false,
                title: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Outbreak Response', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    Text('Incident management & containment', style: TextStyle(fontSize: 11, color: Colors.white70)),
                  ],
                ),
                actions: [
                  IconButton(icon: const Icon(Icons.filter_list_rounded), onPressed: () {}),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  tabs: [
                    Tab(text: 'Active (${active.length})'),
                    Tab(text: 'Investig. (${investigating.length})'),
                    Tab(text: 'Contained (${contained.length})'),
                    const Tab(text: 'Resolved (17)'),
                  ],
                ),
              ),

              // Summary counts
              SliverToBoxAdapter(
                child: Container(
                  color: GovtColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  child: Row(
                    children: [
                      _summaryBadge('Active', active.length, GovtColors.critical),
                      _summaryBadge('Investigating', investigating.length, GovtColors.warning),
                      _summaryBadge('Contained', contained.length, GovtColors.brand),
                      _summaryBadge('Resolved', 17, GovtColors.success),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _incidentList(context, active),
                _incidentList(context, investigating),
                _incidentList(context, contained),
                _resolvedList(),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: GovtColors.brand,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: const Text('New Incident', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            onPressed: () => _showCreateIncident(context),
          ),
        );
      },
    );
  }

  Widget _summaryBadge(String label, int count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: GovtColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _incidentList(BuildContext context, List<OutbreakCluster> clusters) {
    if (clusters.isEmpty) {
      return _emptyState('No incidents in this category', Icons.check_circle_outline_rounded);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: clusters.length,
      itemBuilder: (ctx, i) => _incidentCard(ctx, clusters[i]),
    );
  }

  Widget _incidentCard(BuildContext context, OutbreakCluster c) {
    final riskColor = c.risk.name.toUpperCase().riskColor;
    return GestureDetector(
      onTap: () => _openIncidentDetail(context, c),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: GovtColors.surface,
          borderRadius: GovtRadius.lgRadius,
          border: Border.all(color: GovtColors.border),
          boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            // Header strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: riskColor.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: riskColor.withValues(alpha: 0.15))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 36,
                    decoration: BoxDecoration(color: riskColor, borderRadius: GovtRadius.smRadius),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.clusterId, style: const TextStyle(fontSize: 10, color: GovtColors.textDisabled, letterSpacing: 0.5)),
                        Text('${c.village}, ${c.block}', style: GovtTypography.bodyMedium),
                      ],
                    ),
                  ),
                  RiskBadge(level: c.risk.name.toUpperCase()),
                ],
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      _detailItem(Icons.pets_rounded, c.species),
                      _detailItem(Icons.numbers_rounded, '${c.affectedAnimals} animals'),
                      _detailItem(Icons.warning_rounded, '${c.mortalityCount} deaths'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Wrap(
                        spacing: 4,
                        children: c.commonSymptoms.take(2).map((s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: GovtColors.surfaceSubtle,
                            borderRadius: GovtRadius.smRadius,
                            border: Border.all(color: GovtColors.border),
                          ),
                          child: Text(s.replaceAll(RegExp(r'[^\x20-\x7E]'), '').trim(), style: const TextStyle(fontSize: 10, color: GovtColors.textSecondary)),
                        )).toList(),
                      ),
                      const Spacer(),
                      StatusChip(
                        label: c.status.displayName,
                        color: c.status == ClusterStatus.monitoring ? GovtColors.warning : GovtColors.brand,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(_timeAgo(c.detectedAt), style: GovtTypography.caption),
                      const Spacer(),
                      GovtButton(
                        label: 'View Details',
                        compact: true,
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => _openIncidentDetail(context, c),
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
  }

  Widget _detailItem(IconData icon, String label) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: GovtColors.textSecondary),
          const SizedBox(width: 4),
          Flexible(child: Text(label, style: GovtTypography.caption, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _resolvedList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (ctx, i) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: GovtColors.surface,
          borderRadius: GovtRadius.lgRadius,
          border: Border.all(color: GovtColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: GovtColors.success, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CASE-${2024000 + i * 3}', style: const TextStyle(fontSize: 10, color: GovtColors.textDisabled)),
                  Text('Village ${String.fromCharCode(65 + i)}, Erode', style: GovtTypography.bodyMedium),
                ],
              ),
            ),
            StatusChip(label: 'Resolved', color: GovtColors.success),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 52, color: GovtColors.textDisabled),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: GovtColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  void _openIncidentDetail(BuildContext context, OutbreakCluster c) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _IncidentDetailScreen(cluster: c, dataService: widget.dataService)));
  }

  void _showCreateIncident(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New incident form — connect to backend'), backgroundColor: GovtColors.brand),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return 'Detected ${diff.inDays}d ago';
    if (diff.inHours > 0) return 'Detected ${diff.inHours}h ago';
    return 'Detected ${diff.inMinutes}m ago';
  }
}

// ─── Incident Detail Screen ────────────────────────────────────────────────────

class _IncidentDetailScreen extends StatelessWidget {
  final OutbreakCluster cluster;
  final FarmerDataService dataService;

  const _IncidentDetailScreen({required this.cluster, required this.dataService});

  @override
  Widget build(BuildContext context) {
    final riskColor = cluster.risk.name.toUpperCase().riskColor;

    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      appBar: AppBar(
        backgroundColor: GovtColors.surface,
        foregroundColor: GovtColors.textPrimary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cluster.clusterId, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: GovtColors.textPrimary)),
            Text('${cluster.village}, ${cluster.district}', style: const TextStyle(fontSize: 11, color: GovtColors.textSecondary)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: RiskBadge(level: cluster.risk.name.toUpperCase()),
          ),
        ],
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: GovtColors.border)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Stats
          GovtSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Incident Overview'),
                Row(
                  children: [
                    _stat('Reports', cluster.reportCount, riskColor),
                    _stat('Animals Affected', cluster.affectedAnimals, GovtColors.warning),
                    _stat('Mortalities', cluster.mortalityCount, GovtColors.critical),
                    _stat('Days Active', DateTime.now().difference(cluster.firstReportDate).inDays + 1, GovtColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.pets_rounded, size: 14, color: GovtColors.textSecondary),
                    const SizedBox(width: 6),
                    Text('Species: ${cluster.species}', style: GovtTypography.body),
                    const SizedBox(width: 16),
                    StatusChip(label: cluster.status.displayName, color: GovtColors.brand),
                  ],
                ),
                if (cluster.commonSymptoms.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: cluster.commonSymptoms.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: GovtColors.criticalLight,
                        borderRadius: GovtRadius.smRadius,
                        border: Border.all(color: GovtColors.critical.withValues(alpha: 0.2)),
                      ),
                      child: Text(s.replaceAll(RegExp(r'[^\x20-\x7E]'), '').trim(), style: const TextStyle(fontSize: 11, color: GovtColors.critical)),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Timeline
          GovtSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Incident Timeline'),
                GovtTimeline(events: [
                  GovtTimelineEvent(title: 'First report received', description: 'Farmer submitted symptom report from ${cluster.village}', timestamp: cluster.firstReportDate, isCompleted: true),
                  GovtTimelineEvent(title: 'Veterinary review', description: 'Risk assessed as ${cluster.risk.name.toUpperCase()}', timestamp: cluster.firstReportDate.add(const Duration(hours: 2)), isCompleted: true),
                  GovtTimelineEvent(title: 'Cluster detected', description: 'System flagged geographic clustering of cases', timestamp: cluster.detectedAt, isCompleted: true),
                  GovtTimelineEvent(title: 'Sample collection', description: cluster.status == ClusterStatus.monitoring ? 'Pending dispatch' : 'Samples sent to RDDL Coimbatore', isCompleted: cluster.status != ClusterStatus.monitoring),
                  GovtTimelineEvent(title: 'Laboratory referral', isCompleted: cluster.status == ClusterStatus.escalated),
                  GovtTimelineEvent(title: 'Containment measures', isCompleted: cluster.status == ClusterStatus.contained),
                ]),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action Panel
          GovtSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Government Actions'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    GovtButton(
                      label: 'Assign Vet Team',
                      icon: Icons.assignment_ind_rounded,
                      onPressed: () => _confirmAction(context, 'Assign Veterinary Team', 'This will dispatch a vet team to ${cluster.village}. Proceed?'),
                    ),
                    GovtButton(
                      label: 'Request Investigation',
                      icon: Icons.search_rounded,
                      outlined: true,
                      onPressed: () => _confirmAction(context, 'Request Investigation', 'An investigation team will be deployed. Proceed?'),
                    ),
                    GovtButton(
                      label: 'Request Sample',
                      icon: Icons.science_rounded,
                      outlined: true,
                      onPressed: () => _confirmAction(context, 'Sample Collection Request', 'Lab samples will be requested. Proceed?'),
                    ),
                    GovtButton(
                      label: 'Issue Advisory',
                      icon: Icons.campaign_rounded,
                      outlined: true,
                      onPressed: () => _confirmAction(context, 'Issue Advisory', 'An advisory will be sent to farmers in ${cluster.block}. Proceed?'),
                    ),
                    GovtButton(
                      label: 'Start Vaccination',
                      icon: Icons.vaccines_rounded,
                      outlined: true,
                      onPressed: () => _confirmAction(context, 'Start Vaccination Drive', 'A vaccination campaign will be initiated. Proceed?'),
                    ),
                    GovtButton(
                      label: 'Mark Resolved',
                      icon: Icons.check_circle_rounded,
                      outlined: true,
                      color: GovtColors.success,
                      onPressed: () => _confirmAction(context, 'Mark as Resolved', 'This incident will be marked as resolved. Proceed?'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text('$value', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: GovtColors.textSecondary, textBaseline: TextBaseline.alphabetic), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _confirmAction(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GovtColors.surface,
        shape: RoundedRectangleBorder(borderRadius: GovtRadius.lgRadius),
        title: Text(title, style: GovtTypography.sectionTitle),
        content: Text(message, style: GovtTypography.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: GovtColors.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovtColors.brand, foregroundColor: Colors.white, elevation: 0),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✓ $title initiated'), backgroundColor: GovtColors.brand),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
