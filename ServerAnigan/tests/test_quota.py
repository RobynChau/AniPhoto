

from fastapi.testclient import TestClient
import uuid

from ..main import app

client = TestClient(app)

def test_get_quota_products():
    response = client.get(
        "/quotas/products", 
        headers={"Device-Id": f'{uuid.uuid4()}'}, 
    )
    assert response.status_code == 200
    assert response.json() == [
            {
                "price": 0.99,
                "name": "Credit",
                "quota_amount": 50,
                "updated_at": "2024-05-23T23:51:09.464457",
                "id": "com.PhatCH.AniPhoto.Credit",
                "description": "50 quota for $0.99",
                "created_at": "2024-05-23T23:51:09.464457"
            }
        ]


