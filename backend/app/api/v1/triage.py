from fastapi import APIRouter
from app.models.triage import TriageRequest, TriageResponse
from app.services.triage_service import TriageService

router = APIRouter(prefix="/triage", tags=["Clinical Triage Engine"])


@router.post("", response_model=TriageResponse)
def assess_symptoms(req: TriageRequest):
    """
    Automated Rule-Based Clinical Triage Engine.
    Evaluates reported symptoms, species, and affected counts to assign
    a preliminary risk score (0-100), risk tier (LOW/MEDIUM/HIGH/CRITICAL),
    and differential suspected disease conditions.

    NOTE: AI/Rule outputs provide decision support only. Final diagnosis
    remains with the licensed veterinarian.
    """
    return TriageService.assess(req)
