from pydantic import BaseModel

class ConfirmSubscriptionBody(BaseModel):
    apple_receipt_data_jwt: str
    subscription_id: str