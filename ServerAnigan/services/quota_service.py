from sqlalchemy.orm import Session
from schemas.quota import Quota
from schemas.device_quota import DeviceQuota
from schemas.quota_buy import QuotaBuy

from schemas.subscription_transaction import SubscriptionTransaction

from datetime import datetime
import uuid

class QuotaService:
    def __init__(self, db: Session):
        self.db = db

    def get_all_quotas(self):
        """
        Retrieve all quotas.
        """
        return self.db.query(Quota).all()

    def get_quota_by_id(self, quota_id: str):
        """
        Retrieve a quota by its ID.
        """
        return self.db.query(Quota).filter(Quota.id == quota_id).first()

    def create_quota(self, amount: int):
        """
        Create a new quota.
        """
        now = datetime.now().isoformat()
        new_quota = Quota(
            id=str(uuid.uuid4()),
            amount=amount,
            created_at=now,
            updated_at=now
        )
        self.db.add(new_quota)
        self.db.commit()
        self.db.refresh(new_quota)
        return new_quota

    def get_quota_by_device_id(self, device_id: str):
        """
        Retrieve a quota by the associated device ID.
        """
        return (
            self.db.query(Quota)
            .join(DeviceQuota, Quota.id == DeviceQuota.quota_id)
            .filter(DeviceQuota.device_id == device_id)
            .first()
        )
    
    def update_quota(self, quota_id: str, new_amount: int):
        """
        Update an existing quota.
        """
        quota = self.get_quota_by_id(quota_id)
        if quota:
            quota.amount = new_amount
            quota.updated_at = datetime.now().isoformat()
            self.db.commit()
            self.db.refresh(quota)
        return quota

    def delete_quota(self, quota_id: str):
        """
        Delete a quota.
        """
        quota = self.get_quota_by_id(quota_id)
        if quota:
            self.db.delete(quota)
            self.db.commit()

    def get_total_subcription_quota_by_user_id(self, user_id: str):
        """
        Retrieve the total quota for a user by joining the Quota, DeviceQuota, and SubscriptionTransactionService tables.
        """
        total_quota = (
            self.db.query(Quota)
            .join(SubscriptionTransaction, SubscriptionTransaction.quota_id == Quota.id)
            .filter(SubscriptionTransaction.user_id == user_id)
            .order_by(Quota.created_at.desc())
            .all()
        )
        return total_quota
    
    def get_active_subscription_quota_by_user_id(self, user_id: str):
        """
        Retrieve the total active quota for a user by joining the Quota, DeviceQuota, and SubscriptionTransactionService tables.
        """
        total_active_quota = (
            self.db.query(Quota)
            .join(SubscriptionTransaction, SubscriptionTransaction.quota_id == Quota.id)
            .filter(SubscriptionTransaction.user_id == user_id)
            .filter(SubscriptionTransaction.status == 'ACTIVE')
            .order_by(SubscriptionTransaction.created_at.desc())
            .first()
        )
        return total_active_quota
    
    def get_total_product_quota_by_user_id(self, user_id: str):
        """
        Retrieve the total quota for a user by joining the Quota, DeviceQuota, and SubscriptionTransactionService tables.
        """
        total_quota = (
            self.db.query(Quota)
            .join(QuotaBuy, QuotaBuy.quota_id == Quota.id)
            .filter(QuotaBuy.user_id == user_id)
            .order_by(QuotaBuy.created_at.desc())
            .all()
        )
        return total_quota