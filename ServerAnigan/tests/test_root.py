from fastapi.testclient import TestClient

from ..main import app

client = TestClient(app)

def test_read_root():
    response = client.get("/", headers={"X-Token": "coneofsilence"})
    assert response.status_code == 200
    assert response.json() == {"Name": "I am Anigan server"}
