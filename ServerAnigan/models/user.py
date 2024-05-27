from pydantic import BaseModel
from typing import Optional

class UserCreate(BaseModel):
    username: str
    email: str
    first_name:str
    last_name: str

class UserUpdate(BaseModel):
    username: Optional[str] = None
    email: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None

class User(UserCreate):
    id: str
    created_at: str
    updated_at: str

    class Config:
        orm_mode = True