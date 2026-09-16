from typing import List, Optional
from pydantic import BaseModel


class TriageRequest(BaseModel):
    species: Optional[str] = "Cow"
    symptoms: List[str]
    affected_count: Optional[str] = "1"
    not_eating: Optional[bool] = False
    not_drinking: Optional[bool] = False
    is_mortality_related: Optional[bool] = False
    location_id: Optional[str] = None
    language: Optional[str] = "en"


class TriageResponse(BaseModel):
    risk_score: int
    risk_level: str  # LOW, MEDIUM, HIGH, CRITICAL
    title: str
    advice: str
    recommended_action: str
    suspected_conditions: List[str] = []
    requires_vet_review: bool
    requires_lab_test: bool
    explanation: str
