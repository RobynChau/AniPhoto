from pydantic import BaseModel
from typing import Optional

class ImageCreate(BaseModel):
    title: str
    description: Optional[str] = None
    url: str

class ImageUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    url: Optional[str] = None

class Image(ImageCreate):
    id: str
    created_at: str
    updated_at: str

    class Config:
        orm_mode = True


class ImageCreateBody(BaseModel):
    by_service: str
    url: str