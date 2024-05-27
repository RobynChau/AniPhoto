from sqlalchemy import Column, String, ForeignKey, TIMESTAMP
from config import Base

class DeviceQuota(Base):
    __tablename__ = "app_device_quota"

    id = Column(String, primary_key=True, index=True)
    device_id = Column(String, ForeignKey("app_device.id"))
    quota_id = Column(String, ForeignKey("app_quota.id"))
    expired_at = Column(TIMESTAMP, index=True)
    created_at = Column(TIMESTAMP, index=True)
    updated_at = Column(TIMESTAMP, index=True)