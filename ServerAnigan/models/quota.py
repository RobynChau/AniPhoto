from pydantic import BaseModel

class ConfirmQuotaBuyBody(BaseModel):
    apple_receipt_data_jwt: str
    quota_product_id: str