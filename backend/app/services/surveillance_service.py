from typing import Dict, List, Optional
from app.models.dashboard import FarmerDashboardStats, GovtDashboardStats, VetDashboardStats
from app.models.cluster import OutbreakClusterResponse
from app.services.case_service import CaseService
from app.db.supabase import get_supabase_client

class SurveillanceService:
    @staticmethod
    def get_farmer_dashboard(farmer_id: str) -> FarmerDashboardStats:
        supabase = get_supabase_client()
        animals_res = supabase.table("animals").select("*").eq("owner_id", farmer_id).execute()
        animals = animals_res.data
        
        cases = CaseService.list_cases(farmer_id=farmer_id)
        active_cases = [c for c in cases if c.status not in ["CASE_CLOSED", "CONTAINED"]]
        healthy_count = sum(1 for a in animals if a.get("health_status") == "HEALTHY")
        
        alerts_res = supabase.table("alerts").select("*").eq("recipient_id", farmer_id).eq("is_read", False).execute()
        
        return FarmerDashboardStats(
            total_animals=len(animals),
            healthy_animals=healthy_count,
            active_cases=len(active_cases),
            due_vaccinations=1,
            unread_alerts=len(alerts_res.data),
            recent_cases=cases[:5],
        )

    @staticmethod
    def get_vet_dashboard(vet_id: str) -> VetDashboardStats:
        cases = CaseService.list_cases()
        assigned = [c for c in cases if c.assigned_vet_id == vet_id or c.assigned_vet_id is None]
        pending = [c for c in assigned if c.status in ["SUBMITTED", "UNDER_REVIEW", "VET_ASSIGNED"]]
        visits = [c for c in assigned if c.status == "VISIT_SCHEDULED"]
        lab_ref = [c for c in assigned if c.status in ["SAMPLE_COLLECTED", "LAB_REFERRED"]]
        
        supabase = get_supabase_client()
        clusters_res = supabase.table("outbreak_clusters").select("*").execute()
        
        return VetDashboardStats(
            total_assigned_cases=len(assigned),
            pending_review=len(pending),
            scheduled_visits=len(visits),
            lab_referrals_pending=len(lab_ref),
            active_outbreak_clusters=len(clusters_res.data),
            recent_cases=assigned[:5],
        )

    @staticmethod
    def get_govt_dashboard() -> GovtDashboardStats:
        supabase = get_supabase_client()
        clusters_res = supabase.table("outbreak_clusters").select("*").execute()
        clusters = [OutbreakClusterResponse(**c) for c in clusters_res.data]
        
        high_risk_clusters = [c for c in clusters if c.risk_level == "HIGH" or c.status == "ESCALATED"]
        total_affected = sum(c.animal_count for c in high_risk_clusters)
        districts = set(c.district for c in high_risk_clusters)

        cases_res = supabase.table("cases").select("*").in_("risk_level", ["HIGH", "CRITICAL"]).execute()
        critical_cases = cases_res.data

        all_cases = supabase.table("cases").select("district").execute()
        districts_breakdown: Dict[str, int] = {}
        for c in all_cases.data:
            d = c.get("district", "Unknown")
            districts_breakdown[d] = districts_breakdown.get(d, 0) + 1

        return GovtDashboardStats(
            active_high_risk_alerts=len(high_risk_clusters),
            high_risk_clusters_count=len(high_risk_clusters),
            total_affected_animals=total_affected,
            affected_districts_count=len(districts) if districts else 1,
            critical_cases_count=len(critical_cases),
            districts_breakdown=districts_breakdown,
            high_risk_clusters=high_risk_clusters,
        )

    @staticmethod
    def list_clusters(risk_level: Optional[str] = None, district: Optional[str] = None) -> List[OutbreakClusterResponse]:
        supabase = get_supabase_client()
        query = supabase.table("outbreak_clusters").select("*")
        if risk_level:
            query = query.ilike("risk_level", risk_level)
        if district:
            query = query.ilike("district", district)
            
        res = query.execute()
        return [OutbreakClusterResponse(**c) for c in res.data]
