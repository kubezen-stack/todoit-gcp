from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from main import app, get_db
from models import Base

import os
SQLALCHEMY_TEST_URL = os.getenv("DATABASE_URL", "sqlite:///./test.db")

engine = create_engine(
    SQLALCHEMY_TEST_URL,
    connect_args={"check_same_thread": False} if "sqlite" in SQLALCHEMY_TEST_URL else {}
)
TestingSessionLocal = sessionmaker(bind=engine)

def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db
Base.metadata.create_all(bind=engine)

client = TestClient(app)


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_create_task():
    response = client.post("/tasks?title=Купити молоко")
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == "Купити молоко"
    assert data["done"] == False


def test_get_tasks():
    client.post("/tasks?title=Перша задача")
    response = client.get("/tasks")
    assert response.status_code == 200
    assert len(response.json()) >= 1


def test_complete_task():
    create = client.post("/tasks?title=Зробити тест")
    task_id = create.json()["id"]

    response = client.patch(f"/tasks/{task_id}/done")
    assert response.status_code == 200
    assert response.json()["done"] == True


def test_complete_nonexistent_task():
    response = client.patch("/tasks/99999/done")
    assert response.status_code == 404