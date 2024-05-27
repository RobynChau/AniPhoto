from sqlalchemy.orm import Session
from schemas.device_quota import DeviceQuota
from typing import List
import uuid
from datetime import datetime

class DeviceQuotaService:
    def __init__(self, db: Session):
        self.db = db

    def get_all_device_quotas(self) -> List[DeviceQuota]:
        """
        Retrieve all device quotas.
        """
        return self.db.query(DeviceQuota).all()

    def get_device_quota_by_id(self, device_quota_id: str) -> DeviceQuota:
        """
        Retrieve a device quota by its ID.
        """
        return self.db.query(DeviceQuota).filter(DeviceQuota.id == device_quota_id).first()
    
    def get_device_quota_by_device_id(self, device_id: str) -> DeviceQuota:
        """
        Retrieve device quotas associated with a specific device.
        """
        return self.db.query(DeviceQuota).filter(DeviceQuota.device_id == device_id).first()

    def get_device_quotas_by_device_id(self, device_id: str) -> List[DeviceQuota]:
        """
        Retrieve all device quotas associated with a specific device.
        """
        return self.db.query(DeviceQuota).filter(DeviceQuota.device_id == device_id).all()

    def create_device_quota(self, device_id: str, quota_id: str, expired_at: str) -> DeviceQuota:
        """
        Create a new device quota.
        """
        now = datetime.now().isoformat()

        new_device_quota = DeviceQuota(
            id=str(uuid.uuid4()),
            device_id=device_id,
            quota_id=quota_id,
            expired_at=expired_at,
            created_at=now,
            updated_at=now
        )
        self.db.add(new_device_quota)
        self.db.commit()
        self.db.refresh(new_device_quota)
        return new_device_quota

    def update_device_quota(self, device_quota_id: str, device_id: str, quota_id: str, expired_at: str) -> DeviceQuota:
        """
        Update an existing device quota.
        """
        device_quota = self.get_device_quota_by_id(device_quota_id)
        if device_quota:
            device_quota.device_id = device_id
            device_quota.quota_id = quota_id
            device_quota.expired_at = expired_at
            device_quota.updated_at = datetime.now().isoformat()

            self.db.commit()
            self.db.refresh(device_quota)
        return device_quota

    def delete_device_quota(self, device_quota_id: str) -> None:
        """
        Delete a device quota.
        """
        device_quota = self.get_device_quota_by_id(device_quota_id)
        if device_quota:
            self.db.delete(device_quota)
            self.db.commit()