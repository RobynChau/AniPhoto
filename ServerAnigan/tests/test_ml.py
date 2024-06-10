from fastapi.testclient import TestClient

from ..main import app

client = TestClient(app)

def test_create_anime():
    response = client.post(
        "/v2/ml/anime", 
        headers={"Device-Id": "abc"}, 
        json={"source_img_path": "https://firebasestorage.googleapis.com/v0/b/ios-entertainment-photography.appspot.com/o/806187AA-DC94-40AD-BF52-8C20538B8A32-200102%2Fraw%2F1717311301.jpg?alt=media&token=64cab261-cf17-4e7d-9313-954b26f0ed87"}
    )
    assert response.status_code == 200

