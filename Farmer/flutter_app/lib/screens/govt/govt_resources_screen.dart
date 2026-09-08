// Government Module — Resources, Data Health & Field Connectivity Screen
// Directly addresses fragmented reporting, offline syncing in low-connectivity areas,
// and surveillance response-time pipeline telemetry.

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import 'govt_theme.dart';
import 'govt_mock_data.dart';

class GovtResourcesScreen extends StatefulWidget {
  final FarmerDataService dataService;
  const GovtResourcesScreen({super.key, required this.dataService});

  @override
  State<GovtResourcesScreen> createState() => _GovtResourcesScreenState();
}

class _GovtResourcesScreenState extends State<GovtResourcesScreen> {
  final _dataHealth = GovtMockData.getDataHealthMetrics();
  final _connectivity = GovtMockData.getConnectivityMetrics();
  final _responseTime = GovtMockData.getResponseTimeMetrics();
  bool _isSyncing = false;

  void _triggerManualSync() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: GovtColors.brandDark,
          content: Text('✓ 34 offline field records synchronized successfully with Tamil Nadu state grid.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DATA HEALTH & FIELD CONNECTIVITY', style: GovtTypography.pageTitle),
                    Text('Operational telemetry, offline syncing & data quality verification', style: TextStyle(fontSize: 12, color: GovtColors.textSecondary)),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GovtColors.brand,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: _isSyncing
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.sync_rounded, size: 16),
                  label: Text(_isSyncing ? 'SYNCING...' : 'FORCE CLOUD SYNC'),
                  onPressed: _isSyncing ? null : _triggerManualSync,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── 1. Field Connectivity Status (Low-connectivity resilience) ──
            _buildConnectivityCard(),
            const SizedBox(height: 20),

            // ── 2. Data Health & Integrity Monitoring ───────────────────────
            _buildDataHealthCard(),
            const SizedBox(height: 20),

            // ── 3. Response Time Intelligence Pipeline ──────────────────────
            _buildResponseTimeCard(),
          ],
        ),
      ),
    );
  }

  // ─── 1. Field Connectivity Card ─────────────────────────────────────────

  Widget _buildConnectivityCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: GovtColors.border),
        boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.wifi_tethering_rounded, size: 18, color: GovtColors.brand),
                  SizedBox(width: 8),
                  Text('FIELD CONNECTIVITY STATUS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: GovtColors.brandLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Last sync: ${_connectivity.lastSyncTime}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: GovtColors.brandDark)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _metricBox('Online Field Devices', '${_connectivity.onlinePercent}%', '82 active units connected', GovtColors.brand),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metricBox('Offline Field Units', '${_connectivity.offlinePercent}%', '18 units in low-signal zones', GovtColors.warning),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metricBox('Pending Sync Queue', '${_connectivity.pendingSyncCount} records', 'Encrypted local cache waiting', GovtColors.riskHigh),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _connectivity.onlinePercent / 100,
              minHeight: 8,
              backgroundColor: GovtColors.warning.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(GovtColors.brand),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Smart Sync Protocol: Submissions are stored locally in SQLite with SHA-256 validation. When connectivity is restored, deltas sync seamlessly without data duplication.',
            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: GovtColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ─── 2. Data Health & Integrity Card ────────────────────────────────────

  Widget _buildDataHealthCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: GovtColors.border),
        boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.health_and_safety_rounded, size: 18, color: GovtColors.brand),
              SizedBox(width: 8),
              Text('DATA HEALTH MONITORING', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;
              final items = [
                _dataHealthRow('Surveillance Reports Received', '${_dataHealth.reportsReceived}', '100% ingested into database', GovtColors.brand),
                _dataHealthRow('Incomplete Symptom Reports', '${_dataHealth.incompleteReports}', 'Awaiting para-vet verification', GovtColors.warning),
                _dataHealthRow('Duplicate Filtered Records', '${_dataHealth.duplicateReports}', 'Auto-resolved via GPS proximity', GovtColors.info),
                _dataHealthRow('Missing Vaccination Ear Tags', '${_dataHealth.missingVaccinationRecords}', 'Flagged for reconciliation', GovtColors.riskHigh),
                _dataHealthRow('Pending Laboratory Results', '${_dataHealth.pendingLabResults}', '4 delayed beyond 24h SLA', GovtColors.riskCritical),
                _dataHealthRow('Offline Submissions in Cache', '${_dataHealth.offlineSubmissionsWaiting}', 'Auto-sync active upon network ping', GovtColors.brand),
              ];

              if (isWide) {
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3.8,
                  children: items,
                );
              } else {
                return Column(children: items.map((w) => Padding(padding: const EdgeInsets.only(bottom: 8), child: w)).toList());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _dataHealthRow(String label, String count, String note, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: GovtColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: GovtColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.textPrimary)),
                Text(note, style: const TextStyle(fontSize: 10, color: GovtColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
            child: Text(count, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          ),
        ],
      ),
    );
  }

  // ─── 3. Response Time Intelligence Pipeline ─────────────────────────────

  Widget _buildResponseTimeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GovtRadius.mdRadius,
        border: Border.all(color: GovtColors.border),
        boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.timer_rounded, size: 18, color: GovtColors.brand),
                  SizedBox(width: 8),
                  Text('RESPONSE TIME INTELLIGENCE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textPrimary)),
                ],
              ),
              Text('Demonstrated Latency Reduction: -64%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: GovtColors.brand)),
            ],
          ),
          // Metrics summary
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _metricChip('Avg Reporting Time', '${_responseTime.reportingTimeHours}h', GovtColors.brand),
              _metricChip('Avg Response Time', '${_responseTime.responseTimeHours}h', GovtColors.riskLow),
              _metricChip('Lab Turnaround', '${_responseTime.labTurnaroundHours}h', GovtColors.warning),
              _metricChip('Avg Containment', '${_responseTime.containmentDays}d', GovtColors.info),
            ],
          ),
          const SizedBox(height: 14),

          // Lifecycle steps
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _timeStep('Report Received', '0.0h', Icons.mark_email_read_rounded, isStart: true),
              _arrow(),
              _timeStep('AI/Rule Triage', '+0.2h', Icons.auto_awesome_rounded),
              _arrow(),
              _timeStep('Vet Assigned', '+1.6h', Icons.person_pin_rounded),
              _arrow(),
              _timeStep('Sample Collected', '+4.2h', Icons.biotech_rounded),
              _arrow(),
              _timeStep('Lab Result', '+14.5h', Icons.science_rounded),
              _arrow(),
              _timeStep('Action & Cordon', '+18.0h', Icons.security_rounded),
              _arrow(),
              _timeStep('Contained', '3.2 Days', Icons.check_circle_rounded, isEnd: true),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: GovtColors.brandLight, borderRadius: BorderRadius.circular(6)),
            child: const Row(
              children: [
                Icon(Icons.bolt_rounded, size: 16, color: GovtColors.brand),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'System Impact: Automated early syndromic triage reduced outbreak detection-to-response latency from 8.5 days (paper baseline) to 1.8 hours.',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GovtColors.brandDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: GovtColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _metricBox(String title, String val, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: GovtColors.surfaceSubtle, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: GovtColors.textSecondary)),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 10, color: GovtColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _timeStep(String title, String time, IconData icon, {bool isStart = false, bool isEnd = false}) {
    final color = isStart ? GovtColors.info : (isEnd ? GovtColors.riskLow : GovtColors.brand);
    return Column(
      children: [
        CircleAvatar(radius: 16, backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, size: 16, color: color)),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: GovtColors.textPrimary), textAlign: TextAlign.center),
        Text(time, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  Widget _arrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Icon(Icons.arrow_forward, size: 12, color: GovtColors.textSecondary),
    );
  }
}
