from datetime import datetime
from typing import Optional
from pydantic import BaseModel


class SampleCreateRequest(BaseModel):
    case_id: str
    animal_id: Optional[str] = None
    animal_tag: str
    sample_type: str  # Blood, Faecal, Nasal Swab, Tissue, Milk, Urine, Other
    laboratory: str
    reason: str
    collection_location: Optional[str] = None


class SampleResultUpdateRequest(BaseModel):
    status: str  # RESULT_AVAILABLE, REJECTED, etc.
    result_summary: str
    result_date: Optional[str] = None


class SampleResponse(BaseModel):
    id: str
    sample_code: str
    case_id: str
    animal_id: Optional[str] = None
    animal_tag: str
    sample_type: str
    collection_date: str
    collection_location: Optional[str] = None
    reason: str
    laboratory: str
    status: str
    result_summary: Optional[str] = None
    result_date: Optional[str] = None
    collected_by: str
    created_at: datetime
