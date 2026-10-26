import app as application

def test_healthz():
    client = application.app.test_client()
    assert client.get("/healthz").status_code == 200

def test_index():
    client = application.app.test_client()
    body = client.get("/").get_json()
    assert body["message"].startswith("Hello")