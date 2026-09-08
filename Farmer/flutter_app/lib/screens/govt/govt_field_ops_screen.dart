// Field Operations Screen — command view for field teams

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import 'govt_theme.dart';
import 'govt_models.dart';
import 'govt_mock_data.dart';
import 'widgets/govt_widgets.dart';

class GovtFieldOpsScreen extends StatefulWidget {
  final FarmerDataService dataService;
  const GovtFieldOpsScreen({super.key, required this.dataService});

  @override
  State<GovtFieldOpsScreen> createState() => _GovtFieldOpsScreenState();
}

class _GovtFieldOpsScreenState extends State<GovtFieldOpsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _teams = GovtMockData.getFieldTeams();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final available = _teams.where((t) => t.status == FieldTeamStatus.available).length;
    final active = _teams.where((t) => t.status != FieldTeamStatus.available && t.status != FieldTeamStatus.offline).length;
    final offline = _teams.where((t) => t.status == FieldTeamStatus.offline).length;

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
                Text('Field Operations', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                Text('Team dispatch & assignment command', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
            actions: [
              IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () => setState(() {})),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [Tab(text: 'Teams'), Tab(text: 'Map View')],
            ),
          ),

          // Team status summary
          SliverToBoxAdapter(
            child: Container(
              color: GovtColors.surface,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                children: [
                  _statusSummary('${_teams.length}', 'Total Teams', GovtColors.textPrimary),
                  _statusSummary('$available', 'Available', GovtColors.success),
                  _statusSummary('$active', 'Active', GovtColors.brand),
                  _statusSummary('$offline', 'Offline', GovtColors.textDisabled),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _teamsTab(),
            _mapTab(),
          ],
        ),
      ),
    );
  }

  Widget _teamsTab() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: _teams.length,
      itemBuilder: (ctx, i) => _teamCard(ctx, _teams[i]),
    );
  }

  Widget _mapTab() {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: const Color(0xFFEDF4F2),
            child: CustomPaint(
              painter: _TeamMapPainter(teams: _teams),
              size: Size.infinite,
            ),
          ),
        ),
        Container(
          color: GovtColors.surface,
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: FieldTeamStatus.values.map((s) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Row(
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: _teamStatusColor(s), shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(s.name.toUpperCase(), style: const TextStyle(fontSize: 9, color: GovtColors.textSecondary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _teamCard(BuildContext context, FieldTeam team) {
    final statusColor = _teamStatusColor(team.status);
    final syncAgo = DateTime.now().difference(team.lastSync);
    final syncLabel = syncAgo.inMinutes < 60 ? '${syncAgo.inMinutes}m ago' : '${syncAgo.inHours}h ago';
    final isOffline = team.status == FieldTeamStatus.offline;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: GovtRadius.lgRadius,
        border: Border.all(color: isOffline ? GovtColors.criticalLight : GovtColors.border),
        boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: GovtRadius.smRadius,
                  ),
                  child: Center(
                    child: Text(
                      team.teamId.split('-').last,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: statusColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(team.teamName, style: GovtTypography.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${team.members.length} members · ${team.teamType}', style: GovtTypography.caption),
                    ],
                  ),
                ),
                StatusChip(label: team.statusLabel, color: statusColor),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1, color: GovtColors.divider),
            const SizedBox(height: 10),

            // Location & Assignment
            Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 13, color: GovtColors.textSecondary),
                const SizedBox(width: 4),
                Text('${team.currentVillage}, ${team.currentDistrict}', style: GovtTypography.caption),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.assignment_rounded, size: 13, color: GovtColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(child: Text(team.currentAssignment, style: GovtTypography.caption, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),

            const SizedBox(height: 10),

            // Members
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: team.members.map((m) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: GovtColors.surfaceSubtle, borderRadius: GovtRadius.smRadius, border: Border.all(color: GovtColors.border)),
                child: Text(m, style: const TextStyle(fontSize: 10, color: GovtColors.textPrimary)),
              )).toList(),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Icon(Icons.sync_rounded, size: 12, color: isOffline ? GovtColors.critical : GovtColors.success),
                const SizedBox(width: 4),
                Text('Last sync: $syncLabel', style: TextStyle(fontSize: 10, color: isOffline ? GovtColors.critical : GovtColors.textSecondary)),
                const Spacer(),
                if (team.status == FieldTeamStatus.available)
                  GovtButton(
                    label: 'Assign Task',
                    compact: true,
                    icon: Icons.assignment_ind_rounded,
                    onPressed: () => _assignTask(context, team),
                  ),
                if (isOffline)
                  GovtButton(
                    label: 'Alert Team',
                    compact: true,
                    color: GovtColors.critical,
                    icon: Icons.notification_important_rounded,
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert sent to team'))),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _assignTask(BuildContext context, FieldTeam team) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assign Task to ${team.teamName}', style: GovtTypography.sectionTitle),
            const SizedBox(height: 12),
            ...['FMD Investigation — Veeranam', 'Sample Collection — Kavundampadi', 'Vaccination Coverage — Bhavani', 'Movement Restriction Check'].map(
              (t) => ListTile(
                leading: const Icon(Icons.assignment_ind_rounded, color: GovtColors.brand, size: 20),
                title: Text(t, style: GovtTypography.body),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${team.teamId} assigned to $t'), backgroundColor: GovtColors.brand));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusSummary(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: GovtColors.textSecondary)),
        ],
      ),
    );
  }

  Color _teamStatusColor(FieldTeamStatus s) {
    switch (s) {
      case FieldTeamStatus.available:
        return GovtColors.success;
      case FieldTeamStatus.enRoute:
        return GovtColors.warning;
      case FieldTeamStatus.onSite:
        return GovtColors.brand;
      case FieldTeamStatus.investigating:
        return GovtColors.info;
      case FieldTeamStatus.vaccinating:
        return GovtColors.accent;
      case FieldTeamStatus.offline:
        return GovtColors.textDisabled;
    }
  }
}

// ─── Team Map Painter ─────────────────────────────────────────────────────────

class _TeamMapPainter extends CustomPainter {
  final List<FieldTeam> teams;

  _TeamMapPainter({required this.teams});

  @override
  void paint(Canvas canvas, Size size) {
    // District background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFEDF4F2));

    // Roads
    final roadPaint = Paint()..color = const Color(0xFFE0EAE7)..strokeWidth = 2;
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.5), Offset(size.width * 0.9, size.height * 0.5), roadPaint);
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.1), Offset(size.width * 0.5, size.height * 0.9), roadPaint);

    final positions = [
      const Offset(0.30, 0.25),
      const Offset(0.65, 0.20),
      const Offset(0.45, 0.50),
      const Offset(0.70, 0.70),
      const Offset(0.25, 0.70),
      const Offset(0.80, 0.45),
    ];

    final statusColors = {
      FieldTeamStatus.available: GovtColors.success,
      FieldTeamStatus.enRoute: GovtColors.warning,
      FieldTeamStatus.onSite: GovtColors.brand,
      FieldTeamStatus.investigating: GovtColors.info,
      FieldTeamStatus.vaccinating: GovtColors.accent,
      FieldTeamStatus.offline: GovtColors.textDisabled,
    };

    final tp = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < teams.length && i < positions.length; i++) {
      final team = teams[i];
      final pos = Offset(positions[i].dx * size.width, positions[i].dy * size.height);
      final color = statusColors[team.status] ?? GovtColors.textSecondary;

      // Pulse circle
      canvas.drawCircle(pos, 20, Paint()..color = color.withValues(alpha: 0.15));
      // Inner circle
      canvas.drawCircle(pos, 14, Paint()..color = color);
      // ID label
      tp.text = TextSpan(text: team.teamId.split('-').last, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white));
      tp.layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
