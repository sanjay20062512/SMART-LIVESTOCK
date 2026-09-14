import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class OfflineMediaItem {
  final String caseId;
  final String? voicePath;
  final String? photoPath;
  final String? videoPath;
  final String? voiceTranscript;
  final String language;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  OfflineMediaItem({
    required this.caseId,
    this.voicePath,
    this.photoPath,
    this.videoPath,
    this.voiceTranscript,
    this.language = 'en-IN',
    this.latitude,
    this.longitude,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'caseId': caseId,
        'voicePath': voicePath,
        'photoPath': photoPath,
        'videoPath': videoPath,
        'voiceTranscript': voiceTranscript,
        'language': language,
        'latitude': latitude,
        'longitude': longitude,
        'createdAt': createdAt.toIso8601String(),
      };

  factory OfflineMediaItem.fromJson(Map<String, dynamic> json) => OfflineMediaItem(
        caseId: json['caseId'] ?? '',
        voicePath: json['voicePath'],
        photoPath: json['photoPath'],
        videoPath: json['videoPath'],
        voiceTranscript: json['voiceTranscript'],
        language: json['language'] ?? 'en-IN',
        latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
        longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      );
}

class OfflineSyncService {
  static final OfflineSyncService instance = OfflineSyncService._internal();
  OfflineSyncService._internal();

  static const String _queueKey = 'offline_media_queue';
  bool _isSyncing = false;

  bool get isSyncing => _isSyncing;

  Future<SharedPreferences?> _getPrefs() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      return await SharedPreferences.getInstance();
    } catch (e) {
      return null;
    }
  }

  Future<List<OfflineMediaItem>> getPendingQueue() async {
    try {
      final prefs = await _getPrefs();
      if (prefs == null) return [];
      final raw = prefs.getStringList(_queueKey) ?? [];
      return raw.map((item) => OfflineMediaItem.fromJson(jsonDecode(item))).toList();
    } catch (e) {
      debugPrint('[OfflineSyncService] Error reading queue: $e');
      return [];
    }
  }

  Future<void> enqueue(OfflineMediaItem item) async {
    try {
      final prefs = await _getPrefs();
      if (prefs == null) return;
      final queue = await getPendingQueue();
      queue.add(item);
      final raw = queue.map((i) => jsonEncode(i.toJson())).toList();
      await prefs.setStringList(_queueKey, raw);
      debugPrint('[OfflineSyncService] Enqueued offline media item for case ${item.caseId}');
    } catch (e) {
      debugPrint('[OfflineSyncService] Error enqueuing item: $e');
    }
  }

  Future<void> syncPendingQueue(ApiService apiService) async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final queue = await getPendingQueue();
      if (queue.isEmpty) {
        _isSyncing = false;
        return;
      }

      debugPrint('[OfflineSyncService] Starting sync for ${queue.length} pending media items...');
      final remaining = <OfflineMediaItem>[];

      for (final item in queue) {
        final success = await _uploadItem(item, apiService);
        if (!success) {
          remaining.add(item);
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final raw = remaining.map((i) => jsonEncode(i.toJson())).toList();
      await prefs.setStringList(_queueKey, raw);
      debugPrint('[OfflineSyncService] Sync finished. Remaining: ${remaining.length}');
    } catch (e) {
      debugPrint('[OfflineSyncService] Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _uploadItem(OfflineMediaItem item, ApiService apiService) async {
    try {
      final url = Uri.parse('${ApiService.baseUrl}/cases/${item.caseId}/media');
      final request = http.MultipartRequest('POST', url);

      // Add Authorization header if available
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      if (item.voiceTranscript != null && item.voiceTranscript!.isNotEmpty) {
        request.fields['voice_transcript'] = item.voiceTranscript!;
      }
      request.fields['language'] = item.language;

      // Add voice file
      if (item.voicePath != null && item.voicePath!.isNotEmpty) {
        final file = File(item.voicePath!);
        if (await file.exists()) {
          final ext = file.path.endsWith('.wav') ? 'wav' : 'm4a';
          request.files.add(await http.MultipartFile.fromPath(
            'voice_file',
            file.path,
            filename: 'voice_${DateTime.now().millisecondsSinceEpoch}.$ext',
          ));
        }
      }

      // Add photo file
      if (item.photoPath != null && item.photoPath!.isNotEmpty) {
        final file = File(item.photoPath!);
        if (await file.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
            'photo_file',
            file.path,
            filename: 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ));
        }
      }

      // Add video file
      if (item.videoPath != null && item.videoPath!.isNotEmpty) {
        final file = File(item.videoPath!);
        if (await file.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
            'video_file',
            file.path,
            filename: 'video_${DateTime.now().millisecondsSinceEpoch}.mp4',
          ));
        }
      }

      // If no files exist to upload, consider completed
      if (request.files.isEmpty && !request.fields.containsKey('voice_transcript')) {
        return true;
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('[OfflineSyncService] Successfully synced media for case ${item.caseId}');
        return true;
      } else {
        debugPrint('[OfflineSyncService] Failed to sync media for ${item.caseId}: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('[OfflineSyncService] Upload network error for ${item.caseId}: $e');
      return false;
    }
  }
}
