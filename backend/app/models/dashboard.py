from typing import Dict, List, Optional
from pydantic import BaseModel
from app.models.case import CaseResponse
from app.models.cluster import OutbreakClusterResponse


class FarmerDashboardStats(BaseModel):
    total_animals: int
    healthy_animals: int
    active_cases: int
    due_vaccinations: int
    unread_alerts: int
    recent_cases: List[CaseResponse] = []


class VetDashboardStats(BaseModel):
    total_assigned_cases: int
    pending_review: int
    scheduled_visits: int
    lab_referrals_pending: int
    active_outbreak_clusters: int
    recent_cases: List[CaseResponse] = []


class GovtDashboardStats(BaseModel):
    active_high_risk_alerts: int
    high_risk_clusters_count: int
    total_affected_animals: int
    affected_districts_count: int
    critical_cases_count: int
    districts_breakdown: Dict[str, int] = {}
    high_risk_clusters: List[OutbreakClusterResponse] = []
