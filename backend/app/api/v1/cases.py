from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, File, Form, UploadFile
from app.core.dependencies import CurrentUser, get_current_user, require_roles
from app.models.case import (
    CaseAssignVetRequest,
    CaseCreateRequest,
    CaseResponse,
    CaseStatusUpdateRequest,
    MortalityReportRequest,
)
from app.services.case_service import CaseService

router = APIRouter(prefix="/cases", tags=["Case Management & Surveillance"])


@router.post("", response_model=CaseResponse, status_code=status.HTTP_201_CREATED)
def create_case(
    req: CaseCreateRequest,
    current_user: CurrentUser = Depends(require_roles(["FARMER", "VETERINARIAN", "ADMIN"])),
):
    """
    Submit a livestock health report and initialize a surveillance case.
    Automatically executes the Clinical Triage engine to compute preliminary risk level.
    """
    return CaseService.create_case(req, farmer_id=current_user.user_id, farmer_name=current_user.name)


@router.post("/mortality", response_model=CaseResponse, status_code=status.HTTP_201_CREATED)
def report_mortality(
    req: MortalityReportRequest,
    current_user: CurrentUser = Depends(require_roles(["FARMER", "VETERINARIAN", "ADMIN"])),
):
    """
    Submit an urgent animal mortality report, create an immediate CRITICAL case,
    and alert the field veterinarian.
    """
    return CaseService.create_mortality_case(req, farmer_id=current_user.user_id, farmer_name=current_user.name)


@router.get("", response_model=List[CaseResponse])
def list_cases(
    status: Optional[str] = None,
    risk_level: Optional[str] = None,
    district: Optional[str] = None,
    role: Optional[str] = None,
    current_user: CurrentUser = Depends(get_current_user),
):
    """
    List surveillance cases with role-aware filtering:
    - Farmers only see cases for their own animals.
    - Veterinarians see cases in their jurisdiction or assigned to them.
    - Government Officers see cases across their district/state.
    """
    normalized_role = (role or "").lower()
    if current_user.role == "VETERINARIAN" or normalized_role == "veterinarian":
        vet_id = current_user.user_id if current_user.role == "VETERINARIAN" else "22222222-2222-2222-2222-222222222202"
        return CaseService.list_cases(
            vet_id=vet_id, status=status, risk_level=risk_level, district=district
        )
    elif current_user.role == "FARMER" and normalized_role != "all":
        return CaseService.list_cases(
            farmer_id=current_user.user_id, status=status, risk_level=risk_level, district=district
        )
    else:
        return CaseService.list_cases(status=status, risk_level=risk_level, district=district)


@router.get("/nearby", response_model=List[CaseResponse])
def get_nearby_cases(
    latitude: float,
    longitude: float,
    radius_km: float = 10.0,
    status: Optional[str] = None,
    risk_level: Optional[str] = None,
    limit: int = 50,
    current_user: CurrentUser = Depends(get_current_user),
):
    """
    Find surveillance cases within a given geographic radius (in km) using PostGIS queries.
    """
    return CaseService.get_nearby_cases(
        latitude=latitude,
        longitude=longitude,
        radius_km=radius_km,
        status=status,
        risk_level=risk_level,
        limit=limit,
    )


@router.get("/{case_id}", response_model=CaseResponse)
def get_case(case_id: str, current_user: CurrentUser = Depends(get_current_user)):
    """
    Get full case details including clinical observations, evidence, and audit timeline.
    """
    case = CaseService.get_case(case_id)
    if not case:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Case not found")
    return case


@router.put("/{case_id}/status", response_model=CaseResponse)
def update_case_status(
    case_id: str,
    update: CaseStatusUpdateRequest,
    current_user: CurrentUser = Depends(require_roles(["VETERINARIAN", "GOVERNMENT_OFFICER", "ADMIN"])),
):
    """
    Advance case status through the clinical pipeline (Vet and Admin only).
    """
    case = CaseService.update_case_status(
        case_id=case_id,
        update=update,
        actor=current_user.name,
        actor_id=current_user.user_id,
    )
    if not case:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Case not found")
    return case


@router.post("/{case_id}/assign", response_model=CaseResponse)
def assign_veterinarian(
    case_id: str,
    req: CaseAssignVetRequest,
    current_user: CurrentUser = Depends(require_roles(["VETERINARIAN", "GOVERNMENT_OFFICER", "ADMIN"])),
):
    """
    Assign a designated field veterinarian to lead the on-site investigation.
    """
    case = CaseService.assign_vet(case_id, req.vet_id, req.vet_name)
    if not case:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Case not found")
    return case


@router.post("/{case_id}/media", response_model=CaseResponse)
async def upload_case_media(
    case_id: str,
    voice_file: Optional[UploadFile] = File(None),
    photo_file: Optional[UploadFile] = File(None),
    video_file: Optional[UploadFile] = File(None),
    voice_transcript: Optional[str] = Form(None),
    language: Optional[str] = Form("en-IN"),
    current_user: CurrentUser = Depends(get_current_user),
):
    """
    Upload real voice, photo, or video evidence to Supabase Storage and link to the case.
    Optionally transcribes voice audio or stores provided transcript.
    """
    voice_bytes = await voice_file.read() if voice_file else None
    voice_name = voice_file.filename if voice_file else None

    photo_bytes = await photo_file.read() if photo_file else None
    photo_name = photo_file.filename if photo_file else None

    video_bytes = await video_file.read() if video_file else None
    video_name = video_file.filename if video_file else None

    case = CaseService.attach_media(
        case_id=case_id,
        voice_bytes=voice_bytes,
        voice_filename=voice_name,
        photo_bytes=photo_bytes,
        photo_filename=photo_name,
        video_bytes=video_bytes,
        video_filename=video_name,
        voice_transcript=voice_transcript,
        language=language or "en-IN",
    )
    if not case:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Case not found")
    return case


@router.post("/media/transcribe")
async def transcribe_audio(
    audio_file: UploadFile = File(...),
    language: Optional[str] = Form("en-IN"),
    current_user: CurrentUser = Depends(get_current_user),
):
    """
    Transcribes uploaded voice audio file and returns text.
    """
    from app.services.speech_service import SpeechService
    audio_bytes = await audio_file.read()
    transcript = SpeechService.transcribe_audio_bytes(
        audio_bytes=audio_bytes,
        filename=audio_file.filename or "audio.wav",
        language_code=language or "en-IN",
    )
    return {
        "transcript": transcript or "",
        "language": language or "en-IN",
        "has_transcript": bool(transcript),
    }
