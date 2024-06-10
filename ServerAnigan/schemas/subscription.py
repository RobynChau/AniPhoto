from sqlalchemy import Column, Integer, Float, String,TIMESTAMP
from ..config import Base

class Subscription(Base):
    __tablename__ = "app_subscription"

    id = Column(String, primary_key=True, index=True)
    name = Column(String)
    description = Column(String)
    quota_limit = Column(Integer)
    price = Column(Float)
    level = Column(Integer)
    duration = Column(Integer)  # Duration in days
    created_at = Column(TIMESTAMP, index=True)
    updated_at = Column(TIMESTAMP, index=True)
