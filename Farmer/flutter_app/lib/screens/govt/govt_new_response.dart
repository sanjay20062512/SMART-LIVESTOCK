// Smart Livestock — NEW Government Response Tasks Screen
// Ports React GovernmentResponseView: field response tasks with status, priority, and actions.

import 'package:flutter/material.dart';
import 'govt_theme.dart';
import 'govt_new_data.dart';

class GovtNewResponseTasks extends StatefulWidget {
  const GovtNewResponseTasks({super.key});

  @override
  State<GovtNewResponseTasks> createState() => _GovtNewResponseTasksState();
}

class _GovtNewResponseTasksState extends State<GovtNewResponseTasks> {
  late List<ResponseTask> _tasks;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _tasks = getInitialResponseTasks();
  }

  List<ResponseTask> get _filtered {
    switch (_filter) {
      case 'Critical': return _tasks.where((t) => t.priority == 'Critical').toList();
      case 'High': return _tasks.where((t) => t.priority == 'High').toList();
      case 'In Progress': return _tasks.where((t) => t.status == 'In Progress').toList();
      case 'Completed': return _tasks.where((t) => t.status == 'Completed').toList();
      default: return _tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final critical = _tasks.where((t) => t.priority == 'Critical').length;
    final inProgress = _tasks.where((t) => t.status == 'In Progress').length;
    final completed = _tasks.where((t) => t.status == 'Completed').length;

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
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFEAF3FB), borderRadius: BorderRadius.circular(4)),
                      child: const Text('Field Operations Command', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF1769AA), letterSpacing: 0.5)),
                    ),
                    const SizedBox(width: 6),
                    const Text('•', style: TextStyle(color: Color(0xFF667482), fontSize: 11)),
                    const SizedBox(width: 6),
                    const Text('Containment Response Tracker', style: TextStyle(fontSize: 11, color: Color(0xFF667482))),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Government Response Tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF18232B), letterSpacing: -0.4)),
                const SizedBox(height: 4),
                const Text('Track field containment tasks, veterinary deployments, and government intervention timelines.', style: TextStyle(fontSize: 11.5, color: Color(0xFF667482), height: 1.4)),
              ],
            ),
          ),
          // ── Quick Metrics ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _metricPill('${_tasks.length} Total', const Color(0xFFEAF3FB), const Color(0xFF1769AA)),
                const SizedBox(width: 8),
                _metricPill('$critical Critical', const Color(0xFFFDECEC), const Color(0xFFC94343)),
                const SizedBox(width: 8),
                _metricPill('$inProgress Active', const Color(0xFFFFF5D6), const Color(0xFFD99A18)),
                const SizedBox(width: 8),
                _metricPill('$completed Done', const Color(0xFFE6F4EF), const Color(0xFF087F73)),
              ],
            ),
          ),
          // ── Filter Chips ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Critical', 'High', 'In Progress', 'Completed'].map((f) {
                  final isActive = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF12304A) : GovtColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isActive ? const Color(0xFF12304A) : const Color(0xFFE4EAF0)),
                        ),
                        child: Text(f, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: isActive ? Colors.white : const Color(0xFF667482))),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ── Task List ────────────────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              itemCount: _filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _taskCard(_filtered[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricPill(String label, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _taskCard(ResponseTask task) {
    final priorityColor = task.priority == 'Critical'
        ? const Color(0xFFC94343)
        : task.priority == 'High'
            ? const Color(0xFFE65100)
            : task.priority == 'Medium'
                ? const Color(0xFFD99A18)
                : const Color(0xFF087F73);
    final priorityBg = task.priority == 'Critical'
        ? const Color(0xFFFDECEC)
        : task.priority == 'High'
            ? const Color(0xFFFFEDD5)
            : task.priority == 'Medium'
                ? const Color(0xFFFFF5D6)
                : const Color(0xFFE6F4EF);
    final statusColor = task.status == 'Completed'
        ? const Color(0xFF087F73)
        : task.status == 'In Progress'
            ? const Color(0xFF1769AA)
            : task.status == 'Awaiting Lab Result'
                ? const Color(0xFFD99A18)
                : const Color(0xFF667482);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.status == 'Completed' ? const Color(0xFF087F73).withValues(alpha: 0.3) : const Color(0xFFE4EAF0),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(task.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF18232B))),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: priorityBg, borderRadius: BorderRadius.circular(4)),
                child: Text(task.priority, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: priorityColor)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Location
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF1769AA)),
              const SizedBox(width: 4),
              Text('${task.district}  •  ${task.village}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF1769AA)), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
          const SizedBox(height: 4),
          // Disease concern
          Row(
            children: [
              const Icon(Icons.bug_report_outlined, size: 12, color: Color(0xFF667482)),
              const SizedBox(width: 4),
              Text(task.diseaseConcern, style: const TextStyle(fontSize: 10.5, color: Color(0xFF667482))),
            ],
          ),
          const SizedBox(height: 8),
          // Team & dates
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF7F9FB), borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.groups_outlined, size: 12, color: Color(0xFF667482)),
                    const SizedBox(width: 5),
                    Expanded(child: Text(task.assignedTeam, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF18232B)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 11, color: Color(0xFF667482)),
                    const SizedBox(width: 5),
                    Text('Due: ${task.dueDate}  •  Reported: ${task.reportedDate}', style: const TextStyle(fontSize: 10, color: Color(0xFF667482))),
                  ],
                ),
              ],
            ),
          ),
          if (task.notes != null && task.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: const Color(0xFF1769AA).withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded, size: 12, color: Color(0xFF1769AA)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(task.notes!, style: const TextStyle(fontSize: 10.5, color: Color(0xFF18232B), height: 1.4))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          // Bottom row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: task.status == 'Completed' ? const Color(0xFFE6F4EF) : const Color(0xFFEAF3FB),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(task.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
              ),
              const Spacer(),
              if (task.status != 'Completed')
                GestureDetector(
                  onTap: () => setState(() => task.status = 'Completed'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: const Color(0xFFE6F4EF), borderRadius: BorderRadius.circular(7)),
                    child: const Row(
                      children: [
                        Icon(Icons.check_rounded, size: 12, color: Color(0xFF16845B)),
                        SizedBox(width: 4),
                        Text('Mark Complete', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF16845B))),
                      ],
                    ),
                  ),
                )
              else
                const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF16845B)),
                    SizedBox(width: 4),
                    Text('Completed', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF16845B))),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
