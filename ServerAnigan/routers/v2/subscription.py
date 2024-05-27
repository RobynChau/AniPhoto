from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from services.subscription_transaction_service import SubscriptionTransactionService
from services.subscription_service import SubscriptionService
from services.quota_service import QuotaService

from config import get_db
from dependencies import get_payload
from schemas.user_session import UserSession
from models.subscription import ConfirmSubscriptionBody

router = APIRouter(
    prefix="/subscriptions",
    tags=["Subscriptions"]
)

@router.get("/products")
def get_all_subscriptions_product(db: Session = Depends(get_db)):
    """
    Retrieve all subscriptions.
    """
    subscription_service = SubscriptionService(db)
    return subscription_service.get_all_subscriptions()

@router.get("/active-subscription")
def get_active_subscription(
    data = Depends(get_payload),
    db: Session = Depends(get_db),
):
    user_session: UserSession = data.get('session')
    subcription_service = SubscriptionService(db)
    subcription_transaction_service = SubscriptionTransactionService(db)
    active_sub = subcription_transaction_service.get_user_current_active_subscription(user_session.user_id)
    subcription_detail = subcription_service.get_subscription_by_id(active_sub.subscription_id)
    active_sub.subscription = subcription_detail
    return active_sub

@router.post("/confirm-subscription")
def confirm_subscription_transaction(
    body: ConfirmSubscriptionBody,
    data = Depends(get_payload),
    db: Session = Depends(get_db),
):
    """
    Create a new subscription transaction.
    """
    user_session: UserSession = data.get('session')
    subcription_service = SubscriptionService(db)
    subcription_transaction_service = SubscriptionTransactionService(db)
    quota_service = QuotaService(db)
    subcription_detail = subcription_service.get_subscription_by_id(body.subscription_id)

    prev_transaction = subcription_transaction_service.get_user_current_active_subscription(user_session.user_id)
    if prev_transaction is not None:
        subcription_transaction_service.update_subscription_transaction(prev_transaction.id, 'INACTIVE')

    quota = quota_service.create_quota(subcription_detail.quota_limit)
    return subcription_transaction_service.create_subscription_transaction(
        user_id=user_session.user_id,
        subscription_id=body.subscription_id,
        quota_id=quota.id,
        apple_receipt_data_jwt=body.apple_receipt_data_jwt
    )
