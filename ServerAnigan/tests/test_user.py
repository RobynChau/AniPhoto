from fastapi.testclient import TestClient

from ..main import app

client = TestClient(app)

def test_read_user():
    response = client.get("/user", headers={"Device-Id": "abc"})
    assert response.status_code == 401
    assert response.json() == {"detail": "Not authenticated"}

