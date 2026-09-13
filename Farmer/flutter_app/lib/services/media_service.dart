import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:path_provider/path_provider.dart';

class MediaService {
  static final MediaService instance = MediaService._internal();
  MediaService._internal();

  final ImagePicker _picker = ImagePicker();
  AudioRecorder? _audioRecorder;
  AudioPlayer? _audioPlayer;
  stt.SpeechToText? _speech;

  bool _isSpeechInitialized = false;
  String? _currentRecordingPath;

  AudioRecorder get audioRecorder => _audioRecorder ??= AudioRecorder();
  AudioPlayer get audioPlayer => _audioPlayer ??= AudioPlayer();
  stt.SpeechToText get speech => _speech ??= stt.SpeechToText();

  // ─── Voice Recording ──────────────────────────────────────────────────────────

  Future<bool> hasRecordPermission() async {
    try {
      return await audioRecorder.hasPermission();
    } catch (e) {
      debugPrint('[MediaService] Error checking record permission: $e');
      return true; // proceed to attempt
    }
  }

  Future<String?> startRecording() async {
    try {
      final hasPerm = await hasRecordPermission();
      if (!hasPerm) {
        debugPrint('[MediaService] Microphone permission not granted');
        return null;
      }

      String savePath;
      if (kIsWeb) {
        savePath = 'web_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      } else {
        final tempDir = await getTemporaryDirectory();
        savePath = '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }

      _currentRecordingPath = savePath;
      await audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
        path: savePath,
      );
      debugPrint('[MediaService] Started recording to: $savePath');
      return savePath;
    } catch (e) {
      debugPrint('[MediaService] Failed to start recording: $e');
      return null;
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await audioRecorder.stop();
      _currentRecordingPath = path ?? _currentRecordingPath;
      debugPrint('[MediaService] Stopped recording: $_currentRecordingPath');
      return _currentRecordingPath;
    } catch (e) {
      debugPrint('[MediaService] Failed to stop recording: $e');
      return _currentRecordingPath;
    }
  }

  Future<bool> isRecording() async {
    try {
      return await audioRecorder.isRecording();
    } catch (e) {
      return false;
    }
  }

  // ─── Voice Playback ───────────────────────────────────────────────────────────

  Future<void> playAudio(String path, {VoidCallback? onComplete}) async {
    try {
      await audioPlayer.stop();
      if (onComplete != null) {
        audioPlayer.onPlayerComplete.first.then((_) => onComplete());
      }
      if (kIsWeb) {
        await audioPlayer.play(UrlSource(path));
      } else {
        await audioPlayer.play(DeviceFileSource(path));
      }
    } catch (e) {
      debugPrint('[MediaService] Error playing audio: $e');
      onComplete?.call();
    }
  }

  Future<void> stopAudio() async {
    try {
      await audioPlayer.stop();
    } catch (e) {
      debugPrint('[MediaService] Error stopping audio: $e');
    }
  }

  // ─── Speech To Text (Voice Text) ──────────────────────────────────────────────

  Future<bool> initSpeech() async {
    if (_isSpeechInitialized) return true;
    try {
      _isSpeechInitialized = await speech.initialize(
        onError: (err) => debugPrint('[MediaService] STT error: $err'),
        onStatus: (status) => debugPrint('[MediaService] STT status: $status'),
      );
      return _isSpeechInitialized;
    } catch (e) {
      debugPrint('[MediaService] STT init failed: $e');
      return false;
    }
  }

  Future<void> startListening({
    required String localeId,
    required Function(String recognizedWords) onResult,
  }) async {
    try {
      final ready = await initSpeech();
      if (!ready) {
        debugPrint('[MediaService] Speech recognizer not ready');
        return;
      }
      await speech.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          pauseFor: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      debugPrint('[MediaService] startListening error: $e');
    }
  }

  Future<void> stopListening() async {
    try {
      if (_speech != null && _speech!.isListening) {
        await _speech!.stop();
      }
    } catch (e) {
      debugPrint('[MediaService] stopListening error: $e');
    }
  }

  // ─── Photo Capture ────────────────────────────────────────────────────────────

  Future<XFile?> capturePhoto({ImageSource source = ImageSource.camera}) async {
    try {
      final photo = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return photo;
    } catch (e) {
      debugPrint('[MediaService] Camera capture failed ($e), falling back to gallery...');
      try {
        return await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      } catch (inner) {
        debugPrint('[MediaService] Gallery fallback failed: $inner');
        return null;
      }
    }
  }

  // ─── Video Recording ──────────────────────────────────────────────────────────

  Future<XFile?> recordVideo({ImageSource source = ImageSource.camera}) async {
    try {
      final video = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 2),
      );
      return video;
    } catch (e) {
      debugPrint('[MediaService] Camera video failed ($e), falling back to gallery...');
      try {
        return await _picker.pickVideo(source: ImageSource.gallery);
      } catch (inner) {
        debugPrint('[MediaService] Gallery video fallback failed: $inner');
        return null;
      }
    }
  }

  void dispose() {
    _audioRecorder?.dispose();
    _audioPlayer?.dispose();
    _audioRecorder = null;
    _audioPlayer = null;
  }
}
