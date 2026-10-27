from app import app


def test_index():
    response = app.test_client().get("/")
    assert response.status_code == 200
    assert response.get_json()["name"] == "SecureShip Demo API"


def test_healthz():
    response = app.test_client().get("/healthz")
    assert response.status_code == 200
    assert response.get_json() == {"status": "healthy"}


def test_readyz():
    response = app.test_client().get("/readyz")
    assert response.status_code == 200
    assert response.get_json()["status"] == "ready"
