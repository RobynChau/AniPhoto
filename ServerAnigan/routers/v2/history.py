from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ...services.image_service import ImageService
from ...config import get_db
from ...dependencies import get_payload_optional_token
from ...schemas.user_session import UserSession
from ...dependencies import get_payload
from ...services.subscription_transaction_service import SubscriptionTransactionService
from ...services.quota_buy_service import QuotaBuyService
from ...services.subscription_service import SubscriptionService
from ...services.quota_product_service import QuotaProductService


router = APIRouter(
    prefix="/history",
    tags=["History"],
)

@router.get("/bought-subscription")
def get_subcribe_history(data = Depends(get_payload), db: Session = Depends(get_db)):
    """
    Retrieve all subscription quota.
    """
    user_session: UserSession = data.get('session')
    service = SubscriptionTransactionService(db)
    subscription_service = SubscriptionService(db)

    all_subscriptions = subscription_service.get_all_subscriptions()
    all_transactions = service.get_user_subscription_transactions(user_session.user_id)

    subscription_map = {sub.id: sub for sub in all_subscriptions}
    for transaction in all_transactions:
        transaction.subscription = subscription_map.get(transaction.subscription_id)
    return all_transactions

@router.get("/bought-quota")
def get_buy_quota_history(
    data=Depends(get_payload),
    db: Session = Depends(get_db)
):
    """
    Get quota history
    """
    user_session: UserSession = data.get('session')

    quota_buy_service = QuotaBuyService(db)
    quota_products_service = QuotaProductService(db)

    all_products = quota_products_service.get_all_quota_products()
    all_buy = quota_buy_service.get_quota_buys_by_user(user_session.user_id)

    subscription_map = {product.id: product for product in all_products}
    for buy in all_buy:
        buy.quota_product = subscription_map.get(buy.quota_product_id)
    return all_buy

@router.get("/created-image")
def get_created_images(data = Depends(get_payload_optional_token), db: Session = Depends(get_db)):
    """
    Retrieve all images.
    """
    user_session: UserSession = data.get('session')
    image_service = ImageService(db)
    return image_service.get_all_user_image(user_session.user_id , user_session.device_id)

