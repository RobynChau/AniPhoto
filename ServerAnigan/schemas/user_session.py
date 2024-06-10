from sqlalchemy import  Column, String, ForeignKey, TIMESTAMP
from ..config import Base

class UserSession(Base):
    __tablename__ ="app_user_session"

    id = Column(String, primary_key=True, index=True)
    device_id = Column(String)
    status = Column(String)
    user_id = Column(String, foreign_keys=ForeignKey(("app_user.id")))
    created_at = Column(TIMESTAMP, index=True)
    updated_at = Column(TIMESTAMP, index=True)
