// Assessment Result Screen — Displays automated triage findings and clinical recommendations.
// Shown immediately after a farmer submits a symptom report.

import 'package:flutter/material.dart';
import '../models/health_report.dart';
import '../services/farmer_data_service.dart';
import '../services/localization_service.dart';
import '../services/triage_service.dart';
import 'vet_request_screen.dart';

class AssessmentResultScreen extends StatefulWidget {
  final FarmerDataService dataService;
  final String reportId;
  final TriageResult triageResult;
  final String? animalId;
  final String? animalTag;

  const AssessmentResultScreen({
    super.key,
    required this.dataService,
    required this.reportId,
    required this.triageResult,
    this.animalId,
    this.animalTag,
  });

  @override
  State<AssessmentResultScreen> createState() => _AssessmentResultScreenState();
}

class _AssessmentResultScreenState extends State<AssessmentResultScreen> {
  bool _isSpeaking = false;

  void _readAloud(String text) {
    setState(() => _isSpeaking = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text('🔊 Reading advice aloud: "$text"')),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 4),
      ),
    );
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.triageResult;
    Color riskColor;
    IconData riskIcon;
    String riskBadgeText;

    switch (result.riskLevel) {
      case RiskLevel.low:
        riskColor = const Color(0xFF2E7D32);
        riskIcon = Icons.check_circle_rounded;
        riskBadgeText = 'LOW RISK';
        break;
      case RiskLevel.medium:
        riskColor = Colors.orange.shade800;
        riskIcon = Icons.info_rounded;
        riskBadgeText = 'MEDIUM RISK';
        break;
      case RiskLevel.high:
        riskColor = Colors.deepOrange.shade700;
        riskIcon = Icons.warning_rounded;
        riskBadgeText = 'HIGH RISK';
        break;
      case RiskLevel.critical:
        riskColor = Colors.red.shade900;
        riskIcon = Icons.emergency_rounded;
        riskBadgeText = 'CRITICAL HEALTH RISK';
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Assessment Result',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success Submission Pill
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF81C784)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Report Submitted & Logged to Network',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Emergency Risk Assessment Banner
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: riskColor.withValues(alpha: 0.35), width: 2),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(riskIcon, size: 44, color: riskColor),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: riskColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        riskBadgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      result.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: riskColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Case ID: #${widget.reportId} • Tag: ${widget.animalTag ?? "Livestock"}',
                      style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Recommended Action Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 1.5,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFE65100), size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Recommended Action',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade50,
                              foregroundColor: Colors.green.shade900,
                              elevation: 0,
                              minimumSize: const Size(0, 36),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            icon: Icon(
                              _isSpeaking ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                              size: 16,
                            ),
                            label: Text(context.tr('listen'), style: const TextStyle(fontSize: 12.5)),
                            onPressed: () => _readAloud(result.advice),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        result.advice,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.4, color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        result.recommendedAction,
                        style: const TextStyle(color: Colors.black54, fontSize: 13.5, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Request Veterinarian Button (Prominent for High/Critical)
              if (result.riskLevel == RiskLevel.high || result.riskLevel == RiskLevel.critical) ...[
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.medical_services_rounded, size: 22),
                    label: Text(
                      context.tr('request_veterinarian'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VetRequestScreen(
                            dataService: widget.dataService,
                            preselectedAnimalId: widget.animalId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Back to Home Button
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E7D32),
                    side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    context.tr('back_to_home'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
