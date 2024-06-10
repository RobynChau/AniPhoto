from sqlalchemy import  Column, String, ForeignKey, TIMESTAMP
from ..config import Base

class Image(Base):
    __tablename__ ="app_image"

    id = Column(String, primary_key=True, index=True)
    url = Column(String)
    by_service = Column(String)
    created_session_id = Column(String, foreign_keys=ForeignKey(("app_user_session.id")))
    created_at = Column(TIMESTAMP, index=True)
    updated_at = Column(TIMESTAMP, index=True)