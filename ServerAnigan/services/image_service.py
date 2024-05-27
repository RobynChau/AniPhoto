from sqlalchemy.orm import Session
from schemas.image import Image
from schemas.user_session import UserSession
from schemas.user import User
from schemas.device import Device

from datetime import datetime

class ImageService:
    def __init__(self, db: Session):
        self.db = db

    def get_all_images(self):
        """
        Retrieve all images.
        """
        return self.db.query(Image).all()
    
    def get_all_user_image(self, user_id: str, device_id: str):
        """
        Retrieve all user images.
        """
        user_images = []
        if user_id != None:
            user_images = (
                self.db.query(Image)
                .join(UserSession, Image.created_session_id == UserSession.id)
                .join(User, UserSession.user_id == User.id)
                .filter(User.id == user_id)
                .all()
            )

        device_images = (
            self.db.query(Image)
            .join(UserSession, UserSession.id == Image.created_session_id)
            .filter(UserSession.device_id == device_id, UserSession.user_id.is_(None))
            .all()
        )

        # Combine the two lists and remove duplicates based on image ID
        all_images = {img.id: img for img in user_images + device_images}.values()
        return list(all_images)

    def get_image_by_id(self, image_id: str):
        """
        Retrieve an image by its ID.
        """
        return self.db.query(Image).filter(Image.id == image_id).first()

    def get_images_by_session_id(self, session_id: str):
        """
        Retrieve all images associated with a given user session.
        """
        return self.db.query(Image).filter(Image.created_session_id == session_id).all()

    def create_image(self, url: str, by_service: str, session_id: str):
        """
        Create a new image.
        """
        now = datetime.now().isoformat()
        image = Image(
            id=f"{session_id}_{by_service}_{now}",
            url=url,
            by_service=by_service,
            created_at=now,
            updated_at=now,
            created_session_id=session_id
        )
        self.db.add(image)
        self.db.commit()
        self.db.refresh(image)
        return image

    def update_image(self, image_id: str, url: str, by_service: str):
        """
        Update an existing image.
        """
        image = self.get_image_by_id(image_id)
        if image:
            image.url = url
            image.by_service = by_service
            image.updated_at = datetime.now().isoformat()
            self.db.commit()
            self.db.refresh(image)
        return image

    def delete_image(self, image_id: str):
        """
        Delete an image.
        """
        image = self.get_image_by_id(image_id)
        if image:
            self.db.delete(image)
            self.db.commit()