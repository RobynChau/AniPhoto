from sqlalchemy import Column, String, TIMESTAMP
from ..config import Base

class Device(Base):
    __tablename__ = "app_device"

    id = Column(String, primary_key=True, index=True)
    name = Column(String)
    platform = Column(String)
    created_at = Column(TIMESTAMP, index=True)
    updated_at = Column(TIMESTAMP, index=True)
