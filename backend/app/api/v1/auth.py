import uuid
from fastapi import APIRouter, HTTPException, status
from app.core.security import create_access_token
from app.models.auth import FarmerRegisterRequest, LoginRequest, TokenResponse, UserProfileResponse

router = APIRouter(prefix="/auth", tags=["Authentication"])

# Predefined demo accounts
DEMO_USERS = {
    "9876543210": {
        "id": "22222222-2222-2222-2222-222222222201",
        "name": "Ramesh Pawar",
        "role": "FARMER",
        "password": "farmer123",
        "state": "Maharashtra",
        "district": "Pune",
        "block": "Haveli",
        "village": "Uruli Kanchan",
    },
    "VET001": {
        "id": "22222222-2222-2222-2222-222222222202",
        "name": "Dr. Rajesh Kumar",
        "role": "VETERINARIAN",
        "password": "vet123",
        "state": "Maharashtra",
        "district": "Pune",
        "block": "Haveli",
        "village": "Uruli Kanchan",
    },
    "GOV001": {
        "id": "22222222-2222-2222-2222-222222222203",
        "name": "Dr. Anil Deshmukh",
        "role": "GOVERNMENT_OFFICER",
        "password": "gov123",
        "state": "Maharashtra",
        "district": "Pune",
        "block": "Haveli",
        "village": "Pune City",
    },
}


@router.post("/login", response_model=TokenResponse)
def login(req: LoginRequest):
    identifier = req.phone_or_id.strip()
    user = DEMO_USERS.get(identifier)

    # In demo mode, permit any phone number for farmers if not strictly mapped
    if not user:
        if identifier.isdigit() and len(identifier) == 10:
            user = {
                "id": str(uuid.uuid4()),
                "name": f"Farmer {identifier[-4:]}",
                "role": "FARMER",
                "password": req.password,
                "state": "Maharashtra",
                "district": "Pune",
                "block": "Haveli",
                "village": "Uruli Kanchan",
            }
            DEMO_USERS[identifier] = user
        else:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid username or password. Demo accounts: VET001/vet123, GOV001/gov123, 9876543210/any",
            )

    token = create_access_token(
        subject=user["id"],
        role=user["role"],
        extra_claims={"name": user["name"], "district": user["district"]},
    )

    return TokenResponse(
        access_token=token,
        token_type="bearer",
        role=user["role"],
        user_id=user["id"],
        name=user["name"],
    )


@router.post("/register", response_model=TokenResponse)
def register_farmer(req: FarmerRegisterRequest):
    user_id = str(uuid.uuid4())
    DEMO_USERS[req.phone] = {
        "id": user_id,
        "name": req.full_name,
        "role": "FARMER",
        "password": req.password,
        "state": req.state,
        "district": req.district,
        "block": req.block,
        "village": req.village,
    }

    token = create_access_token(
        subject=user_id,
        role="FARMER",
        extra_claims={"name": req.full_name, "district": req.district},
    )

    return TokenResponse(
        access_token=token,
        token_type="bearer",
        role="FARMER",
        user_id=user_id,
        name=req.full_name,
    )
