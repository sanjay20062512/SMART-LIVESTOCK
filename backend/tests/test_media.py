import io
import pytest


def test_upload_case_media_and_linking(client):
    # 1. Login as demo farmer
    login_res = client.post("/api/v1/auth/login", json={"phone_or_id": "9876543210", "password": "farmer123"})
    assert login_res.status_code == 200
    farmer_token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {farmer_token}"}

    # 2. Submit a new case
    case_payload = {
        "animal_tag": "MEDIA-001",
        "species": "Cow",
        "breed": "Gir",
        "symptoms": ["Fever", "Excessive salivation"],
        "duration": "1–2 days",
        "affected_count": "1",
        "village": "Uruli Kanchan",
        "district": "Pune",
    }
    case_res = client.post("/api/v1/cases", json=case_payload, headers=headers)
    assert case_res.status_code == 201
    created_case = case_res.json()
    case_id = created_case["id"]

    # 3. Upload real media files (voice, photo, video) + transcript
    voice_content = b"RIFF....WAVEfmt ....data...."  # mock wav header bytes
    photo_content = b"\xff\xd8\xff\xe0\x00\x10JFIF"  # real JPEG magic bytes
    video_content = b"\x00\x00\x00\x18ftypmp42"      # real MP4 magic bytes

    files = {
        "voice_file": ("test_voice.wav", io.BytesIO(voice_content), "audio/wav"),
        "photo_file": ("test_photo.jpg", io.BytesIO(photo_content), "image/jpeg"),
        "video_file": ("test_video.mp4", io.BytesIO(video_content), "video/mp4"),
    }
    data = {
        "voice_transcript": "Cow has high fever and is not eating feed since yesterday morning.",
        "language": "en-IN",
    }

    media_res = client.post(
        f"/api/v1/cases/{case_id}/media",
        files=files,
        data=data,
        headers=headers,
    )
    assert media_res.status_code == 200
    updated = media_res.json()

    # 4. Verify media linkage and Supabase Storage URLs
    assert updated["has_voice_note"] is True
    assert updated["voice_note_url"] is not None
    assert "livestock-media/voices/" in updated["voice_note_url"]

    assert updated["has_photo"] is True
    assert updated["photo_urls"] is not None
    assert len(updated["photo_urls"]) >= 1
    assert "livestock-media/photos/" in updated["photo_urls"][0]

    assert updated["has_video"] is True
    assert updated["video_url"] is not None
    assert "livestock-media/videos/" in updated["video_url"]

    # 5. Verify voice transcript is linked to description
    assert "Cow has high fever and is not eating feed" in (updated["description"] or "")

    # 6. Verify timeline has recorded the upload and transcription
    timeline_statuses = [t["status"] for t in updated["timeline"]]
    assert "Evidence Media Attached" in timeline_statuses
    assert "Voice Transcribed" in timeline_statuses


def test_transcribe_audio_endpoint(client):
    login_res = client.post("/api/v1/auth/login", json={"phone_or_id": "9876543210", "password": "farmer123"})
    farmer_token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {farmer_token}"}

    files = {
        "audio_file": ("sample.wav", io.BytesIO(b"dummy audio bytes"), "audio/wav")
    }
    res = client.post("/api/v1/cases/media/transcribe", files=files, headers=headers)
    assert res.status_code == 200
    data = res.json()
    assert "transcript" in data
    assert "language" in data
