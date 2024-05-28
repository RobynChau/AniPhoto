from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from services.quota_service import QuotaService
from services.quota_product_service import QuotaProductService
from services.quota_buy_service import QuotaBuyService

from dependencies import get_payload_optional_token, get_payload
from schemas.user_session import UserSession
from schemas.user import User
from config import get_db
from models.quota import ConfirmQuotaBuyBody

router = APIRouter(
    prefix="/quotas",
    tags=["Quotas"]
)

@router.get("/products")
def get_all_quota_products(db: Session = Depends(get_db)):
    """
    Retrieve all quota products.
    """
    quota_product_service = QuotaProductService(db)
    return quota_product_service.get_all_quota_products()

@router.get("/total")
def get_total_quota(data = Depends(get_payload_optional_token), db: Session = Depends(get_db)):
    """
    Get total user quota.
    """
    user: User = data.get('user')
    user_session: UserSession = data.get('session')
    quota_service = QuotaService(db)
    
    device_quota = quota_service.get_quota_by_device_id(user_session.device_id)

    if user is None:
        return {
            "device_quota": device_quota,
            "subscription_quota": {},
            "product_quota": [],
            "total_quota_amount": device_quota.amount,
        }
    
    subscription_quota = quota_service.get_active_subscription_quota_by_user_id(user.id)
    product_quota = quota_service.get_total_product_quota_by_user_id(user.id)

    
    product_quota_total = sum(item.amount for item in product_quota)
    device_quota_amount = 0 if device_quota is None else device_quota.amount
    subscription_quota_amount = 0 if subscription_quota is None else subscription_quota.amount

    subscription_quota = {} if subscription_quota is None else subscription_quota
    device_quota = {} if device_quota is None else device_quota
    
    return {
        "device_quota": device_quota,
        "subcriptions_quota": subscription_quota,
        "product_quota": product_quota,
        "total_quota_amount": device_quota_amount + subscription_quota_amount + product_quota_total
    }

@router.post("/confirm-buy")
def buy_quota_product(
    body: ConfirmQuotaBuyBody,
    data=Depends(get_payload),
    db: Session = Depends(get_db)
):
    """
    Create a new quota buy.
    """
    quota_service = QuotaService(db)
    quota_buy_service = QuotaBuyService(db)
    quota_product_service = QuotaProductService(db)
    product = quota_product_service.get_quota_product_by_id(body.quota_product_id)
    quota = quota_service.create_quota(product.quota_amount)

    return quota_buy_service.create_quota_buy(
        data.get('user').id,
        body.apple_receipt_data_jwt,
        body.quota_product_id,
        product.price,
        quota.id
    )


