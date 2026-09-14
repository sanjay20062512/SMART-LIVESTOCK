from fastapi import APIRouter, Depends
from app.core.dependencies import CurrentUser, get_current_user
from app.models.dashboard import FarmerDashboardStats, GovtDashboardStats, VetDashboardStats
from app.services.surveillance_service import SurveillanceService

router = APIRouter(prefix="/dashboard", tags=["Portals & Surveillance Dashboards"])


@router.get("/farmer", response_model=FarmerDashboardStats)
def get_farmer_dashboard(current_user: CurrentUser = Depends(get_current_user)):
    """
    Returns Farmer Home KPIs: total animals, active cases, pending vaccinations, and unread alerts.
    """
    return SurveillanceService.get_farmer_dashboard(farmer_id=current_user.user_id)


@router.get("/vet", response_model=VetDashboardStats)
def get_vet_dashboard(current_user: CurrentUser = Depends(get_current_user)):
    """
    Returns Field Veterinarian KPIs: assigned cases, pending triage reviews, visits, and referrals.
    """
    return SurveillanceService.get_vet_dashboard(vet_id=current_user.user_id)


@router.get("/govt", response_model=GovtDashboardStats)
def get_govt_dashboard(current_user: CurrentUser = Depends(get_current_user)):
    """
    Returns Government Disease Surveillance KPIs:
    Active high-risk alerts, outbreak clusters, total affected livestock, and district breakdown.
    """
    return SurveillanceService.get_govt_dashboard()
