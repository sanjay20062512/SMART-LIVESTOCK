import io
import os
import tempfile
from typing import Optional


class SpeechService:
    @staticmethod
    def transcribe_audio_bytes(
        audio_bytes: bytes,
        filename: str = "voice.wav",
        language_code: str = "en-IN",
    ) -> Optional[str]:
        """
        Transcribes audio bytes to text using speech_recognition.
        Supports language_code: 'en-IN', 'hi-IN', 'mr-IN'.
        """
        if not audio_bytes or len(audio_bytes) < 100:
            return None

        try:
            import speech_recognition as sr
            r = sr.Recognizer()

            # Write to temp file for recognition
            suffix = os.path.splitext(filename)[1] or ".wav"
            with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
                tmp.write(audio_bytes)
                tmp_path = tmp.name

            try:
                # If wav format, read directly with AudioFile
                with sr.AudioFile(tmp_path) as source:
                    audio_data = r.record(source)
                    text = r.recognize_google(audio_data, language=language_code)
                    return text.strip() if text else None
            except Exception as inner_e:
                print(f"[SpeechService] AudioFile recognition note: {inner_e}")
                return None
            finally:
                if os.path.exists(tmp_path):
                    try:
                        os.remove(tmp_path)
                    except Exception:
                        pass
        except Exception as e:
            print(f"[SpeechService] Transcription error: {e}")
            return None
