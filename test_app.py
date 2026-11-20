import pytest
from app import app

@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client

def test_home(client):
    response = client.get("/")
    assert response.status_code == 200
    assert b"TaskFlow" in response.data

def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json["status"] == "healthy"

def test_add_task(client):
    response = client.post(
        "/add",
        data={"title": "Complete DevOps Lab"},
        follow_redirects=True
    )
    assert response.status_code == 200
    assert b"Complete DevOps Lab" in response.data