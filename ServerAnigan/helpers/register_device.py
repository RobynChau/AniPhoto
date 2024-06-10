from sqlalchemy.orm import Session
from datetime import datetime, timedelta

from ..services.device_service import DeviceService
from ..services.device_quota_service import DeviceQuotaService
from ..services.quota_service import QuotaService
from ..config import FREE_QUOTA, EXPIRED_FREE_QUOTA_DAYS

def register_device(device_id:str , db: Session):
    device_service = DeviceService(db)
    quota_service = QuotaService(db)
    device_quota_service = DeviceQuotaService(db)

    expired = (datetime.now() + timedelta(days=EXPIRED_FREE_QUOTA_DAYS)).isoformat()

    device = device_service.create_device(device_id, "", "IOS")
    quota = quota_service.create_quota(FREE_QUOTA)
    device_quota_service.create_device_quota(device.id, quota.id, expired)

    return device