import uuid
from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from app.core.dependencies import CurrentUser, get_current_user, require_roles
from app.models.sample import SampleCreateRequest, SampleResultUpdateRequest, SampleResponse
from app.db.supabase import get_supabase_client

router = APIRouter(prefix="/samples", tags=["Laboratory Samples"])

@router.get("", response_model=List[SampleResponse])
def list_samples(case_id: Optional[str] = None, current_user: CurrentUser = Depends(get_current_user)):
    supabase = get_supabase_client()
    query = supabase.table("samples").select("*")
    if case_id:
        query = query.eq("case_id", case_id)
        
    res = query.execute()
    return [SampleResponse(**s) for s in res.data]

@router.post("", response_model=SampleResponse, status_code=status.HTTP_201_CREATED)
def create_sample(req: SampleCreateRequest, current_user: CurrentUser = Depends(require_roles(["VETERINARIAN", "ADMIN"]))):
    supabase = get_supabase_client()
    
    # Get count for short ID
    count_res = supabase.table("samples").select("id", count="exact").execute()
    count = count_res.count or 0
    short_code = f"SMP-{datetime.now().strftime('%m%d')}-{count + 1:03d}"

    sample_id = str(uuid.uuid4())
    now = datetime.now().isoformat()
    sample_data = {
        "id": sample_id,
        "sample_code": short_code,
        "case_id": req.case_id,
        "animal_id": req.animal_id,
        "animal_tag": req.animal_tag,
        "sample_type": req.sample_type.upper(),
        "laboratory": req.laboratory,
        "reason": req.reason,
        "collected_by": current_user.name,
        "status": "COLLECTED",
        "collection_date": datetime.now().date().isoformat(),
        "created_at": now,
    }

    res = supabase.table("samples").insert(sample_data).execute()
    
    # Update case status
    if req.case_id:
        update_data = {
            "status": "LAB_REFERRED",
            "updated_at": now
        }
        supabase.table("cases").update(update_data).eq("id", req.case_id).execute()
        
        supabase.table("case_timeline_events").insert({
            "case_id": req.case_id,
            "status": "Sample Collected",
            "description": f"{req.sample_type} sample sent to {req.laboratory}",
            "actor": current_user.name,
            "created_at": now
        }).execute()

    return SampleResponse(**res.data[0])

@router.get("", response_model=List[SampleResponse])
def list_samples(case_id: Optional[str] = None, current_user: CurrentUser = Depends(get_current_user)):
    supabase = get_supabase_client()
    query = supabase.table("samples").select("*")
    if case_id:
        query = query.eq("case_id", case_id)
    res = query.execute()
    return [SampleResponse(**s) for s in res.data]

@router.get("/{sample_id}", response_model=SampleResponse)
def get_sample(sample_id: str, current_user: CurrentUser = Depends(get_current_user)):
    supabase = get_supabase_client()
    res = supabase.table("samples").select("*").eq("id", sample_id).execute()
    if not res.data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Sample not found")
    return SampleResponse(**res.data[0])


@router.put("/{sample_id}/result", response_model=SampleResponse)
def update_sample_result(
    sample_id: str,
    req: SampleResultUpdateRequest,
    current_user: CurrentUser = Depends(require_roles(["VETERINARIAN", "ADMIN"])),
):
    supabase = get_supabase_client()
    now = datetime.now().isoformat()
    result_date = req.result_date or datetime.now().date().isoformat()

    update_data = {
        "status": req.status,
        "result_summary": req.result_summary,
        "result_date": result_date,
        "updated_at": now,
    }
    res = supabase.table("samples").update(update_data).eq("id", sample_id).execute()
    if not res.data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Sample not found")

    sample = res.data[0]
    case_id = sample.get("case_id")
    if case_id:
        supabase.table("case_timeline_events").insert({
            "case_id": case_id,
            "status": "Lab Result Available",
            "description": f"Diagnostic result: {req.result_summary}",
            "actor": current_user.name,
            "created_at": now,
        }).execute()

    return SampleResponse(**sample)

