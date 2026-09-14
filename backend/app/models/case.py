from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel


class CaseTimelineItem(BaseModel):
    status: str
    description: str
    actor: Optional[str] = None
    timestamp: datetime = datetime.now()


class CaseCreateRequest(BaseModel):
    animal_id: Optional[str] = None
    animal_tag: str
    species: str
    breed: Optional[str] = None
    age: Optional[str] = None
    gender: Optional[str] = None
    symptoms: List[str]
    duration: Optional[str] = "2–3 days"
    eating_status: Optional[str] = "Less than usual"
    drinking_status: Optional[str] = "Yes"
    affected_count: Optional[str] = "1"
    is_pregnant: Optional[bool] = None
    is_lactating: Optional[bool] = None
    description: Optional[str] = None
    has_voice_note: bool = False
    voice_note_url: Optional[str] = None
    has_photo: bool = False
    photo_urls: Optional[List[str]] = None
    has_video: bool = False
    video_url: Optional[str] = None
    voice_transcript: Optional[str] = None
    village: Optional[str] = None
    block: Optional[str] = None
    district: Optional[str] = None
    state: Optional[str] = "Maharashtra"
    latitude: Optional[float] = None
    longitude: Optional[float] = None


class MortalityReportRequest(BaseModel):
    animal_id: Optional[str] = None
    animal_tag: str
    reason: Optional[str] = "Animal mortality reported"
    species: Optional[str] = "Cow"
    number_affected: Optional[int] = 1
    village: Optional[str] = "Uruli Kanchan"
    block: Optional[str] = "Haveli"
    district: Optional[str] = "Pune"
    state: Optional[str] = "Maharashtra"
    latitude: Optional[float] = None
    longitude: Optional[float] = None


class CaseStatusUpdateRequest(BaseModel):
    status: str
    description: Optional[str] = None
    clinical_observation: Optional[str] = None
    treatment_summary: Optional[str] = None
    visit_scheduled_date: Optional[datetime] = None
    assigned_vet_id: Optional[str] = None
    assigned_vet_name: Optional[str] = None


class CaseAssignVetRequest(BaseModel):
    vet_id: str
    vet_name: str


class CaseResponse(BaseModel):
    id: str
    case_code: str
    farmer_id: str
    farmer_name: Optional[str] = "Farmer"
    farm_name: Optional[str] = "Farm"
    animal_id: Optional[str] = None
    animal_tag: str
    species: str
    breed: Optional[str] = None
    age: Optional[str] = None
    gender: Optional[str] = None
    symptoms: List[str]
    duration: Optional[str] = None
    affected_count: Optional[str] = "1"
    risk_score: int
    risk_level: str
    status: str
    description: Optional[str] = None
    village: str
    block: str
    district: str
    state: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    distance_km: Optional[float] = None
    has_voice_note: bool = False
    voice_note_url: Optional[str] = None
    has_photo: bool = False
    photo_urls: Optional[List[str]] = None
    has_video: bool = False
    video_url: Optional[str] = None
    voice_transcript: Optional[str] = None
    assigned_vet_id: Optional[str] = None
    assigned_vet_name: Optional[str] = None
    visit_scheduled_date: Optional[datetime] = None
    clinical_observation: Optional[str] = None
    treatment_summary: Optional[str] = None
    is_escalated_to_govt: bool = False
    timeline: List[CaseTimelineItem] = []
    created_at: datetime
    updated_at: datetime
