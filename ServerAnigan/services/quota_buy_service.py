from sqlalchemy.orm import Session
from schemas.quota_buy import QuotaBuy
from datetime import datetime
import uuid

class QuotaBuyService:
    def __init__(self, db: Session):
        self.db = db

    def get_all_quota_buys(self):
        """
        Retrieve all quota buys.
        """
        return self.db.query(QuotaBuy).all()
    
    def get_quota_buys_by_user(self, user_id: str):
        """
        Retrieve all quota buys for a given user.
        """
        return self.db.query(QuotaBuy).filter(QuotaBuy.user_id == user_id).all()

    def get_quota_buy_by_id(self, buy_id: str):
        """
        Retrieve a quota buy by its ID.
        """
        return self.db.query(QuotaBuy).filter(QuotaBuy.id == buy_id).first()

    def create_quota_buy(self, user_id: str, apple_receipt_data_jwt: str, quota_product_id: str, buy_price: float, quota_id: str):
        """
        Create a new quota buy.
        """
        now = datetime.now()
        new_buy = QuotaBuy(
            id=str(uuid.uuid4()),
            user_id=user_id,
            apple_receipt_data_jwt=apple_receipt_data_jwt,
            quota_product_id=quota_product_id,
            quota_id=quota_id,
            buy_price=buy_price,
            created_at=now.isoformat(),
            updated_at=now.isoformat()
        )
        self.db.add(new_buy)
        self.db.commit()
        self.db.refresh(new_buy)
        return new_buy

    def update_quota_buy(self, buy_id: str, apple_receipt_data_jwt: str, buy_price: float):
        """
        Update an existing quota buy.
        """
        buy = self.get_quota_buy_by_id(buy_id)
        if buy:
            buy.apple_receipt_data_jwt = apple_receipt_data_jwt
            buy.buy_price = buy_price
            buy.updated_at = datetime.now().isoformat()
            self.db.commit()
            self.db.refresh(buy)
            return buy
        return None

    def delete_quota_buy(self, buy_id: str):
        """
        Delete a quota buy.
        """
        buy = self.get_quota_buy_by_id(buy_id)
        if buy:
            self.db.delete(buy)
            self.db.commit()
            return True
        return False