from datetime import date, datetime
from typing import Optional
from pydantic import BaseModel


class VaccinationCreateRequest(BaseModel):
    animal_id: str
    animal_tag: str
    vaccine_name: str
    administered_date: date
    next_due_date: Optional[date] = None
    status: Optional[str] = "COMPLETED"
    notes: Optional[str] = None


class VaccinationResponse(BaseModel):
    id: str
    animal_id: str
    animal_tag: str
    vaccine_name: str
    administered_date: date
    next_due_date: Optional[date] = None
    status: str
    veterinarian_name: Optional[str] = None
    notes: Optional[str] = None
    created_at: datetime
