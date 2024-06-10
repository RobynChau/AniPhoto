from sqlalchemy import Column, String, ForeignKey, TIMESTAMP
from ..config import Base

class SubscriptionTransaction(Base):
    __tablename__ = "app_subscription_transaction"

    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, ForeignKey("app_user.id"))
    subscription_id = Column(String, ForeignKey("app_subscription.id"))
    quota_id = Column(String, ForeignKey("app_quota.id"))
    apple_receipt_data_jwt = Column(String)
    expired_at = Column(TIMESTAMP, index=True)
    created_at = Column(TIMESTAMP, index=True)
    updated_at = Column(TIMESTAMP, index=True)
    status = Column(String)