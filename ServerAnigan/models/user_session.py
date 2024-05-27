from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class UserSessionCreate(BaseModel):
    device_id: str
    status: str
    user_id: str

class UserSessionUpdate(BaseModel):
    device_id: Optional[str] = None
    status: Optional[str] = None

class UserSession(UserSessionCreate):
    id: str
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True