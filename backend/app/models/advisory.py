from datetime import datetime
from typing import Optional
from pydantic import BaseModel


class AdvisoryCreateRequest(BaseModel):
    title: str
    message: str
    target: str = "ALL"  # ALL, DISTRICT, BLOCK, VILLAGE
    target_location: Optional[str] = None
    language: str = "en"


class AdvisoryResponse(BaseModel):
    id: str
    advisory_code: str
    title: str
    message: str
    target: str
    target_location: Optional[str] = None
    language: str
    created_by: str
    status: str
    published_at: Optional[datetime] = None
    created_at: datetime
