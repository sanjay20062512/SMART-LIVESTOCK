from typing import Optional, List
from pydantic import BaseModel


class UserRole(str):
    FARMER = "FARMER"
    VETERINARIAN = "VETERINARIAN"
    PARAVET = "PARAVET"
    LAB_STAFF = "LAB_STAFF"
    GOVERNMENT_OFFICER = "GOVERNMENT_OFFICER"
    ADMIN = "ADMIN"


class LoginRequest(BaseModel):
    phone_or_id: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: str
    user_id: str
    name: str


class FarmerRegisterRequest(BaseModel):
    full_name: str
    phone: str
    password: str
    email: Optional[str] = None
    state: str = "Maharashtra"
    district: str
    block: str
    village: str
    farm_name: Optional[str] = None
    farm_size: Optional[float] = 5.0
    farm_size_unit: Optional[str] = "Acres"
    preferred_language: Optional[str] = "en"
    livestock_types: Optional[list[str]] = ["Cow", "Goat"]


class UserProfileResponse(BaseModel):
    id: str
    full_name: str
    phone: str
    email: Optional[str] = None
    role: str
    state: Optional[str] = None
    district: Optional[str] = None
    block: Optional[str] = None
    village: Optional[str] = None
    farm_name: Optional[str] = None
