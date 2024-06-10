from sqlalchemy.orm import Session
from typing import List
from datetime import datetime
from ..schemas.device import Device

class DeviceService:
    def __init__(self, db: Session):
        self.db = db

    def get_all_devices(self) -> List[Device]:
        """
        Retrieve all devices.
        """
        return self.db.query(Device).all()

    def get_device_by_id(self, device_id: str) -> Device:
        """
        Retrieve a device by its ID.
        """
        return self.db.query(Device).filter(Device.id == device_id).first()

    def create_device(self, id:str, name: str, platform: str) -> Device:
        """
        Create a new device.
        """
        now = datetime.now().isoformat()
        
        new_device = Device(
            id=id,
            name=name,
            platform=platform,
            updated_at=now,
            created_at=now
        )
        self.db.add(new_device)
        self.db.commit()
        self.db.refresh(new_device)
        return new_device

    def update_device(self, device_id: str, name: str, platform: str) -> Device:
        """
        Update an existing device.
        """
        device = self.get_device_by_id(device_id)
        now = datetime.now().isoformat()

        if device:
            device.name = name
            device.platform = platform
            device.updated_at = now
            self.db.commit()
            self.db.refresh(device)
        return device

    def delete_device(self, device_id: str) -> None:
        """
        Delete a device.
        """
        device = self.get_device_by_id(device_id)
        if device:
            self.db.delete(device)
            self.db.commit()