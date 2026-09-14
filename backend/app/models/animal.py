from datetime import datetime
from typing import Optional
from pydantic import BaseModel


class AnimalBase(BaseModel):
    ear_tag: str
    species: str
    breed: Optional[str] = "Standard"
    gender: Optional[str] = "Female"
    age_category: Optional[str] = "2–5 years"
    health_status: Optional[str] = "HEALTHY"
    location: Optional[str] = None


class AnimalCreate(AnimalBase):
    farm_id: Optional[str] = None


class AnimalUpdate(BaseModel):
    ear_tag: Optional[str] = None
    species: Optional[str] = None
    breed: Optional[str] = None
    gender: Optional[str] = None
    age_category: Optional[str] = None
    health_status: Optional[str] = None
    location: Optional[str] = None


class AnimalResponse(AnimalBase):
    id: str
    farm_id: Optional[str] = None
    owner_id: str
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
