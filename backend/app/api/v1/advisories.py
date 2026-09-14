import uuid
from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from app.core.dependencies import CurrentUser, get_current_user, require_roles
from app.models.advisory import AdvisoryCreateRequest, AdvisoryResponse
from app.db.supabase import get_supabase_client

router = APIRouter(prefix="/advisories", tags=["Advisories & Broadcasts"])


@router.get("", response_model=List[AdvisoryResponse])
def list_advisories(target: Optional[str] = None, current_user: CurrentUser = Depends(get_current_user)):
    supabase = get_supabase_client()
    query = supabase.table("advisories").select("*")
    if target:
        query = query.ilike("target_level", target)
        
    res = query.execute()
    return [AdvisoryResponse(**a) for a in res.data]


@router.post("", response_model=AdvisoryResponse, status_code=status.HTTP_201_CREATED)
def create_advisory(
    req: AdvisoryCreateRequest, current_user: CurrentUser = Depends(require_roles(["GOVERNMENT_OFFICER", "ADMIN"]))
):
    supabase = get_supabase_client()
    
    # Get count for short ID
    count_res = supabase.table("advisories").select("id", count="exact").execute()
    count = count_res.count or 0
    short_code = f"ADV-{datetime.now().strftime('%m%d')}-{count + 1:03d}"

    adv_id = str(uuid.uuid4())
    now = datetime.now().isoformat()
    adv_data = {
        "id": adv_id,
        "advisory_code": short_code,
        "title": req.title,
        "message": req.message,
        "target": req.target,
        "target_location": req.target_location,
        "language": req.language or "en",
        "created_by": current_user.name,
        "status": "PUBLISHED",
        "published_at": now,
        "created_at": now,
    }

    res = supabase.table("advisories").insert(adv_data).execute()

    # Generate an alert payload for pushing to users in the target area
    alert_data = {
        "id": str(uuid.uuid4()),
        "category": "GOVERNMENT_ADVISORY",
        "title": f"Advisory: {req.title}",
        "message": req.message,
        "severity": "INFO",
        "target_role": "FARMER", # Broadcast to farmers
        "created_at": now,
    }
    supabase.table("alerts").insert(alert_data).execute()

    return AdvisoryResponse(**res.data[0])
