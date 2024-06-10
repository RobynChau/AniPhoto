from fastapi.testclient import TestClient
import uuid

from ..main import app

client = TestClient(app)

def test_get_subscription_products():
    response = client.get(
        "/subscriptions/products", 
        headers={"Device-Id": f'{uuid.uuid4()}'}, 
    )
    assert response.status_code == 200
    assert response.json() == [
            {
                "quota_limit": 50,
                "id": "com.PhatCH.AniPhoto.Pro.Month",
                "level": 2,
                "created_at": "2024-05-23T15:58:36.687202",
                "updated_at": "2024-05-23T15:58:36.687202",
                "name": "Pro",
                "description": "50 AI generations each month",
                "price": 0.99,
                "duration": 30
            },
            {
                "quota_limit": 50,
                "id": "com.PhatCH.AniPhoto.Pro.Year",
                "level": 2,
                "created_at": "2024-05-23T15:58:36.687000",
                "updated_at": "2024-05-23T15:58:36.687000",
                "name": "Pro",
                "description": "50 AI generations each month",
                "price": 9.99,
                "duration": 30
            },
            {
                "quota_limit": 1000000000,
                "id": "com.PhatCH.AniPhoto.ProPlus.Month",
                "level": 1,
                "created_at": "2024-05-23T15:58:36.687000",
                "updated_at": "2024-05-23T15:58:36.687000",
                "name": "Pro+",
                "description": "Unlimited AI generations",
                "price": 11.99,
                "duration": 365
            },
            {
                "quota_limit": 1000000000,
                "id": "com.PhatCH.AniPhoto.ProPlus.Year",
                "level": 1,
                "created_at": "2024-05-23T15:58:36.687000",
                "updated_at": "2024-05-23T15:58:36.687000",
                "name": "Pro+",
                "description": "Unlimited AI generations",
                "price": 119.99,
                "duration": 365
            }
        ]


