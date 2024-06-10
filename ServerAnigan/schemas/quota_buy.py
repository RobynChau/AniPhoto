from sqlalchemy import Column, String, TIMESTAMP, Float, ForeignKey
from ..config import Base

class QuotaBuy(Base):
    __tablename__ = "app_quota_buy"

    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, ForeignKey("app_user.id"))
    apple_receipt_data_jwt = Column(String)
    quota_product_id = Column(String, ForeignKey("app_quota_product.id"))
    quota_id = Column(String, ForeignKey("app_quota.id"))
    buy_price = Column(Float)
    created_at = Column(TIMESTAMP, index=True)
    updated_at = Column(TIMESTAMP, index=True)