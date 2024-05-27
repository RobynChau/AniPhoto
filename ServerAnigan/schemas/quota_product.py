from sqlalchemy import Column, Integer, String,TIMESTAMP,Float
from config import Base

class QuotaProduct(Base):
    __tablename__ = "app_quota_product"

    id = Column(String, primary_key=True, index=True)
    name = Column(String)
    quota_amount = Column(Integer)
    description = Column(String)
    price = Column(Float)
    created_at = Column(TIMESTAMP, index=True)
    updated_at = Column(TIMESTAMP, index=True)