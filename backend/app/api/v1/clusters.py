import uuid
from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from app.core.dependencies import CurrentUser, get_current_user, require_roles
from app.models.cluster import OutbreakClusterCreate, OutbreakClusterResponse
from app.db.supabase import get_supabase_client
from app.services.surveillance_service import SurveillanceService

router = APIRouter(prefix="/clusters", tags=["Disease Clusters"])

@router.get("", response_model=List[OutbreakClusterResponse])
def list_clusters(
    risk_level: Optional[str] = None,
    district: Optional[str] = None,
    current_user: CurrentUser = Depends(get_current_user),
):
    return SurveillanceService.list_clusters(risk_level, district)

@router.post("", response_model=OutbreakClusterResponse, status_code=status.HTTP_201_CREATED)
def escalate_cluster(
    req: OutbreakClusterCreate, current_user: CurrentUser = Depends(require_roles(["VETERINARIAN", "ADMIN"]))
):
    supabase = get_supabase_client()
    
    # Get count for short ID
    count_res = supabase.table("outbreak_clusters").select("id", count="exact").execute()
    count = count_res.count or 0
    short_code = f"CLU-{datetime.now().strftime('%m%d')}-{count + 1:03d}"

    cluster_id = str(uuid.uuid4())
    now = datetime.now().isoformat()
    cluster_data = {
        "id": cluster_id,
        "cluster_code": short_code,
        "name": req.name,
        "location": req.location,
        "village": req.village,
        "block": req.block,
        "district": req.district,
        "state": req.state,
        "risk_level": req.risk_level,
        "species": req.species,
        "report_count": req.report_count,
        "animal_count": req.animal_count,
        "mortality": req.mortality,
        "symptoms": req.symptoms,
        "suspected_disease": req.suspected_disease,
        "description": req.description,
        "status": "ESCALATED",
        "detected_at": now,
        "created_by": current_user.name,
    }

    res = supabase.table("outbreak_clusters").insert(cluster_data).execute()
    return OutbreakClusterResponse(**res.data[0])
