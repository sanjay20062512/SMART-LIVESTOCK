import uuid
from datetime import datetime
from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from app.core.dependencies import CurrentUser, get_current_user
from app.models.animal import AnimalCreate, AnimalResponse, AnimalUpdate
from app.db.supabase import get_supabase_client

router = APIRouter(prefix="/animals", tags=["Animal Records"])

@router.post("", response_model=AnimalResponse, status_code=status.HTTP_201_CREATED)
def add_animal(animal_in: AnimalCreate, current_user: CurrentUser = Depends(get_current_user)):
    supabase = get_supabase_client()
    if not supabase:
        raise HTTPException(status_code=500, detail="Database connection not configured")
        
    # Check duplicate ear tag for owner
    existing = supabase.table("animals").select("*").eq("owner_id", current_user.user_id).eq("ear_tag", animal_in.ear_tag.upper()).execute()
    if existing.data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Ear Tag '{animal_in.ear_tag}' is already registered on your farm.",
        )

    animal_id = str(uuid.uuid4())
    now = datetime.now().isoformat()
    animal_data = {
        "id": animal_id,
        "farm_id": animal_in.farm_id or "33333333-3333-3333-3333-333333333301",
        "owner_id": current_user.user_id,
        "ear_tag": animal_in.ear_tag.upper(),
        "species": animal_in.species,
        "breed": animal_in.breed or "Standard",
        "gender": animal_in.gender or "Female",
        "age_years": animal_in.age_category or "2",
        "health_status": animal_in.health_status or "HEALTHY",
        "created_at": now,
        "updated_at": now,
    }
    
    res = supabase.table("animals").insert(animal_data).execute()
    if not res.data:
        raise HTTPException(status_code=500, detail="Failed to insert animal")
    return AnimalResponse(**res.data[0])


DEMO_ANIMALS = [
    {
        "id": "11111111-1111-1111-1111-111111111101",
        "farm_id": "33333333-3333-3333-3333-333333333301",
        "owner_id": "22222222-2222-2222-2222-222222222201",
        "ear_tag": "TAG-8821",
        "species": "Cow",
        "breed": "Gir",
        "gender": "Female",
        "age_category": "3.5 years",
        "health_status": "HEALTHY",
        "location": "Uruli Kanchan, Pune",
    },
    {
        "id": "11111111-1111-1111-1111-111111111102",
        "farm_id": "33333333-3333-3333-3333-333333333301",
        "owner_id": "22222222-2222-2222-2222-222222222201",
        "ear_tag": "TAG-8822",
        "species": "Buffalo",
        "breed": "Murrah",
        "gender": "Female",
        "age_category": "4 years",
        "health_status": "HEALTHY",
        "location": "Uruli Kanchan, Pune",
    },
    {
        "id": "11111111-1111-1111-1111-111111111103",
        "farm_id": "33333333-3333-3333-3333-333333333301",
        "owner_id": "22222222-2222-2222-2222-222222222201",
        "ear_tag": "TAG-8823",
        "species": "Cow",
        "breed": "Sahiwal",
        "gender": "Female",
        "age_category": "2 years",
        "health_status": "QUARANTINED",
        "location": "Uruli Kanchan, Pune",
    },
]


@router.get("", response_model=List[AnimalResponse])
def list_animals(current_user: CurrentUser = Depends(get_current_user)):
    supabase = get_supabase_client()
    if not supabase:
        return [AnimalResponse(**a) for a in DEMO_ANIMALS]
        
    if current_user.role == "FARMER":
        res = supabase.table("animals").select("*").eq("owner_id", current_user.user_id).execute()
    else:
        # Vet/Govt can see all
        res = supabase.table("animals").select("*").execute()
        
    return [AnimalResponse(**a) for a in res.data]


@router.get("/{animal_id}", response_model=AnimalResponse)
def get_animal(animal_id: str, current_user: CurrentUser = Depends(get_current_user)):
    supabase = get_supabase_client()
    if not supabase:
        raise HTTPException(status_code=500, detail="Database connection not configured")
        
    res = supabase.table("animals").select("*").eq("id", animal_id).execute()
    if not res.data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Animal record not found")
        
    return AnimalResponse(**res.data[0])


@router.put("/{animal_id}", response_model=AnimalResponse)
def update_animal(animal_id: str, animal_in: AnimalUpdate, current_user: CurrentUser = Depends(get_current_user)):
    supabase = get_supabase_client()
    if not supabase:
        raise HTTPException(status_code=500, detail="Database connection not configured")
        
    # Check exists
    res = supabase.table("animals").select("*").eq("id", animal_id).execute()
    if not res.data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Animal record not found")

    update_data = {k: v for k, v in animal_in.dict(exclude_unset=True).items() if v is not None}
    update_data["updated_at"] = datetime.now().isoformat()
    
    updated_res = supabase.table("animals").update(update_data).eq("id", animal_id).execute()
    if not updated_res.data:
         raise HTTPException(status_code=500, detail="Failed to update animal")
         
    return AnimalResponse(**updated_res.data[0])
