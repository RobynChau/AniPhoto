import datetime
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from config import get_db
from helpers.animegan import generate_anime_image, upload_to_firebase
from dependencies import get_payload_optional_token
from schemas.user_session import UserSession
from schemas.user import User
from services.image_service import ImageService
from helpers.use_quota import use_quota
from models.ml import GenerateAnimeBody

router = APIRouter(
    prefix="/v2/ml",
    tags=["Machine Learning"]
)   

@router.post("/anime")
def create_anime_image(body: GenerateAnimeBody, data = Depends(get_payload_optional_token), db: Session = Depends(get_db)):
    image_service = ImageService(db)
    session: UserSession = data.get('session')
    user: User = data.get('user')

    user_id = None if user is None else user.id
    # Decrease the quota
    use_quota(data.get('device_id'), user_id, db)

    image_file_path = generate_anime_image(body.source_img_path)[0]
    timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    firebase_url = upload_to_firebase(image_file_path, f'images/{session.id}/{timestamp}.png')
    image_service.create_image(firebase_url, 'anime', session.id)
    return {
       "processed_url": firebase_url
    }