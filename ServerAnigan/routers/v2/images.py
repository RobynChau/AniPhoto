from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ...services.image_service import ImageService
from ...config import get_db
from ...dependencies import get_payload_optional_token
from ...schemas.user_session import UserSession
from ...models.image import ImageCreateBody

router = APIRouter(
    prefix="/images",
    tags=["Images"],
)

@router.get("/{image_id}")
def get_image_by_id(image_id: str, db: Session = Depends(get_db)):
    """
    Retrieve an image by its ID.
    """
    image_service = ImageService(db)
    image = image_service.get_image_by_id(image_id)
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    return image

@router.post("/", status_code=201)
def create_image(body: ImageCreateBody, data = Depends(get_payload_optional_token), db: Session = Depends(get_db)):
    """
    Create a new image.
    """
    user_session: UserSession = data.get('session')
    image_service = ImageService(db)
    return image_service.create_image(body.url, body.by_service, user_session.id)

