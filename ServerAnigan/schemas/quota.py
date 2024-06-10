from sqlalchemy import Column, Integer, String,TIMESTAMP
from ..config import Base

class Quota(Base):
    __tablename__ = "app_quota"

    id = Column(String, primary_key=True, index=True)
    amount = Column(Integer)
    created_at = Column(TIMESTAMP, index=True)
    updated_at = Column(TIMESTAMP, index=True)