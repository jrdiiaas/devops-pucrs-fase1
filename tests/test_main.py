import pytest
from app.main import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_health_check(client):
    response = client.get("/health")
    assert response.status_code == 200
    json_data = response.get_json()
    assert json_data["status"] == "UP"
    assert json_data["service"] == "devops-pucrs-api"


def test_somar(client):
    response = client.get("/calcular/10/25")
    assert response.status_code == 200
    json_data = response.get_json()
    assert json_data["resultado"] == 35


def test_metrics_endpoint(client):
    response = client.get("/metrics")
    assert response.status_code == 200
    json_data = response.get_json()
    assert json_data["service"] == "devops-pucrs-api"
    assert "requests_total" in json_data["metrics"]
