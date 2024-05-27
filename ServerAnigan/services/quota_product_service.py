from sqlalchemy.orm import Session
from schemas.quota_product import QuotaProduct
from datetime import datetime

class QuotaProductService:
    def __init__(self, db: Session):
        self.db = db

    def get_all_quota_products(self):
        """
        Retrieve all quota products.
        """
        return self.db.query(QuotaProduct).all()

    def get_quota_product_by_id(self, product_id: str):
        """
        Retrieve a quota product by its ID.
        """
        return self.db.query(QuotaProduct).filter(QuotaProduct.id == product_id).first()

    def create_quota_product(self, id:str, name: str, quota_amount: int, description: str, price: float):
        """
        Create a new quota product.
        """
        now = datetime.now()
        new_product = QuotaProduct(
            id=id,
            name=name,
            quota_amount=quota_amount,
            description=description,
            price=price,
            created_at=now.isoformat(),
            updated_at=now.isoformat()
        )
        self.db.add(new_product)
        self.db.commit()
        self.db.refresh(new_product)
        return new_product

    def update_quota_product(self, product_id: str, name: str, quota_amount: int, description: str, price: float):
        """
        Update an existing quota product.
        """
        product = self.get_quota_product_by_id(product_id)
        if product:
            product.name = name
            product.quota_amount = quota_amount
            product.description = description
            product.price = price
            product.updated_at = datetime.now().isoformat()
            self.db.commit()
            self.db.refresh(product)
            return product
        return None

    def delete_quota_product(self, product_id: str):
        """
        Delete a quota product.
        """
        product = self.get_quota_product_by_id(product_id)
        if product:
            self.db.delete(product)
            self.db.commit()
            return True
        return False