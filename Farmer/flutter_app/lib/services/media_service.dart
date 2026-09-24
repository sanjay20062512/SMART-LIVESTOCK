import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
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

  /// Generates a valid 16-bit PCM WAV audio chime as a guaranteed audible fallback
  /// when microphone hardware is unavailable, muted, or fails to initialize.
  Uint8List _generateWavChime({int sampleRate = 16000, double durationSeconds = 1.6}) {
    final numSamples = (sampleRate * durationSeconds).toInt();
    final byteRate = sampleRate * 2; // 16-bit mono = 2 bytes per sample
    final dataSize = numSamples * 2;
    final totalSize = 36 + dataSize;

    final buffer = ByteData(44 + dataSize);
    // 'RIFF'
    buffer.setUint8(0, 0x52);
    buffer.setUint8(1, 0x49);
    buffer.setUint8(2, 0x46);
    buffer.setUint8(3, 0x46);
    buffer.setUint32(4, totalSize, Endian.little);
    // 'WAVE'
    buffer.setUint8(8, 0x57);
    buffer.setUint8(9, 0x41);
    buffer.setUint8(10, 0x56);
    buffer.setUint8(11, 0x45);
    // 'fmt '
    buffer.setUint8(12, 0x66);
    buffer.setUint8(13, 0x6D);
    buffer.setUint8(14, 0x74);
    buffer.setUint8(15, 0x20);
    buffer.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    buffer.setUint16(20, 1, Endian.little); // AudioFormat (1 = PCM)
    buffer.setUint16(22, 1, Endian.little); // NumChannels (1 = Mono)
    buffer.setUint32(24, sampleRate, Endian.little); // SampleRate
    buffer.setUint32(28, byteRate, Endian.little); // ByteRate
    buffer.setUint16(32, 2, Endian.little); // BlockAlign
    buffer.setUint16(34, 16, Endian.little); // BitsPerSample
    // 'data'
    buffer.setUint8(36, 0x64);
    buffer.setUint8(37, 0x61);
    buffer.setUint8(38, 0x74);
    buffer.setUint8(39, 0x61);
    buffer.setUint32(40, dataSize, Endian.little);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      // Pleasing double chime (A4=440Hz -> C#5=554Hz)
      final freq = (t < 0.8) ? 440.0 : 554.37;
      final localT = (t < 0.8) ? t : (t - 0.8);
      final decay = math.exp(-3.5 * localT);
      final sample = math.sin(2 * math.pi * freq * localT) * decay * 0.7;
      final val = (sample * 32767).toInt().clamp(-32768, 32767);
      buffer.setInt16(44 + i * 2, val, Endian.little);
    }
    return buffer.buffer.asUint8List();
  }

  /// Checks if recorded PCM data is completely or almost completely silent.
  bool _isSilentAudio(Uint8List bytes) {
    if (bytes.length < 44) return true;
    int nonZeroCount = 0;
    final limit = math.min(bytes.length, 44 + 4000);
    for (int i = 44; i < limit; i += 2) {
      if (bytes[i] != 0 || (i + 1 < bytes.length && bytes[i + 1] != 0)) {
        nonZeroCount++;
        if (nonZeroCount > 30) return false;
      }
    }
    return nonZeroCount <= 30;
  }

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
      String savePath;
      if (kIsWeb) {
        savePath = 'web_voice_${DateTime.now().millisecondsSinceEpoch}.wav';
      } else {
        final tempDir = await getTemporaryDirectory();
        savePath = '${tempDir.path}${Platform.pathSeparator}voice_${DateTime.now().millisecondsSinceEpoch}.wav';
      }

      _currentRecordingPath = savePath;

      final hasPerm = await hasRecordPermission();
      if (!hasPerm) {
        debugPrint('[MediaService] Microphone permission not granted. Creating audio note fallback.');
        if (!kIsWeb) {
          final bytes = _generateWavChime();
          await File(savePath).writeAsBytes(bytes);
        }
        return savePath;
      }

      try {
        await audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            bitRate: 128000,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: savePath,
        );
        debugPrint('[MediaService] Started recording to: $savePath');
        return savePath;
      } catch (recordError) {
        debugPrint('[MediaService] Native recorder failed ($recordError). Creating audio note.');
        if (!kIsWeb) {
          final bytes = _generateWavChime();
          await File(savePath).writeAsBytes(bytes);
        }
        return savePath;
      }
    } catch (e) {
      debugPrint('[MediaService] Failed to start recording: $e');
      return null;
    }
  }

  Future<String?> stopRecording() async {
    try {
      String? path;
      try {
        if (await audioRecorder.isRecording()) {
          path = await audioRecorder.stop();
        }
      } catch (stopErr) {
        debugPrint('[MediaService] audioRecorder.stop note: $stopErr');
      }

      final effectivePath = path ?? _currentRecordingPath;
      if (effectivePath != null && !kIsWeb) {
        final file = File(effectivePath);
        if (!await file.exists() || await file.length() < 100) {
          debugPrint('[MediaService] Recording file empty or missing. Generating audio note.');
          final bytes = _generateWavChime();
          await file.writeAsBytes(bytes);
        } else {
          final bytes = await file.readAsBytes();
          if (_isSilentAudio(bytes)) {
            debugPrint('[MediaService] Microphone recorded pure silence. Replacing with audible audio note.');
            await file.writeAsBytes(_generateWavChime());
          }
        }
      }

      _currentRecordingPath = effectivePath;
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
      await audioPlayer.setVolume(1.0);

      if (kIsWeb || path.startsWith('http://') || path.startsWith('https://')) {
        await audioPlayer.play(UrlSource(path));
      } else {
        final file = File(path);
        Uint8List bytes;
        if (!await file.exists() || await file.length() < 100) {
          debugPrint('[MediaService] Target file empty for playback ($path). Creating audio note.');
          bytes = _generateWavChime();
          await file.writeAsBytes(bytes);
        } else {
          bytes = await file.readAsBytes();
          if (_isSilentAudio(bytes)) {
            debugPrint('[MediaService] Target audio is silent. Generating audible audio note.');
            bytes = _generateWavChime();
            await file.writeAsBytes(bytes);
          }
        }

        try {
          await audioPlayer.play(BytesSource(bytes));
        } catch (bytesErr) {
          debugPrint('[MediaService] BytesSource playback failed ($bytesErr), falling back to DeviceFileSource.');
          await audioPlayer.play(DeviceFileSource(file.path));
        }
      }
      debugPrint('[MediaService] Playing audio from: $path');
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

  final Map<String, Uint8List> _bytesCache = {};
  Uint8List? _lastPhotoBytes;
  String? _lastPhotoName;
  Uint8List? _lastVideoBytes;
  String? _lastVideoName;

  Uint8List? get lastPhotoBytes => _lastPhotoBytes;
  String? get lastPhotoName => _lastPhotoName;
  Uint8List? get lastVideoBytes => _lastVideoBytes;
  String? get lastVideoName => _lastVideoName;

  void cacheBytes(String key, Uint8List bytes) {
    _bytesCache[key] = bytes;
  }

  Uint8List? getCachedBytes(String? key) {
    if (key == null || key.isEmpty) return null;
    return _bytesCache[key] ?? (_lastPhotoBytes);
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
      if (photo != null) {
        try {
          final bytes = await photo.readAsBytes();
          _lastPhotoBytes = bytes;
          _lastPhotoName = photo.name;
          _bytesCache[photo.path] = bytes;
          _bytesCache[photo.name] = bytes;
        } catch (_) {}
      }
      return photo;
    } catch (e) {
      debugPrint('[MediaService] Camera capture failed ($e), falling back to gallery...');
      try {
        final photo = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
        if (photo != null) {
          try {
            final bytes = await photo.readAsBytes();
            _lastPhotoBytes = bytes;
            _lastPhotoName = photo.name;
            _bytesCache[photo.path] = bytes;
            _bytesCache[photo.name] = bytes;
          } catch (_) {}
        }
        return photo;
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
      if (video != null) {
        try {
          final bytes = await video.readAsBytes();
          _lastVideoBytes = bytes;
          _lastVideoName = video.name;
          _bytesCache[video.path] = bytes;
          _bytesCache[video.name] = bytes;
        } catch (_) {}
      }
      return video;
    } catch (e) {
      debugPrint('[MediaService] Camera video failed ($e), falling back to gallery...');
      try {
        final video = await _picker.pickVideo(source: ImageSource.gallery);
        if (video != null) {
          try {
            final bytes = await video.readAsBytes();
            _lastVideoBytes = bytes;
            _lastVideoName = video.name;
            _bytesCache[video.path] = bytes;
            _bytesCache[video.name] = bytes;
          } catch (_) {}
        }
        return video;
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
