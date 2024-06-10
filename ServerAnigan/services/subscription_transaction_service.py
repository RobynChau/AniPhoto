from sqlalchemy.orm import Session
from ..schemas.subscription_transaction import SubscriptionTransaction
from ..schemas.quota import Quota
from ..schemas.subscription import Subscription
from datetime import datetime, timedelta
import uuid

class SubscriptionTransactionService:
    def __init__(self, db: Session):
        self.db = db

    def get_all_subscription_transactions(self):
        """
        Retrieve all subscription transactions.
        """
        return self.db.query(SubscriptionTransaction).all()

    def get_subscription_transaction_by_id(self, transaction_id: str):
        """
        Retrieve a subscription transaction by its ID.
        """
        return self.db.query(SubscriptionTransaction).filter(SubscriptionTransaction.id == transaction_id).first()

    def create_subscription_transaction(self, user_id: str, subscription_id: str, quota_id: str, apple_receipt_data_jwt: str):
        """
        Create a new subscription transaction.
        """
        now = datetime.now()
        new_transaction = SubscriptionTransaction(
            id=str(uuid.uuid4()),
            user_id=user_id,
            subscription_id=subscription_id,
            quota_id=quota_id,
            apple_receipt_data_jwt=apple_receipt_data_jwt,
            status='ACTIVE',
            created_at=now.isoformat(),
            updated_at=now.isoformat(),
            expired_at=(now + timedelta(days=self.get_subscription_duration(subscription_id))).isoformat()
        )
        self.db.add(new_transaction)
        self.db.commit()
        self.db.refresh(new_transaction)
        return new_transaction

    def get_user_current_quota(self, user_id: str):
        """
        Retrieve the current quota of a user by joining the subscription transaction and quota tables.
        """
        user_quota = (
            self.db.query(Quota)
            .join(SubscriptionTransaction, SubscriptionTransaction.quota_id == Quota.id)
            .filter(SubscriptionTransaction.user_id == user_id)
            .order_by(SubscriptionTransaction.created_at.desc())
            .first()
        )
        return user_quota

    def get_subscription_duration(self, subscription_id: str):
        """
        Retrieve the duration of a subscription.
        """
        subscription = self.db.query(Subscription).filter(Subscription.id == subscription_id).first()
        return subscription.duration
    
    def get_user_subscription_transactions(self, user_id: str):
        """
        Retrieve all subscription transactions for a given user.
        """
        return (
            self.db.query(SubscriptionTransaction)
            .filter(SubscriptionTransaction.user_id == user_id)
            .order_by(SubscriptionTransaction.created_at.desc())
            .all()
        )
    
    def update_subscription_transaction(self, transaction_id: str, status: str):
        """
        Update an existing subscription transaction.
        """
        transaction = self.db.query(SubscriptionTransaction).filter(SubscriptionTransaction.id == transaction_id).first()
        if transaction:
            transaction.status = status
            transaction.updated_at = datetime.now().isoformat()
            self.db.commit()
            self.db.refresh(transaction)
            return transaction
        else:
            return None
        
    
    def get_user_current_active_subscription(self, user_id: str):
        """
        Retrieve the current active subscription transaction for a given user.
        """
        active_transaction = (
            self.db.query(SubscriptionTransaction)
            .filter(SubscriptionTransaction.user_id == user_id)
            .filter(SubscriptionTransaction.status == 'ACTIVE')
            .order_by(SubscriptionTransaction.created_at.desc())
            .first()
        )
        return active_transaction