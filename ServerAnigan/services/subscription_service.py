from sqlalchemy.orm import Session
from schemas.subscription import Subscription
from datetime import datetime
import uuid

class SubscriptionService:
    def __init__(self, db: Session):
        self.db = db

    def get_all_subscriptions(self):
        """
        Retrieve all subscriptions.
        """
        return self.db.query(Subscription).all()

    def get_subscription_by_id(self, subscription_id: str):
        """
        Retrieve a subscription by its ID.
        """
        return self.db.query(Subscription).filter(Subscription.id == subscription_id).first()

    def create_subscription(self, name: str, description: str, quota_limit: int, price: float, duration: int, level: int):
        """
        Create a new subscription.
        """
        now = datetime.now().isoformat()
        new_subscription = Subscription(
            id=str(uuid.uuid4()),
            name=name,
            description=description,
            quota_limit=quota_limit,
            price=price,
            duration=duration,
            level=level,
            created_at=now,
            updated_at=now
        )
        self.db.add(new_subscription)
        self.db.commit()
        self.db.refresh(new_subscription)
        return new_subscription

    def update_subscription(self, subscription_id: str, name: str, description: str, quota_limit: int, price: float, duration: int, level: int):
        """
        Update an existing subscription.
        """
        subscription = self.get_subscription_by_id(subscription_id)
        if subscription:
            subscription.name = name
            subscription.description = description
            subscription.quota_limit = quota_limit
            subscription.price = price
            subscription.duration = duration
            subscription.updated_at = datetime.now().isoformat()
            subscription.level = level
            self.db.commit()
            self.db.refresh(subscription)
        return subscription

    def delete_subscription(self, subscription_id: str):
        """
        Delete a subscription.
        """
        subscription = self.get_subscription_by_id(subscription_id)
        if subscription:
            self.db.delete(subscription)
            self.db.commit()