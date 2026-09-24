// Veterinary Case Detail Screen — full view with actions

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../services/media_service.dart';
import '../../models/case.dart';
import '../../models/sample.dart';
import '../../models/vet_visit.dart';
import 'vet_sample_screen.dart';
import 'vet_visit_screen.dart';
import '../../services/localization_service.dart';

class VetCaseDetailScreen extends StatefulWidget {
  final FarmerDataService dataService;
  final LivestockCase lcase;

  const VetCaseDetailScreen({
    super.key,
    required this.dataService,
    required this.lcase,
  });

  @override
  State<VetCaseDetailScreen> createState() => _VetCaseDetailScreenState();
}

class _VetCaseDetailScreenState extends State<VetCaseDetailScreen> {
  bool _isPlayingVoice = false;

  void _togglePlayVoice(String? path) async {
    if (_isPlayingVoice) {
      await MediaService.instance.stopAudio();
      setState(() => _isPlayingVoice = false);
    } else {
      setState(() => _isPlayingVoice = true);
      await MediaService.instance.playAudio(
        path ?? 'audio_sample.wav',
        onComplete: () {
          if (mounted) setState(() => _isPlayingVoice = false);
        },
      );
    }
  }

  void _showFullImageDialog(BuildContext context, String? photoPath, String? photoUrl) {
    final cachedBytes = MediaService.instance.getCachedBytes(photoPath);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.photo_camera_rounded, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  const Text('Field Clinical Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              color: Colors.black,
              child: cachedBytes != null
                  ? Image.memory(cachedBytes, fit: BoxFit.contain)
                  : (photoUrl != null && photoUrl.startsWith('http')
                      ? Image.network(photoUrl, fit: BoxFit.contain)
                      : Container(
                          height: 260,
                          color: const Color(0xFF1E293B),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_rounded, size: 70, color: Colors.blueAccent),
                                SizedBox(height: 10),
                                Text('Clinical Symptom Photo Attached by Farmer', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                        )),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Source: ${photoPath ?? photoUrl ?? "Farmer Mobile Upload"}',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoPlayerDialog(BuildContext context, String? videoPath, String? videoUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.videocam_rounded, color: Colors.tealAccent),
                  const SizedBox(width: 8),
                  const Text('Clinical Video Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade700),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.teal,
                        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                      ),
                      SizedBox(height: 10),
                      Text('Clinical Video Evidence (Playing)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      SizedBox(height: 4),
                      Text('Recorded at Farm Location · 1080p', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'File: ${videoPath ?? videoUrl ?? "clinical_recording.mp4"}',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.dataService, LocalizationService.instance]),
      builder: (context, _) {
        final c = widget.dataService.getCaseById(widget.lcase.caseId) ?? widget.lcase;
        final samples = widget.dataService.getSamplesForCase(c.caseId);
        final visits = widget.dataService.getVisitsForCase(c.caseId);

        final riskColor = switch (c.riskLevel) {
          'CRITICAL' => const Color(0xFFB71C1C),
          'HIGH' => const Color(0xFFE65100),
          'MEDIUM' => const Color(0xFFF57F17),
          _ => const Color(0xFF2E7D32),
        };

        return Scaffold(
          backgroundColor: const Color(0xFFF0F4FF),
          appBar: AppBar(
            title: Text(c.caseId, style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: riskColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Risk badge
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: riskColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_rounded, color: Colors.white),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('risk_header', params: {'level': context.tr(c.riskLevel.toLowerCase())}),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(context.translateText('Preliminary risk assessment'),
                              style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      _statusPill(context.translateStatus(c.status.displayName)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Farmer & Farm info
                _section(context.translateText('Farmer & Farm'), [
                  _row(context.translateText('Farmer'), c.farmerName),
                  _row(context.translateText('Farm'), c.farmName),
                  _row(context.translateText('Village'), c.village),
                  _row(context.translateText('Block'), c.block),
                  _row(context.translateText('District'), c.district),
                ]),

                // Animal details
                _section(context.translateText('Animal Details'), [
                  _row(context.translateText('Species'), context.translateSpecies(c.species)),
                  if (c.breed != null) _row(context.translateText('Breed'), context.translateBreed(c.breed!)),
                  if (c.age != null) _row(context.translateText('Age'), c.age!),
                  if (c.gender != null) _row(context.translateText('Gender'), context.translateText(c.gender!)),
                  _row(context.translateText('Tag'), c.animalTag),
                ]),

                // Clinical info
                _section(context.translateText('Clinical Information'), [
                  _row(context.translateText('Symptoms'), c.symptoms.map((s) => context.translateSymptom(s)).join(', ')),
                  if (c.duration != null) _row(context.translateText('Duration'), context.translateText(c.duration!)),
                  if (c.affectedCount != null) _row(context.translateText('Animals Affected'), '${c.affectedCount}'),
                  if (c.otherAnimalsAffected != null)
                    _row(context.translateText('Other Animals Affected'), context.translateText(c.otherAnimalsAffected!)),
                  if (c.nearbyFarmsAffected != null)
                    _row(context.translateText('Nearby Farms Affected'), context.translateText(c.nearbyFarmsAffected!)),
                ]),

                // Rich Evidence Section
                if (c.hasVoiceNote || c.hasPhoto || c.hasVideo)
                  _section('Attached Media Evidence', [
                    if (c.hasPhoto) ...[
                      _buildVetPhotoEvidence(context, c),
                      const SizedBox(height: 10),
                    ],
                    if (c.hasVideo) ...[
                      _buildVetVideoEvidence(context, c),
                      const SizedBox(height: 10),
                    ],
                    if (c.hasVoiceNote) ...[
                      _buildVetVoiceEvidence(context, c),
                    ],
                  ]),

                // Clinical Observation (if added)
                if (c.clinicalObservation != null)
                  _section('Clinical Observation', [
                    Text(c.clinicalObservation!,
                        style: const TextStyle(fontSize: 14, height: 1.4)),
                  ]),

                // Treatment (if added)
                if (c.treatmentSummary != null)
                  _section('Treatment Summary', [
                    Text(c.treatmentSummary!,
                        style: const TextStyle(fontSize: 14, height: 1.4)),
                  ]),

                // Samples
                if (samples.isNotEmpty)
                  _section('Laboratory Samples', samples.map((s) => _sampleRow(s)).toList()),

                // Visits
                if (visits.isNotEmpty)
                  _section('Field Visits', visits.map((v) => _visitRow(v)).toList()),

                // Timeline
                _section('Case Timeline', c.timeline.map((e) => _timelineEvent(e)).toList()),

                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomNavigationBar: _buildActionBar(context, c),
        );
      },
    );
  }

  Widget _buildVetPhotoEvidence(BuildContext context, LivestockCase c) {
    final photoPath = c.localPhotoPath ?? (c.photoUrls?.isNotEmpty == true ? c.photoUrls!.first : null);
    final cachedBytes = MediaService.instance.getCachedBytes(photoPath);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 70,
              height: 70,
              color: Colors.blue.shade100,
              child: cachedBytes != null
                  ? Image.memory(cachedBytes, width: 70, height: 70, fit: BoxFit.cover)
                  : const Center(
                      child: Icon(Icons.photo_library_rounded, color: Colors.blue, size: 36),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.photo_camera_rounded, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    const Text(
                      'Symptom Photo',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D47A1)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Attached by farmer during report',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    minimumSize: const Size(0, 28),
                    side: BorderSide(color: Colors.blue.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.fullscreen_rounded, size: 16),
                  label: const Text('View Full Photo', style: TextStyle(fontSize: 11)),
                  onPressed: () => _showFullImageDialog(context, photoPath, c.photoUrls?.first),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVetVideoEvidence(BuildContext context, LivestockCase c) {
    final videoPath = c.localVideoPath ?? c.videoUrl;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => _showVideoPlayerDialog(context, videoPath, c.videoUrl),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.videocam_rounded, size: 16, color: Colors.teal),
                    const SizedBox(width: 4),
                    const Text(
                      'Clinical Video Clip',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF004D40)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Motion / symptom video evidence',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 6),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    minimumSize: const Size(0, 28),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 15),
                  label: const Text('Play Video', style: TextStyle(fontSize: 11)),
                  onPressed: () => _showVideoPlayerDialog(context, videoPath, c.videoUrl),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVetVoiceEvidence(BuildContext context, LivestockCase c) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mic_rounded, size: 18, color: Colors.orange),
              const SizedBox(width: 6),
              const Text(
                'Farmer Voice Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFE65100)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPlayingVoice ? Colors.red.shade700 : Colors.orange.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  minimumSize: const Size(0, 28),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: Icon(_isPlayingVoice ? Icons.stop_rounded : Icons.volume_up_rounded, size: 15),
                label: Text(_isPlayingVoice ? 'Stop' : 'Listen', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: () => _togglePlayVoice(c.localVoicePath ?? c.voiceNoteUrl),
              ),
            ],
          ),
          if (c.voiceTranscript != null && c.voiceTranscript!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote_rounded, size: 18, color: Colors.orange.shade800),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '"${c.voiceTranscript}"',
                      style: TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: Colors.grey.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A237E))),
          const Divider(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _sampleRow(Sample s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.science_outlined, size: 16, color: Colors.purple),
          const SizedBox(width: 8),
          Expanded(
            child: Text('${s.sampleType} · ${s.collectedBy}',
                style: const TextStyle(fontSize: 13)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(s.status.displayName,
                style: TextStyle(fontSize: 11, color: Colors.purple.shade700, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _visitRow(VetVisit v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            v.isCompleted ? Icons.check_circle : Icons.schedule,
            size: 16,
            color: v.isCompleted ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${v.vetName} · ${v.scheduledDate.day}/${v.scheduledDate.month}',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Text(v.isCompleted ? 'Completed' : 'Scheduled',
              style: TextStyle(
                fontSize: 11,
                color: v.isCompleted ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  Widget _timelineEvent(CaseTimelineEvent e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF1565C0),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 28,
                color: Colors.blue.shade100,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.status,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(e.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                if (e.actor != null)
                  Text('by ${e.actor}',
                      style: const TextStyle(color: Colors.blueGrey, fontSize: 11)),
              ],
            ),
          ),
          Text(
            '${e.timestamp.hour}:${e.timestamp.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white54),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionBar(BuildContext context, LivestockCase c) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.directions_car, size: 18),
                  label: const Text('Schedule Visit', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: c.status == FullCaseStatus.caseClosed ? null : () => _scheduleVisit(context, c),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.science, size: 18),
                  label: const Text('Add Sample', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: c.status == FullCaseStatus.caseClosed ? null : () => _addSample(context, c),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.note_add, size: 18),
                  label: const Text('Add Observation'),
                  onPressed: () => _addObservation(context, c),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.upgrade, size: 18),
                  label: const Text('Update Status'),
                  onPressed: () => _updateStatus(context, c),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: c.isEscalatedToGovt || c.status == FullCaseStatus.escalated
                    ? Colors.grey.shade700
                    : Colors.deepOrange.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(
                c.isEscalatedToGovt || c.status == FullCaseStatus.escalated
                    ? Icons.check_circle_rounded
                    : Icons.report_problem_rounded,
                size: 18,
              ),
              label: Text(
                c.isEscalatedToGovt || c.status == FullCaseStatus.escalated
                    ? 'Escalated to Govt Surveillance'
                    : 'Escalate Case to Government',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: c.isEscalatedToGovt || c.status == FullCaseStatus.escalated
                  ? null
                  : () => _handleEscalateCase(context, c),
            ),
          ),
        ],
      ),
    );
  }

  void _handleEscalateCase(BuildContext context, LivestockCase c) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.report_problem_rounded, color: Colors.deepOrange),
            SizedBox(width: 8),
            Expanded(child: Text('Escalate Case to Government')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Escalating Case #${c.caseId} (${c.species}, ${c.animalTag}) will dispatch an emergency high-priority alert to the State Government Surveillance Portal.',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Reason for Escalation (Optional)',
                hintText: 'e.g. Suspected contagious epidemic outbreak...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange.shade800,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.dataService.escalateCase(
                c.caseId,
                reason: reasonCtrl.text.trim().isNotEmpty ? reasonCtrl.text.trim() : null,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✓ Case #${c.caseId} escalated to Government Surveillance.'),
                  backgroundColor: Colors.deepOrange.shade800,
                ),
              );
            },
            child: const Text('Escalate Now'),
          ),
        ],
      ),
    );
  }

  void _scheduleVisit(BuildContext context, LivestockCase c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VetVisitScreen(dataService: widget.dataService, lcase: c),
      ),
    );
  }

  void _addSample(BuildContext context, LivestockCase c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VetSampleScreen(dataService: widget.dataService, lcase: c),
      ),
    );
  }

  void _addObservation(BuildContext context, LivestockCase c) {
    final ctrl = TextEditingController(text: c.clinicalObservation ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clinical Observation'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter clinical findings, symptoms observed, preliminary assessment...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              c.clinicalObservation = ctrl.text.trim();
              widget.dataService.updateCaseStatus(c.caseId, FullCaseStatus.investigation,
                  actor: 'Veterinarian', description: 'Clinical observation added.');
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _updateStatus(BuildContext context, LivestockCase c) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Update Case Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(height: 16),
              RadioGroup<FullCaseStatus>(
                groupValue: c.status,
                onChanged: (v) {
                  if (v != null) {
                    widget.dataService.updateCaseStatus(c.caseId, v, actor: 'Veterinarian');
                    Navigator.pop(ctx);
                  }
                },
                child: Column(
                  children: FullCaseStatus.values.map((s) => ListTile(
                    title: Text(s.displayName),
                    leading: Radio<FullCaseStatus>(value: s),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
