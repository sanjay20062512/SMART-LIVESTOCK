import math
import uuid
from datetime import datetime
from typing import List, Optional
from app.db.supabase import get_supabase_client
from app.models.case import CaseCreateRequest, CaseResponse, CaseStatusUpdateRequest, CaseTimelineItem, MortalityReportRequest
from app.models.triage import TriageRequest
from app.services.triage_service import TriageService
from app.services.storage_service import StorageService
from app.services.speech_service import SpeechService
from fastapi import HTTPException


def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate great-circle distance between two points in km using Haversine formula."""
    r = 6371.0  # Earth's radius in kilometers
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2.0) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2.0) ** 2
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    return round(r * c, 2)


def resolve_animal_uuid(supabase, animal_id: Optional[str], animal_tag: Optional[str]) -> Optional[str]:
    """
    Ensure animal_id is a valid UUID before inserting into PostgreSQL.
    If animal_id is a human-friendly string (e.g. 'ANM001' or 'ANM101'),
    attempt to look up the animal in the animals table by ear_tag.
    If not found, returns None so foreign key constraint is satisfied.
    """
    if animal_id:
        try:
            uuid.UUID(str(animal_id))
            return str(animal_id)
        except (ValueError, TypeError):
            pass

    if animal_tag and supabase:
        try:
            match = supabase.table("animals").select("id").eq("ear_tag", animal_tag).execute()
            if match.data and len(match.data) > 0:
                return str(match.data[0]["id"])
        except Exception:
            pass

    return None


class CaseService:
    @staticmethod
    def create_case(req: CaseCreateRequest, farmer_id: str, farmer_name: str) -> CaseResponse:
        supabase = get_supabase_client()
        if not supabase:
            raise HTTPException(status_code=500, detail="Database connection not configured")

        # 1. Run Automated Triage
        triage_res = TriageService.assess(
            TriageRequest(
                species=req.species,
                symptoms=req.symptoms,
                affected_count=req.affected_count,
                not_eating=(req.eating_status == "No"),
                not_drinking=(req.drinking_status == "No"),
            )
        )

        case_id = str(uuid.uuid4())
        
        # Get count for short ID
        count_res = supabase.table("cases").select("id", count="exact").execute()
        count = count_res.count or 0
        short_id = f"CASE-{datetime.now().strftime('%m%d')}-{count + 1:03d}"
        now = datetime.now().isoformat()

        # Build description with transcript if available
        desc = req.description
        if req.voice_transcript:
            if desc and "[Voice Transcript]:" not in desc:
                desc = f"[Voice Transcript]: {req.voice_transcript}\nNotes: {desc}"
            else:
                desc = f"[Voice Transcript]: {req.voice_transcript}"

        # Resolve animal_id to a valid UUID or lookup by ear_tag
        animal_uuid = resolve_animal_uuid(supabase, req.animal_id, req.animal_tag)

        case_data = {
            "id": case_id,
            "case_code": short_id,
            "reporter_id": farmer_id,
            "farmer_id": farmer_id,
            "animal_id": animal_uuid,
            "animal_tag": req.animal_tag,
            "species": req.species,
            "breed": req.breed,
            "age": req.age,
            "gender": req.gender,
            "symptoms": req.symptoms,
            "duration": req.duration,
            "affected_count": str(req.affected_count or "1"),
            "risk_score": triage_res.risk_score,
            "risk_level": triage_res.risk_level,
            "status": "SUBMITTED",
            "description": desc,
            "village": req.village or "Uruli Kanchan",
            "block": req.block or "Haveli",
            "district": req.district or "Pune",
            "state": req.state or "Maharashtra",
            "latitude": req.latitude,
            "longitude": req.longitude,
            "has_voice_note": req.has_voice_note or bool(req.voice_note_url),
            "voice_note_url": req.voice_note_url,
            "has_photo": req.has_photo or bool(req.photo_urls),
            "photo_urls": req.photo_urls,
            "has_video": req.has_video or bool(req.video_url),
            "video_url": req.video_url,
            "created_at": now,
            "updated_at": now,
        }

        # Insert Case
        res = supabase.table("cases").insert(case_data).execute()
        if not res.data:
            raise HTTPException(status_code=500, detail="Failed to create case")

        # Insert Timeline
        timeline_data = [
            {
                "case_id": case_id,
                "status": "Report Submitted",
                "description": f"Farmer submitted health report for {req.species} ({req.animal_tag}).",
                "actor": "Farmer",
                "created_at": now,
            },
            {
                "case_id": case_id,
                "status": "Risk Assessed",
                "description": f"Automated Triage: {triage_res.risk_level} Risk (Score {triage_res.risk_score}). {triage_res.advice}",
                "actor": "System",
                "created_at": now,
            }
        ]
        supabase.table("case_timeline_events").insert(timeline_data).execute()

        # Update animal health status
        if animal_uuid:
            new_status = "ACTIVE_CASE" if triage_res.risk_level in ["HIGH", "CRITICAL"] else "UNDER_MONITORING"
            supabase.table("animals").update({"health_status": new_status}).eq("id", animal_uuid).execute()

        # Generate alert if High or Critical for both Farmer and Veterinarian
        if triage_res.risk_level in ["HIGH", "CRITICAL"]:
            alerts_to_insert = [
                {
                    "id": str(uuid.uuid4()),
                    "category": "HIGH_RISK_HEALTH_ALERT",
                    "title": f"{triage_res.risk_level} Risk: {req.animal_tag}",
                    "message": triage_res.advice,
                    "severity": triage_res.risk_level,
                    "target_role": "FARMER",
                    "related_id": case_id,
                    "created_at": now,
                },
                {
                    "id": str(uuid.uuid4()),
                    "category": "HIGH_RISK_HEALTH_ALERT",
                    "title": f"New {triage_res.risk_level} Case: {req.species} ({req.animal_tag}) in {req.village or 'District'}",
                    "message": f"Reported by {farmer_name}. Symptoms: {', '.join(req.symptoms)}. Action required.",
                    "severity": triage_res.risk_level,
                    "target_role": "VETERINARIAN",
                    "related_id": case_id,
                    "created_at": now,
                },
            ]
            supabase.table("alerts").insert(alerts_to_insert).execute()

        # Get the full inserted case and its timeline to return
        return CaseService.get_case(case_id)

    @staticmethod
    def create_mortality_case(req: MortalityReportRequest, farmer_id: str, farmer_name: str) -> CaseResponse:
        supabase = get_supabase_client()
        if not supabase:
            raise HTTPException(status_code=500, detail="Database connection not configured")

        case_id = str(uuid.uuid4())
        case_code = f"CAS-MOR-{uuid.uuid4().hex[:6].upper()}"
        now = datetime.now().isoformat()

        # Resolve animal_id to a valid UUID or lookup by ear_tag
        animal_uuid = resolve_animal_uuid(supabase, req.animal_id, req.animal_tag)

        case_data = {
            "id": case_id,
            "case_code": case_code,
            "reporter_id": farmer_id,
            "farmer_id": farmer_id,
            "animal_id": animal_uuid,
            "animal_tag": req.animal_tag,
            "species": req.species or "Cow",
            "symptoms": [f"Mortality: {req.reason}"],
            "duration": "Immediate",
            "eating_status": "No",
            "drinking_status": "No",
            "affected_count": str(req.number_affected or 1),
            "risk_level": "CRITICAL",
            "status": "SUBMITTED",
            "village": req.village or "Uruli Kanchan",
            "block": req.block or "Haveli",
            "district": req.district or "Pune",
            "state": req.state or "Maharashtra",
            "latitude": req.latitude,
            "longitude": req.longitude,
            "has_voice_note": False,
            "has_photo": False,
            "has_video": False,
            "created_at": now,
            "updated_at": now,
        }

        # Insert Case
        res = supabase.table("cases").insert(case_data).execute()
        if not res.data:
            raise HTTPException(status_code=500, detail="Failed to create mortality case")

        # Insert Timeline
        timeline_data = [
            {
                "case_id": case_id,
                "status": "Report Submitted",
                "description": f"Mortality reported for {req.species or 'Livestock'} ({req.animal_tag}). Reason: {req.reason}",
                "actor": "Farmer",
                "created_at": now,
            },
            {
                "case_id": case_id,
                "status": "Emergency Alert",
                "description": "Critical triage: Livestock mortality reported. Immediate veterinary investigation recommended.",
                "actor": "System",
                "created_at": now,
            }
        ]
        supabase.table("case_timeline_events").insert(timeline_data).execute()

        # Update animal health status if animal_id resolved
        if animal_uuid:
            supabase.table("animals").update({"health_status": "DECEASED"}).eq("id", animal_uuid).execute()

        # Insert emergency alerts for both Vet and Farmer
        emergency_alerts = [
            {
                "id": str(uuid.uuid4()),
                "category": "MORTALITY_ALERT",
                "title": f"🚨 CRITICAL: Animal Mortality Reported in {req.village or 'District'}",
                "message": f"Farmer {farmer_name} reported death of {req.species or 'Livestock'} ({req.animal_tag}). Suspected cause: {req.reason}. Immediate visit required.",
                "severity": "CRITICAL",
                "target_role": "VETERINARIAN",
                "related_id": case_id,
                "created_at": now,
            },
            {
                "id": str(uuid.uuid4()),
                "category": "MORTALITY_ALERT",
                "title": f"Critical Mortality Report Registered: {req.animal_tag}",
                "message": "Veterinary officer has been notified. Keep carcass isolated from healthy herd.",
                "severity": "CRITICAL",
                "target_role": "FARMER",
                "related_id": case_id,
                "created_at": now,
            },
        ]
        supabase.table("alerts").insert(emergency_alerts).execute()

        return CaseService.get_case(case_id)

    @staticmethod
    def attach_media(
        case_id: str,
        voice_bytes: Optional[bytes] = None,
        voice_filename: Optional[str] = None,
        photo_bytes: Optional[bytes] = None,
        photo_filename: Optional[str] = None,
        video_bytes: Optional[bytes] = None,
        video_filename: Optional[str] = None,
        voice_transcript: Optional[str] = None,
        language: str = "en-IN",
    ) -> Optional[CaseResponse]:
        """
        Uploads provided media files (voice, photo, video) to Supabase Storage,
        transcribes voice audio if needed, updates the PostgreSQL case, and logs timeline events.
        """
        supabase = get_supabase_client()
        if not supabase:
            raise HTTPException(status_code=500, detail="Database connection not configured")

        case_res = supabase.table("cases").select("*").eq("id", case_id).execute()
        if not case_res.data:
            raise HTTPException(status_code=404, detail="Case not found")

        current_case = case_res.data[0]
        updates = {"updated_at": datetime.now().isoformat()}
        timeline_items = []

        # 1. Voice Note
        if voice_bytes and voice_filename:
            voice_url = StorageService.upload_file(
                file_bytes=voice_bytes,
                file_name=voice_filename,
                folder="voices",
            )
            if voice_url:
                updates["voice_note_url"] = voice_url
                updates["has_voice_note"] = True

                # If no transcript supplied, attempt server-side speech recognition
                if not voice_transcript:
                    transcribed = SpeechService.transcribe_audio_bytes(
                        voice_bytes, filename=voice_filename, language_code=language
                    )
                    if transcribed:
                        voice_transcript = transcribed

        # 2. Photos
        if photo_bytes and photo_filename:
            photo_url = StorageService.upload_file(
                file_bytes=photo_bytes,
                file_name=photo_filename,
                folder="photos",
            )
            if photo_url:
                existing_photos = current_case.get("photo_urls") or []
                if not isinstance(existing_photos, list):
                    existing_photos = [str(existing_photos)]
                existing_photos = list(existing_photos)
                if photo_url not in existing_photos:
                    existing_photos.append(photo_url)
                updates["photo_urls"] = existing_photos
                updates["has_photo"] = True

        # 3. Video
        if video_bytes and video_filename:
            video_url = StorageService.upload_file(
                file_bytes=video_bytes,
                file_name=video_filename,
                folder="videos",
            )
            if video_url:
                updates["video_url"] = video_url
                updates["has_video"] = True

        # 4. Transcript & Description
        if voice_transcript:
            current_desc = current_case.get("description") or ""
            if current_desc and "[Voice Transcript]:" not in current_desc:
                updates["description"] = f"[Voice Transcript]: {voice_transcript}\nNotes: {current_desc}"
            else:
                updates["description"] = f"[Voice Transcript]: {voice_transcript}"

            timeline_items.append({
                "case_id": case_id,
                "status": "Voice Transcribed",
                "description": f'Voice Transcript: "{voice_transcript}"',
                "actor": "System",
                "created_at": datetime.now().isoformat(),
            })

        if updates.get("voice_note_url") or updates.get("photo_urls") or updates.get("video_url"):
            media_types = []
            if updates.get("voice_note_url"):
                media_types.append("Voice Note")
            if updates.get("photo_urls"):
                media_types.append("Photo")
            if updates.get("video_url"):
                media_types.append("Video")

            timeline_items.append({
                "case_id": case_id,
                "status": "Evidence Media Attached",
                "description": f"Uploaded {', '.join(media_types)} to Supabase Storage.",
                "actor": "Farmer",
                "created_at": datetime.now().isoformat(),
            })

        # Persist to PostgreSQL
        supabase.table("cases").update(updates).eq("id", case_id).execute()
        if timeline_items:
            supabase.table("case_timeline_events").insert(timeline_items).execute()

        return CaseService.get_case(case_id)

    @staticmethod
    def get_case(case_id: str) -> Optional[CaseResponse]:
        supabase = get_supabase_client()
        res = supabase.table("cases").select("*").eq("id", case_id).execute()
        if not res.data:
            return None
            
        case_dict = res.data[0]
        
        # Fetch timeline
        timeline_res = supabase.table("case_timeline_events").select("*").eq("case_id", case_id).order("created_at").execute()
        
        # Transform timeline items
        timeline = []
        for t in timeline_res.data:
            timeline.append({
                "status": t["status"],
                "description": t["description"],
                "actor": t["actor"],
                "timestamp": t["created_at"],
            })
            
        if not case_dict.get("farmer_name"):
            case_dict["farmer_name"] = "Farmer"
        case_dict["timeline"] = timeline

        # If any associated diagnostic sample has RESULT_AVAILABLE, reflect it in status
        sample_res = supabase.table("samples").select("status").eq("case_id", case_id).execute()
        if sample_res.data and any(s.get("status") == "RESULT_AVAILABLE" for s in sample_res.data):
            case_dict["status"] = "RESULT_AVAILABLE"

        return CaseResponse(**case_dict)

    @staticmethod
    def list_cases(
        farmer_id: Optional[str] = None,
        vet_id: Optional[str] = None,
        status: Optional[str] = None,
        risk_level: Optional[str] = None,
        district: Optional[str] = None,
    ) -> List[CaseResponse]:
        supabase = get_supabase_client()
        
        query = supabase.table("cases").select("*")
        
        if farmer_id:
            query = query.eq("farmer_id", farmer_id)
        # For vet role: return ALL cases (assigned to them OR unassigned/submitted)
        # Filtering is done after fetch so vets see new submissions immediately
        if status:
            query = query.ilike("status", status)
        if risk_level:
            query = query.ilike("risk_level", risk_level)
        if district:
            query = query.ilike("district", district)
            
        query = query.order("created_at", desc=True)
        res = query.execute()
        
        cases = res.data or []
        
        # For vet view: show cases assigned to this vet OR any unassigned/submitted case
        if vet_id:
            cases = [
                c for c in cases
                if c.get("assigned_vet_id") == vet_id
                or c.get("assigned_vet_id") is None
                or c.get("status", "").upper() == "SUBMITTED"
            ]
        
        # Fetch and attach timeline events
        case_ids = [c["id"] for c in cases]
        timeline_map: dict = {}
        if case_ids:
            tl_res = supabase.table("case_timeline_events").select("*").in_("case_id", case_ids).execute()
            for t in (tl_res.data or []):
                timeline_map.setdefault(t["case_id"], []).append({
                    "status": t["status"],
                    "description": t["description"],
                    "actor": t.get("actor"),
                    "timestamp": t["created_at"],
                })
        
        results = []
        for c in cases:
            c.setdefault("farmer_name", "Farmer")
            c.setdefault("farm_name", "Farm")
            c["timeline"] = timeline_map.get(c["id"], [])
            # Ensure affected_count is a string (model expects Optional[str])
            if c.get("affected_count") is not None:
                c["affected_count"] = str(c["affected_count"])
            try:
                results.append(CaseResponse(**c))
            except Exception as e:
                import logging
                logging.warning(f"Skipping case {c.get('id')} due to parse error: {e}")
        
        return results

    @staticmethod
    def update_case_status(
        case_id: str, update: CaseStatusUpdateRequest, actor: str, actor_id: Optional[str] = None
    ) -> Optional[CaseResponse]:
        supabase = get_supabase_client()
        
        update_data = {
            "status": update.status.upper(),
            "updated_at": datetime.now().isoformat()
        }
        
        if update.clinical_observation:
            update_data["clinical_observation"] = update.clinical_observation
        if update.treatment_summary:
            update_data["treatment_summary"] = update.treatment_summary
        if update.visit_scheduled_date:
            update_data["visit_scheduled_date"] = update.visit_scheduled_date.isoformat()
        if update.assigned_vet_id:
            update_data["assigned_vet_id"] = update.assigned_vet_id
        if update.assigned_vet_name:
            update_data["assigned_vet_name"] = update.assigned_vet_name
            
        res = supabase.table("cases").update(update_data).eq("id", case_id).execute()
        if not res.data:
            return None
            
        desc = update.description or f"Status transitioned to {update.status.upper()}"
        
        supabase.table("case_timeline_events").insert({
            "case_id": case_id,
            "status": update.status.upper(),
            "description": desc,
            "actor_id": actor_id,
            "actor": actor,
            "created_at": datetime.now().isoformat()
        }).execute()

        # If a visit is scheduled, record in vet_visits and notify the farmer
        if update.visit_scheduled_date:
            vet_id = update.assigned_vet_id or actor_id or "22222222-2222-2222-2222-222222222202"
            vet_name = update.assigned_vet_name or actor or "Dr. Rajesh Kumar"
            try:
                import uuid
                visit_id = str(uuid.uuid4())
                supabase.table("vet_visits").insert({
                    "id": visit_id,
                    "case_id": case_id,
                    "vet_id": vet_id,
                    "vet_name": vet_name,
                    "scheduled_date": update.visit_scheduled_date.isoformat(),
                    "findings": update.clinical_observation or update.description,
                    "is_completed": update.status.upper() in ["TREATMENT_STARTED", "CASE_CLOSED", "CONTAINED"],
                    "created_at": datetime.now().isoformat()
                }).execute()
            except Exception as e:
                import logging
                logging.warning(f"Could not record vet_visit: {e}")

            case_row = res.data[0] if res.data else {}
            farmer_id = case_row.get("farmer_id")
            animal_tag = case_row.get("animal_tag", "animal")
            if farmer_id:
                try:
                    formatted_date = update.visit_scheduled_date.strftime("%d %b %Y, %I:%M %p")
                    supabase.table("alerts").insert({
                        "category": "VETERINARIAN_MESSAGE",
                        "title": f"Visit Scheduled: {vet_name}",
                        "message": f"{vet_name} has scheduled a field visit for {animal_tag} on {formatted_date}.",
                        "severity": "INFO",
                        "recipient_id": farmer_id,
                        "target_role": "FARMER",
                        "related_id": case_id,
                        "is_read": False,
                        "created_at": datetime.now().isoformat()
                    }).execute()
                except Exception as e:
                    import logging
                    logging.warning(f"Could not send alert for scheduled visit: {e}")
        
        return CaseService.get_case(case_id)

    @staticmethod
    def assign_vet(case_id: str, vet_id: str, vet_name: str) -> Optional[CaseResponse]:
        supabase = get_supabase_client()
        
        update_data = {
            "assigned_vet_id": vet_id,
            "assigned_vet_name": vet_name,
            "status": "VET_ASSIGNED",
            "updated_at": datetime.now().isoformat()
        }
        
        res = supabase.table("cases").update(update_data).eq("id", case_id).execute()
        if not res.data:
            return None
            
        supabase.table("case_timeline_events").insert({
            "case_id": case_id,
            "status": "Vet Assigned",
            "description": f"{vet_name} assigned to manage this case.",
            "actor": "Veterinarian",
            "created_at": datetime.now().isoformat()
        }).execute()
        
        return CaseService.get_case(case_id)

    @staticmethod
    def get_nearby_cases(
        latitude: float,
        longitude: float,
        radius_km: float = 10.0,
        status: Optional[str] = None,
        risk_level: Optional[str] = None,
        limit: int = 50,
    ) -> List[CaseResponse]:
        """
        Find cases within radius_km of (latitude, longitude) using PostGIS RPC with Haversine fallback.
        """
        supabase = get_supabase_client()
        if not supabase:
            raise HTTPException(status_code=500, detail="Database connection not configured")

        # 1. Attempt PostGIS stored procedure RPC
        try:
            rpc_res = supabase.rpc(
                "get_nearby_cases",
                {
                    "lat": float(latitude),
                    "lon": float(longitude),
                    "radius_km": float(radius_km),
                    "limit_count": limit,
                },
            ).execute()
            if rpc_res.data and isinstance(rpc_res.data, list):
                results = []
                for item in rpc_res.data:
                    if status and str(item.get("status", "")).upper() != status.upper():
                        continue
                    if risk_level and str(item.get("risk_level", "")).upper() != risk_level.upper():
                        continue
                    item.setdefault("farmer_name", "Farmer")
                    item.setdefault("farm_name", "Farm")
                    item.setdefault("timeline", [])
                    if item.get("affected_count") is not None:
                        item["affected_count"] = str(item["affected_count"])
                    try:
                        results.append(CaseResponse(**item))
                    except Exception:
                        pass
                if results:
                    return results
        except Exception:
            # Fall back to Haversine calculation if PostGIS RPC is not deployed
            pass

        # 2. Python Haversine fallback over all cases
        all_cases = CaseService.list_cases(status=status, risk_level=risk_level)
        nearby: List[CaseResponse] = []
        for c in all_cases:
            c_lat = float(c.latitude) if c.latitude is not None else None
            c_lon = float(c.longitude) if c.longitude is not None else None
            
            # If coordinates not stored directly, use known village defaults
            if c_lat is None or c_lon is None:
                if c.village and c.village.strip().lower() == "uruli kanchan":
                    c_lat, c_lon = 18.4870, 74.1330
                elif c.village and c.village.strip().lower() == "loni kalbhor":
                    c_lat, c_lon = 18.4900, 74.0200
                elif c.village and c.village.strip().lower() == "wagholi":
                    c_lat, c_lon = 18.5800, 73.9800

            if c_lat is not None and c_lon is not None:
                dist = haversine_distance(latitude, longitude, c_lat, c_lon)
                if dist <= radius_km:
                    c.distance_km = dist
                    nearby.append(c)

        nearby.sort(key=lambda x: (x.distance_km if x.distance_km is not None else 999999.0))
        return nearby[:limit]
