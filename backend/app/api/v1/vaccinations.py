import uuid
from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from app.core.dependencies import CurrentUser, get_current_user
from app.models.vaccination import VaccinationCreateRequest, VaccinationResponse
from app.db.supabase import get_supabase_client

router = APIRouter(prefix="/vaccinations", tags=["Vaccination Records"])

@router.post("", response_model=VaccinationResponse, status_code=status.HTTP_201_CREATED)
def add_vaccination(req: VaccinationCreateRequest, current_user: CurrentUser = Depends(get_current_user)):
    supabase = get_supabase_client()
    
    # Check if animal exists
    animal_res = supabase.table("animals").select("*").eq("id", req.animal_id).execute()
    if not animal_res.data:
        raise HTTPException(status_code=404, detail="Animal not found")

    vac_id = str(uuid.uuid4())
    now = datetime.now().isoformat()
    
    # Try parsing date to format properly if provided, or just use it
    vac_data = {
        "id": vac_id,
        "animal_id": req.animal_id,
        "vaccine_name": req.vaccine_name,
        "administered_date": req.administered_date or now,
        "next_due_date": req.next_due_date,
        "status": "COMPLETED",
        "vet_name": req.vet_name or (current_user.name if current_user.role == "VETERINARIAN" else "Self-Administered"),
        "created_at": now,
    }

    res = supabase.table("vaccinations").insert(vac_data).execute()
    return VaccinationResponse(**res.data[0])

@router.get("", response_model=List[VaccinationResponse])
def list_vaccinations(animal_id: Optional[str] = None, current_user: CurrentUser = Depends(get_current_user)):
    supabase = get_supabase_client()
    query = supabase.table("vaccinations").select("*")
    if animal_id:
        query = query.eq("animal_id", animal_id)
        
    res = query.execute()
    return [VaccinationResponse(**v) for v in res.data]
