from sqlalchemy.orm import Session
from fastapi import HTTPException

from services.subscription_transaction_service import SubscriptionTransactionService
from services.device_quota_service import DeviceQuotaService
from services.quota_service import QuotaService

def use_quota(device_id: str, user_id: str, db: Session):
    device_quota_service = DeviceQuotaService(db)
    quota_service = QuotaService(db)
    subscription_service = SubscriptionTransactionService(db)

    # check free quota of device
    device_quota = device_quota_service.get_device_quota_by_device_id(device_id)
    quota_to_use = quota_service.get_quota_by_id(device_quota.quota_id)

    use_free_quota = False
    if quota_to_use.amount > 0:
        use_free_quota = True

    # Check subcribe quota
    use_subcribe_quota = False
    if use_free_quota == False:
        quota_to_use = subscription_service.get_user_current_active_subscription(user_id)
        if quota_to_use != None and quota_to_use.amount > 0:
            use_subcribe_quota= True

    # Check bought quota
    use_buy_quota = False
    if use_free_quota == False and use_subcribe_quota == False:
        quotas = quota_service.get_total_product_quota_by_user_id(user_id)
        total = sum(item.amount for item in quotas)
        if total > 0:
            use_subcribe_quota= True
            # Select the quota_to_use
            for quota in quotas:
                if quota.amount > 0:
                    quota_to_use = quota
                    break
    if use_buy_quota == False and use_subcribe_quota == False and use_free_quota == False:
        raise HTTPException(status_code=500, detail="quota not enough")    
    quota_service.update_quota(quota_to_use.id, quota_to_use.amount - 1)
    