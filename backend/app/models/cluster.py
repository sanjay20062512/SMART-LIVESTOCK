from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel


class OutbreakClusterCreate(BaseModel):
    name: str
    location: str
    village: Optional[str] = None
    block: Optional[str] = None
    district: str
    state: str = "Maharashtra"
    risk_level: str = "HIGH"  # LOW, MEDIUM, HIGH
    species: str
    report_count: int = 1
    animal_count: int = 1
    mortality: int = 0
    symptoms: List[str] = []
    suspected_disease: str
    description: Optional[str] = None


class OutbreakClusterResponse(BaseModel):
    id: str
    cluster_code: str
    name: str
    location: str
    village: Optional[str] = None
    block: Optional[str] = None
    district: str
    state: str
    risk_level: str
    species: str
    report_count: int
    animal_count: int
    mortality: int
    symptoms: List[str]
    suspected_disease: str
    description: Optional[str] = None
    status: str
    detected_at: datetime
    created_by: Optional[str] = None
